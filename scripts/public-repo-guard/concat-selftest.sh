#!/usr/bin/env bash
# Regression: concatenated / continued secrets must BLOCK. Constructs fixture
# values at runtime so this file never contains a contiguous live-key pattern.
set -euo pipefail

POLICY="$(cd "$(dirname "$0")" && pwd)/content-policy.sh"
command -v python3 >/dev/null 2>&1 || { echo "concat-selftest: python3 required"; exit 2; }
command -v rg >/dev/null 2>&1 || { echo "concat-selftest: rg required"; exit 2; }

REST="$(python3 -c 'import secrets,string; a=string.ascii_letters+string.digits; print("".join(secrets.choice(a) for _ in range(32)))')"
PREFIX="sk"
MID="_live_"
KEY="${PREFIX}${MID}${REST}"
HEAD="${KEY:0:12}"
TAIL="${KEY:12}"

WORKDIR="$(mktemp -d "${TMPDIR:-/tmp}/prg-selftest.XXXXXX")"
trap 'rm -rf "$WORKDIR"' EXIT
fail=0

expect_block() {
  local name="$1" dir="$2"
  if bash "$POLICY" "$dir" >/dev/null 2>&1; then
    echo "FAIL $name: expected BLOCK, got OK"
    fail=1
  else
    echo "PASS $name: BLOCK"
  fi
}

expect_ok() {
  local name="$1" dir="$2"
  if bash "$POLICY" "$dir" >/dev/null 2>&1; then
    echo "PASS $name: OK"
  else
    echo "FAIL $name: expected OK, got BLOCK"
    fail=1
  fi
}

mkdir -p "$WORKDIR/control/src"
printf "export const stripe = '%s'\n" "$KEY" > "$WORKDIR/control/src/pay.ts"
expect_block control-plaintext "$WORKDIR/control"

mkdir -p "$WORKDIR/jsplus/src"
printf "export const stripe = '%s' + '%s'\n" "$HEAD" "$TAIL" > "$WORKDIR/jsplus/src/pay.ts"
expect_block js-plus-concat "$WORKDIR/jsplus"

mkdir -p "$WORKDIR/jsplusnl/src"
printf "export const stripe =\n  '%s' +\n  '%s'\n" "$HEAD" "$TAIL" > "$WORKDIR/jsplusnl/src/pay.ts"
expect_block js-plus-newline "$WORKDIR/jsplusnl"

mkdir -p "$WORKDIR/pyimp/src"
printf 'stripe = ("%s"\n          "%s")\n' "$HEAD" "$TAIL" > "$WORKDIR/pyimp/src/pay.py"
expect_block python-implicit "$WORKDIR/pyimp"

mkdir -p "$WORKDIR/shcont/src"
printf "export STRIPE_SECRET=%s\\\\\n%s\n" "$HEAD" "$TAIL" > "$WORKDIR/shcont/src/deploy.sh"
expect_block shell-backslash "$WORKDIR/shcont"

mkdir -p "$WORKDIR/clean/src"
printf "export const stripe = process.env.STRIPE_SECRET\n" > "$WORKDIR/clean/src/pay.ts"
expect_ok clean-env-ref "$WORKDIR/clean"

if (( fail > 0 )); then
  echo "concat-selftest: $fail case(s) failed"
  exit 1
fi
echo "concat-selftest: all cases passed"
