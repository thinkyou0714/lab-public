# CONTRIBUTING.md

Source-Exempt: operational-doc

_Last updated: 2026-03-15_

## Purpose

このリポジトリへ公開可能な知見や運用ドキュメントを追加するときの最小手順をまとめる。

## Before You Add Files

- `README.md` と `LOG_POLICY.md` を確認する
- 知見メモは出典 URL を必ず付ける
- 運用ドキュメントは `Source-Exempt: operational-doc` を明示する

## Templates

- 知見メモ: `templates/public-note.md`
- 運用ドキュメント: `templates/operational-doc.md`
- 生成補助: `pwsh -File scripts/new-from-template.ps1 -Template public-note -OutputPath notes/2026-03-15-example.md`

## Local Checks

- 統合チェック: `pwsh -File scripts/validate-all.ps1`
- 個別チェック: `pwsh -File scripts/check-public-safety.ps1`

## jj Flow

1. 変更を作る
2. `jj describe -m "short summary"`
3. `jj bookmark set master -r "@"`
4. `jj git push --bookmark master`

## Notes

- push 後に空の作業コピーができたら `jj abandon "@"` で整理できる
- 公開可否に迷う内容は private 側で扱う