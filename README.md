# LAB_PUBLIC — 公開可能な実験・知見

Source-Exempt: operational-doc

_THINK YOU LAB / 最終更新: 2026-03-13_

---

## 用途

公開可能な実験メモ・知見・調査結果を保存するフォルダ。

## 記入ルール（必須）

- **出典URLが必ずある**（知見メモ・調査ログは URL なきまま置かない）
- **機微な文脈ゼロ**（個人情報・顧客情報・感情・推測を含まない）
- **公開しても不利益が生じない**内容のみ
- **運用ドキュメントは exempt を明示**（`Source-Exempt: operational-doc`）

## ログフォーマット（推奨）

```markdown
## YYYY-MM-DD: タイトル

- 学んだこと / 気づき
- 出典: https://example.com/article （必須）
- Plugin使用: あり（Plugin名） / なし
- 外部送信データ: 公開URLのテキストのみ / 送信なし
```

## テンプレート

- 新しい知見メモの雛形: `templates/public-note.md`
- 新しい運用ドキュメントの雛形: `templates/operational-doc.md`

## 外部共有ルール

- このフォルダのファイルは条件付きで外部共有可
- 共有前に `LOG_POLICY.md` のチェックリストを再確認すること
- 共有した記録（日時・相手・ファイル名）は `../logs/private/` に残す

## インフラ補助

- n8n の公開安全な起動テンプレート: `infra/n8n/docker-compose.yml`
- 環境変数テンプレート: `infra/n8n/.env.example`
- セットアップと復旧手順: `infra/n8n/README.md`
- 公開前チェック: `scripts/check-public-safety.ps1`