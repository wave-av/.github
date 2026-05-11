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

## How to add a new template

1. Create `workflow-templates/<name>.yml` (the actual workflow).
2. Create `workflow-templates/<name>.properties.json` with the metadata
   (`name`, `description`, `iconName`, `categories`, `filePatterns`).
3. Commit + push. The template auto-appears in the "New workflow" UI for every
   repo in the wave-av org.

See [GitHub docs on workflow templates](https://docs.github.com/en/actions/sharing-automations/creating-workflow-templates-for-your-organization).
