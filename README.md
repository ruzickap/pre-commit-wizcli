# pre-commit-wizcli

[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit)](https://github.com/pre-commit/pre-commit)

A collection of [pre-commit](https://pre-commit.com/) hooks for
[WizCLI](https://docs.wiz.io/wiz-docs/docs/wizcli-overview) — the Wiz
command-line interface for security scanning.

## Overview

These hooks integrate WizCLI into your development workflow, allowing you to
scan your code for security issues, misconfigurations, and vulnerabilities
before committing.

## Prerequisites

[WizCLI](https://docs.wiz.io/wiz-docs/docs/wizcli-overview) installed and
authenticated.

## Available Hooks

| Hook ID                   | Publishes to Wiz | Description                         |
|---------------------------|------------------|-------------------------------------|
| `wizcli-scan-dir`         | No               | Scan directory for security issues  |
| `wizcli-scan-dir-publish` | Yes          | Scan and upload results to Wiz platform |

## Usage

Add the following to your `.pre-commit-config.yaml`:

### Basic Scan

```yaml
repos:
  - repo: https://github.com/ruzickap/pre-commit-wizcli
    rev: v1.0.0
    hooks:
      - id: wizcli-scan-dir
```

### Scan and Publish Results to Wiz

```yaml
repos:
  - repo: https://github.com/ruzickap/pre-commit-wizcli
    rev: v1.0.0
    hooks:
      - id: wizcli-scan-dir-publish
```

## Hook Details

### wizcli-scan-dir

Scans your repository using locally installed WizCLI. Results are displayed
in the terminal but not published to the Wiz platform.

```bash
wizcli scan dir --use-device-code --no-publish .
```

### wizcli-scan-dir-publish

Scans your repository and publishes the results to the Wiz platform with
metadata tags including location, user, and hostname.

```bash
wizcli scan dir --use-device-code --tags location=pre-commit .
```

## Authentication

All hooks use `--use-device-code` for authentication. On first run, you'll be
prompted to authenticate using the device code flow.

For more information on WizCLI authentication, see the
[WizCLI documentation](https://docs.wiz.io/wiz-docs/docs/wizcli-overview).

## License

[Apache-2.0](LICENSE)
