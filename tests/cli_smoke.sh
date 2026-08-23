#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

moon run cmd/main -- github-check examples/sample.sarif >"$TMP_DIR/github-check.json"
moon run cmd/main -- report examples/sample.sarif --format markdown --output "$TMP_DIR/report.md"
moon run cmd/main -- report examples/sample.sarif --format html --output "$TMP_DIR/report.html"
moon run cmd/main -- baseline examples/sample.sarif examples/sample.sarif --fail-on-new >"$TMP_DIR/baseline.json"

test -s "$TMP_DIR/report.md"
test -s "$TMP_DIR/report.html"
grep -q 'MoonSARIF Report' "$TMP_DIR/report.md"
grep -q '<!doctype html>' "$TMP_DIR/report.html"

grep 'MB001' examples/sample.sarif | sed 's/MB001/MB999/g' >/dev/null
sed 's/MB001/MB999/g' examples/sample.sarif >"$TMP_DIR/new.sarif"
set +e
moon run cmd/main -- baseline "$TMP_DIR/new.sarif" examples/sample.sarif --fail-on-new >"$TMP_DIR/new-baseline.json"
status=$?
set -e
test "$status" -eq 3

echo "CLI smoke tests passed"
