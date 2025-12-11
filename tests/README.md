# 🧪 WizCLI Pre-commit Tests

This directory contains test scripts for validating the WizCLI pre-commit hooks.

## 📋 Prerequisites

### 🔐 Environment Variables

The following environment variables must be set before running tests:

| Variable            | Description                          |
|---------------------|--------------------------------------|
| `WIZ_CLIENT_ID`     | Wiz API client ID for authentication |
| `WIZ_CLIENT_SECRET` | Wiz API client secret                |

### 🛠️ Required Tools

- **yq** — YAML processor for generating test configurations
- **prek** — Pre-commit hook runner

## ▶️ Running Tests

### 🚀 Run All Tests

From the repository root:

```bash
./tests/run-all-tests.sh
```

### 🎯 Run Individual Tests

Each test is self-contained in its own directory with a `run.sh` script:

```bash
./tests/wizcli-scan-dir/run.sh
```

## 📁 Test Structure

```text
tests/
├── README.md                   # This file
├── run-all-tests.sh            # Main test runner script
├── lib/
│   └── common.sh               # Shared test utilities
├── wizcli-scan-dir/
│   └── run.sh                  # Basic directory scan test
├── wizcli-scan-dir-params/
│   ├── private-s3-bucket.yaml  # Test fixture (should pass)
│   └── run.sh                  # Parametrized scan test
└── wizcli-scan-dir-secret/
    ├── public-s3-bucket.yaml   # Test fixture
    └── run.sh                  # Secret detection test
```

### ➕ Adding New Tests

1. Create a new directory under `tests/` with a descriptive name
2. Add a `run.sh` script that:
   - Is executable (`chmod +x run.sh`)
   - Uses `set -euo pipefail` for strict error handling
   - Returns exit code 0 on success, non-zero on failure
3. The main `run-all-tests.sh` will automatically discover and run it
