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

## Security

Vulnerabilities go through the [Security Policy](./SECURITY.md) (security@wave.online), never a public issue. Auth/scope/metering for WAVE services is enforced at the gateway — don't reimplement it in a spoke.
