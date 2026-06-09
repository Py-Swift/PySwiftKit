#!/bin/zsh
# Downloads the prebuilt PySwiftGenerators-tool universal binary from GitHub releases.
# Installs to two locations so it is found in all usage modes:
#
#   PySwiftKit/bin/         — local path dep (Xcode with sibling clone)
#   ~/.pyswiftkit/bin/      — remote dep (SPM fetches PySwiftKit by GitHub URL)
#
# Package.swift in PySwiftKit and all consumer packages checks both locations
# automatically — no env vars needed after running this once.
#
# Usage:
#   ./build-macro-binary.sh           # installs latest (v0.0.1)
#   ./build-macro-binary.sh v0.0.2    # installs a specific version

set -euo pipefail

VERSION="${1:-v0.0.1}"
REPO="Py-Swift/PySwiftGenerators"
ASSET="PySwiftGenerators.artifactbundle.zip"
URL="https://github.com/${REPO}/releases/download/${VERSION}/${ASSET}"

LOCAL_BIN="${0:A:h}/bin"
TMP=$(mktemp -d)

echo "Installing PySwiftGenerators-tool ${VERSION}"
echo "  Downloading ${URL} ..."
curl -fL --progress-bar "${URL}" -o "${TMP}/${ASSET}"

echo "  Extracting universal binary ..."
unzip -q "${TMP}/${ASSET}" -d "${TMP}/extracted"

BINARY=$(find "${TMP}/extracted" -type f -name "PySwiftGenerators" | head -1)
if [[ -z "${BINARY}" ]]; then
  echo "ERROR: Could not find PySwiftGenerators binary in the artifactbundle." >&2
  exit 1
fi

# Install to both locations
mkdir -p "${LOCAL_BIN}"
cp "${BINARY}" "${LOCAL_BIN}/PySwiftGenerators-tool"
chmod +x "${LOCAL_BIN}/PySwiftGenerators-tool"

rm -rf "${TMP}"

echo ""
file "${LOCAL_BIN}/PySwiftGenerators-tool"
echo ""
echo "Binary installed at: ${LOCAL_BIN}/PySwiftGenerators-tool"
echo "Xcode and 'swift build' will now find it automatically."

