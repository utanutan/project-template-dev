# Antigravity Life OS - Claude Code Configuration

このプロジェクトはマルチエージェント・オーケストレーション（12エージェント構成）を採用。

---

## 🔑 サブエージェント起動方法（重要）

### PM がサブエージェントを起動する際の手順

### PM がサブエージェントを起動する際の手順

1. **プロンプト生成スクリプトを実行**して、完全な制約付きプロンプトを取得する:

   ```bash
   ./scripts/subagent-prompt-generator.sh architect-plan
   ```

2. **出力されたプロンプト**をそのままコピーし、サブエージェントへの指示として使用する。
   - `agents.json` の全フィールド（制約、責務、禁止ツール、Workflow）が含まれているため、確実にルールが適用されます。

3. **起動例** (PM → Architect):

   ```
   (上記スクリプトの出力をペースト)
   ```

---

## 指揮系統

```
PM (統括) ────────────────────────────────────────────┐
   │                                                  │
   ├→ Researcher (調査) → research/                   │
   │                                                  │
   ├→ Architect-Plan (設計) → spec/                   │
   │      │                                           │
   │      └→ Senior-Coder (実装) → src/               │
   │            │                                     │
   │            └→ Review-Guardian (レビュー)         │
   │                                                  │
   ├→ Designer (デザイン) → resources/mockups/        │
   │                                                  │
   └→ Marketing (最適化) → docs/marketing_strategy.md │
                                                      │
最終統合 ←────────────────────────────────────────────┘
```

**重要**: PM は Coder に直接指示しない。必ず Architect 経由。

---

## Agent Team

| Role | Mission | agents.json key |
|------|---------|-----------------|
| **Project-Manager** | 統括・進行管理 | `project-manager` |
| **Architect-Plan** | 技術設計・タスク分割 | `architect-plan` |
| **Senior-Coder** | 実装 | `senior-coder` |
| **Review-Guardian** | レビュー | `review-guardian` |
| **Designer** | UIデザイン | `designer` |
| **Researcher** | 調査・分析 | `researcher` |
| **Marketing** | SEO/マーケ | `marketing` |

---

## Project Structure

```
library/config/agents.json  # エージェント定義（必読）
docs/PRP.md                 # 要件
docs/requirements.md        # 詳細要件
spec/                       # 実装プラン（読み取り専用）
tracks/                     # 進捗管理（開発エージェント必読・更新）
  └── PROGRESS.md           # タスク進捗一覧
research/                   # 調査結果
resources/mockups/          # デザインモックアップ
src/                        # ソースコード
```

---

## 📊 進捗管理ルール

### 進捗管理の責任分担

| エージェント | 責任 |
|-------------|------|
| **Project-Manager** | `tracks/PROGRESS.md` の初期化・進捗報告 |
| **Senior-Coder** | タスク開始/完了時にステータス更新 |
| **Review-Guardian** | レビュー結果の反映 |
| **QA-Tester** | テスト結果の反映 |

### ステータス一覧

| ステータス | 意味 |
|-----------|------|
| ⏳ 待機 | 未着手 |
| 🔄 進行中 | 作業中 |
| ✅ 完了 | 完了 |
| 🔙 差し戻し | レビューで差し戻し |
| ⛔ ブロック | 依存関係でブロック中 |

### 更新ルール

1. **タスク開始時**
   - `tracks/PROGRESS.md` のステータスを `🔄 進行中` に変更
   - 開始日と担当エージェント名を記入

2. **タスク完了時**
   - ステータスを `✅ 完了` に変更
   - 完了日を記入

3. **差し戻し/ブロック時**
   - ステータスを `🔙 差し戻し` または `⛔ ブロック` に変更

---

## References

- [agents.json](../../library/config/agents.json) - 全エージェント定義
- [subagent-prompt-generator.sh](../../scripts/subagent-prompt-generator.sh) - プロンプト生成
