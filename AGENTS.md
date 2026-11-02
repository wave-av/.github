# AGENTS.md — wave-av (org default)

Contract for AI agents working in any wave-av repository. A repo MAY override with its own `AGENTS.md`.

## Rules

- Branch; never push to the default branch. Open a PR. All gates must pass before merge.
- Do not commit secrets, tokens, or `.env`. Secret-scan is a required gate and will block.
- Match the existing code, comment density, and conventions of the file you edit.
- Keep files focused (~200–500 lines; split before 800).
- Run the repo's typecheck/lint/test before opening a PR; fix what you broke.

## Gates (must be green)

Per the [repo-governance matrix](https://github.com/wave-av/wave-foundation/blob/master/frameworks/repo-governance/governance-matrix.md): secret-scan, lint, typecheck, tests, file-size, CodeRabbit review, CODEOWNERS review. Public repos also: SCA, OpenSSF Scorecard, license/SBOM. Copy must pass the copywriting gate.

## Conventions

- Conventional Commit titles (`feat:`, `fix:`, `docs:`, `chore:` …). PRs use the template.
- Update `CHANGELOG.md` (`Unreleased`) with user-facing changes.
- Human docs (`README`) are warm and benefit-led; agent docs (this file, `llms.txt`, `skill.md`) are terse and contract-led. Keep both in sync — never ship one without the other.

## CI courtesy rule (WAVE-32167)

- On Buildkite queue expiry, never push an empty commit or rebase just to get a build. Rebuild the same commit once, and only when at least 2 agents are connected and the oldest waiting job is under 30 minutes old. If that rebuild expires too, stop and post one note.
- Rebase only for a real conflict or a check that needs a newer main, at most once per day per PR.
- Keep at most 2 open builds per lane on the shared isolated queue.

## Security

Vulnerabilities go through the [Security Policy](./SECURITY.md) (security@wave.online), never a public issue. Auth/scope/metering for WAVE services is enforced at the gateway — don't reimplement it in a spoke.


## Machine surface

```yaml agents-router
version: "0.1"
budget_lines: 200
index:
  - family: permissions-contract
    path: PERMISSIONS.md
```
