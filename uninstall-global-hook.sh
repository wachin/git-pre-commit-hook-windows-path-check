#!/usr/bin/env bash
set -euo pipefail

HOOKS_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/git/hooks"
TARGET_HOOK="${HOOKS_DIR}/pre-commit"

if [ -L "${TARGET_HOOK}" ] || [ -f "${TARGET_HOOK}" ]; then
    rm -f "${TARGET_HOOK}"
fi

cat <<EOF
Removed:
  ${TARGET_HOOK}

If you want Git to stop using the global hooks directory entirely, run:
  git config --global --unset core.hooksPath
EOF
