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

Depending on which hook you use, you'll need one of the following:

- **Local hooks**: [WizCLI](https://docs.wiz.io/wiz-docs/docs/wizcli-overview)
  installed and authenticated
- **Container hooks**: [Docker](https://www.docker.com/) installed and running

## Available Hooks

| Hook ID                             | Runtime | Publishes to Wiz | Description                                        |
| ----------------------------------- | ------- | ---------------- | -------------------------------------------------- |
| `wizcli-scan-dir`                   | Local   | No               | Scan directory for security issues (local only)    |
| `wizcli-scan-dir-container`         | Docker  | No               | Scan directory using containerized WizCLI          |
| `wizcli-scan-dir-publish`           | Local   | Yes              | Scan and upload results to Wiz platform            |
| `wizcli-scan-dir-publish-container` | Docker  | Yes              | Scan and upload results using containerized WizCLI |

## Usage

Add the following to your `.pre-commit-config.yaml`:

### Basic Scan (Local WizCLI)

```yaml
repos:
  - repo: https://github.com/ruzickap/pre-commit-wizcli
    rev: v1.0.0
    hooks:
      - id: wizcli-scan-dir
```

### Basic Scan (Container)

```yaml
repos:
  - repo: https://github.com/ruzickap/pre-commit-wizcli
    rev: v1.0.0
    hooks:
      - id: wizcli-scan-dir-container
```

### Scan and Publish Results to Wiz (Local WizCLI)

```yaml
repos:
  - repo: https://github.com/ruzickap/pre-commit-wizcli
    rev: v1.0.0
    hooks:
      - id: wizcli-scan-dir-publish
```

### Scan and Publish Results to Wiz (Container)

```yaml
repos:
  - repo: https://github.com/ruzickap/pre-commit-wizcli
    rev: v1.0.0
    hooks:
      - id: wizcli-scan-dir-publish-container
```

## Hook Details

### wizcli-scan-dir

Scans your repository using locally installed WizCLI. Results are displayed
in the terminal but not published to the Wiz platform.

```bash
wizcli scan dir --use-device-code --no-publish .
```

### wizcli-scan-dir-container

Same as `wizcli-scan-dir` but runs WizCLI from a Docker container. Useful when
you don't want to install WizCLI locally.

### wizcli-scan-dir-publish

Scans your repository and publishes the results to the Wiz platform with
metadata tags including location, user, and hostname.

```bash
wizcli scan dir --use-device-code --tags 'location=Local,triggered-by="${USER}",hostname="$(hostname)"' .
```

### wizcli-scan-dir-publish-container

Same as `wizcli-scan-dir-publish` but runs WizCLI from a Docker container.

## Authentication

All hooks use `--use-device-code` for authentication. On first run, you'll be
prompted to authenticate using the device code flow.

For more information on WizCLI authentication, see the
[WizCLI documentation](https://docs.wiz.io/wiz-docs/docs/wizcli-overview).

## License

[Apache-2.0](LICENSE)
