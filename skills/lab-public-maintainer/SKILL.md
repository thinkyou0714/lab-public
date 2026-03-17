---
name: lab-public-maintainer
description: Maintain the LAB_PUBLIC repository's public-safe documentation workflow. Use when adding or updating public notes, operational docs, templates, validation scripts, or CI, especially when work should follow LOG_POLICY.md, scripts/validate-all.ps1, and the jj bookmark and push flow.
---

Source-Exempt: operational-doc

# Lab Public Maintainer

## Overview

Work inside the LAB_PUBLIC repository. Keep content public-safe, prefer the existing templates and helper scripts, and keep local validation and CI behavior aligned.

## Workflow

1. Read `README.md`, `LOG_POLICY.md`, and `CONTRIBUTING.md` when changing repo rules or contributor flow.
2. For new content, use `templates/public-note.md` or `templates/operational-doc.md`, or generate from `scripts/new-from-template.ps1`.
3. When changing validation or CI, keep `scripts/validate-all.ps1` and `.github/workflows/public-safety.yml` in sync.
4. Before finishing, run `pwsh -File scripts/validate-all.ps1`.
5. Publish with `jj describe -m`, `jj bookmark set master -r "@"`, and `jj git push --bookmark master`.
6. If push creates an empty working copy, clean up with `jj abandon "@"`.

## Guardrails

- Keep knowledge notes sourced with `出典: https://...`.
- Mark operational docs with `Source-Exempt: operational-doc`.
- Keep secrets and host-specific values out of tracked files; use `infra/n8n/.env.example`.
- Prefer small, auditable changes.

## Key Files

- `README.md`
- `LOG_POLICY.md`
- `CONTRIBUTING.md`
- `scripts/validate-all.ps1`
- `scripts/check-public-safety.ps1`
- `.github/workflows/public-safety.yml`