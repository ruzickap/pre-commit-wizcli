# AI Agent Guidelines

## Project Overview

Pre-commit hooks repository for WizCLI security scanning. The
"product" is `.pre-commit-hooks.yaml` which defines hooks consumers
install. All source code is Bash shell scripts. No compiled code,
no package manager, no build step.

## Build / Lint / Test Commands

```bash
# Run all tests (requires WIZ_CLIENT_ID + WIZ_CLIENT_SECRET env vars)
./tests/run-all-tests.sh

# Run a single test
./tests/wizcli-scan-dir/run.sh
./tests/wizcli-scan-dir-params/run.sh
./tests/wizcli-scan-dir-secret/run.sh
./tests/wizcli-scan-dir-secret-wiz-file/run.sh

# Pre-commit hooks (lint + format everything)
pre-commit run --all-files

# Individual linters
shellcheck <file.sh>
shfmt --case-indent --indent 2 --space-redirects <file.sh>
rumdl <file.md>
lychee --config lychee.toml <files>
jsonlint --comments <file.json>
actionlint
```

MegaLinter runs all linters in CI (`.mega-linter.yml`). ShellCheck
excludes SC2317. Markdown uses `rumdl` (not markdownlint). Links use
`lychee` (not markdown-link-check).

## Shell Script Style

### Boilerplate

Every shell script must start with:

```bash
#!/usr/bin/env bash
set -euo pipefail
```

Use `set -euxo pipefail` only in CI workflows.

### Naming Conventions

- **Variables**: UPPER_SNAKE_CASE with braces: `${MY_VARIABLE}`
- **Default values**: `${VAR:-}` or `${VAR:-default}`
- **Functions**: lower_snake_case: `generate_precommit_config()`
- **Local variables**: Declare with `local` keyword inside functions
- **Files/directories**: lowercase with hyphens: `run-all-tests.sh`

### Formatting (enforced by `shfmt`)

- 2-space indentation (no tabs)
- Indent `case` statement bodies
- Space before redirect operators (`> file`, not `>file`)

### Error Handling

- Send errors to stderr: `echo "Error: message" >&2`
- Exit with non-zero: `exit 1`
- Use `trap cleanup EXIT` for temp file cleanup
- ShellCheck directives: `# shellcheck source=...` for sourced files

### Patterns Used in This Repo

```bash
# Variable with default
local HOOK_NAME="${1:-}"

# Sourcing with shellcheck directive
# shellcheck source=tests/lib/common.sh
source "$(dirname "$0")/../lib/common.sh"

# Cleanup trap
trap 'rm -rf "${TMPDIR}"' EXIT
```

## Markdown Style

- Wrap lines at 72 characters
- Proper heading hierarchy (never skip levels)
- Language identifiers on all code fences (`bash`, `json`, `yaml`)
- Shell code blocks in Markdown are extracted and validated by
  ShellCheck + shfmt during CI
- Use `rumdl` for linting (config: `.rumdl.toml`)
- Check links with `lychee` (config: `lychee.toml`)

## YAML Style

- 2-space indentation
- Document start marker `---` on workflow files
- Use `# keep-sorted start` / `# keep-sorted end` comment blocks
  to maintain alphabetical ordering where appropriate
- Heavily comment configuration options

## GitHub Actions Workflows

- **Validate** with `actionlint` after any workflow modification
- **Pin actions** to full SHA commits, add semver in a comment:

  ```yaml
  uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
  ```

- **Permissions**: Always set `permissions: read-all` (minimal)
- **Timeouts**: Always set `timeout-minutes` (5 or 10)
- **Shell default**: `bash -euxo pipefail {0}`

## Security Scanning

CI runs: Checkov, DevSkim, KICS (fail on HIGH), Trivy (HIGH +
CRITICAL, ignore unfixed), Gitleaks, Secretlint, CodeQL.

Test fixtures intentionally contain insecure patterns (fake SSH
keys, public S3 buckets). These are excluded via `.gitleaksignore`,
`.secretlintignore`, and `.wiz` ignore files. Do not remove these
exclusions.

## Version Control

### Commit Messages

Conventional commit format. Subject line rules:

- Format: `<type>: <description>` (e.g., `feat:`, `fix:`, `docs:`,
  `chore:`, `refactor:`, `test:`, `ci:`, `build:`, `revert:`)
- Imperative mood, lowercase, no trailing period
- Maximum 72 characters (body lines too)
- Body: explain **what** and **why**, reference issues with
  `Fixes:`, `Closes:`, `Resolves:`

### Branching

Conventional Branch format: `<type>/<description>`

- `feature/` or `feat/`: new features
- `bugfix/` or `fix/`: bug fixes
- `hotfix/`: urgent fixes
- `chore/`: non-code tasks
- Lowercase, hyphens only, include ticket numbers when applicable

### Pull Requests

- Always create as **draft**
- Title must follow conventional commit format
- Include clear description and link related issues

## Quality Checklist

Before submitting changes:

- [ ] `pre-commit run --all-files` passes
- [ ] Shell scripts pass `shellcheck` and `shfmt` checks
- [ ] Markdown passes `rumdl` and `lychee` checks
- [ ] Workflow files pass `actionlint` validation
- [ ] Actions pinned to full SHA with version comment
- [ ] Tests pass for affected hooks
- [ ] 2-space indentation, no tabs, no trailing whitespace
- [ ] Files end with a newline
