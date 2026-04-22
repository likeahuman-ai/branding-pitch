#!/bin/bash
set -e
command -v uv >/dev/null 2>&1 || { echo "ERROR: uv is not installed. Run: curl -LsSf https://astral.sh/uv/install.sh | sh"; exit 1; }
[ -n "$KREA_API_TOKEN" ] || { echo "ERROR: KREA_API_TOKEN is not set. Get one from https://krea.ai/settings/api"; exit 1; }
echo "OK: uv $(uv --version), KREA_API_TOKEN set"
