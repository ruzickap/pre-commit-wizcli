#!/usr/bin/env bash
# Run all tests in the tests directory

set -euo pipefail

# Verify authentication: either ~/.wiz/auth.json exists or env vars are set
if [[ ! -f "${HOME}/.wiz/auth.json" ]]; then
  if [[ -z "${WIZ_CLIENT_ID:-}" ]]; then
    echo "❌ Error: WIZ_CLIENT_ID environment variable is not set" >&2
    exit 1
  fi
  if [[ -z "${WIZ_CLIENT_SECRET:-}" ]]; then
    echo "❌ Error: WIZ_CLIENT_SECRET environment variable is not set" >&2
    exit 1
  fi
fi

# Check required dependencies
for CMD in yq git prek wizcli; do
  if ! command -v "${CMD}" &> /dev/null; then
    echo "Error: Required command '${CMD}' not found" >&2
    exit 1
  fi
done

# Change to repository root directory
cd "$(git rev-parse --show-toplevel)"

echo "🧪 Running tests..."

for TEST in tests/*/run.sh; do
  echo "🧪 Running test: ${TEST}"
  "./${TEST}"
done
