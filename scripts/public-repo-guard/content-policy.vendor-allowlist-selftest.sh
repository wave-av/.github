#!/usr/bin/env bash
# Regression: gitleaks 8.30.1 useDefault path/filename allowlists skip vendor JS
# (jquery.min.js, bootstrap.min.js, …), bower_components, and site-packages.
# content-policy must still BLOCK Slack / classic GitHub PAT / Google / npm
# families in those trees — they are the remaining half of the org gate.
# Tokens are assembled at runtime so this file never matches the BLOCK rules.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SCRIPT="$ROOT/scripts/public-repo-guard/content-policy.sh"
command -v rg >/dev/null 2>&1 || { echo "selftest: ripgrep (rg) required"; exit 2; }
[[ -f "$SCRIPT" ]] || { echo "selftest: missing $SCRIPT"; exit 2; }

WORK="$(mktemp -d "${TMPDIR:-/tmp}/content-policy-vendor-selftest.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT

slack_line() { printf 'token=xoxb-%s\n' '123456789012-123456789012-abcdefghijklmnopqrstuvwx'; }
ghp_line() { printf 'token=ghp_%s\n' 'abcdefghijklmnopqrstuvwxyzABCD0123456789'; }
google_line() { printf 'token=AIza%s\n' 'SyAaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'; }
npm_line() { printf 'token=npm_%s\n' 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJ'; }

fail() { echo "selftest FAIL: $1" >&2; exit 1; }
run() { bash "$SCRIPT" "$1" >/dev/null 2>&1; echo $?; }

# Control: Slack-shaped token in ordinary src/ must BLOCK (gitleaks already
# catches this path; content-policy is the complementary half).
mkdir -p "$WORK/control-src/src"
slack_line > "$WORK/control-src/src/app.js"
[[ "$(run "$WORK/control-src")" == 1 ]] || fail "src/app.js Slack-shaped token should BLOCK"

# Vendor JS filenames that gitleaks 8.30.1 default-allowlists (0 bytes scanned).
mkdir -p "$WORK/jquery/assets"
slack_line > "$WORK/jquery/assets/jquery.min.js"
[[ "$(run "$WORK/jquery")" == 1 ]] || fail "assets/jquery.min.js Slack-shaped token should BLOCK"

mkdir -p "$WORK/jqueryver/assets"
ghp_line > "$WORK/jqueryver/assets/jquery-3.7.1.min.js"
[[ "$(run "$WORK/jqueryver")" == 1 ]] || fail "jquery-3.7.1.min.js classic PAT should BLOCK"

mkdir -p "$WORK/bootstrap/vendor-js"
google_line > "$WORK/bootstrap/vendor-js/bootstrap.min.js"
[[ "$(run "$WORK/bootstrap")" == 1 ]] || fail "bootstrap.min.js Google API key should BLOCK"

mkdir -p "$WORK/angular/src"
npm_line > "$WORK/angular/src/angular.min.js"
[[ "$(run "$WORK/angular")" == 1 ]] || fail "angular.min.js npm token should BLOCK"

# gitleaks default path allowlists that content-policy does not skip.
mkdir -p "$WORK/bower/bower_components/pkg"
slack_line > "$WORK/bower/bower_components/pkg/index.js"
[[ "$(run "$WORK/bower")" == 1 ]] || fail "bower_components Slack-shaped token should BLOCK"

mkdir -p "$WORK/sitepkg/lib/python3.12/site-packages"
ghp_line > "$WORK/sitepkg/lib/python3.12/site-packages/hidden.py"
[[ "$(run "$WORK/sitepkg")" == 1 ]] || fail "site-packages classic PAT should BLOCK"

# Documented source-line allow still works for the new rules.
mkdir -p "$WORK/line-allow/src"
printf 'token=xoxb-%s # guard:allow fixture\n' '123456789012-123456789012-abcdefghijklmnopqrstuvwx' \
  > "$WORK/line-allow/src/ok.js"
[[ "$(run "$WORK/line-allow")" == 0 ]] || fail "source-line # guard:allow <reason> should still pass"

echo "selftest OK"
