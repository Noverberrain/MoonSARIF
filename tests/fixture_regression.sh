#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

for fixture in \
  minimal-valid.sarif \
  multi-run.sarif \
  multi-location.sarif \
  with-fixes.sarif \
  with-suppressions.sarif \
  github-compatible.sarif
 do
  moon run cmd/main -- validate "fixtures/$fixture" >/dev/null
 done

moon run cmd/main -- github-check fixtures/github-compatible.sarif >/dev/null

for fixture in \
  invalid-version.sarif \
  invalid-region.sarif \
  invalid-message.sarif
 do
  set +e
  moon run cmd/main -- validate "fixtures/$fixture" >/dev/null
  status=$?
  set -e
  test "$status" -eq 1
 done

set +e
moon run cmd/main -- github-check fixtures/missing-rule-id.sarif >/dev/null
status=$?
set -e
test "$status" -eq 1

set +e
moon run cmd/main -- github-check fixtures/invalid-baseline-state.sarif >/dev/null
status=$?
set -e
test "$status" -eq 1

echo "SARIF fixture regression tests passed"
