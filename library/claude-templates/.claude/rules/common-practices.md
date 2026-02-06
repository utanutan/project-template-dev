# Common Practices - プロジェクト共通知見

## コーディング規約
- コミットメッセージは Conventional Commits 形式 (`feat:`, `fix:`, `docs:`, `refactor:` 等)
- テストは実装と同時に書く
- エラーハンドリングは境界（ユーザー入力、外部API）で行う

## エージェント運用
- エージェント起動時は `.claude/agents/<name>.md` のエージェント定義を参照する
- 方式に応じた起動方法を使用する:
  - **Agent Teams**: teammate として spawn（エージェント定義が自動適用）
  - **Task Subagents**: `.claude/agents/<name>.md` を読んでプロンプトに含める
- `tracks/PROGRESS.md` はタスク開始・完了時に必ず更新
- PM は Coder に直接指示せず、必ず Architect 経由

## ドキュメント
- README.md はプロジェクト概要・セットアップ手順を常に最新に保つ
- API を作成した場合は API 仕様書を必ず作成
- DB スキーマ変更時はスキーマ定義ドキュメントを更新

## 知見の記録
- プロジェクト中に得た技術的知見は `.claude/rules/` 配下に記録する
- ファイル名は `<topic>.md` 形式（例: `docker-tips.md`, `api-design.md`）
- グローバルに有用な知見はテンプレートリポジトリへのフィードバックを検討する
