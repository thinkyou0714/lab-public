# AGENTS.md — lab-public

THINK YOU LAB の公開可能な実験・知見・調査ログの置き場（`LAB_PUBLIC`）。**公開情報のみ**・出典URL必須。

- **中身**: `docs/` 知見 · `templates/` 雛形 · `scripts/` 運用スクリプト (PowerShell) · `infra/` · `skills/` (配布 skill: `lab-public-maintainer`)。
- **記入ルール（必須）**: 出典URLがある / 機微な文脈ゼロ（PII・顧客情報・推測なし）/ 公開しても不利益なし。運用ドキュメントは `Source-Exempt: operational-doc` を明示。ログは `LOG_POLICY.md`。
- **依存**: なし（Markdown 中心 + PowerShell スクリプト）。ビルド/インストール不要。
- **雛形から作成**: `pwsh -File scripts/new-from-template.ps1 -Template public-note -OutputPath notes/...`（PowerShell はローカル専用）。

## Claude Code on the web

A cloud session loads this `AGENTS.md` and the repo `skills/` context. No build/deps to install.
Note: the `scripts/*.ps1` are PowerShell (Windows/pwsh) — run them locally, not in the Linux cloud
sandbox. MCP is local-only. See `thinkyou0714/.github` → `docs/claude-code-web-readiness.md`.
