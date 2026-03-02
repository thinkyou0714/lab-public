# CLAUDE.md — LAB_PUBLIC

Source-Exempt: operational-doc

_リポジトリ固有の運用指示 / 最終更新: 2026-03-07_

---

## WHY（何を解決するか）

公開可能な実験・知見を蓄積し、将来の自分や他者が参照できる資産にする。
業務・個人情報とのクロス汚染を防ぎ、安心して公開できるリポジトリを維持する。

---

## 技術スタック

- Markdown（ドキュメント中心）
- Python / TypeScript（実験スクリプト）
- jj + git（バージョン管理、co-locate済み）

---

## 主要コマンド

```bash
# jj でコミット
jj describe -m "メッセージ"
jj git push --bookmark master

# リモート確認
jj git remote list
```

---

## 参照パス

- 運用原則: `README.md`
- 公開チェック: `LOG_POLICY.md`
- Playbook: `docs/remote-control-playbook.md`
- n8n セットアップ: `infra/n8n/README.md`

---

## 制約

1. **知見メモには出典URLが必ずある** — URLなきまま公開ログを置かない
2. **運用ドキュメントは exempt を明示** — `Source-Exempt: operational-doc`
3. **機微な文脈ゼロ** — 個人情報・顧客情報・推測を含まない
4. **LAB_PUBLIC = 公開可能** — 業務・私用ファイルと混在させない
5. **ファイル作成・編集のみ** — git push / jj push 等は確認を取ってから実行
6. **外部送信データは公開情報のみ** — `LOG_POLICY.md` のチェックリストを守る