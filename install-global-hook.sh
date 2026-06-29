#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/git/hooks"
TARGET_HOOK="${HOOKS_DIR}/pre-commit"
SOURCE_HOOK="${SCRIPT_DIR}/pre-commit-windows-paths"

mkdir -p "${HOOKS_DIR}"
chmod +x "${SOURCE_HOOK}"
ln -sf "${SOURCE_HOOK}" "${TARGET_HOOK}"
chmod +x "${TARGET_HOOK}"
git config --global core.hooksPath "${HOOKS_DIR}"

cat <<EOF
Global Git pre-commit hook installed.

Source hook:
  ${SOURCE_HOOK}

Global hooks directory:
  ${HOOKS_DIR}

Active pre-commit hook:
  ${TARGET_HOOK}

Git global configuration updated:
  core.hooksPath=${HOOKS_DIR}

Optional tuning:
  export REPOPATH_SANITIZER_MAX_PATH=260
  export REPOPATH_SANITIZER_MAX_SEGMENT=255
  export REPOPATH_SANITIZER_CHECKOUT_ROOT='C:\\Users\\Juan\\Documents\\Projects'
EOF
