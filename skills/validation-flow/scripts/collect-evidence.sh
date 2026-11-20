#!/usr/bin/env bash
# collect-evidence.sh — generic evidence collector for a work unit.
# Part of the validation-flow skill (project-independent).
#
# Usage: scripts/collect-evidence.sh [work-unit-slug]
#
# Creates an evidence directory (odd/artifacts/<slug>/ when the project uses
# ODD, otherwise artifacts/<slug>/) holding:
#   diff.txt     git diff --stat
#   status.txt   git status --short
#   checks.log   raw output of the detected check suite
# Prints the paths it created. It NEVER commits.
#
# Projects with a custom check suite: run it yourself and save the output to
# checks.log — the detector below only covers common defaults.
set -uo pipefail

slug="${1:-$(date -u +%Y%m%d-%H%M%S)}"

if [ -d odd ]; then
  dir="odd/artifacts/$slug"
else
  dir="artifacts/$slug"
fi
mkdir -p "$dir"

git diff --stat > "$dir/diff.txt" 2>&1
git status --short > "$dir/status.txt" 2>&1

checks="$dir/checks.log"
: > "$checks"

found=""
if command -v bun >/dev/null 2>&1 && [ -f package.json ] && grep -q '"test"' package.json 2>/dev/null; then
  found="bun test"; (bun test 2>&1 || true) | tee -a "$checks"
elif command -v npm >/dev/null 2>&1 && [ -f package.json ] && grep -q '"test"' package.json 2>/dev/null; then
  found="npm test"; (npm test 2>&1 || true) | tee -a "$checks"
elif command -v go >/dev/null 2>&1 && [ -f go.mod ]; then
  found="go test ./..."; (go test ./... 2>&1 || true) | tee -a "$checks"
elif command -v pytest >/dev/null 2>&1; then
  found="pytest"; (pytest 2>&1 || true) | tee -a "$checks"
elif command -v cargo >/dev/null 2>&1 && [ -f Cargo.toml ]; then
  found="cargo test"; (cargo test 2>&1 || true) | tee -a "$checks"
fi

if [ -z "$found" ]; then
  echo "no default check suite detected — run the project's suite and save the output to $checks" | tee -a "$checks"
else
  echo "check suite: $found" | tee -a "$checks"
fi

echo "evidence dir: $dir"
ls -1 "$dir"
