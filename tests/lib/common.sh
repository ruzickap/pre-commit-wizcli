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
#   $@ - remaining arguments to add to the hook (optional)
# Example:
#   generate_precommit_config "wizcli-scan-dir" "--no-publish" "--policies=Default IaC policy"
generate_precommit_config() {
  local HOOK_ID="$1"
  shift
  local ARGS=("$@")

  yq -n '{"fail_fast": true, "repos": [{"repo": "local", "hooks": load("'"${HOOKS_FILE}"'")}]}' > "${TMPDIR}/.pre-commit-config.yaml"

  for ARG in "${ARGS[@]}"; do
    ARG="${ARG}" yq -i '((.repos[].hooks[] | select(.id == "'"${HOOK_ID}"'")).args |= (.[:-1] + [strenv(ARG) | . style="double"] + .[-1:]))' "${TMPDIR}/.pre-commit-config.yaml"
  done
}

# Configure client credentials in the pre-commit config
# Adds --client-id and --client-secret, removes --use-device-code
configure_client_credentials() {
  yq -i '.repos[].hooks[].args |= map(select(. != "--use-device-code"))' "${TMPDIR}/.pre-commit-config.yaml"
  yq -i '.repos[].hooks[].args |= (.[:-1] + ["--client-id=" + strenv(WIZ_CLIENT_ID), "--client-secret=" + strenv(WIZ_CLIENT_SECRET)] + .[-1:])' "${TMPDIR}/.pre-commit-config.yaml"
}

# Initialize git repo and run pre-commit
# Arguments:
#   $@ - hook IDs to run (optional, runs all hooks if not specified)
# Example:
#   run_precommit_test "wizcli-scan-dir" "wizcli-scan-iac"
run_precommit_test() {
  local HOOKS=("$@")

  cd "${TMPDIR}"
  git init --quiet
  git add .pre-commit-config.yaml

  echo -e "\n🚀 Running pre-commit hooks:\n*******************************************************************************"
  if prek run --verbose --log-file "${LOG_FILE}" "${HOOKS[@]}"; then
    echo -e "*******************************************************************************\n\n✅ All hooks passed successfully"
  else
    local EXIT_CODE=$?
    echo -e "*******************************************************************************\n\n💥 Pre-commit failed with exit code ${EXIT_CODE}"
    printf "📝 Logs / Traces:\n\n"
    cat "${LOG_FILE}"
    exit "${EXIT_CODE}"
  fi
}
