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

**What it does:** three complementary checks —
1. **gitleaks** — formatted secrets (API keys, tokens, private keys), using the
   canonical `.gitleaks.toml` at the root of this repo (placeholders / fixtures
   allowlisted).
2. **content-policy.sh** — the WAVE-specific things gitleaks does *not* catch:
   live Stripe account IDs (`acct_…`), hardcoded Cloudflare `account_id`s,
   developer absolute paths (`/Users/…`), references to private WAVE repos, and
   committed `.env` files.
3. **body-policy.sh** — the same leak classes in PR / review / issue / comment
   TEXT, which is equally world-readable and was previously scanned by nothing
   server-side. On a PR it blocks the merge; on an issue, comment, or review it
   detects so the text can be redacted fast.

The config and the scripts are VENDORED into each repo alongside the workflow —
they are NOT fetched at run time, so the gate is fully reviewable and cannot be
reprogrammed out-of-band. A repo may extend its local `.gitleaks.toml` to add
rules.

**Private-repo name denylist:** the list of private repo/product names to block
is *not* baked into the (public) script. Set an org-level Actions **variable**
`GUARD_PRIVATE_REPOS` (comma-separated) and the workflow passes it through; the
check is skipped when the variable is empty.

**Allowlisting:** annotate a verified-safe line with `# guard:allow <reason>`, or
add a path glob to a `.guardignore` at the repo root.

**Install + enforce:** copy the five files the workflow's header lists —
`public-repo-guard.yml` into `.github/workflows/`, plus `.gitleaks.toml`,
`scripts/public-repo-guard/content-policy.sh`,
`scripts/public-repo-guard/body-policy.sh`, and
`scripts/public-repo-guard/tests/body-policy.test.sh` — then add BOTH check
names, `public-repo-guard / Secrets + content policy` and
`public-repo-guard / Body content policy`, to the branch's required status
checks. The tree check alone does not gate body edits: on an `edited` event
only the body job runs, so without the second required check a failing body
scan leaves the PR mergeable.

## How to add a new template

1. Create `workflow-templates/<name>.yml` (the actual workflow).
2. Create `workflow-templates/<name>.properties.json` with the metadata
   (`name`, `description`, `iconName`, `categories`, `filePatterns`).
3. Commit + push. The template auto-appears in the "New workflow" UI for every
   repo in the wave-av org.

See [GitHub docs on workflow templates](https://docs.github.com/en/actions/sharing-automations/creating-workflow-templates-for-your-organization).
