#!/bin/zsh
# Updates bin/PySwiftGenerators-tool from a new PySwiftGenerators GitHub release.
#
# The binary is already committed in bin/ — you do NOT need to run this on a
# fresh clone. Only run this when updating to a newer PySwiftGenerators release.
#
# Usage:
#   ./build-macro-binary.sh           # re-downloads current version (v0.0.1)
#   ./build-macro-binary.sh v0.0.2    # updates to a specific version

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

