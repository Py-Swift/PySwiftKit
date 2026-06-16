#!/usr/bin/env python3
"""Merge partial .xcframework slices across iOS cibuildwheel output wheels.

cibuildwheel builds one wheel per iOS target (arm64 device, x86_64 simulator,
arm64 simulator, ...).  Each wheel contains a single-architecture .xcframework
slice under .frameworks/.  This script:

  1. Extracts every xcframework slice from every iOS .whl in the wheelhouse.
  2. Groups slices by Python version (cp313, cp314, ...) then by platform
     (ios device vs ios simulator).
  3. lipo-merges multiple slices that share the same platform+variant into a
     single fat dylib (e.g. arm64-simulator + x86_64-simulator).
  4. Calls `xcodebuild -create-xcframework` to build a proper multi-slice
     bundle with a regenerated Info.plist.
  5. Rewrites every iOS wheel, replacing the old single-slice .xcframework
     with the combined one.

Usage
-----
  python tools/merge-ios-xcframeworks.py [wheelhouse_dir]
  wheelhouse_dir defaults to ./wheelhouse

Run this after `cibuildwheel --platform ios` has produced all iOS wheels.
"""
from __future__ import annotations

import argparse
import os
import plistlib
import shutil
import subprocess
import tempfile
import zipfile
from collections import defaultdict
from pathlib import Path


def _python_tag(wheel: Path) -> str:
    """Extract the Python tag (e.g. 'cp313') from a wheel filename."""
    return wheel.stem.split("-")[-3]


def _platform_key(lib_entry: dict) -> str:
    """Grouping key for xcframework slices that should be lipo'd together.

    Slices sharing the same platform+variant (e.g. both ios-simulator) are
    combined into a single fat dylib before being passed to xcodebuild.
    """
    platform = lib_entry["SupportedPlatform"]           # "ios"
    variant  = lib_entry.get("SupportedPlatformVariant", "")  # "simulator" or ""
    return f"{platform}-{variant}" if variant else platform


def merge_ios_xcframeworks(wheelhouse: str) -> None:
    wheels_dir = Path(wheelhouse)
    ios_wheels = sorted(wheels_dir.glob("*-ios_*.whl"))
    if not ios_wheels:
        print(f"[merge] no iOS wheels found in {wheels_dir}")
        return

    print(f"[merge] {len(ios_wheels)} iOS wheel(s):")
    for w in ios_wheels:
        print(f"  {w.name}")

    with tempfile.TemporaryDirectory() as _tmp:
        tmp = Path(_tmp)

        # ── 1. Extract xcframework slices from every wheel ─────────────────
        #
        # xcf_slices[(python_tag, xcf_name)][platform_key]
        #           = [(arch_list, dylib_path), ...]
        xcf_slices: dict[
            tuple[str, str],
            dict[str, list[tuple[list[str], Path]]],
        ] = defaultdict(lambda: defaultdict(list))

        for wheel in ios_wheels:
            pytag       = _python_tag(wheel)
            extract_root = tmp / "wheels" / wheel.stem

            with zipfile.ZipFile(wheel) as zf:
                xcf_names: set[str] = set()
                for name in zf.namelist():
                    parts = Path(name).parts
                    if (
                        len(parts) >= 2
                        and parts[0] == ".frameworks"
                        and parts[1].endswith(".xcframework")
                    ):
                        xcf_names.add(parts[1])

                for xcf_name in xcf_names:
                    prefix   = f".frameworks/{xcf_name}/"
                    xcf_root = extract_root / xcf_name

                    for info in zf.infolist():
                        if not info.filename.startswith(prefix):
                            continue
                        rel = info.filename[len(prefix):]
                        if not rel:
                            continue
                        dest = xcf_root / rel
                        dest.parent.mkdir(parents=True, exist_ok=True)
                        dest.write_bytes(zf.read(info.filename))

                    plist_path = xcf_root / "Info.plist"
                    if not plist_path.exists():
                        print(f"  WARNING: {wheel.name}/{xcf_name}: no Info.plist")
                        continue

                    plist = plistlib.loads(plist_path.read_bytes())
                    for lib in plist["AvailableLibraries"]:
                        identifier = lib["LibraryIdentifier"]   # "ios-x86_64-simulator"
                        binary     = lib["BinaryPath"]           # "libPySwiftKit.dylib"
                        arches     = lib["SupportedArchitectures"]
                        pkey       = _platform_key(lib)

                        dylib = xcf_root / identifier / binary
                        if not dylib.exists():
                            print(f"  WARNING: dylib not found: {dylib}")
                            continue

                        xcf_slices[(pytag, xcf_name)][pkey].append((arches, dylib))
                        print(
                            f"  [{pytag}] {xcf_name}  {pkey:20}  "
                            f"arches={'+'.join(arches):15}  "
                            f"← {wheel.stem.split('-')[-1]}"
                        )

        if not xcf_slices:
            print("[merge] no xcframework slices found — nothing to do.")
            return

        # ── 2. Per-(python_tag, xcf_name): lipo same-platform slices, build ─
        #
        # combined_xcfs[(python_tag, xcf_name)] = Path to combined xcframework
        combined_xcfs: dict[tuple[str, str], Path] = {}

        for (pytag, xcf_name), platform_map in sorted(xcf_slices.items()):
            print(f"\n[merge] building combined {xcf_name}  [{pytag}]")
            per_platform_dylibs: list[Path] = []

            for pkey, slices in sorted(platform_map.items()):
                if len(slices) == 1:
                    _, dylib = slices[0]
                    per_platform_dylibs.append(dylib)
                    print(f"  {pkey:20}  1 slice  → {dylib.parent.name}/{dylib.name}")
                else:
                    # Multiple arches share the same platform+variant: lipo them.
                    lipo_dir = tmp / "lipo" / pytag / xcf_name
                    lipo_dir.mkdir(parents=True, exist_ok=True)
                    fat_out = lipo_dir / f"{pkey}-{slices[0][1].name}"
                    lipo_cmd = (
                        ["lipo", "-create"]
                        + [str(d) for _, d in slices]
                        + ["-output", str(fat_out)]
                    )
                    arch_str = " + ".join("+".join(a) for a, _ in slices)
                    print(f"  {pkey:20}  lipo {arch_str} → {fat_out.name}")
                    subprocess.check_call(lipo_cmd)
                    per_platform_dylibs.append(fat_out)

            xcf_out = tmp / "combined" / pytag / xcf_name
            if xcf_out.exists():
                shutil.rmtree(xcf_out)
            xcf_out.parent.mkdir(parents=True, exist_ok=True)

            xcf_cmd = (
                ["xcodebuild", "-create-xcframework"]
                + [x for lib in per_platform_dylibs for x in ("-library", str(lib))]
                + ["-output", str(xcf_out)]
            )
            subprocess.check_call(xcf_cmd)
            combined_xcfs[(pytag, xcf_name)] = xcf_out
            print(f"  → {xcf_out.relative_to(tmp)}")

        # ── 3. Rewrite each wheel with its combined xcframework ────────────
        for wheel in ios_wheels:
            pytag     = _python_tag(wheel)
            tmp_wheel = wheel.with_suffix(".tmp.whl")

            # Collect the combined xcframeworks for this Python version
            to_inject = {
                xcf_name: path
                for (pt, xcf_name), path in combined_xcfs.items()
                if pt == pytag
            }
            if not to_inject:
                print(f"\n[merge] {wheel.name}: no combined xcframeworks for {pytag}, skipping")
                continue

            print(f"\n[merge] rewriting {wheel.name}")
            with (
                zipfile.ZipFile(wheel, "r") as src,
                zipfile.ZipFile(
                    tmp_wheel, "w",
                    compression=zipfile.ZIP_DEFLATED,
                    compresslevel=6,
                ) as dst,
            ):
                # Copy every entry that is NOT in .frameworks/
                for item in src.infolist():
                    if not item.filename.startswith(".frameworks/"):
                        dst.writestr(item, src.read(item.filename))

                # Add the combined xcframeworks
                xcf_parent = tmp / "combined" / pytag
                for xcf_name, xcf_dir in to_inject.items():
                    for root, _, files in os.walk(xcf_dir):
                        for fname in sorted(files):
                            fp   = Path(root) / fname
                            arcn = ".frameworks/" + str(fp.relative_to(xcf_parent))
                            dst.write(fp, arcn)

            tmp_wheel.replace(wheel)
            print(f"  ✓ {wheel.name}")

    print("\n[merge] done.")


if __name__ == "__main__":
    ap = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    ap.add_argument(
        "wheelhouse",
        nargs="?",
        default="wheelhouse",
        help="directory containing iOS .whl files (default: ./wheelhouse)",
    )
    merge_ios_xcframeworks(ap.parse_args().wheelhouse)
