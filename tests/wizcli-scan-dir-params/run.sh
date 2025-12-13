#!/usr/bin/env bash
# Test script for wizcli-scan-dir pre-commit hook with parametrized scanning
# Creates a temporary git repo with the hooks and runs pre-commit

SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
HOOK_NAME="wizcli-scan-dir"
# shellcheck source=tests/lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

# Generate pre-commit config with only wizcli-scan-dir hook and custom arguments
generate_precommit_config "${HOOK_NAME}" "--no-publish" "--disabled-scanners=Vulnerability,Secret,SensitiveData,SoftwareSupplyChain,AIModels,SAST,Malware" "--by-policy-hits=DISABLED" "--policies=Default IaC policy"

# Copy test files and display pre-commit config
copy_test_files_and_show_config "${SCRIPT_DIR}"

# Configure client credentials
configure_client_credentials

# Run the test with specific hook
run_precommit_test "${HOOK_NAME}"
