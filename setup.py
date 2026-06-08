import json
import os
import re
import shutil
import subprocess
import sysconfig
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

if IS_ANDROID:
    # sysconfig returns e.g. "android-24-x86_64" for Android cross-builds.
    _parts = _PLAT.split("-")
    _arch  = _parts[-1]                          # x86_64 | aarch64 | ...
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
else:
    ANDROID_TRIPLE = None
    SWIFT_SDK      = None
    # macOS: product "PySwiftKit" → "libPySwiftKit.dylib"
    SWIFT_ARTIFACT = "libPySwiftKit.dylib"
    INSTALL_LIB    = "libPySwiftKit.dylib"


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

    def _build_swift(self):
        include_dir = os.environ.get("CPATH") or sysconfig.get_path("include")

        if IS_ANDROID:
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
