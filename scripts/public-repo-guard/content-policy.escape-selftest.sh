#!/usr/bin/env bash
# Regression: language-level escapes must not hide Stripe live-key-shaped
# values from content-policy. gitleaks 8.30.1 --no-git already decodes JSON
# \uXXXX and base64, but misses JS/Python \xHH, JS \u{...}, HTML numeric
# entities, and zero-width joiners. Tokens are assembled at runtime so this
# file never matches the BLOCK rules.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SCRIPT="$ROOT/scripts/public-repo-guard/content-policy.sh"
command -v rg >/dev/null 2>&1 || { echo "selftest: ripgrep (rg) required"; exit 2; }
command -v python3 >/dev/null 2>&1 || { echo "selftest: python3 required"; exit 2; }
[[ -f "$SCRIPT" ]] || { echo "selftest: missing $SCRIPT"; exit 2; }

WORK="$(mktemp -d "${TMPDIR:-/tmp}/content-policy-escape-selftest.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT

SK_PREFIX="sk_live_"
SK_BODY="0a1b2c3d4e5f678901234567"
sk() { printf '%s%s' "$SK_PREFIX" "$SK_BODY"; }

hex_escape() {
  python3 -c 'import sys; print("".join("\\x%02x" % ord(c) for c in sys.argv[1]))' "$(sk)"
}
brace_escape() {
  python3 -c 'import sys; print("".join("\\u{%x}" % ord(c) for c in sys.argv[1]))' "$(sk)"
}
html_escape() {
  python3 -c 'import sys; print("".join("&#%d;" % ord(c) for c in sys.argv[1]))' "$(sk)"
}
zwj_escape() {
  python3 -c 'import sys; s=sys.argv[1]; print(s[:3]+"\u200b"+s[3:])' "$(sk)"
}

fail() { echo "selftest FAIL: $1" >&2; exit 1; }
run() { bash "$SCRIPT" "$1" >/dev/null 2>&1; echo $?; }

mkdir -p "$WORK/control/src"
printf 'key=%s\n' "$(sk)" > "$WORK/control/src/app.js"
[[ "$(run "$WORK/control")" == 1 ]] || fail "plaintext src/app.js live-key-shaped value should BLOCK"

mkdir -p "$WORK/jshex/src"
printf 'const k="%s";\n' "$(hex_escape)" > "$WORK/jshex/src/app.js"
[[ "$(run "$WORK/jshex")" == 1 ]] || fail "JS \\xHH-encoded live-key-shaped value should BLOCK"

mkdir -p "$WORK/pyhex/src"
printf 'k="%s"\n' "$(hex_escape)" > "$WORK/pyhex/src/app.py"
[[ "$(run "$WORK/pyhex")" == 1 ]] || fail "Python \\xHH-encoded live-key-shaped value should BLOCK"

mkdir -p "$WORK/jsbrace/src"
printf 'const k="%s";\n' "$(brace_escape)" > "$WORK/jsbrace/src/app.js"
[[ "$(run "$WORK/jsbrace")" == 1 ]] || fail "JS \\u{...}-encoded live-key-shaped value should BLOCK"

mkdir -p "$WORK/htmlent/src"
printf '<meta token="%s">\n' "$(html_escape)" > "$WORK/htmlent/src/app.html"
[[ "$(run "$WORK/htmlent")" == 1 ]] || fail "HTML-entity-encoded live-key-shaped value should BLOCK"

mkdir -p "$WORK/zwj/src"
printf 'const k="%s";\n' "$(zwj_escape)" > "$WORK/zwj/src/app.js"
[[ "$(run "$WORK/zwj")" == 1 ]] || fail "zero-width-joiner split live-key-shaped value should BLOCK"

mkdir -p "$WORK/line-allow/src"
printf 'const k="%s"; # guard:allow fixture\n' "$(hex_escape)" > "$WORK/line-allow/src/ok.js"
[[ "$(run "$WORK/line-allow")" == 0 ]] || fail "source-line # guard:allow <reason> should still pass after decode"

echo "selftest OK"
