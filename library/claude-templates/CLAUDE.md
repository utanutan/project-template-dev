# Antigravity Life OS - Claude Code Configuration

このプロジェクトはマルチエージェント・オーケストレーション（20エージェント構成）を採用。

---

## Agent Teams によるオーケストレーション（重要）

### Agent Teams（推奨）

PMが **Agent Teams** 機能を使い、各teammateを独立したtmux paneとしてスポーンする:

```
# 自然言語でteammateをspawn
エージェントチームを作成してください:
- requirements-analyst: docs/PRP.mdを分析し要件を明確化
- researcher: 競合分析と技術調査
- architect-plan: 技術設計とタスク分割
```

- 各teammateが独立したClaude Codeインスタンスとして動作
- teammate間で直接メッセージ可能
- tmux paneで各teammateの状態を直接確認・操作
- 共有タスクリストで進捗を自動管理
- Shift+Tab でPMをdelegate mode（調整専任）に切り替え可能

### 起動方法

**対話モード（推奨）** — tmuxセッション内で対話的に操作:
```bash
tmux new-session -s <session-name> -c <project-dir>
# tmux内で実行:
claude --agent project-manager --teammate-mode tmux
# TUI内でプロンプトを入力
```

**自動モード（放置運用）** — `-p` + `--dangerously-skip-permissions` で自動実行:
```bash
claude --agent project-manager --teammate-mode tmux --dangerously-skip-permissions -p \
  'docs/PRP.md を読み、プロジェクトを完遂してください。' 2>&1 | tee agent-pm.log
```

**注意**: `--teammate-mode tmux` は実験的フラグ（`--help` に表示されない、v2.1.34で動作確認済み）。
`~/.claude/settings.json` に `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` の設定が必要。

### プロンプト生成スクリプト（手動起動用・レガシー）

```bash
# 特定エージェントのプロンプト表示
./scripts/subagent-prompt-generator.sh architect-plan

# エージェント一覧
./scripts/subagent-prompt-generator.sh list
```

---

## 指揮系統（Agent Teams）

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

**Agent Teamsの特徴**:
- 各teammateが独立したClaude Codeインスタンス
- teammate間で直接メッセージが可能（PMを経由しなくてもよい）
- PMはdelegate modeでオーケストレーションに専念可能
- ファイル競合を避けるため、各teammateの出力先を明確に分離すること

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

### 進捗管理方式（Agent Teams）

Agent Teamsの**共有タスクリスト**（Claude Code内蔵）をメインの進捗管理に使用する。
`tracks/PROGRESS.md` は補助的な記録・レポート用として併用する。

| 管理方式 | 用途 |
|---------|------|
| **共有タスクリスト**（メイン） | リアルタイムのタスク管理・依存関係・ステータス追跡 |
| **tracks/PROGRESS.md**（補助） | マイルストーン記録・ユーザーへの進捗レポート |

### 進捗管理の責任分担

| エージェント | 責任 |
|-------------|------|
| **Project-Manager** | 共有タスクリストの管理・`tracks/PROGRESS.md` の更新 |
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

1. **タスク開始時** - 共有タスクリストでステータスを「進行中」に変更
2. **タスク完了時** - 共有タスクリストでステータスを「完了」に変更
3. **差し戻し/ブロック時** - ステータスを「差し戻し」または「ブロック」に変更
4. **マイルストーン達成時** - `tracks/PROGRESS.md` にサマリーを記録

---

## 知見管理ルール

### 二層知見管理

| レイヤー | パス | 管理方法 |
|---------|------|---------|
| 自動学習（公式） | `.claude/agent-memory/<name>/MEMORY.md` | `memory: project` による自動管理 |
| Git管理知見 | `.claude/rules/agents/<key>.md` | 手動管理の永続知見 |

### `.claude/rules/` の参照・更新

- セッション開始時に `.claude/rules/` 配下のファイルを読み、過去の知見を適用する
- プロジェクト中に得た技術的知見は `.claude/rules/` に記録する

---

## References

- [.claude/agents/](.claude/agents/) - 全エージェント定義（公式形式）
- [subagent-prompt-generator.sh](scripts/subagent-prompt-generator.sh) - プロンプト生成（レガシー）
