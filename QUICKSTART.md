# Antigravity Life OS - クイックスタートガイド

12エージェント構成のマルチエージェントシステム。
**PMエージェントを起動するだけで、サブエージェントが自動的に呼び出され、必要に応じて並列実行されます。**

---

## 基本の使い方

### Step 1: プロジェクト作成

```bash
./projects/scripts/init-project.sh my-app --type dev
cd projects/my-app
```

### Step 2: PRP作成

`docs/PRP.md` に要件を記載

### Step 3: PMエージェントを起動

プロジェクトディレクトリで Claude Code を起動し、以下のプロンプトを入力：

```
あなたは Project-Manager です。
docs/PRP.md を読み、プロジェクトを完遂してください。
```

**これだけでOKです。** PMが自動的に：
1. PRPを分析
2. 必要なサブエージェントを順次/並列で起動
3. 各フェーズの進行を管理
4. 最終統合まで実行

---

## PMの起動方法

### 方法1: Claude Code CLI（推奨）

```bash
# プロジェクトディレクトリに移動
cd projects/my-app

# Claude Codeを起動
claude

# プロンプトを入力
> あなたは Project-Manager です。docs/PRP.md を読み、プロジェクトを完遂してください。
```

### 方法2: ワンライナー起動

```bash
cd projects/my-app && claude "あなたは Project-Manager です。docs/PRP.md を読み、プロジェクトを完遂してください。"
```

### 方法3: launch-agents.sh 使用

```bash
./projects/scripts/launch-agents.sh my-app --agents pm
```

---

## 自動実行されるワークフロー

PMが起動すると、以下のフェーズが自動的に実行されます：

```
Phase 0: Requirements-Analyst  → 要件明確化
Phase 1: Researcher           → 調査・競合分析
Phase 2: Architect-Plan       → 技術設計・タスク分割
Phase 3: Designer             → UIモックアップ生成
Phase 4: Senior-Coder         → 実装（並列実行可能）
Phase 5: Review-Guardian      → コードレビュー
Phase 6: QA-Tester            → ブラウザテスト・E2E
Phase 7: Marketing            → SEO最適化
Phase 8: Integration          → 最終統合
```

### 並列実行

PMは独立したタスクを検出すると、複数のサブエージェントを**並列起動**します：

- **Research & Design**: Researcher と Designer を並列実行
- **Implementation**: 複数の Senior-Coder を Track A/B/C で並列実行
- **Content & Marketing**: Content-Writer と Marketing を並列実行

---

## 委譲構造

```
PM (Project-Manager)
├── Requirements-Analyst
├── Researcher ─────────────→ Architect-Plan に報告
├── Architect-Plan ─────────→ Senior-Coder に実装指示（委譲）
├── Designer ───────────────→ Architect-Plan に報告
├── Review-Guardian
├── QA-Tester
├── Spec-Writer
├── Content-Writer
└── Marketing
```

**重要**: PMは Senior-Coder に直接指示しません。実装タスクは Architect-Plan が設計・分割し、Senior-Coder に委譲します。

---

## 高度な使い方（オプション）

### 手動で並列エージェント起動

別ターミナルでエージェントを直接起動する場合：

```bash
# 並列コーダー起動（Track A, B + Reviewer）
./projects/scripts/launch-agents.sh my-app --agents parallel-coders

# 全エージェント起動
./projects/scripts/launch-agents.sh my-app --agents full-team

# 個別指定
./projects/scripts/launch-agents.sh my-app --agents coder-a,coder-b,reviewer
```

### プロンプト生成スクリプト

`agents.json` から動的にサブエージェント用プロンプトを生成：

```bash
# 特定エージェントのプロンプト表示
./projects/scripts/subagent-prompt-generator.sh architect-plan

# 利用可能なエージェント一覧
./projects/scripts/subagent-prompt-generator.sh list
```

---

## エージェント一覧（12名）

| Agent | Model | 役割 |
|-------|-------|------|
| Project-Manager | Opus | 統括・オーケストレーション |
| Requirements-Analyst | Sonnet | 要件分析・質問作成 |
| Researcher | Sonnet | 市場調査・競合分析 |
| Architect-Plan | Opus | 技術設計・タスク分割 |
| Designer | Gemini Pro | UIモックアップ・デザインシステム |
| Senior-Coder | Sonnet | 実装・テスト作成 |
| Review-Guardian | Sonnet | コードレビュー・セキュリティ |
| QA-Tester | Sonnet | ブラウザテスト・E2E |
| Spec-Writer | Haiku | 技術ドキュメント |
| Content-Writer | Sonnet | Webコンテンツ |
| Marketing | Sonnet | SEO・マーケティング |

---

## クイックリファレンス

| 操作 | コマンド |
|------|----------|
| プロジェクト作成 | `./projects/scripts/init-project.sh <name>` |
| PM起動 | `claude` → PMプロンプト入力 |
| 並列エージェント起動 | `./projects/scripts/launch-agents.sh <name> --agents <agents>` |
| プロンプト生成 | `./projects/scripts/subagent-prompt-generator.sh <agent>` |

### プリセット

| Preset | 内容 |
|--------|------|
| `parallel-coders` | coder-a, coder-b, reviewer, qa-tester |
| `test-team` | coder-a, reviewer, qa-tester |
| `full-team` | 全エージェント（12名） |

---

*See: [GUILD_REFERENCE](library/docs/GUILD_REFERENCE.md) | [PM_ORCHESTRATION](library/docs/PM_ORCHESTRATION.md)*
