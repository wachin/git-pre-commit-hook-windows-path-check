#!/usr/bin/env bash
set -euo pipefail

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

if [ -L "${TARGET_HOOK}" ] || [ -f "${TARGET_HOOK}" ]; then
    rm -f "${TARGET_HOOK}"
fi

cat <<EOF
Removed:
  ${TARGET_HOOK}
EOF
