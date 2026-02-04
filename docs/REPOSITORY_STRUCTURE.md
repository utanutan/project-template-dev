# Repository Structure - Antigravity Life OS

このドキュメントは `project-template-dev` リポジトリの全ファイル構造と目的を記載したものです。

---

## 目次

1. [リポジトリ概要](#リポジトリ概要)
2. [ディレクトリ構造](#ディレクトリ構造)
3. [ルートディレクトリのファイル](#ルートディレクトリのファイル)
4. [.claude/ - Claude Code設定](#claude---claude-code設定)
5. [scripts/ - 自動化スクリプト](#scripts---自動化スクリプト)
6. [library/ - ナレッジベースとテンプレート](#library---ナレッジベースとテンプレート)
7. [infra/ - インフラストラクチャ](#infra---インフラストラクチャ)
8. [projects/ - プロジェクトワークスペース](#projects---プロジェクトワークスペース)
9. [inbox/ - マルチモーダル受信箱](#inbox---マルチモーダル受信箱)
10. [ワークフローと設計パターン](#ワークフローと設計パターン)

---

## リポジトリ概要

### 目的

このリポジトリは **マルチエージェントAIオーケストレーションプラットフォーム** です。

**主な機能:**
- 14種類の専門エージェントによるプロジェクト自動実行
- PRP (Product Requirement Plan) 駆動の開発ワークフロー
- プロジェクトテンプレートと知見の蓄積システム
- クロスプラットフォーム対応（Bash/PowerShell/Windows）

### コンセプト

```
┌─ PM (Project Manager) ────────────────────┐
│  - 全体オーケストレーション                │
│  - 進捗管理・品質監視                      │
└────────────┬──────────────────────────────┘
             │ 委譲
    ┌────────┼────────┬──────────┐
    ▼        ▼        ▼          ▼
  Architect  Coder   Reviewer    QA
  (設計)    (実装)   (レビュー)  (テスト)
```

---

## ディレクトリ構造

```
project-template-dev/
├── .claude/                    # Claude Code設定・知見
│   ├── rules/                  # ルール・ナレッジベース
│   │   ├── agents/             # エージェント別知見 (17ファイル)
│   │   └── global-learnings.md # グローバル知見
│   ├── skills/                 # カスタムスキル
│   │   └── retro/SKILL.md      # 振り返りスキル
│   ├── settings.json           # 許可リスト (バージョン管理)
│   └── settings.local.json     # ローカル拡張許可
│
├── scripts/                    # 自動化スクリプト (10ファイル)
│   ├── init-project.sh/.bat/.ps1
│   ├── launch-agents.sh/.bat/.ps1
│   ├── subagent-prompt-generator.sh/.ps1
│   ├── claude-tmux.sh
│   └── claude-watcher.sh/.ps1
│
├── library/                    # ナレッジベース・テンプレート
│   ├── config/                 # 設定ファイル
│   ├── dev-templates/          # 開発テンプレート
│   ├── creative-templates/     # クリエイティブテンプレート
│   ├── life-templates/         # ライフプランニング
│   ├── claude-templates/       # Claude設定テンプレート
│   ├── project-templates/      # 再利用可能プロジェクトテンプレート
│   └── docs/                   # ドキュメント・ガイド
│
├── infra/                      # インフラストラクチャ (共有)
│   └── monitoring/             # 中央ログ基盤
│       └── victoria-logs/      # VictoriaLogs サーバー
│
├── projects/                   # プロジェクトワークスペース (.gitignore)
│
├── inbox/                      # マルチモーダル受信箱
│   └── text/                   # テキストメモ
│
├── docs/                       # 本ドキュメント
│
├── CLAUDE.md                   # メイン操作手順
├── QUICKSTART.md               # クイックスタートガイド
├── BLOG_SYSTEM_OVERVIEW.md     # システム概要 (ブログ形式)
├── .project-meta.json          # プロジェクトメタデータ
└── .gitignore                  # Git除外設定
```

---

## ルートディレクトリのファイル

### CLAUDE.md

**目的:** Claude Codeがこのリポジトリで作業する際のメイン操作手順

**主な内容:**
- Context Discovery: `.claude/rules/` の参照方法
- 知見の永続化: 技術的知見の記録方法
- 新規プロジェクト開始手順 (Step 1-6)
- tmuxセッションでのPMエージェント起動方法
- ユーザー確認の監視スクリプト

### QUICKSTART.md

**目的:** 14エージェントシステムの概要と使い方ガイド

**主な内容:**
- 全エージェントの役割定義
- 9フェーズワークフロー
- コマンドラインの使用例
- プリセット（parallel-coders, deploy-team等）

### BLOG_SYSTEM_OVERVIEW.md

**目的:** システム全体のナラティブ解説（ブログ記事形式）

**主な内容:**
- 11エージェントの協調動作の解説
- 機能とアーキテクチャの概要
- ユースケースと利点

### .project-meta.json

**目的:** リポジトリのメタデータ（ダッシュボード連携用）

```json
{
  "name": "project-template-dev",
  "type": "template",
  "pm2_name": null,
  "db_path": null,
  "victoria_logs_query": null,
  "status_file": null,
  "created_at": "2025-01-01",
  "tags": ["template", "infrastructure"],
  "description": "Antigravity Life OS - Project template repository"
}
```

### .gitignore

**目的:** Git除外設定

**主な除外対象:**
- `projects/` - 各プロジェクトは独立リポジトリとして管理
- `*.log` - ログファイル
- `.env` - 環境変数

---

## .claude/ - Claude Code設定

### .claude/settings.json

**目的:** Claude Codeの許可コマンドホワイトリスト（バージョン管理対象）

**許可される操作:**
- PowerShell/Pythonスクリプト実行
- Git操作（add, commit, checkout, merge, pull）
- GitHub CLI (gh)
- Vercel デプロイ
- テストツール（pytest, jest, playwright, eslint, prettier）

### .claude/settings.local.json

**目的:** ローカル環境固有の拡張許可

**追加許可:**
- tmuxセッション管理
- Docker操作
- ファイルシステム操作
- Claude CLI実行
- プロジェクト固有のtmuxランチャー

### .claude/rules/agents/

**目的:** 各エージェントの過去知見を蓄積

| ファイル | 対象エージェント |
|---------|-----------------|
| README.md | 仕組みの説明 |
| TEMPLATE.md | 知見記録テンプレート |
| architect-plan.md | Architect-Plan |
| cicd-deployer.md | CICD-Deployer |
| content-writer.md | Content-Writer |
| designer.md | Designer |
| legal-advisor.md | Legal-Advisor |
| marketing.md | Marketing |
| monetization.md | Monetization-Strategist |
| ops-monitor.md | Ops-Monitor |
| qa-tester.md | QA-Tester |
| requirements-analyst.md | Requirements-Analyst |
| researcher.md | Researcher |
| review-guardian.md | Review-Guardian |
| senior-coder.md | Senior-Coder |
| spec-writer.md | Spec-Writer |
| tech-educator.md | Tech-Educator |

**知見記録フォーマット:**
```markdown
## YYYY-MM-DD: [カテゴリ] タイトル

**指摘内容**: ユーザーからの指摘の要約
**原因分析**: なぜこの問題が発生したか
**改善策**: 今後どうすべきか
**適用条件**: どのような状況でこの知見を適用すべきか
```

### .claude/rules/global-learnings.md

**目的:** 全プロジェクト共通のグローバル知見

**蓄積された知見:**
- SSEストリーミング（FastAPI + Next.js）
- 外部CLIのグレースフルデグレード
- ハイブリッド監視アーキテクチャ
- ログ基盤の中央集約化
- Claude Code Hooks活用パターン
- Slack Interactive Components連携
- Claude Code CLI のsubprocess呼び出し
- uvicornのコード変更反映

### .claude/skills/retro/SKILL.md

**目的:** プロジェクト完了時の振り返りスキル

**使用方法:** `/retro` コマンドで呼び出し

---

## scripts/ - 自動化スクリプト

### init-project.sh / .bat / .ps1

**目的:** 新規プロジェクトの初期化

**使用方法:**
```bash
# 空の開発プロジェクト
./scripts/init-project.sh my-app --type dev

# テンプレートから作成
./scripts/init-project.sh my-app --template user-mgmt

# テンプレート一覧表示
./scripts/init-project.sh --list-templates
```

**作成される構造:**
```
projects/my-app/
├── src/
├── tests/
├── docs/
│   └── PRP.md
├── spec/
├── research/
├── resources/mockups/
├── tracks/
├── CLAUDE.md
├── .claude/
│   ├── rules/
│   │   └── common-practices.md
│   └── skills/
│       └── retro/SKILL.md
└── .project-meta.json
```

### launch-agents.sh / .bat / .ps1

**目的:** エージェントの並列起動

**使用方法:**
```bash
# PMを起動
./scripts/launch-agents.sh my-app

# 特定エージェントを起動
./scripts/launch-agents.sh my-app --agents coder-a,coder-b

# プリセットを使用
./scripts/launch-agents.sh my-app --agents parallel-coders

# 許可スキップ（自動化用）
./scripts/launch-agents.sh my-app --dangerously-skip-permissions
```

**プリセット一覧:**
| プリセット | エージェント |
|-----------|-------------|
| pm | Project Manager |
| parallel-coders | Coder A + Coder B + Reviewer |
| deploy-team | Reviewer + QA + CICD |
| ops-team | QA + CICD + Ops |
| full-team | 全14エージェント |

### subagent-prompt-generator.sh / .ps1

**目的:** agents.jsonからエージェントプロンプトを動的生成

**使用方法:**
```bash
# プロンプト表示
./scripts/subagent-prompt-generator.sh architect-plan

# エージェント一覧
./scripts/subagent-prompt-generator.sh list
```

**生成内容:**
- エージェント名・モデル・役割
- ミッション
- 責務（箇条書き）
- 制約（MUST FOLLOWセクション）
- 禁止ツール
- コマンドチェーン
- 入力・出力定義

### claude-tmux.sh

**目的:** Claude Codeをtmuxセッション内で自動実行

**インストール:**
```bash
sudo ln -sf $(pwd)/scripts/claude-tmux.sh /usr/local/bin/claude-tmux
```

**動作:**
- ディレクトリ名からユニークなセッション名を自動生成
- tmux外から実行：新規セッション作成してアタッチ
- tmux内から実行：直接実行
- tmux未インストール：直接実行にフォールバック

### claude-watcher.sh / .ps1

**目的:** エージェントの許可リクエストを監視

**使用方法:**
```bash
./scripts/claude-watcher.sh <session-name>
```

---

## library/ - ナレッジベースとテンプレート

### library/config/

#### agents.json

**目的:** 14エージェントの完全定義

**定義されるエージェント:**

| エージェント | モデル | 役割 |
|-------------|--------|------|
| Project-Manager | Opus | 全体オーケストレーション |
| Requirements-Analyst | Sonnet | 要件分析 |
| Researcher | Sonnet | 市場・技術調査 |
| Architect-Plan | Opus | 技術設計・タスク分割 |
| Designer | Gemini Pro | UI/UXモックアップ |
| Senior-Coder | Sonnet | 実装 |
| Review-Guardian | Sonnet | コードレビュー・セキュリティ |
| QA-Tester | Sonnet | ブラウザテスト・E2E |
| Spec-Writer | Haiku | 技術ドキュメント |
| Content-Writer | Sonnet | Webコンテンツ作成 |
| Marketing | Sonnet | SEO・マーケティング |
| Monetization-Strategist | Sonnet | 収益戦略 |
| Legal-Advisor | Opus | 利用規約・法務 |
| CICD-Deployer | Sonnet | ビルド・デプロイ |
| Ops-Monitor | Sonnet | 監視・オブザーバビリティ |

**各エージェントのスキーマ:**
```json
{
  "name": "表示名",
  "model": "推奨モデル",
  "role": "主な責任",
  "mission": "高レベルの目的",
  "responsibilities": ["責務1", "責務2"],
  "constraints": ["制約1 (MUST FOLLOW)"],
  "forbiddenTools": ["禁止ツール"],
  "workflow": ["ステップ1", "ステップ2"],
  "receivesInstructionsFrom": ["上位エージェント"],
  "delegatesTo": ["下位エージェント"],
  "inputs": ["入力ファイル"],
  "outputFormat": "出力形式と報告先",
  "learningsFile": "知見ファイルパス"
}
```

#### templates.json

**目的:** プロジェクトテンプレートのレジストリ

**登録テンプレート:**
- `user-mgmt` - Node.js + Express認証テンプレート

#### user_skill_profile.yaml

**目的:** ユーザーのスキルマトリクス（Tech-Educatorが参照）

**スキルレベル:**
- beginner / intermediate / advanced / expert

#### common_settings.env

**目的:** 環境変数テンプレート

```env
ANTHROPIC_API_KEY=[key]
OPENAI_API_KEY=[key]
WORKSPACE_ROOT=/workspace_root
MAX_PARALLEL_AGENTS=3
CONTEXT_THRESHOLD_LINES=1000
DEFAULT_PLANNING_MODEL=claude-opus
DEFAULT_CODING_MODEL=claude-sonnet
```

#### notification.env

**目的:** 通知設定テンプレート

### library/dev-templates/

| ファイル | 目的 |
|---------|------|
| PRP_TEMPLATE.md | Product Requirement Planテンプレート |
| IMPLEMENTATION_PLAN_TEMPLATE.md | Architect出力サンプル |
| CODE_REVIEW_CHECKLIST.md | レビューガイドライン |
| EDUCATION_TEMPLATE.md | 教育コンテンツ構造 |
| DESIGN_SYSTEM_GENERATOR.md | デザインシステム仕様 |
| promtail-config.yml | ログシッパー設定 |
| vercel.json | Vercelデプロイ設定 |
| start-all.sh.template | マルチプロジェクト起動 |

### library/creative-templates/

| ファイル | 目的 |
|---------|------|
| CONTENT_TEMPLATE.md | コンテンツ作成テンプレート |

### library/life-templates/

| ファイル | 目的 |
|---------|------|
| WEEKLY_PLANNER.md | 週次計画テンプレート |

### library/claude-templates/

**目的:** 新規プロジェクトにコピーされるClaude設定

```
claude-templates/
├── CLAUDE.md                    # プロジェクト用操作手順
└── .claude/
    ├── rules/
    │   └── common-practices.md  # 共通プラクティス
    └── skills/
        └── retro/SKILL.md       # 振り返りスキル
```

**common-practices.md の内容:**
- Conventional Commits形式
- テストファースト開発
- エラーハンドリングは境界で
- サブエージェント呼び出しはスクリプト経由
- 進捗追跡必須
- PM → Architect → Coder チェーン
- README/API/Schema ドキュメント標準

### library/project-templates/user-mgmt/

**目的:** ユーザー認証の完全実装テンプレート

```
user-mgmt/
├── TEMPLATE_INFO.md           # テンプレート説明
├── src/                       # 実行可能Express.jsアプリ
│   ├── app.js
│   ├── server.js
│   ├── package.json
│   ├── .env.example
│   ├── config/
│   │   ├── database.js        # SQLite (better-sqlite3)
│   │   └── session.js         # express-session設定
│   ├── middleware/
│   │   └── auth.js            # 認証ミドルウェア
│   ├── models/
│   │   └── user.js            # Userモデル
│   ├── routes/
│   │   ├── auth.js            # /api/auth エンドポイント
│   │   ├── pages.js           # ページルーティング
│   │   └── user.js            # /api/users エンドポイント
│   └── public/
│       ├── pages/             # HTMLテンプレート
│       ├── css/style.css
│       └── js/
│           ├── auth.js
│           └── dashboard.js
├── spec/BASE_REFERENCE/       # 設計ドキュメント
│   ├── architecture.md
│   ├── implementation-plan.md
│   └── google-oauth-plan.md
├── research/BASE_REFERENCE/   # 調査資料
│   ├── tech-stack-analysis.md
│   ├── tech-stack-analysis-v2.md
│   ├── tech-stack-analysis-v3-stripe.md
│   └── google-oauth-analysis.md
└── learning/                  # 技術ガイド
    ├── 01-express-session-auth.md
    ├── 02-sqlite-better-sqlite3.md
    ├── 03-google-oauth-gis.md
    ├── 04-mvc-architecture.md
    └── 05-web-security-basics.md
```

**技術スタック:**
- Runtime: Node.js
- Framework: Express.js
- Database: SQLite (better-sqlite3)
- Authentication: bcrypt + express-session + Google OAuth

### library/docs/

| ファイル | 目的 |
|---------|------|
| PM_ORCHESTRATION.md | PMのワークフロー実行方法 |
| GUILD_REFERENCE.md | エージェント定義表・9フェーズワークフロー |
| DESIGN_WORKFLOW.md | Gemini/Nano Bananaデザイン連携 |
| CLAUDE_CODE_ORCHESTRATION.md | 外部オーケストレーションパターン |
| AGENT_PROMPT_EXAMPLES.md | 5つのプロンプトパターン |
| PM_REMOTE_WORKFLOW.md | リモートワークフロー |
| USER_INTERACTION_FLOW.md | ユーザーインタラクション |
| WORKFLOW_EXAMPLES.md | ワークフロー例 |

---

## infra/ - インフラストラクチャ

### infra/monitoring/victoria-logs/

**目的:** 全プロジェクト共通のログ集約基盤

```
victoria-logs/
├── start.sh           # 起動・停止・ステータススクリプト
├── victoria-logs-prod # バイナリ
├── vlogs-data/        # ログストレージ（永続化）
├── vlogs.pid          # プロセスID
└── vlogs.log          # サーバーログ
```

**コマンド:**
```bash
./start.sh start    # 起動 (port 9428)
./start.sh stop     # 停止
./start.sh status   # ステータス確認
./start.sh restart  # 再起動
```

**エンドポイント:**
- Web UI: `http://localhost:9428`
- Loki Push API: `http://localhost:9428/insert/loki/api/v1/push`
- Query API: `http://localhost:9428/select/logsql/query`

**設計意図:**
- プロジェクト外で中央管理（プロジェクト削除時にログ消失防止）
- ログ基盤のライフサイクルはプロジェクトより長い
- 複数プロジェクトからの集約が容易

---

## projects/ - プロジェクトワークスペース

**目的:** 実際のプロジェクトを作成・実行する場所

**特徴:**
- `.gitignore` で除外（親リポジトリに含まれない）
- 各プロジェクトは独立したGitリポジトリとして管理
- `init-project.sh` で自動作成

**プロジェクト作成後の流れ:**
1. `init-project.sh` でプロジェクト作成
2. `docs/PRP.md` に要件記載
3. `git init` で独立リポジトリ化
4. tmuxでPMエージェント起動
5. 完了後 `gh repo create` でGitHubにプッシュ

---

## inbox/ - マルチモーダル受信箱

**目的:** アイデアやメモの一時保存場所

```
inbox/
└── text/
    └── sample_idea_memo.md  # サンプルメモ
```

---

## ワークフローと設計パターン

### 9フェーズワークフロー

```
Phase 0: Requirements Analysis    → Requirements-Analyst
Phase 1: Research & Competitive   → Researcher
Phase 2: Design & Mockups         → Designer
Phase 3: Technical Design         → Architect-Plan
Phase 4: Frontend Implementation  → Senior-Coder (Track A)
Phase 5: Backend Implementation   → Senior-Coder (Track B)
Phase 6: Code Review              → Review-Guardian
Phase 7: QA & Testing             → QA-Tester
Phase 8: Documentation & Marketing→ Content-Writer, Marketing
Phase 9: Integration & Deployment → CICD-Deployer
```

### 委譲チェーン

**重要ルール:** PMは直接Senior-Coderに指示しない

```
PM → Architect-Plan → Senior-Coder
     (設計・タスク分割)   (実装)
```

### マルチエージェントオーケストレーション

```
┌─ Main Thread (PM) ─────────────────────┐
│  - コンテキスト保護 (200kトークン)      │
│  - オーケストレーション・進捗管理       │
└────────────┬─────────────────────────────┘
             │
    ┌────────┼────────┬──────────┐
    ▼        ▼        ▼          ▼
  Coder-A  Coder-B  Reviewer    QA
  (並列バックグラウンド実行)
```

**利点:**
- トークン効率（サブエージェントは独自コンテキスト）
- 並列実行（3+エージェント同時）
- 専門化（各エージェントは役割に最適化）
- コンテキスト分離（メインスレッド保護）

### 知見永続化システム

```
レベル                    ファイルパス
─────────────────────────────────────────────
プロジェクト固有          .claude/rules/<topic>.md
グローバル共通            .claude/rules/global-learnings.md
エージェント固有          .claude/rules/agents/<agent>.md
```

**フィードバックループ:**
1. ユーザーから指摘・修正指示
2. PMが該当エージェントにフィードバック伝達
3. エージェントが知見を自分のファイルに追記
4. 次回プロジェクトで起動時に参照

---

## クロスプラットフォーム対応

| スクリプト | Bash | PowerShell | Batch |
|-----------|------|------------|-------|
| init-project | .sh | .ps1 | .bat |
| launch-agents | .sh | .ps1 | .bat |
| subagent-prompt-generator | .sh | .ps1 | - |
| claude-watcher | .sh | .ps1 | - |
| claude-tmux | .sh | - | - |

---

## アーキテクチャ上の決定事項

1. **テンプレートリポジトリパターン**: プロジェクトは独立Gitリポジトリ（サブモジュールではない）
2. **中央集約監視**: ログ基盤は `infra/` に配置（プロジェクト削除に耐える）
3. **動的プロンプト生成**: agents.jsonが真実の源、プロンプトは実行時生成
4. **許可ホワイトリスト**: settings.jsonでClaude Codeの実行可能コマンドを制限
5. **スキルベース説明**: ユーザープロファイルでエージェントの説明深度を調整
6. **二層知見**: プロジェクト固有 + グローバル知見の蓄積
7. **マルチエージェント分離**: サブエージェントは独立コンテキストウィンドウ
8. **制約伝播**: エージェント制約は設定にエンコード、プロンプトで強制

---

## 更新履歴

- 2026-02-04: 初版作成
