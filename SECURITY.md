# Security Policy

## Reporting a Vulnerability

**DO NOT open a public issue for security vulnerabilities.**

Email security@wave.online with:
- Description of the vulnerability
- Steps to reproduce
- Impact assessment

Encrypt sensitive reports with our PGP key (available on request).

## Our commitment

- We acknowledge your report within **48 hours**.
- We provide an assessment and a fix timeline within **5 business days**.
- We aim to resolve critical issues within **90 days** of disclosure and will keep you updated.
- With your permission, we credit you once a fix ships.

## Coordinated disclosure

Please give us a reasonable window to remediate before any public disclosure. We will coordinate timing with you and will not pursue legal action against good-faith research that:

- respects user privacy and data, and avoids destruction or exfiltration;
- does not degrade service availability (no DoS / spam / social engineering); and
- stays within the scope below.

## Scope

In scope: wave-av source repositories and WAVE-operated services (`*.wave.online`, `api.wave.online`). Out of scope: third-party services we integrate, and findings requiring physical access or a compromised end-user device.

## Supported Versions

| Package | Supported |
|---------|-----------|
| @wave-av/sdk | Latest |
| @wave-av/adk | Latest |
| @wave-av/mcp-server | Latest |
