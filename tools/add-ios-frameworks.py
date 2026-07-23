"""Inject .xcframework bundles built by setup.py into iOS wheels.

Called from cibuildwheel's repair-wheel-command:
    python {project}/tools/add-ios-frameworks.py {dest_dir}

setup.py's iOS branch stages xcframeworks in build/ios_frameworks/.
Each bundle is injected into every .whl in dest_dir as:
    .frameworks/<name>.xcframework/...
"""
from __future__ import annotations

import argparse
import os
import zipfile
from pathlib import Path

HERE = Path(__file__).parent.parent  # PySwiftKit/ root


def add_ios_frameworks_to_wheels(wheels_path: str) -> None:
    frameworks_dir = HERE / "build" / "ios_frameworks"
    if not frameworks_dir.exists():
        raise FileNotFoundError(
            f"iOS frameworks staging dir not found: {frameworks_dir}\n"
            "Ensure the iOS swift build completed before the repair step."
        )

    xcframeworks = sorted(d for d in frameworks_dir.iterdir() if d.suffix == ".xcframework")
    if not xcframeworks:
        raise FileNotFoundError(f"No .xcframework bundles found in {frameworks_dir}")

    wheels_dir = Path(wheels_path)
    for wheel in sorted(wheels_dir.glob("*.whl")):
        print(f"[add-ios-frameworks] injecting into {wheel.name}")
        with zipfile.ZipFile(wheel, "a", compression=zipfile.ZIP_DEFLATED, compresslevel=6) as whl:
            for xcf in xcframeworks:
                print(f"  .frameworks/{xcf.name}")
                for root, _, files in os.walk(xcf):
                    for file in files:
                        file_path = Path(root) / file
                        arc_name = str(Path(".frameworks") / file_path.relative_to(frameworks_dir))
                        whl.write(file_path, arc_name)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Inject .xcframework bundles into iOS wheels as .frameworks/"
    )
    parser.add_argument("wheels_path", help="Directory containing .whl files")
    args = parser.parse_args()
    add_ios_frameworks_to_wheels(args.wheels_path)
