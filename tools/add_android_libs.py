"""Inject .libs/<abi>/ into a built Android wheel.

setup.py stages libPySwiftKit.so into `<project>/.libs/<abi>/` for Android, but
setuptools will not package it: a leading-dot directory is not a discoverable
package and nothing declares it as package data. So it is added here, after the
wheel is built, as a cibuildwheel repair step.

Same job and the same arcname as thorvg-cython's tools/add_android_libs.py —
`.libs/{abi}/lib*.so` at the wheel *root*, so every Android wheel shipping a
native library merges into one site-packages/.libs/<abi>/ that ksproject moves
into the APK's jniLibs. Unlike that one this copies whatever is staged rather
than a hardcoded filename.

Usage (from the project directory):
    python3 tools/add_android_libs.py <wheels_dir>
"""
from __future__ import annotations

import base64
import hashlib
import os
import sys
import tempfile
import zipfile
from pathlib import Path

HERE = Path(__file__).resolve().parent.parent


def _staged_libs() -> list[Path]:
    root = Path(os.environ.get("ANDROID_LIBS_DIR", HERE / ".libs"))
    if not root.is_dir():
        return []
    return sorted(p for p in root.rglob("*") if p.is_file())


def add_libs_to_wheels(wheels_dir: str) -> None:
    staged = _staged_libs()
    if not staged:
        print("  no .libs/ staged — nothing to inject")
        return
    root = Path(os.environ.get("ANDROID_LIBS_DIR", HERE / ".libs"))

    for wheel in sorted(Path(wheels_dir).glob("*.whl")):
        # Rebuild rather than append: appending to a zip and overwriting RECORD
        # leaves duplicate entries and a corrupt archive.
        tmp_fd, tmp_path = tempfile.mkstemp(suffix=".whl", dir=wheels_dir)
        os.close(tmp_fd)

        dist_info_name = None
        record_data = ""
        with zipfile.ZipFile(wheel, "r") as zin, \
             zipfile.ZipFile(tmp_path, "w", zipfile.ZIP_DEFLATED, compresslevel=6) as zout:
            existing = set()
            for item in zin.infolist():
                if item.filename.endswith(".dist-info/RECORD"):
                    dist_info_name = item.filename
                    record_data = zin.read(item).decode("utf-8")
                    continue
                zout.writestr(item, zin.read(item))
                existing.add(item.filename)

            added = []
            for lib in staged:
                arcname = ".libs/" + str(lib.relative_to(root))
                if arcname in existing:
                    continue
                data = lib.read_bytes()
                info = zipfile.ZipInfo(arcname)
                info.compress_type = zipfile.ZIP_DEFLATED
                info.external_attr = 0o755 << 16
                zout.writestr(info, data)
                digest = base64.urlsafe_b64encode(
                    hashlib.sha256(data).digest()
                ).rstrip(b"=").decode("ascii")
                added.append(f"{arcname},sha256={digest},{len(data)}")
                print(f"  Adding {arcname} to {wheel.name}")

            if dist_info_name:
                zout.writestr(dist_info_name, record_data + "".join(a + "\n" for a in added))

        Path(tmp_path).replace(wheel)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <wheels_dir>")
        sys.exit(1)
    add_libs_to_wheels(sys.argv[1])
