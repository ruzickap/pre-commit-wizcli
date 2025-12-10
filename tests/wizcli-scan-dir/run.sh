#!/usr/bin/env bash
# Test script for wizcli-scan-dir pre-commit hook
# Creates a temporary git repo with the hooks and runs pre-commit

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

# Verify hooks file exists
if [[ ! -f "${HOOKS_FILE}" ]]; then
  echo "❌ Error: Hooks file not found: ${HOOKS_FILE}" >&2
  exit 1
fi

# Verify required environment variables are set
if [[ -z "${WIZ_CLIENT_ID:-}" ]]; then
  echo "❌ Error: WIZ_CLIENT_ID environment variable is not set" >&2
  exit 1
fi
if [[ -z "${WIZ_CLIENT_SECRET:-}" ]]; then
  echo "❌ Error: WIZ_CLIENT_SECRET environment variable is not set" >&2
  exit 1
fi

# Create temporary directory for test
echo "🧪 Setting up test environment: ${TMPDIR}"

# Generate pre-commit config from hooks file
# Skip container-based hooks on ARM systems (Docker images may not be available)
if [[ "$(uname -m)" =~ ^(arm64|aarch64)$ ]]; then
  echo "⚠️ ARM architecture detected - skipping container-based hooks"
  yq -n '{"fail_fast": true, "repos": [{"repo": "local", "hooks": [load("'"${HOOKS_FILE}"'")[] | select(.id | test("container") | not)]}]}' > "${TMPDIR}/.pre-commit-config.yaml"
else
  yq -n '{"fail_fast": true, "repos": [{"repo": "local", "hooks": load("'"${HOOKS_FILE}"'")}]}' > "${TMPDIR}/.pre-commit-config.yaml"
fi

# Add --policies parameter to the hooks args (insert before the final ".")
yq -i '.repos[].hooks[].args |= (.[:-1] + ["--policies=Default IaC policy,Default malware policy,Default SAST policy (Wiz CI/CD scan),Default secrets policy,Default sensitive data policy"] + .[-1:])' "${TMPDIR}/.pre-commit-config.yaml"

# Configure client credentials: add --client-id + --client-secret and remove --use-device-code
yq -i '.repos[].hooks[].args |= (.[:-1] + ["--client-id='"${WIZ_CLIENT_ID}"'", "--client-secret='"${WIZ_CLIENT_SECRET}"'"] + .[-1:])' "${TMPDIR}/.pre-commit-config.yaml"
yq -i '.repos[].hooks[].args |= map(select(. != "--use-device-code"))' "${TMPDIR}/.pre-commit-config.yaml"

# Initialize git repo and stage config
cd "${TMPDIR}"
git init --quiet
git add .pre-commit-config.yaml

# Run pre-commit and capture exit code
echo -e "🚀 Running pre-commit hooks:\n\n*******************************************************************************"
if prek run --verbose --log-file "${LOG_FILE}"; then
  echo -e "*******************************************************************************\n\n✅ All hooks passed successfully"
else
  EXIT_CODE=$?
  echo -e "*******************************************************************************\n\n💥 Pre-commit failed with exit code ${EXIT_CODE}"
  printf "📝 Logs / Traces:\n\n"
	cat "${LOG_FILE}"
  exit "${EXIT_CODE}"
fi
