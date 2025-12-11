#!/usr/bin/env bash
# Test script for wizcli-scan-dir-secrets pre-commit hook
# Creates a temporary git repo with the hooks and runs pre-commit

SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
# shellcheck source=tests/lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

# Generate pre-commit config with only wizcli-scan-dir-secrets hook
generate_precommit_config "wizcli-scan-dir-secrets"

# Add policies
add_policies "Default secrets policy"

# Configure client credentials
configure_client_credentials

# Run the test
run_precommit_test
