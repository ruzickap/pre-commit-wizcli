#!/usr/bin/env bash
# Common functions and setup for pre-commit hook tests
# Source this file in test scripts to avoid code duplication

# Make sure you set the WIZ_CLIENT_ID and WIZ_CLIENT_SECRET environment variables
# before running test scripts.

set -euo pipefail

# Configuration
HOOKS_FILE="$(git rev-parse --show-toplevel)/.pre-commit-hooks.yaml"
TMPDIR=$(mktemp -d)
LOG_FILE="${TMPDIR}/prek.log"

# Cleanup function - runs on exit (success or failure)
cleanup() {
  if [[ -n "${TMPDIR}" && -d "${TMPDIR}" ]]; then
    rm -rf "${TMPDIR}"
  fi
}
trap cleanup EXIT

echo "🧪 Setting up test environment: ${TMPDIR}"

# Generate pre-commit config for a specific hook
# Arguments:
#   $1 - hook ID to select from .pre-commit-hooks.yaml
generate_precommit_config() {
  local HOOK_ID="$1"
  yq -n '{"fail_fast": true, "repos": [{"repo": "local", "hooks": [load("'"${HOOKS_FILE}"'")[] | select(.id == "'"${HOOK_ID}"'")]}]}' > "${TMPDIR}/.pre-commit-config.yaml"
}

# Configure client credentials in the pre-commit config
# Adds --client-id and --client-secret, removes --use-device-code
configure_client_credentials() {
  yq -i '.repos[].hooks[].args |= map(select(. != "--use-device-code"))' "${TMPDIR}/.pre-commit-config.yaml"
  yq -i '.repos[].hooks[].args |= (.[:-1] + ["--client-id=" + strenv(WIZ_CLIENT_ID), "--client-secret=" + strenv(WIZ_CLIENT_SECRET)] + .[-1:])' "${TMPDIR}/.pre-commit-config.yaml"
}

# Add policies to the hook args
# Arguments:
#   $1 - comma-separated list of policy names
add_policies() {
  local POLICIES="$1"
  yq -i '.repos[].hooks[].args |= (.[:-1] + ["--policies='"${POLICIES}"'"] + .[-1:])' "${TMPDIR}/.pre-commit-config.yaml"
}

# Initialize git repo and run pre-commit
run_precommit_test() {
  cd "${TMPDIR}"
  git init --quiet
  git add .pre-commit-config.yaml

  echo -e "🚀 Running pre-commit hooks:\n\n*******************************************************************************"
  if prek run --verbose --log-file "${LOG_FILE}"; then
    echo -e "*******************************************************************************\n\n✅ All hooks passed successfully"
  else
    local EXIT_CODE=$?
    echo -e "*******************************************************************************\n\n💥 Pre-commit failed with exit code ${EXIT_CODE}"
    printf "📝 Logs / Traces:\n\n"
    cat "${LOG_FILE}"
    exit "${EXIT_CODE}"
  fi
}
