---
description: 現セッションの引き継ぎサマリを生成してクリップボードにコピーする (/clear 直後の新セッションに貼って使う)
---

新しい Claude Code セッションに渡すための引き継ぎ (handoff) サマリを作って、`pbcopy` でクリップボードにコピーする。

## 手順

1. **状態を集める** (並列で OK):
   - `git status` / `git log --oneline -10` / `git rev-parse --abbrev-ref HEAD` で branch と最近の commit
   - `gh pr list --state open --limit 10` で open PR (gh があれば)
   - 直近のチャット履歴から「やったこと」「未完了」「決めた方針」を抽出
   - リポジトリ名はカレントディレクトリの basename か `git remote get-url origin` から取る

2. **次のテンプレートで Markdown を組み立てる**:

   ```markdown
   # 引き継ぎ (<repo-name>, <YYYY-MM-DD>)

   ## 直近セッションでやったこと
   - <bullet — どのファイルに何をしたか / どの PR を出したか>
   - ...

   ## PR / branch
   - <PR #N の状態 (open / merged / draft)、現在の branch、main との同期状況>
   - ...

   ## 次に着手するなら
   - <未完了タスク / TODO / 残 issue。無ければ「特になし」と書く>
   - ...

   ## 注意点 (memory / project rules より)
   - <この会話で参照した memory / CLAUDE.md / AGENTS.md ルールのうち、次セッションでも効くもの>
   - ...
   ```

3. **pbcopy に流す**:
   - 上で組み立てた Markdown をヒアドキュメントで `pbcopy` に渡す
   - 例:
     ```bash
     cat <<'HANDOFF' | pbcopy
     # 引き継ぎ (...)
     ...
     HANDOFF
     ```

4. **ユーザーへ結果を 1〜2 行で伝える**:
   - 「引き継ぎを pbcopy しました。`/clear` してから貼り付けてください。」
   - チャットには Markdown 全文を再掲しなくてよい (クリップボードに入っていれば十分)

## 引数

- `/handoff` — フル形式 (4 セクション全部)
- `/handoff brief` — 「直近セッションでやったこと」+ 「次に着手するなら」 のみの短縮版

## ガイドライン

- 推測で書かない。conversation で明確に話題に出ていない事項を勝手に「次に着手」に入れない
- ユーザーの memory に既にあるルール (例: 「co-author trailer 付けない」「main で直接 commit しない」) は注意点に毎回コピペせず、特にこのセッションで衝突 / 学習があった項目だけ入れる
- 日付は project memory の `currentDate` を使う。会話の日跨ぎがあれば最新側
- repo を跨ぐセッションだった場合は repo 名を複数並べる
