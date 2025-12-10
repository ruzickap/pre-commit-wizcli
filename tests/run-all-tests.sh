#!/usr/bin/env bash
# Run all tests in the tests directory

set -euo pipefail

# Check required dependencies
for CMD in yq git prek; do
	if ! command -v "${CMD}" &>/dev/null; then
		echo "Error: Required command '${CMD}' not found" >&2
		exit 1
	fi
done
