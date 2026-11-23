#!/usr/bin/env bash
# Regression tests for content-policy.sh. Keys are assembled at runtime so this
# file does not itself contain a BLOCK-shaped secret.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SCRIPT="$ROOT/scripts/public-repo-guard/content-policy.sh"
command -v rg >/dev/null 2>&1 || { echo "selftest: ripgrep (rg) required"; exit 2; }
[[ -x "$SCRIPT" || -f "$SCRIPT" ]] || { echo "selftest: missing $SCRIPT"; exit 2; }

WORK="$(mktemp -d "${TMPDIR:-/tmp}/content-policy-selftest.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT

stripe_line() {
  # split so this source file never matches stripe-live-key
  printf 'STRIPE_KEY=sk_live_%s\n' 'c0ffee99c0ffee99c0ffee99c0ffee99'
}

fail() { echo "selftest FAIL: $1" >&2; exit 1; }
run() { bash "$SCRIPT" "$1" >/dev/null 2>&1; echo $?; }

# Control: live-key-shaped value under examples/ is a BLOCK (gitleaks skips
# examples/; content-policy is the remaining half of the gate).
mkdir -p "$WORK/control-examples/examples"
stripe_line > "$WORK/control-examples/examples/leak.env"
[[ "$(run "$WORK/control-examples")" == 1 ]] || fail "examples/ live-key-shaped value should BLOCK"

# Documented allowlist: same value with a source-line reason still passes.
mkdir -p "$WORK/line-allow/src"
printf 'STRIPE_KEY=sk_live_%s # guard:allow fixture\n' 'c0ffee99c0ffee99c0ffee99c0ffee99' \
  > "$WORK/line-allow/src/ok.env"
[[ "$(run "$WORK/line-allow")" == 0 ]] || fail "source-line # guard:allow <reason> should still pass"

# Path spoof: marker in the directory name must BLOCK (previously skipped the file).
mkdir -p "$WORK/path-spoof/examples/# guard:allow bypass"
stripe_line > "$WORK/path-spoof/examples/# guard:allow bypass/leak.env"
[[ "$(run "$WORK/path-spoof")" == 1 ]] || fail "marker in file path should BLOCK, not skip the file"

# Path spoof with no secret still BLOCK (the path itself is the violation).
mkdir -p "$WORK/path-only/src/# guard:allow stealth"
printf 'ok\n' > "$WORK/path-only/src/# guard:allow stealth/notes.txt"
[[ "$(run "$WORK/path-only")" == 1 ]] || fail "path containing guard:allow should BLOCK even without a secret"

echo "selftest OK"
