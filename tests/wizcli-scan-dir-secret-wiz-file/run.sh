#!/usr/bin/env bash
# Test script for wizcli-scan-dir-secrets pre-commit hook
# Creates a temporary git repo with the hooks and runs pre-commit

SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
HOOK_NAME="wizcli-scan-dir-secrets"
# shellcheck source=tests/lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

# Generate pre-commit config with only wizcli-scan-dir-secrets hook and custom arguments
generate_precommit_config "${HOOK_NAME}" "--policies=Default secrets policy" "--by-policy-hits=AUDIT"

# Copy test files and display pre-commit config
copy_test_files_and_show_config "${SCRIPT_DIR}"

# Configure client credentials
configure_client_credentials

# Without the .wiz ignore file the fake key must block the commit
echo "🧪 Expecting ${HOOK_NAME} to block the fake key (no .wiz file)"
rm "${TMPDIR}/.wiz"
if (run_precommit_test "${HOOK_NAME}"); then
  echo "❌ ${HOOK_NAME} did not block the fake private key" >&2
  exit 1
fi
cp "${SCRIPT_DIR}/.wiz" "${TMPDIR}/"

# Run the test with specific hook
run_precommit_test "${HOOK_NAME}"
