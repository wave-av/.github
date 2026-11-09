#!/usr/bin/env bash
# Fixture tests for body-policy.sh.
#
# Deliberately fixture-only: the gate is NEVER proved by writing a real leak into a
# live public PR body, because doing so would publish the exact thing it guards.
#
# The negatives here are the load-bearing half. A leak gate that blocks everything
# is trivially "correct" and useless — it gets disabled within a week. The bare
# cross-reference case below is the one that keeps this gate deployable.
set -uo pipefail

SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/body-policy.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# The names the real gate is configured with come from an org variable; the tests
# pin their own so they are hermetic and do not depend on CI configuration. The
# pinned names are deliberately FICTITIOUS: this file is public, and it sits in
# the one path NEITHER gate scans (content-policy.sh excludes
# scripts/public-repo-guard/ and .gitleaks.toml allowlists it), so a real
# private-repo name written here would be published with nothing able to flag
# it, the exact violation of body-policy.sh's "names are NOT hardcoded" rule.
export GUARD_PRIVATE_REPOS="fixture-repo-alpha, fixture-repo-beta, fixture-repo-gamma"

PASS=0; FAIL=0

# expect <exit-code> <name> <body-text>
expect() {
  local want="$1" name="$2" body="$3" out rc
  printf '%s\n' "$body" > "$TMP/body.txt"
  out="$(bash "$SCRIPT" "$TMP/body.txt" 2>&1)"; rc=$?
  if [[ "$rc" == "$want" ]]; then
    PASS=$((PASS+1)); printf '  ok   %s\n' "$name"
  else
    FAIL=$((FAIL+1)); printf '  FAIL %s — want exit %s, got %s\n%s\n' "$name" "$want" "$rc" "$out"
  fi
  # The annotation is world-readable; a hit must never echo the matched text.
  if [[ "$rc" == 1 ]] && printf '%s' "$out" | grep -qF "$body"; then
    FAIL=$((FAIL+1)); printf '  FAIL %s — LEAKED the matched text into the annotation\n' "$name"
  fi
}

echo "body-policy fixtures"

# --- must BLOCK ---------------------------------------------------------------
expect 1 'private repo + credential name' \
  'Flip is live: WAVE_VIEWPORT_LEASE_SECRET is bound on fixture-repo-alpha now.'
expect 1 'private repo + credential name, reverse order' \
  'The MOQ_JOIN_SECRET was added; fixture-repo-beta picks it up on deploy.'
# Regression: the credential-name class once excluded `_`, so `\b` could only
# anchor mid-identifier (before `LEASE_SECRET`, right after a `_` — never a word
# boundary) and the name-then-detail order sailed through unflagged.
expect 1 'private repo THEN multi-segment credential name' \
  'fixture-repo-alpha now stores WAVE_VIEWPORT_LEASE_SECRET.'
expect 1 'private repo + secret count' \
  'fixture-repo-alpha went from 74 secrets to 75 after this change.'
expect 1 'private repo + service binding' \
  'This adds a service binding from the worker to fixture-repo-gamma for settlement.'
# Regression: the proximity gap was once [^\n]-only while rg matched per line,
# so a hard-wrapped or bulleted body — the most common Markdown shape — put the
# repo name and the credential name on different lines and NEVER tripped the rule.
expect 1 'private repo + credential name across a hard wrap' \
  'Rotation notes:
- fixture-repo-alpha
- WAVE_VIEWPORT_LEASE_SECRET rotated today'
expect 1 'operator home path' \
  'Repro: run it from /Users/someoperator/Documents/notes and it fails.'  # enforce-ignore (fixture)
expect 1 'operator linux home path' \
  'The crash log sits at /home/someoperator/wave/edge.log on my machine.'  # enforce-ignore (fixture)
expect 1 'internal-only marker' \
  'Attaching the internal-only rollout plan for context.'
# Regression: the marker rule was once case-sensitive, so a capitalised banner —
# the way these warnings are actually written — sailed through unflagged.
expect 1 'internal-only marker, capitalised banner' \
  'INTERNAL ONLY: Do Not Share outside the team.'
# Assembled at run time rather than written as a literal: a fixture that LOOKS like
# a live AWS key trips this repo's own pre-commit secret scanners (it did, on the
# first draft). Splitting the prefix keeps the fixture exercising the real regex
# without parking a credential-shaped string in source.
AKID_FIXTURE="AKI""A1234567890ABCDEF"
expect 1 'AWS access key id' \
  "The failing job had ${AKID_FIXTURE} configured."
expect 1 'internal tailscale IP' \
  'It resolves to 100.71.4.19 from inside the fleet.'
# Regression: the about-the-control allowlist once applied to EVERY rule, so a
# credential-shaped hit vanished if the same line happened to name the gate.
expect 1 'credential leak is NOT exempted by naming the control' \
  "public-repo-guard missed this: ${AKID_FIXTURE} showed up in the logs — see SECURITY.md."

# --- must PASS (precision — these keep the gate deployable) -------------------
expect 0 'bare private-repo cross-reference' \
  'This is the companion change to fixture-repo-beta#260; merge that one first.'
expect 0 'two private repos, no operational detail' \
  'Both fixture-repo-alpha and fixture-repo-beta will need a follow-up for this.'
expect 0 'credential NAME with no private repo nearby' \
  'The handler now reads SOME_API_TOKEN from the environment instead of a literal.'
# The other half of the paragraph-scoped gap: a blank line is a topic boundary.
# Two facts in separate paragraphs are not one wiring statement, even within
# 140 characters — without this, any body that mentions a private repo and,
# paragraphs later, any credential NAME would block.
expect 0 'private repo and credential name in separate paragraphs' \
  'Companion change to fixture-repo-alpha#41; merge that one first.

Unrelated: WAVE_VIEWPORT_LEASE_SECRET is now read from the env template.'
# Regression: the paragraph-break lookahead once padded with [ \t] only, so a
# CRLF blank line (\r\n\r\n — the shape GitHub event payloads actually deliver)
# never matched, the newline was consumed as gap, and this clean two-paragraph
# body blocked. The hard-wrap twin proves CRLF wraps still stay in scope.
expect 0 'separate paragraphs with CRLF endings (GitHub payload shape)' \
  $'Companion change to fixture-repo-alpha#41; merge that one first.\r\n\r\nUnrelated: WAVE_VIEWPORT_LEASE_SECRET is now read from the env template.\r'
expect 1 'hard wrap with CRLF endings still blocks' \
  $'Rotation notes:\r\n- fixture-repo-alpha\r\n- WAVE_VIEWPORT_LEASE_SECRET rotated today\r'
# Regression: a bare (?i) prefix once made the SCREAMING_CASE credential pattern
# case-blind, so lowercase "api_key" near a private repo name blocked the body.
expect 0 'lowercase credential-ish word near a private repo' \
  'Companion to fixture-repo-alpha#12: fixes the api_key parsing bug in the client.'
expect 0 'public runner path is not an operator path' \
  'CI checks out to /home/runner/work/repo/repo before the scan runs.'  # enforce-ignore (fixture)
# Regression: the home-path rule was once unanchored, so the `/home/guides/`
# SUBSTRING of a relative docs path — common in prose, rare in a tree — blocked
# the body, and the redacted annotation gave the author nothing to fix.
expect 0 'relative docs path is not a home dir' \
  'See docs/home/guides/setup for details on the rollout.'
expect 0 'URL route starting with /home/ is not a home dir' \
  'The endpoint /home/status/ returns 200 once the worker is warm.'
# Regression: the do-not-<verb> alternative once fired on everyday scheduling
# prose; an object or temporal clause after the verb marks it as prose, not a
# banner.
expect 0 'scheduling prose with a do-not verb' \
  'Please do not publish until Friday; the announcement is still in review.'
expect 0 'do-not verb with an ordinary object' \
  'For now, do not share the link outside this thread.'
expect 1 'bare do-not banner still blocks' \
  'DO NOT DISTRIBUTE'
expect 0 'talking about the control' \
  'body-policy blocks a private repo named next to a SECRET_TOKEN; that is intended.'
# Pins the DELIBERATE trade for the proximity rule: it is about-exempt, so a line
# that names the gate is dropped even when it also carries a private repo name
# next to a credential name. Without this the gate blocks its own PRs — every
# body describing the rule has to write exactly this shape. The exemption is
# line-scoped; the same leak on a line that does NOT name a control still blocks
# (the fixtures above prove that half).
expect 0 'proximity hit on a line naming the control is exempt' \
  'body-policy should flag fixture-repo-alpha next to WAVE_VIEWPORT_LEASE_SECRET.'
expect 0 'explicit guard:allow with a reason' \
  'Example for the docs: fixture-repo-alpha holds EXAMPLE_SECRET — guard:allow documented-example'
expect 0 'ordinary clean body' \
  'Bumps the draft revision and regenerates the fixtures. No behaviour change.'
# Regression: the first CI run of this job failed on its own PR, because a review
# bot edited the body to summarize the change and quoted the marker verbatim.
expect 0 'marker MENTIONED in straight quotes is a description' \
  'Blocks infra identifiers and markers (account_id, home paths, "internal-only" text).'
expect 0 'marker MENTIONED in a code span' \
  'The rule matches `internal-only` and `for internal use` in body text.'
expect 0 'marker MENTIONED in smart quotes' \
  'Blocks operator home paths and “internal-only” text.'
expect 0 'capitalised marker MENTIONED in quotes is still a description' \
  'The rule now also catches an "INTERNAL ONLY" banner regardless of case.'
expect 1 'marker USED unquoted still blocks' \
  'Attaching the internal-only rollout plan; do not share outside the team.'

# --- fail closed --------------------------------------------------------------
# Invoked directly, not through expect(): expect() always materializes a file, so
# it cannot reach these paths. A gate that returns "OK" when it was handed nothing
# to scan is the failure mode this whole file exists to prevent.
for case in "no argument at all::" "nonexistent path::$TMP/does-not-exist.txt"; do
  name="${case%%::*}"; arg="${case##*::}"
  if [[ -n "$arg" ]]; then bash "$SCRIPT" "$arg" >/dev/null 2>&1; else bash "$SCRIPT" >/dev/null 2>&1; fi
  rc=$?
  if [[ "$rc" == 2 ]]; then
    PASS=$((PASS+1)); printf '  ok   %s → exit 2 (fails closed)\n' "$name"
  else
    FAIL=$((FAIL+1)); printf '  FAIL %s — want exit 2, got %s\n' "$name" "$rc"
  fi
done

echo "  ---"
if (( FAIL > 0 )); then
  echo "  $PASS passed, $FAIL FAILED"; exit 1
fi
echo "  $PASS passed, 0 failed"
