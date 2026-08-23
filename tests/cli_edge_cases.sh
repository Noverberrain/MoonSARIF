#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

set +e
moon run cmd/main -- validate >/dev/null
status=$?
set -e
test "$status" -eq 2

set +e
moon run cmd/main -- validate missing.sarif >/dev/null
status=$?
set -e
test "$status" -eq 2

set +e
moon run cmd/main -- validate fixtures/github-compatible.sarif --profile invalid >/dev/null
status=$?
set -e
test "$status" -eq 2

set +e
moon run cmd/main -- report examples/sample.sarif --format pdf >/dev/null
status=$?
set -e
test "$status" -eq 2

set +e
moon run cmd/main -- baseline examples/sample.sarif examples/sample.sarif --max-new abc >/dev/null
status=$?
set -e
test "$status" -eq 2

set +e
moon run cmd/main -- validate fixtures/invalid-version.sarif --profile generic >/dev/null
status=$?
set -e
test "$status" -eq 1

moon run cmd/main -- validate fixtures/github-compatible.sarif --profile github >/dev/null
moon run cmd/main -- validate fixtures/github-compatible.sarif --profile strict >/dev/null
moon run cmd/main -- help >/dev/null
moon run cmd/main -- version >/dev/null

echo "CLI edge case tests passed"
