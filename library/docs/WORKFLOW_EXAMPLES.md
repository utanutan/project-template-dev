# Claude Code Multi-Agent Workflow Examples

このドキュメントは、Claude Codeでマルチエージェントを実行する際の具体的なワークフローサンプルです。

---

## 1. 基本: シングルエージェント実行

### Architect-Plan を呼び出す

```
あなたは Architect-Plan です。以下の仕様を分析し、spec/implementation_plan.md に
段階的な実装プランを作成してください。

# CONTEXT
- プロジェクト: Todo App MVP
- 技術スタック: React + Node.js + SQLite

# REQUIREMENTS
- [要件を記載]

# OUTPUT
1. 依存関係のないタスクを並列トラックに分割
2. 各タスクの見積もり時間を記載
3. 実装順序を明示
```

---

## 2. 並列実行: バックグラウンドでCoder起動

### Track A: フロントエンド（バックグラウンド起動 Ctrl+B）

```
あなたは Senior-Coder (Track A: Frontend) です。
メインスレッドを汚さないよう、すべての作業をこのセッション内で完結させてください。

# TASK
projects/todo-app/src/components/ にReactコンポーネントを実装する。

# CONSTRAINTS
- DRY原則厳守
- 各コンポーネントにテストを作成
- 完了したら「Track A: Complete」と報告

# FILES TO CREATE
1. TodoList.tsx
2. TodoItem.tsx
3. TodoForm.tsx
```

### Track B: バックエンド（別のバックグラウンドで起動）

```
あなたは Senior-Coder (Track B: Backend) です。
メインスレッドを汚さないよう、すべての作業をこのセッション内で完結させてください。

# TASK
projects/todo-app/src/api/ にREST APIを実装する。

# CONSTRAINTS
- エラーハンドリング必須
- SQLiteとの接続を確立
- 完了したら「Track B: Complete」と報告

# ENDPOINTS
1. GET /api/todos
2. POST /api/todos
3. DELETE /api/todos/:id
```

---

## 3. レビューサイクル: Coder ↔ Guardian ループ

### Review-Guardian を起動

```
あなたは Review-Guardian です。
Senior-Coderの成果物をレビューし、問題があれば修正を依頼してください。
修正ループはメインスレッドに戻さず、このセッション内で完結させてください。

# TARGET
projects/todo-app/src/

# CHECKLIST
□ セキュリティ脆弱性
□ 入力バリデーション
□ エラーハンドリング
□ 命名の一貫性
□ テストカバレッジ

# FLOW
1. コードを分析
2. 問題発見 → Senior-Coderに修正依頼
3. 修正確認 → 問題なければ「Review Passed」を報告
```

---

## 4. 統合: メインスレッドで最終確認

```
すべてのサブエージェントが完了しました。
最終的な動作確認とビルドチェックを行ってください。

# VERIFY
1. npm run build が成功するか
2. npm test が全パスするか
3. 機能が正しく動作するか

# REPORT
- ビルド結果
- テスト結果
- 発見された問題（あれば）
```

---

## クイックリファレンス

| 操作 | キー/アクション |
|------|-----------------|
| バックグラウンド起動 | `Ctrl+B` |
| 新規サブエージェント | `/clear` → プロンプト入力 |
| コンテキスト保護 | 「メインスレッドを汚さない」指示 |
| 完了報告 | 「要約のみ報告」指示 |

---

*See also: [GUILD_REFERENCE.md](./GUILD_REFERENCE.md)*
