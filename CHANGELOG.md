# Changelog

User-facing changes to this repository's org-wide workflow templates and vendored
guard scripts. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## Unreleased

### Added

- `public-repo-guard` now has a BODY gate: a second workflow file
  (`public-repo-guard-body.yml`) plus `scripts/public-repo-guard/body-policy.sh`
  scan pull-request titles/bodies, issue titles/bodies, comments, and review
  bodies for the same leak classes the tree gate covers (credential formats,
  infrastructure identifiers, internal markers, and private-repo names near
  operational detail). Previously nothing scanned these world-readable surfaces
  server-side.

### Changed

- Installing `public-repo-guard` in a repo now means vendoring six files and
  requiring BOTH check names (`public-repo-guard / Secrets + content policy`
  and `public-repo-guard / Body content policy`) in branch protection; the tree
  check alone does not gate body edits. See `workflow-templates/README.md` for
  the install and enforce steps.
