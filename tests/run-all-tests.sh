#!/usr/bin/env bash
# Run all tests in the tests directory

set -euo pipefail

# Change to repository root directory
cd "$(git rev-parse --show-toplevel)"

# Check required dependencies
for CMD in yq git prek; do
	if ! command -v "${CMD}" &> /dev/null; then
		echo "Error: Required command '${CMD}' not found" >&2
		exit 1
	fi
done

echo "🧪 Running tests..."

for TEST in tests/*/run.sh; do
	echo "🧪 Running test: ${TEST}"
	"./${TEST}"
done
