#!/usr/bin/env bash
# Test script for wizcli-scan-dir pre-commit hook
# Creates a temporary git repo with the hooks and runs pre-commit

SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
# shellcheck source=tests/lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

# Generate pre-commit config with only wizcli-scan-dir hook
generate_precommit_config "wizcli-scan-dir"

# Configure client credentials
configure_client_credentials

# Add policies
add_policies "Default IaC policy,Default malware policy,Default SAST policy (Wiz CI/CD scan),Default secrets policy,Default sensitive data policy"

# Run the test
run_precommit_test
