# 🔐 pre-commit-wizcli

[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit)](https://github.com/pre-commit/pre-commit)
[![Mega-Linter](https://github.com/ruzickap/pre-commit-wizcli/actions/workflows/mega-linter.yml/badge.svg)](https://github.com/ruzickap/pre-commit-wizcli/actions/workflows/mega-linter.yml)
[![Tests](https://github.com/ruzickap/pre-commit-wizcli/actions/workflows/pre-commit-tests.yml/badge.svg)](https://github.com/ruzickap/pre-commit-wizcli/actions/workflows/pre-commit-tests.yml)
[![CodeQL](https://github.com/ruzickap/pre-commit-wizcli/actions/workflows/codeql.yml/badge.svg)](https://github.com/ruzickap/pre-commit-wizcli/actions/workflows/codeql.yml)
[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/ruzickap/pre-commit-wizcli/badge)](https://securityscorecards.dev/viewer/?uri=github.com/ruzickap/pre-commit-wizcli)
[![OpenSSF Best Practices](https://www.bestpractices.dev/projects/11600/badge)](https://www.bestpractices.dev/projects/11600)

A collection of [pre-commit](https://pre-commit.com/) hooks for
[WizCLI](https://www.wiz.io/lp/wiz-cli) - the Wiz command-line interface for
security scanning.

## 📖 Overview

These hooks integrate WizCLI into your development workflow, allowing you to
scan your code for security issues, misconfigurations, and vulnerabilities
before committing.

## 📋 Prerequisites

* [WizCLI](https://docs.wiz.io/docs/set-up-wiz-cli#get-wiz-cli) (version `1.x`)
* [pre-commit](https://pre-commit.com/) / [prek](https://prek.j178.dev/)

## 🪝 Available Hooks

| Hook ID                   | Description                        |
|---------------------------|------------------------------------|
| `wizcli-scan-dir`         | Scan directory for security issues |
| `wizcli-scan-dir-secrets` | Scan directory for secrets only    |

## 🚀 Usage

Add the following to your `.pre-commit-config.yaml`:

### Scan all issues (recommended)

<!-- x-release-please-start-version -->
```yaml
repos:
  - repo: https://github.com/ruzickap/pre-commit-wizcli
    rev: v1.0.0
    hooks:
      - id: wizcli-scan-dir
```
<!-- x-release-please-end -->

### Secret scanning only

Use this hook for faster scans focused exclusively on detecting secrets.

<!-- x-release-please-start-version -->
```yaml
repos:
  - repo: https://github.com/ruzickap/pre-commit-wizcli
    rev: v1.0.0
    hooks:
      - id: wizcli-scan-dir-secrets
```
<!-- x-release-please-end -->

### Parametrized scanning

Customize the scan by passing additional arguments. The final command will be:

```bash
wizcli scan dir --use-device-code --no-publish --disabled-scanners=Misconfiguration .
```

<!-- x-release-please-start-version -->
```yaml
repos:
  - repo: https://github.com/ruzickap/pre-commit-wizcli
    rev: v1.0.0
    hooks:
      - id: wizcli-scan-dir
        args:
          - --use-device-code
          - --no-publish
          - --disabled-scanners=Misconfiguration
          - .
```
<!-- x-release-please-end -->

## 📝 Hook Details

### wizcli-scan-dir

Scans your repository using locally installed WizCLI. Results are displayed
in the terminal but not published to the Wiz platform.

```bash
wizcli scan dir --use-device-code --no-publish .
```

### wizcli-scan-dir-secrets

Scans your repository for secrets only using locally installed WizCLI. All other
scanners (Vulnerability, SensitiveData, Misconfiguration, SoftwareSupplyChain,
AIModels, SAST, Malware) are disabled. Results are displayed in the terminal but
not published to the Wiz platform.

```bash
wizcli scan dir --use-device-code --no-publish \
  --disabled-scanners=Vulnerability,SensitiveData,Misconfiguration,SoftwareSupplyChain,AIModels,SAST,Malware .
```

## 🔓 Authentication

All hooks use `--use-device-code` for authentication. On first run, you'll be
prompted to authenticate using the device code flow.

For more information on WizCLI authentication, see the
[WizCLI documentation](https://docs.wiz.io/wiz-docs/docs/wizcli-overview).

## 📄 License

[Apache-2.0](LICENSE)
