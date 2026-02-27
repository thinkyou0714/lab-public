# CLAUDE.md — LAB_PUBLIC

_リポジトリ固有の運用指示 / 最終更新: 2026-02-28_

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

- 運用原則: `C:/Users/Rikuto/CLAUDE.md`
- Plugin ポリシー: `C:/docs/governance/PLUGIN_POLICY.md`
- Playbook: `docs/remote-control-playbook.md`

---

## 制約

1. **出典URLが必ずある** — URLなき知見はここに置かない
2. **機微な文脈ゼロ** — 個人情報・顧客情報・推測を含まない
3. **LAB_PUBLIC = 公開可能** — 業務・私用ファイルと混在させない
4. **ファイル作成・編集のみ** — git push / jj push 等は確認を取ってから実行
5. **外部送信データは公開情報のみ** — LOG_POLICY.md のチェックリストを守る
