#!/usr/bin/env bash
# public-repo-guard for Buildkite: same gate as .github/workflows/public-repo-guard.yml
# ("Secrets + content policy"), for CI that does not run on GitHub Actions.
#
#   1. gitleaks (pinned + SHA-256 verified) over the published tree, repo .gitleaks.toml
#   2. scripts/public-repo-guard/content-policy.sh (ripgrep pinned + SHA-256 verified)
#
# Differences from the workflow, on purpose:
#   - no sudo: verified binaries run from a temp dir outside the checkout.
#   - GUARD_PRIVATE_REPOS is only used when the job environment provides it.
#     Pull-request builds carry no secrets, so the private-repo rule is skipped
#     there (content-policy.sh already skips it when the variable is unset).
# Bump a version and its SHA-256 together.
set -euo pipefail

GITLEAKS_VERSION="8.30.1"
GITLEAKS_SHA256="551f6fc83ea457d62a0d98237cbad105af8d557003051f41f3e7ca7b3f2470eb"
RG_VERSION="14.1.1"
RG_SHA256="4cf9f2741e6c465ffdb7c26f38056a59e2a2544b51f7cc128ef28337eeae4d8e"

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

TOOLS="$(mktemp -d "${TMPDIR:-/tmp}/prg.XXXXXX")"
trap 'rm -rf "$TOOLS"' EXIT

fetch() { # url sha256 dest
  curl -fsSL --proto '=https' --tlsv1.2 --retry 3 -o "$3" "$1"
  echo "$2  $3" | sha256sum -c -
}

echo "--- :lock: install gitleaks ${GITLEAKS_VERSION} (pinned + checksum-verified)"
fetch "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz" \
  "$GITLEAKS_SHA256" "$TOOLS/gitleaks.tar.gz"
tar -xzf "$TOOLS/gitleaks.tar.gz" -C "$TOOLS" gitleaks
"$TOOLS/gitleaks" version

echo "--- :lock: install ripgrep ${RG_VERSION} (pinned + checksum-verified)"
fetch "https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
  "$RG_SHA256" "$TOOLS/rg.tar.gz"
tar -xzf "$TOOLS/rg.tar.gz" -C "$TOOLS" --strip-components=1 "ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl/rg"
export PATH="$TOOLS:$PATH"
rg --version | head -1

echo "+++ :mag: gitleaks (secret scan, published tree)"
gitleaks detect --no-git --source . --config .gitleaks.toml --redact --no-banner --exit-code 1

echo "+++ :mag: content-policy concat selftest"
bash scripts/public-repo-guard/concat-selftest.sh

echo "+++ :mag: content policy"
bash scripts/public-repo-guard/content-policy.sh .
