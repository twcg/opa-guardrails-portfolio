#!/usr/bin/env bash
set -euo pipefail

# Always run from repo root (so relative paths work)
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "=== Repo root ==="
pwd
echo ""

echo "=== Conftest version ==="
conftest --version
echo ""

echo "=== Policy files ==="
ls -la policy/opa/baseline
echo ""

echo "=== BAD S3 (should FAIL) ==="
conftest test infra/examples/bad_s3/main.tf \
  -p policy/opa/baseline \
  --parser hcl2 \
  --all-namespaces || true

echo ""
echo "=== GOOD S3 (should PASS) ==="
conftest test infra/examples/good_s3/main.tf \
  -p policy/opa/baseline \
  --parser hcl2 \
  --all-namespaces
