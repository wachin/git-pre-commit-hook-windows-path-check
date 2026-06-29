#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_HOOK="${SCRIPT_DIR}/pre-commit-windows-paths"
TARGET_REPO="${1:-}"

if [ -z "${TARGET_REPO}" ]; then
    echo "Usage: $0 /path/to/target-repository" >&2
    exit 1
fi

if [ ! -d "${TARGET_REPO}/.git" ]; then
    echo "Error: ${TARGET_REPO} does not look like a Git repository." >&2
    exit 1
fi

TARGET_HOOK="${TARGET_REPO}/.git/hooks/pre-commit"

chmod +x "${SOURCE_HOOK}"
mkdir -p "${TARGET_REPO}/.git/hooks"
ln -sf "${SOURCE_HOOK}" "${TARGET_HOOK}"
chmod +x "${TARGET_HOOK}"

cat <<EOF
Repository pre-commit hook installed.

Target repository:
  ${TARGET_REPO}

Source hook:
  ${SOURCE_HOOK}

Active pre-commit hook:
  ${TARGET_HOOK}

Optional tuning:
  export REPOPATH_SANITIZER_MAX_PATH=260
  export REPOPATH_SANITIZER_MAX_SEGMENT=255
  export REPOPATH_SANITIZER_CHECKOUT_ROOT='C:\\Users\\YourUser\\Documents\\Projects'
EOF
