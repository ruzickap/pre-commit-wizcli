#!/usr/bin/env bash
# Common functions and setup for pre-commit hook tests
# Source this file in test scripts to avoid code duplication

# Optionally set WIZ_CLIENT_ID and WIZ_CLIENT_SECRET environment variables
# for non-interactive authentication. Otherwise, --use-device-code is used.

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

# Copy test files and display pre-commit config
# Arguments:
#   $1 - source directory containing test files (typically SCRIPT_DIR)
# Copies all files (except run.sh) from source directory to TMPDIR
# and displays the generated pre-commit config
copy_test_files_and_show_config() {
  local SOURCE_DIR="$1"

  # Copy all files except run.sh from source directory to TMPDIR
  find "${SOURCE_DIR}" -maxdepth 1 -type f ! -name "run.sh" -exec cp {} "${TMPDIR}/" \;

  echo "🔍 Pre-commit config:"
  cat "${TMPDIR}/.pre-commit-config.yaml"
}

# If WIZ_CLIENT_ID and WIZ_CLIENT_SECRET are set, remove --use-device-code so
# wizcli reads them from the environment (not args: prek logs the command).
# Otherwise, keep --use-device-code for interactive auth.
configure_client_credentials() {
  if [[ -n "${WIZ_CLIENT_ID:-}" && -n "${WIZ_CLIENT_SECRET:-}" ]]; then
    yq -i '.repos[].hooks[].args |= map(select(. != "--use-device-code"))' "${TMPDIR}/.pre-commit-config.yaml"
  fi
}

# Initialize git repo and run pre-commit
# Arguments:
#   $@ - hook IDs to run (optional, runs all hooks if not specified)
# Example:
#   run_precommit_test "wizcli-scan-dir" "wizcli-scan-dir-secrets"
run_precommit_test() {
  local HOOKS=("$@")

  cd "${TMPDIR}"
  git init --quiet
  git add .pre-commit-config.yaml

  echo -e "\n🚀 Running pre-commit hooks:\n*******************************************************************************"
  # An audit-only policy hit (WARN_BY_POLICY) exits 0, so fail on any policy hit
  # PRECOMMIT_OUTPUT stays set for extra checks in the test scripts
  if PRECOMMIT_OUTPUT=$(prek run --verbose --log-file "${LOG_FILE}" "${HOOKS[@]}" | tee /dev/stderr) && ! grep -q -E '(WARN|FAIL(ED)?)_BY_POLICY' <<< "${PRECOMMIT_OUTPUT}"; then
    echo -e "*******************************************************************************\n\n✅ All hooks passed successfully"
  else
    local EXIT_CODE=$?
    echo -e "*******************************************************************************\n\n💥 Pre-commit failed or reported a policy hit (exit code ${EXIT_CODE})"
    printf "📝 Logs / Traces:\n\n"
    cat "${LOG_FILE}"
    exit "${EXIT_CODE}"
  fi
}
