# Antigravity Life OS - Claude Code Configuration

このプロジェクトはマルチエージェント・オーケストレーション（20エージェント構成）を採用。

---

## オーケストレーション方式

PMエージェント起動時に、以下の2方式からオーケストレーション方式を選択する。

### 方式比較表

| | Mode A: Agent Teams (spawn) | Mode B: Task Subagents |
|---|---|---|
| 起動方法 | `claude --agent project-manager`（対話モード） | `claude --dangerously-skip-permissions` + PMプロンプト |
| 実行形態 | TeamCreate → teammate spawn（各独立インスタンス） | Task tool (subagent_type) で子エージェント起動 |
| 通信 | teammate間で直接メッセージ可能 | 親に結果を返すのみ（一方向） |
| 可視性 | tmux paneで各teammate表示 | TUI内で不可視 |
| タスク管理 | 共有タスクリスト（メイン）+ tracks/PROGRESS.md（補助） | tracks/PROGRESS.md（メイン） |
| 監視 | paneクリックで直接操作可 | capture-pane不可 |
| コスト | 高い（各teammateが独立インスタンス） | 低い（1セッション内で完結） |
| 適用場面 | 大規模・長時間・複数人監視が必要な場合 | 小〜中規模・コスト重視・自動実行の場合 |

### Mode A: Agent Teams — 起動方法

```bash
tmux new-session -s <session-name> -c <project-dir>
# tmux内で実行:
claude --agent project-manager
# TUI内でプロンプトを入力
```

### Mode B: Task Subagents — 起動方法

```bash
tmux new-session -d -s <session-name> -n pm \
  -c <project-dir> \
  "claude --dangerously-skip-permissions 'あなたは Project-Manager です。docs/PRP.md を読み、プロジェクトを完遂してください。'; exec bash"
```

---

## 指揮系統

### Mode A: Agent Teams

```
PM (統括) ─── Agent Teams で各teammateをtmux paneとしてspawn
   │
   ├→ requirements-analyst (teammate) → docs/requirements.md
   ├→ researcher (teammate)           → research/
   ├→ designer (teammate)             → resources/mockups/
   ├→ architect-plan (teammate)       → spec/implementation_plan.md
   ├→ senior-coder (teammate)         → src/
   ├→ review-guardian (teammate)      → review_report.md
   ├→ qa-tester (teammate)            → tests/e2e/
   ├→ cicd-deployer (teammate)        → docs/deployment.md
   ├→ ops-monitor (teammate)          → monitoring/
   ├→ content-writer (teammate)       → src/content/
   ├→ marketing (teammate)            → docs/marketing_strategy.md
   ├→ monetization (teammate)         → docs/monetization_plan.md
   ├→ legal-advisor (teammate)        → docs/legal_compliance.md
   ├→ spec-writer (teammate)          → docs/
   ├→ tech-educator (teammate)        → docs/tutorials/
   ├→ gemini-advisor (teammate)       → docs/gemini_review.md, resources/images/
   ├→ grok-analyst (teammate)         → research/trends/, research/sentiment/
   ├→ perplexity-researcher (teammate)→ research/facts/, research/industry/
   └→ obsidian-librarian (teammate)   → Vaultノート
```

### Mode B: Task Subagents

```
PM (統括) ─── Task tool で各エージェントを起動
   │
   ├→ requirements-analyst (subagent) → docs/requirements.md
   ├→ researcher (subagent)           → research/
   ├→ architect-plan (subagent)       → spec/implementation_plan.md
   │     └→ senior-coder (subagent)   → src/  ← Architect が起動可能
   ├→ senior-coder (subagent)         → src/
   ├→ review-guardian (subagent)      → review_report.md
   ├→ qa-tester (subagent)            → tests/
   ├→ cicd-deployer (subagent)        → docs/deployment.md
   └→ ... (他のエージェントも同様)
```

---

## Agent Team

| Role | Mission | Agent Key |
|------|---------|-----------|
| **Project-Manager** | 統括・進行管理 | `project-manager` |
| **Requirements-Analyst** | 要件分析 | `requirements-analyst` |
| **Architect-Plan** | 技術設計・タスク分割 | `architect-plan` |
| **Senior-Coder** | 実装 | `senior-coder` |
| **Review-Guardian** | レビュー | `review-guardian` |
| **QA-Tester** | ブラウザテスト・E2E | `qa-tester` |
| **Designer** | UIデザイン | `designer` |
| **Researcher** | 調査・分析 | `researcher` |
| **Spec-Writer** | 技術ドキュメント | `spec-writer` |
| **Content-Writer** | コンテンツ | `content-writer` |
| **Marketing** | SEO/マーケ | `marketing` |
| **Monetization** | 収益化戦略 | `monetization` |
| **Legal-Advisor** | 法務 | `legal-advisor` |
| **CICD-Deployer** | CI/CD | `cicd-deployer` |
| **Ops-Monitor** | 監視 | `ops-monitor` |
| **Tech-Educator** | 教育 | `tech-educator` |
| **Gemini-Advisor** | クロスモデルレビュー・画像生成 | `gemini-advisor` |
| **Grok-Analyst** | X/Twitterトレンド・センチメント分析 | `grok-analyst` |
| **Perplexity-Researcher** | 引用付きファクトチェック・業界調査 | `perplexity-researcher` |
| **Obsidian-Librarian** | Vault知識管理・過去知見連携 | `obsidian-librarian` |

---

## Project Structure

```
.claude/agents/             # エージェント定義（公式形式 *.md）
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

## 進捗管理ルール

### Mode A: Agent Teams

Agent Teamsの**共有タスクリスト**（Claude Code内蔵）をメインの進捗管理に使用する。
`tracks/PROGRESS.md` は補助的な記録・レポート用として併用する。

| 管理方式 | 用途 |
|---------|------|
| **共有タスクリスト**（メイン） | リアルタイムのタスク管理・依存関係・ステータス追跡 |
| **tracks/PROGRESS.md**（補助） | マイルストーン記録・ユーザーへの進捗レポート |

### Mode B: Task Subagents

`tracks/PROGRESS.md` をメインの進捗管理に使用する。

| 管理方式 | 用途 |
|---------|------|
| **tracks/PROGRESS.md**（メイン） | タスク管理・ステータス追跡・進捗レポート |

### 共通: 進捗管理の責任分担

| エージェント | 責任 |
|-------------|------|
| **Project-Manager** | 全体の進捗管理・`tracks/PROGRESS.md` の更新 |
| **Senior-Coder** | 担当タスクのステータス更新 |
| **Review-Guardian** | レビュー結果の反映 |
| **QA-Tester** | テスト結果の反映 |

### ステータス一覧

| ステータス | 意味 |
|-----------|------|
| 待機 | 未着手 |
| 進行中 | 作業中 |
| 完了 | 完了 |
| 差し戻し | レビューで差し戻し |
| ブロック | 依存関係でブロック中 |

### 更新ルール

1. **タスク開始時** - ステータスを「進行中」に変更
2. **タスク完了時** - ステータスを「完了」に変更
3. **差し戻し/ブロック時** - ステータスを「差し戻し」または「ブロック」に変更
4. **マイルストーン達成時** - `tracks/PROGRESS.md` にサマリーを記録

---

## 知見管理ルール

### 二層知見管理

| レイヤー | パス | 管理方法 |
|---------|------|---------|
| 自動学習（公式） | `.claude/agent-memory/<name>/MEMORY.md` | `memory: project` による自動管理 |
| Git管理知見（メインリポジトリ） | `../../.claude/learnings/<key>.md` | メインリポジトリで一元管理の永続知見 |

### 知見の参照・更新

- セッション開始時に `../../.claude/learnings/` 配下の自分の知見ファイルを読み、過去の学びを適用する
- プロジェクト中に得た技術的知見は `../../.claude/learnings/<key>.md` に記録する
- 子プロジェクトは `projects/<name>/` に作成されるため、`../../` でメインリポジトリのルートに到達する

---

## References

- [.claude/agents/](.claude/agents/) - 全エージェント定義（公式形式）
