# Antigravity Life OS - クイックスタートガイド

実際にマルチエージェントを動かすための手順書です。

---

## 🚀 Step 1: 新規プロジェクト作成

```bash
cd /Users/carpediem/workspace/AntiGravity/project-template-dev

# 開発プロジェクトを作成
./scripts/init-project.sh my-app --type dev
```

---

## 📋 Step 2: 要件定義（PRP作成）

```bash
# 作成されたPRPを編集
code projects/my-app/docs/PRP.md
```

PRPに以下を記載：
- 概要・目的
- 技術スタック
- 機能要件

---

## 🏗️ Step 3: Architect-Plan に設計依頼

**Claude Codeで実行：**

```
あなたは Architect-Plan です。
projects/my-app/docs/PRP.md を読み、spec/my-app_implementation_plan.md に
段階的な実装プランを作成してください。

# OUTPUT
1. 並列実行可能なトラックに分割
2. 各タスクの依存関係を明示
3. 見積もり時間を記載
```

---

## ⚡ Step 4: 並列実装（バックグラウンド起動）

### Track A: Frontend（Ctrl+B でバックグラウンド起動）

```
あなたは Senior-Coder (Track A) です。
メインスレッドを汚さず、このセッション内で作業を完結させてください。

# TASK
spec/my-app_implementation_plan.md の Track A タスクを実装する。

# CONSTRAINTS
- 完了したら「Track A: Complete」と報告
- コードはテスト付きで作成
```

### Track B: Backend（別ウィンドウでバックグラウンド起動）

```
あなたは Senior-Coder (Track B) です。
メインスレッドを汚さず、このセッション内で作業を完結させてください。

# TASK
spec/my-app_implementation_plan.md の Track B タスクを実装する。

# CONSTRAINTS
- 完了したら「Track B: Complete」と報告
```

---

## 🔍 Step 5: レビューサイクル

**両トラック完了後：**

```
あなたは Review-Guardian です。
projects/my-app/src/ のコードをレビューしてください。

# CHECKLIST
□ セキュリティ脆弱性
□ エラーハンドリング
□ テストカバレッジ

# ACTION
- 問題発見 → 修正を指示
- 問題なし → 「Review Passed」を報告
```

---

## ✅ Step 6: 最終統合

```
すべてのエージェントが完了しました。
最終確認を行ってください。

# VERIFY
1. ビルド成功確認
2. テスト全パス確認
3. 動作確認
```

---

## 📌 クイックリファレンス

| 操作 | 方法 |
|------|------|
| バックグラウンド起動 | `Ctrl+B` |
| 新規セッション | `/clear` |
| プロジェクト作成 | `./scripts/init-project.sh <name>` |

| エージェント | 指示のキーワード |
|--------------|------------------|
| Architect-Plan | 「設計して」「プラン作成」 |
| Senior-Coder | 「実装して」「コード書いて」 |
| Review-Guardian | 「レビューして」「確認して」 |
| Spec-Writer | 「ドキュメント作成」 |

---

## 💡 Tips

1. **コンテキスト保護**: 大きなタスクは必ずサブエージェントに委譲
2. **並列実行**: 独立したタスクは同時に3つ以上起動
3. **完了報告**: 「要約のみ報告」を指示すると効率的

---

*See: [GUILD_REFERENCE.md](./GUILD_REFERENCE.md) | [WORKFLOW_EXAMPLES.md](./WORKFLOW_EXAMPLES.md)*
