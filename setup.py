import json
import os
import re
import shutil
import subprocess
import sysconfig
import tempfile
from pathlib import Path

from setuptools import setup
from setuptools.dist import Distribution
from setuptools.command.build_py import build_py

HERE = Path(__file__).parent.resolve()
PKG_DIR = HERE / "pyswiftkit"

SWIFT_BUILD_CONFIG = os.environ.get("SWIFT_BUILD_CONFIG", "release")

# Detect target platform from sysconfig (works correctly inside cibuildwheel).
_PLAT = sysconfig.get_platform()
IS_ANDROID = "android" in _PLAT
IS_IOS     = "ios" in _PLAT and not IS_ANDROID

if IS_ANDROID:
    # sysconfig returns e.g. "android-28-arm64_v8a" for Android cross-builds —
    # the last segment is the Android ABI name, not the LLVM arch Swift target
    # triples use, so arm64_v8a has to be mapped to aarch64 or the triple comes
    # out as the nonexistent arm64_v8a-unknown-linux-androidNN. x86_64 is
    # spelled the same either way, which is why this only shows up on ARM.
    # 64-bit only — matches build_aar.py's ABIS table: armeabi-v7a is
    # deliberately unsupported everywhere in this project (not worth the
    # build time, and Play has required 64-bit support since 2019).
    _ABI_TO_ARCH = {
        "arm64_v8a": "aarch64",
        "arm64-v8a": "aarch64",
        "x86_64": "x86_64",
    }
    _parts = _PLAT.split("-")
    _arch  = _ABI_TO_ARCH.get(_parts[-1], _parts[-1])
    _api   = int(_parts[1]) if len(_parts) >= 3 else 24

    # The Swift Android SDK only ships triples for API 28+.
    # Clamp the API level to the minimum supported by the installed SDK.
    _SDK_MIN_API = 28
    _api = max(_api, _SDK_MIN_API)

    ANDROID_TRIPLE = os.environ.get(
        "SWIFT_TRIPLE", f"{_arch}-unknown-linux-android{_api}"
    )
    SWIFT_SDK = os.environ.get(
        "SWIFT_SDK", "swift-6.3-DEVELOPMENT-SNAPSHOT-2026-03-05-a_android"
    )
    # Swift prepends "lib" to the product name on every platform:
    #   product "PySwiftKit" → "libPySwiftKit.so"
    SWIFT_ARTIFACT = "libPySwiftKit.so"
    INSTALL_LIB    = "libPySwiftKit.so"

    IOS_TRIPLE = None

elif IS_IOS:
    # sysconfig returns e.g. "ios-17.0-arm64-iphoneos" or "ios-17.0-arm64-iphonesimulator"
    _parts       = _PLAT.split("-")
    _ios_version = _parts[1] if len(_parts) > 1 else "17.0"
    _ios_arch    = _parts[2] if len(_parts) > 2 else "arm64"
    _ios_env     = _parts[3] if len(_parts) > 3 else "iphoneos"

    _sim_suffix = "-simulator" if "simulator" in _ios_env else ""
    IOS_TRIPLE = os.environ.get(
        "SWIFT_TRIPLE", f"{_ios_arch}-apple-ios{_ios_version}{_sim_suffix}"
    )

    ANDROID_TRIPLE = None
    SWIFT_SDK      = None
    # iOS: same dylib format as macOS
    SWIFT_ARTIFACT = "libPySwiftKit.dylib"
    INSTALL_LIB    = "libPySwiftKit.dylib"

else:
    ANDROID_TRIPLE = None
    SWIFT_SDK      = None
    IOS_TRIPLE     = None
    # macOS: product "PySwiftKit" → "libPySwiftKit.dylib"
    SWIFT_ARTIFACT = "libPySwiftKit.dylib"
    INSTALL_LIB    = "libPySwiftKit.dylib"


def _ensure_ios_swift_sdk(triple: str) -> None:
    """Install a minimal Swift SDK bundle so `swift build --swift-sdk <triple>` resolves correctly.

    Xcode 15/16 handles Apple-platform cross-compilation triples natively.
    Xcode 26 broke that built-in lookup (falls back to macOS sysroot), causing
    'unable to load standard library for target ...' errors.  Installing a thin
    bundle that only provides sdkRootPath fixes the regression without affecting
    the host-tool (macOS) build path.
    """
    result = subprocess.run(["swift", "sdk", "list"], capture_output=True, text=True)
    if triple in (result.stdout or ""):
        return  # already registered

    sdk_xcrun = "iphonesimulator" if "simulator" in triple else "iphoneos"
    try:
        sdk_path = subprocess.check_output(
            ["xcrun", "--sdk", sdk_xcrun, "--show-sdk-path"], text=True
        ).strip()
    except subprocess.CalledProcessError:
        print(f"[pyswiftkit] warning: could not locate {sdk_xcrun} SDK via xcrun; skipping SDK bundle install")
        return

    with tempfile.TemporaryDirectory() as tmp:
        bundle = Path(tmp) / f"{triple}.artifactbundle"
        (bundle / triple).mkdir(parents=True)
        (bundle / "info.json").write_text(json.dumps({
            "schemaVersion": "1.0",
            "artifacts": {
                triple: {
                    "version": "1.0.0",
                    "type": "swiftSDK",
                    "variants": [{
                        "path": triple,
                        "supportedTriples": ["x86_64-apple-macosx", "arm64-apple-macosx"],
                    }],
                },
            },
        }, indent=4))
        (bundle / triple / "swift-sdk.json").write_text(json.dumps({
            "schemaVersion": "4.0",
            "targetTriples": {
                triple: {"sdkRootPath": sdk_path},
            },
        }, indent=4))
        print(f"[pyswiftkit] installing Swift SDK bundle for {triple} → {sdk_path}")
        subprocess.check_call(["swift", "sdk", "install", str(bundle)])


def _patch_ios_sdk_python_linker(triple: str, link_args: list) -> None:
    """Inject Python linker flags into the iOS Swift SDK bundle's toolset.

    toolset.linkerDriver.extraCLIOptions apply only to TARGET (iOS) link steps,
    not HOST (macOS) macro-plugin links.  This avoids the error
    'building for macOS, but linking in dylib built for iOS-simulator'
    that occurs when the same flags are passed via -Xlinker globally.
    """
    sdk_base = Path.home() / "Library/org.swift.swiftpm/swift-sdks"
    for bundle in sorted(sdk_base.glob("*.artifactbundle")):
        for variant in sorted(bundle.iterdir()):
            if not variant.is_dir():
                continue
            sdk_json_path = variant / "swift-sdk.json"
            if not sdk_json_path.exists():
                continue
            try:
                sdk_data = json.loads(sdk_json_path.read_text())
            except (json.JSONDecodeError, OSError):
                continue
            if triple not in sdk_data.get("targetTriples", {}):
                continue
            # Swift module final-link uses swiftc (not clang), so
            # linkerDriver.extraCLIOptions doesn't reach it.  Use
            # swiftCompiler.extraCLIOptions with -Xlinker forwarding instead.
            toolset_name = "swift-toolset-python.json"
            xlinker_args = [x for a in link_args for x in ("-Xlinker", a)]
            (variant / toolset_name).write_text(json.dumps(
                {"schemaVersion": "1.0", "swiftCompiler": {"extraCLIOptions": xlinker_args}},
                indent=4,
            ))
            triple_info = sdk_data["targetTriples"][triple]
            if toolset_name not in triple_info.get("toolsetPaths", []):
                triple_info["toolsetPaths"] = [toolset_name]
                sdk_json_path.write_text(json.dumps(sdk_data, indent=4))
            return
    print(f"[pyswiftkit] warning: Swift SDK bundle for {triple} not found; Python link flags not applied")


def _patch_android_sdk_toolset(sdk_bundle: Path, arch: str, resource_dir: Path) -> None:
    """Create (or update) a per-arch toolset JSON inside the SDK bundle that
    injects the correct -resource-dir for this architecture, then update
    swift-sdk.json so all triples for this arch reference it.

    SwiftPM strips the API suffix when looking up the resource-dir
    (android28 → android) and falls back to the first registered arch
    (armv7) when the bare triple isn't found.  Embedding the override in
    the toolset fixes this for target builds only — host-tool builds
    (macro plugins) continue to use the macOS SDK toolchain unmodified.
    """
    toolset_name = f"swift-toolset-{arch}.json"
    toolset_path = sdk_bundle / toolset_name

    # Start from the base toolset so we inherit -fPIC, -fuse-ld=lld, etc.
    base = sdk_bundle / "swift-toolset.json"
    toolset = json.loads(base.read_text()) if base.exists() else {"schemaVersion": "1.0"}

    # Inject -resource-dir (remove any previous value first).
    swift_opts = list(toolset.setdefault("swiftCompiler", {}).get("extraCLIOptions", []))
    cleaned: list = []
    skip = False
    for opt in swift_opts:
        if skip:
            skip = False
            continue
        if opt == "-resource-dir":
            skip = True
            continue
        cleaned.append(opt)
    cleaned += ["-resource-dir", str(resource_dir)]
    toolset["swiftCompiler"]["extraCLIOptions"] = cleaned
    toolset_path.write_text(json.dumps(toolset, indent=2))

    # Point all triples for this arch to the new per-arch toolset.
    sdk_json_path = sdk_bundle / "swift-sdk.json"
    sdk_data = json.loads(sdk_json_path.read_text())
    changed = False
    for triple, info in sdk_data.get("targetTriples", {}).items():
        if triple.startswith(arch + "-"):
            existing = info.get("toolsetPaths", [])
            if toolset_name not in existing:
                info["toolsetPaths"] = [toolset_name] + [p for p in existing if p != "swift-toolset.json"]
                changed = True
    if changed:
        sdk_json_path.write_text(json.dumps(sdk_data, indent=2))


class BinaryDistribution(Distribution):
    """Forces a platform-specific wheel even without a C extension."""
    def has_ext_modules(self):
        return True


class BuildSwift(build_py):
    def run(self):
        self._build_swift()
        super().run()
        if IS_IOS:
            # build_py may carry a stale dylib in the build-lib tree from a
            # previous macOS or Android build.  Remove it so bdist_wheel does
            # not bundle a wrong-platform binary alongside the xcframework.
            stale = Path(self.build_lib) / "pyswiftkit" / INSTALL_LIB
            if stale.exists():
                stale.unlink()

    def _build_swift(self):
        include_dir = os.environ.get("CPATH") or sysconfig.get_path("include")

        if IS_IOS:

            # iOS linker does not support -undefined dynamic_lookup — link
            # explicitly against the libpython provided by cibuildwheel.
            libdir    = sysconfig.get_config_var("LIBDIR") or ""
            ldlibrary = sysconfig.get_config_var("LDLIBRARY") or ""

            env = {
                **os.environ,
                "PIP_MODE": "1",
                "CPATH": include_dir,
            }

            cmd = [
                "swift", "build",
                "-c", SWIFT_BUILD_CONFIG,
                "--product", "PySwiftKit",
                "--swift-sdk", IOS_TRIPLE,
                "--disable-sandbox",
                "-Xcc", f"-isystem{include_dir}",
            ]

            # Compute Python link args to inject via the SDK bundle toolset.
            # We do NOT use -Xlinker here — those flags are applied globally to
            # every link step including the HOST (macOS) macro-plugin link, which
            # would fail with 'building for macOS, but linking in dylib built for
            # iOS-simulator'.  The SDK bundle toolset's linkerDriver.extraCLIOptions
            # applies only to TARGET (iOS) link steps.
            #
            # sysconfig's LIBDIR is baked to the CI builder path, so derive the
            # framework parent from include_dir (cibuildwheel sets this to the real
            # local path):  <xcframework-slice>/include/python3.x  →  <xcframework-slice>/
            _py_link_args: list = []
            if ldlibrary:
                if ".framework/" in ldlibrary:
                    fw_name = ldlibrary.split(".framework/")[0].split("/")[-1]
                    _inc_first = include_dir.split(":")[0] if include_dir else ""
                    _fw_dir = str(Path(_inc_first).parent.parent) if _inc_first else ""
                    if _fw_dir and (Path(_fw_dir) / f"{fw_name}.framework").exists():
                        _py_link_args = ["-F", _fw_dir, "-framework", fw_name]
                    elif libdir:
                        _py_link_args = [f"-F{libdir}", "-framework", fw_name]
                elif libdir:
                    pylib_name = ldlibrary.removeprefix("lib").removesuffix(".dylib")
                    _py_link_args = [f"-L{libdir}", f"-l{pylib_name}"]

            # SwiftPM normalises the triple in the build dir by stripping the OS
            # version (e.g. ios13.0 → ios), so the output lives at:
            #   .build/x86_64-apple-ios-simulator/  not  .build/x86_64-apple-ios13.0-simulator/
            _ios_build_triple = re.sub(r"ios\d+[\.\d]*", "ios", IOS_TRIPLE)
            src = HERE / ".build" / _ios_build_triple / SWIFT_BUILD_CONFIG / SWIFT_ARTIFACT

            # Ensure the Swift SDK bundle is registered so --swift-sdk resolves
            # the iOS sysroot correctly (needed on Xcode 26+ which broke built-in
            # Apple-platform triple lookup), then patch its toolset with the
            # Python linker flags so only the TARGET link gets them.
            _ensure_ios_swift_sdk(IOS_TRIPLE)
            if _py_link_args:
                _patch_ios_sdk_python_linker(IOS_TRIPLE, _py_link_args)

            print(f"[pyswiftkit] swift build  iOS triple={IOS_TRIPLE}  CPATH={include_dir}")
            subprocess.check_call(cmd, cwd=HERE, env=env)

            # Package the dylib as an xcframework so iOS app builders
            # (Briefcase, Kivy, etc.) can embed it in Frameworks/ at app-build
            # time.  The repair-wheel-command injects this staging dir as
            # .frameworks/ into the wheel.
            xcf_staging = HERE / "build" / "ios_frameworks"
            xcf_staging.mkdir(parents=True, exist_ok=True)
            xcf_out = xcf_staging / "libPySwiftKit.xcframework"
            if xcf_out.exists():
                shutil.rmtree(xcf_out)

            print(f"[pyswiftkit] xcodebuild -create-xcframework → {xcf_out.relative_to(HERE)}")
            subprocess.check_call([
                "xcodebuild", "-create-xcframework",
                "-library", str(src),
                "-output", str(xcf_out),
            ])
            # iOS wheels ship the library exclusively via .frameworks/; remove
            # any stale dylib left by a previous macOS build so build_py does
            # not bundle a wrong-platform binary alongside the xcframework.
            _stale = PKG_DIR / INSTALL_LIB
            if _stale.exists():
                _stale.unlink()
            return

        elif IS_ANDROID:
            # Cross-compilation: pass headers only to the target C compiler via
            # -Xcc -isystem rather than CPATH (which would also affect the macOS
            # host compiler and corrupt the macOS SDK module cache).
            #
            # cibuildwheel exports CFLAGS / CXXFLAGS / CC / CXX etc. for the Android
            # NDK clang; those must NOT bleed into the swift build command because
            # Swift Package Manager with --swift-sdk already configures the correct
            # cross-compiling clang — mixing in NDK-direct CFLAGS causes wrong
            # include paths and host/target mismatches.
            #
            # The Android Swift SDK was built with a specific Swift development
            # snapshot.  If SWIFT_SDK_TOOLCHAIN_BIN is set (or we find the matching
            # toolchain automatically), prepend it to PATH so that `swift build`
            # uses the right compiler instead of Xcode's bundled Swift.
            toolchain_bin = os.environ.get("SWIFT_SDK_TOOLCHAIN_BIN", "")
            if not toolchain_bin:
                # Auto-detect: look for a toolchain whose name contains the SDK name
                # (e.g. "swift-6.3-DEVELOPMENT-SNAPSHOT-2026-01-06-a").
                sdk_base = SWIFT_SDK.replace("_android", "")  # strip platform suffix
                tc_search = Path.home() / "Library/Developer/Toolchains"
                for tc in sorted(tc_search.glob("*.xctoolchain")):
                    if sdk_base in tc.name:
                        candidate = tc / "usr" / "bin"
                        if (candidate / "swift").exists():
                            toolchain_bin = str(candidate)
                            break

            base_path = os.environ.get("PATH", "")
            path_with_toolchain = f"{toolchain_bin}:{base_path}" if toolchain_bin else base_path

            # SwiftPM's triple resolution strips the API suffix (android28 →
            # android) for internal resource-dir lookup, then
            # fails to find an exact match in swift-sdk.json and falls back to the
            # wrong arch.  Inject the correct -resource-dir via a per-arch toolset
            # in the SDK bundle — toolset options apply to target builds only, so
            # host tool builds (macro plugins) are unaffected.
            swift_sdks_base = Path.home() / "Library/org.swift.swiftpm/swift-sdks"
            swift_bundle = (
                swift_sdks_base / f"{SWIFT_SDK}.artifactbundle" / "swift-android"
            )
            swift_resource_dir = (
                swift_bundle / "swift-resources" / "usr" / "lib" / f"swift-{_arch}"
            )
            if swift_resource_dir.exists():
                _patch_android_sdk_toolset(swift_bundle, _arch, swift_resource_dir)

            env = {
                **os.environ,
                "PIP_MODE": "1",
                "PATH": path_with_toolchain,
                "CPATH": "",          # clear any host CPATH
                "CFLAGS": "",         # strip cibuildwheel's Android NDK CFLAGS
                "CXXFLAGS": "",
                "LDFLAGS": "",
                "CC": "",
                "CXX": "",
                "SWIFT_ANDROID_HOME": os.environ.get(
                    "ANDROID_HOME",
                    str(Path.home() / "Library/Android/sdk"),
                ),
            }

            cmd = [
                "swift", "build",
                "-c", SWIFT_BUILD_CONFIG,
                "--product", "PySwiftKit",
                # Pass the full triple as the SDK identifier — SPM resolves both
                # the SDK bundle and the target triple from a single argument, which
                # ensures the per-arch toolset (with the correct -resource-dir) is
                # selected automatically.  Using --swift-sdk <name> + --triple
                # <triple> was selecting the wrong arch toolset.
                "--swift-sdk", ANDROID_TRIPLE,
                "--disable-sandbox",
                # The 2026-03-05-a dev snapshot crashes (SIGSEGV) in
                # PerformanceSILLinker during cross-module optimization (-O).
                # Force -Onone to match the debug build that succeeds.
                "-Xswiftc", "-Onone",
                # -isystem marks Python headers as system includes, so the NDK
                # sysroot headers (stdint.h, etc.) take priority for angle-bracket
                # includes instead of being shadowed by Python's cross-compiled headers.
                "-Xcc", f"-isystem{include_dir}",
            ]
            # SwiftPM cross-compilation output: .build/<triple>/<config>/
            src = HERE / ".build" / ANDROID_TRIPLE / SWIFT_BUILD_CONFIG / SWIFT_ARTIFACT
            print(f"[pyswiftkit] swift build  ANDROID triple={ANDROID_TRIPLE}  sdk={SWIFT_SDK}  toolchain={toolchain_bin or '(system)'}")
        else:
            # macOS: CPATH propagates to all compilation units automatically.
            env = {
                **os.environ,
                "PIP_MODE": "1",
                "CPATH": include_dir,
            }

            # Determine target arch(es). cibuildwheel sets ARCHFLAGS="-arch <arch>"
            # (or two -arch entries for universal2). When invoked outside
            # cibuildwheel, fall back to the platform tag from sysconfig.
            archflags = os.environ.get("ARCHFLAGS", "")
            target_arches = re.findall(r"-arch\s+(\S+)", archflags)
            if not target_arches:
                plat_arch = _PLAT.split("-")[-1]
                if plat_arch == "universal2":
                    target_arches = ["arm64", "x86_64"]
                elif plat_arch in ("arm64", "x86_64"):
                    target_arches = [plat_arch]
                else:
                    target_arches = []  # let swift build pick host arch

            PKG_DIR.mkdir(exist_ok=True)
            dst = PKG_DIR / INSTALL_LIB

            if len(target_arches) <= 1:
                cmd = [
                    "swift", "build",
                    "-c", SWIFT_BUILD_CONFIG,
                    "--product", "PySwiftKit",
                ]
                if target_arches:
                    cmd += ["--arch", target_arches[0]]
                    src = HERE / ".build" / f"{target_arches[0]}-apple-macosx" / SWIFT_BUILD_CONFIG / SWIFT_ARTIFACT
                else:
                    src = HERE / ".build" / SWIFT_BUILD_CONFIG / SWIFT_ARTIFACT
                print(f"[pyswiftkit] swift build  CPATH={include_dir}  arch={target_arches or 'host'}")
                subprocess.check_call(cmd, cwd=HERE, env=env)
                shutil.copy2(src, dst)
                print(f"[pyswiftkit] copied {src.name} → pyswiftkit/{INSTALL_LIB}")
            else:
                # universal2: build each slice, then lipo together.
                slices = []
                for arch in target_arches:
                    cmd = [
                        "swift", "build",
                        "-c", SWIFT_BUILD_CONFIG,
                        "--product", "PySwiftKit",
                        "--arch", arch,
                    ]
                    print(f"[pyswiftkit] swift build  CPATH={include_dir}  arch={arch}")
                    subprocess.check_call(cmd, cwd=HERE, env=env)
                    slices.append(
                        HERE / ".build" / f"{arch}-apple-macosx" / SWIFT_BUILD_CONFIG / SWIFT_ARTIFACT
                    )
                subprocess.check_call(
                    ["lipo", "-create", *[str(s) for s in slices], "-output", str(dst)]
                )
                print(f"[pyswiftkit] lipo {[s.name for s in slices]} → pyswiftkit/{INSTALL_LIB}")
            return

        subprocess.check_call(cmd, cwd=HERE, env=env)

        dst = PKG_DIR / INSTALL_LIB
        PKG_DIR.mkdir(exist_ok=True)
        shutil.copy2(src, dst)
        print(f"[pyswiftkit] copied {src.name} → pyswiftkit/{INSTALL_LIB}")


setup(
    distclass=BinaryDistribution,
    cmdclass={"build_py": BuildSwift},
)
