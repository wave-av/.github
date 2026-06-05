# WAVE org-level reusable workflow templates

GitHub Actions workflow templates that every WAVE public repo can install via
GitHub's UI ("Actions → New workflow → By wave-av").

## moq-draft-drift

**For:** any WAVE repo that touches IETF MoQ Transport (wave-moq-edge, sdk,
sdk-python, mcp-server, examples, …).

**What it does:** fails CI when `draft-ietf-moq-transport-00` through `-06`
appears outside the documented negotiation matrix. Pulls the canonical
drift-check script from `wave-av/wave-moq-edge` so the IETF-current pin lives
in exactly one place across the org.

**Install:** copy `moq-draft-drift.yml` into `.github/workflows/` of your repo,
or use GitHub's "New workflow" UI and pick the WAVE template.

## public-repo-guard

**For:** **every** WAVE public repo. This is the standing pre-publication gate.

**What it does:** two complementary checks on each PR / push —
1. **gitleaks** — formatted secrets (API keys, tokens, private keys), using the
   canonical `.gitleaks.toml` at the root of this repo (placeholders / fixtures
   allowlisted).
2. **content-policy.sh** — the WAVE-specific things gitleaks does *not* catch:
   live Stripe account IDs (`acct_…`), hardcoded Cloudflare `account_id`s,
   developer absolute paths (`/Users/…`), references to private WAVE repos, and
   committed `.env` files.

Both the config and the script are fetched from `wave-av/.github` at run time, so
the rules live in exactly one place across the org. A repo may ship its own
`.gitleaks.toml` to extend the rules locally.

**Private-repo name denylist:** the list of private repo/product names to block
is *not* baked into the (public) script. Set an org-level Actions **variable**
`GUARD_PRIVATE_REPOS` (comma-separated) and the workflow passes it through; the
check is skipped when the variable is empty.

**Allowlisting:** annotate a verified-safe line with `# guard:allow <reason>`, or
add a path glob to a `.guardignore` at the repo root.

**Install + enforce:** copy `public-repo-guard.yml` into `.github/workflows/`
(or use the "New workflow" UI), then add `public-repo-guard / Secrets + content
policy` to the branch's required status checks so it blocks merges.

## How to add a new template

1. Create `workflow-templates/<name>.yml` (the actual workflow).
2. Create `workflow-templates/<name>.properties.json` with the metadata
   (`name`, `description`, `iconName`, `categories`, `filePatterns`).
3. Commit + push. The template auto-appears in the "New workflow" UI for every
   repo in the wave-av org.

See [GitHub docs on workflow templates](https://docs.github.com/en/actions/sharing-automations/creating-workflow-templates-for-your-organization).
