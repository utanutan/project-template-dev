# Antigravity Life OS - システム全体解説

**Claude Codeを活用した11エージェント構成のマルチエージェント・オーケストレーション・プラットフォーム**

---

## 目次

1. [プロジェクト概要](#1-プロジェクト概要)
2. [システムの特徴・すごいところ](#2-システムの特徴すごいところ)
3. [技術アーキテクチャ](#3-技術アーキテクチャ)
4. [11エージェント構成](#4-11エージェント構成)
5. [ワークフロー詳細](#5-ワークフロー詳細)
6. [ディレクトリ構造](#6-ディレクトリ構造)
7. [開発の経緯とGitログ分析](#7-開発の経緯とgitログ分析)
8. [うまくいかなかったこと・課題](#8-うまくいかなかったこと課題)
9. [今後の展望](#9-今後の展望)
10. [使い方クイックスタート](#10-使い方クイックスタート)

---

## 1. プロジェクト概要

### 1.1 What is Antigravity Life OS?

「Antigravity Life OS」は、Claude Codeを基盤としたマルチエージェント・オーケストレーション・プラットフォームです。ソフトウェア開発だけでなく、執筆、学習、生活管理など、ユーザーの**あらゆる活動を11個の特化型AIエージェント**が協調して支援するシステムです。

### 1.2 なぜ作ったのか（背景）

従来のAIアシスタントには以下の課題がありました：

- **単一スレッドの限界**: 1つのAIが全てを処理しようとすると、コンテキストウィンドウが溢れて品質が低下
- **指示待ちの受動性**: ユーザーが全てを指示しないと動かない
- **専門性の欠如**: 汎用AIは器用貧乏になりがち

これらを解決するため、**役割特化型のエージェント群**を**オーケストレーター（指揮者）**が束ねる構造を設計しました。

### 1.3 コアミッション

1. **Life & Workの統合支援**: 開発、執筆、計画、生活管理を単一システムで管理
2. **有機的な提案機能**: ユーザーのメモから自律的に価値あるアウトプットを提案
3. **コンテキストフリーな基盤**: 場所や職種に依存しない汎用的なテンプレート体系

---

## 2. システムの特徴・すごいところ

### 2.1 並列マルチエージェント・オーケストレーション

```
┌─────────────────────────────────────────────────────────────┐
│                    Main Thread (PM)                         │
│            コンテキスト保護 & 全体統括                        │
└─────────────────────────────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        ▼                   ▼                   ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Coder-A    │     │  Coder-B    │     │  Reviewer   │
│ (Frontend)  │     │ (Backend)   │     │ (Quality)   │
│ Background  │     │ Background  │     │ Background  │
└─────────────┘     └─────────────┘     └─────────────┘
```

**最大の強み**: 複数のサブエージェントがバックグラウンドで**並列実行**され、メインスレッドのコンテキストウィンドウを保護します。

- メインスレッドは**200,000トークン**の制限がある
- サブエージェントはそれぞれ独自のコンテキストを持つ
- 完了報告のみをメインに返すことで、トークン消費を最小化

### 2.2 "Ralph Wiggum" Loop（粘り強さは洗練に勝る）

YouTubeで紹介されていた「Ralph Wiggum」アプローチを採用：

> "Persistence beats sophistication"（粘り強さは洗練に勝る）

- 単発の指示ではなく、「完了条件（"DONE"）」が満たされるまで試行錯誤を繰り返す
- PRP（Product Requirement Plan）を厳密に定義してからループに入ることで、「Vibe Coding」の低品質化を防止

### 2.3 PRP（Product Requirement Plan）駆動開発

全てのプロジェクトは `docs/PRP.md` から始まる：

```markdown
# Product Requirement Plan

## 1. 概要
- プロジェクト名
- 目的
- ターゲットユーザー

## 2. 機能要件
- 必須機能
- オプション機能

## 3. 非機能要件
- パフォーマンス
- セキュリティ
```

PMがPRPを読み込み → 各エージェントを順序立てて呼び出し → 自律的に完成まで導く

### 2.4 3モード対応

| モード | 用途 | テンプレート |
|--------|------|--------------|
| **dev** | ソフトウェア開発 | PRP、実装プラン、コードレビューチェックリスト |
| **creative** | 執筆・コンテンツ制作 | コンテンツテンプレート |
| **life** | 生活管理・計画 | 週間プランナー |

```bash
./scripts/init-project.sh my-blog --type creative
./scripts/init-project.sh weekly-plan --type life
```

### 2.5 マルチプラットフォーム対応

- **macOS / Linux**: Bash スクリプト（`*.sh`）
- **Windows**: PowerShell（`*.ps1`）+ Batch（`*.bat`）

### 2.6 ワンコマンド・プロジェクト初期化

```bash
./scripts/init-project.sh my-app --type dev
```

これだけで以下の構造が自動生成：

```
projects/my-app/
├── CLAUDE.md          # エージェント設定
├── README.md
├── docs/
│   └── PRP.md         # 要件定義テンプレート
├── spec/              # 実装プラン
├── research/          # 調査結果
├── resources/
│   └── mockups/       # デザイン
├── src/
├── tests/
└── tracks/            # 並列実行トラック
```

### 2.7 サブエージェントによるコンテキスト節約

実験結果（YouTubeチュートリアルより）：

| 手法 | 最終コンテキスト使用率 |
|------|------------------------|
| メインエージェントのみ | 約60% |
| サブエージェント活用 | 約26% |

**2倍以上の効率化**を実現。

---

## 3. 技術アーキテクチャ

### 3.1 2層アーキテクチャ

```
┌────────────────────────────────────────────────────────────┐
│                   計画・指揮層 (Planning)                    │
│   Main Thread / Orchestrator / Project Manager             │
│   - 高レベルな計画策定                                       │
│   - タスク分割                                              │
│   - 全体進行管理                                            │
└────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌────────────────────────────────────────────────────────────┐
│                    実行層 (Execution)                       │
│   Sub-Agents / Executors                                   │
│   - 具体的なタスク実行                                       │
│   - コーディング、テスト                                     │
│   - 並列実行 & コンテキスト分離                              │
└────────────────────────────────────────────────────────────┘
```

### 3.2 制約事項（Constraints）

1. **コンテキスト節約**: 1,000行超過の調査は必ずサブエージェントに委譲
2. **並列性の活用**: 独立した作業は最低3つ以上のエージェントを同時稼働
3. **自律性**: 各エージェントは自己判断で問題解決を完結

---

## 4. 11エージェント構成

### 4.1 エージェント一覧

| # | Agent | Model | 役割 | 出力先 |
|---|-------|-------|------|--------|
| 1 | **Project-Manager** | Claude Opus | 全体統括・進行管理 | `docs/project_status.md` |
| 2 | **Requirements-Analyst** | Claude Sonnet | 要件分析・明確化 | `docs/requirements.md` |
| 3 | **Researcher** | Claude Sonnet | 市場調査・競合分析 | `research/` |
| 4 | **Architect-Plan** | Claude Opus | 技術設計・構造設計 | `spec/implementation_plan.md` |
| 5 | **Designer** | Gemini Pro | UIデザイン（Nano Banana連携） | `resources/mockups/` |
| 6 | **Senior-Coder** | Claude Sonnet | 実装・テスト作成 | `src/` |
| 7 | **Review-Guardian** | Claude Sonnet | コードレビュー・品質保証 | `review_report.md` |
| 8 | **QA-Tester** | Claude Sonnet | ブラウザテスト・E2E | `tests/e2e/` |
| 9 | **Spec-Writer** | Claude Haiku | 技術ドキュメント | `docs/api/` |
| 10 | **Content-Writer** | Claude Sonnet | コンテンツ執筆 | `src/content/` |
| 11 | **Marketing** | Claude Sonnet | SEO最適化・マーケティング | `docs/marketing_strategy.md` |

### 4.2 モデル選定の根拠

| モデル | 用途 | 理由 |
|--------|------|------|
| **Claude Opus** | 計画・設計 | 高度な推論能力が必要 |
| **Claude Sonnet** | 実装・レビュー | バランスの良い性能とコスト |
| **Claude Haiku** | ドキュメント生成 | 高速・低コストで十分 |
| **Gemini Pro** | デザイン | 画像生成との連携（Nano Banana） |

### 4.3 エージェント設定ファイル構造

`library/config/agents.json`:

```json
{
  "agents": {
    "project-manager": {
      "name": "Project Manager",
      "model": "claude-opus",
      "role": "Orchestrator",
      "mission": "全プロジェクトの統括と進行管理",
      "responsibilities": [
        "PRPの読み込みと解釈",
        "エージェントの適切な呼び出し",
        "進捗の追跡と報告"
      ],
      "constraints": [
        "自らコードを書かない",
        "各エージェントの専門性を尊重する"
      ]
    }
  },
  "orchestration": {
    "parallelExecution": {
      "enabled": true,
      "maxConcurrentAgents": 3
    }
  }
}
```

---

## 5. ワークフロー詳細

### 5.1 標準ワークフロー（7フェーズ）

```
Phase 0: Research        → Researcher         (市場・競合調査)
Phase 1: Requirements    → Requirements-Analyst (要件明確化)
Phase 2: Planning        → Architect-Plan     (技術設計)
Phase 3: Design          → Designer           (UIモックアップ)
Phase 4: Implementation  → Senior-Coder       (並列実装)
Phase 5: Review          → Review-Guardian    (品質検証)
Phase 6: Marketing       → Marketing          (SEO最適化)
```

### 5.2 PM オーケストレーション・プロンプト

```
あなたは Project-Manager です。
docs/PRP.md を読み、以下のフェーズを順番に実行してください：

1. RA: 要件明確化
2. Researcher: 市場調査
3. Architect-Plan: 技術設計
4. Designer: モックアップ作成
5. Senior-Coder: 並列実装（Track A/B）
6. Review-Guardian: コードレビュー
7. Content-Writer: コンテンツ作成
8. Marketing: SEO最適化

各フェーズはサブエージェントをバックグラウンド（Ctrl+B）で起動し、
メインスレッドのコンテキストを保護してください。
```

### 5.3 並列実行戦略

```
┌─────────────────────────────────────────────────────────────┐
│                    Track Configuration                       │
├─────────────────────────────────────────────────────────────┤
│  Track A: Frontend (Coder-A)                                │
│  Track B: Backend (Coder-B)                                 │
│  Track C: Review (Guardian) - 並列監視                       │
│  Track D: QA (QA-Tester) - 並列テスト                        │
└─────────────────────────────────────────────────────────────┘
```

**並列起動コマンド**:

```bash
./scripts/launch-agents.sh my-app --agents parallel-coders
# → coder-a, coder-b, reviewer, qa-tester が別ターミナルで起動
```

---

## 6. ディレクトリ構造

### 6.1 全体構造

```
/project-template-dev/
├── QUICKSTART.md                    # クイックスタートガイド
├── BLOG_SYSTEM_OVERVIEW.md          # このファイル
│
├── library/                         # ナレッジベース & テンプレート
│   ├── 01_PROJECT_PLAN.md          # プロジェクト計画書
│   ├── 02_DEVELOPMENT_PLAN.md      # 開発計画書
│   ├── 03_SYSTEM_ARCHITECTURE.md   # システムアーキテクチャ
│   ├── config/
│   │   ├── agents.json             # エージェント定義
│   │   └── common_settings.env     # 共通環境変数
│   ├── dev-templates/              # 開発用テンプレート
│   ├── creative-templates/         # 執筆用テンプレート
│   ├── life-templates/             # 生活用テンプレート
│   ├── claude-templates/           # Claude Code設定テンプレート
│   └── docs/                       # システムドキュメント
│
├── inbox/                          # マルチモーダル・インボックス
│   └── text/
│
├── projects/                       # アクティブなプロジェクト作業場
│   ├── scripts/                   # プロジェクト管理スクリプト
│   │   ├── init-project.sh        # 初期化（Bash）
│   │   ├── init-project.ps1       # 初期化（PowerShell）
│   │   ├── init-project.bat       # 初期化（Batch）
│   │   ├── launch-agents.sh       # エージェント起動（Bash）
│   │   ├── launch-agents.ps1      # エージェント起動（PowerShell）
│   │   └── launch-agents.bat      # エージェント起動（Batch）
│   │
│   ├── memo/                      # 設計・研究メモ
│   ├── my-app/                    # 実装済みプロジェクト例
│   └── sample/                    # サンプルプロジェクト
```

### 6.2 プロジェクト内構造

```
projects/[project-name]/
├── CLAUDE.md              # エージェント設定・ルール
├── README.md              # プロジェクト概要
├── config/
│   └── agents.json        # プロジェクト固有のエージェント定義
├── docs/
│   └── PRP.md            # Product Requirement Plan
├── spec/
│   └── implementation_plan.md  # 実装プラン
├── research/              # 調査資料
├── resources/
│   └── mockups/          # UIデザイン
├── src/                   # ソースコード
├── tests/                 # テストコード
└── tracks/                # 並列実行トラック
```

---

## 7. 開発の経緯とGitログ分析

### 7.1 コミット履歴（時系列）

| コミット | 内容 | 分析 |
|----------|------|------|
| `07f5067` | Initial commit | 日本語ファイル名でスタート（計画書.md等） |
| `964c97d` | Add Development Plan | 開発計画とユーザーインタラクションフロー追加 |
| `12d4ba6` | rename | 日本語→英語ファイル名への移行開始 |
| `feaeb60` | rename | テンプレートファイルの整理 |
| `25a39f0` - `9cd47f2` | update | 詳細不明な更新（曖昧なコミットメッセージ） |
| `172d97d` | update | 設定ファイル・テンプレート大量追加 |
| `a255056` | Initialize project template | 本格的なプロジェクト構造確立 |
| `c5d43ac` | create v1 | ディレクトリ構造の再編成 |
| `bae6d93` | Introduce design workflow | Nano Banan連携のデザインワークフロー追加 |
| `d002045` | Add PM orchestration | PMオーケストレーションドキュメント追加 |
| `8e2a105` | Add agent launch script | エージェント起動スクリプト追加 |
| `26c15e5` | Add Windows batch and PowerShell | Windows対応スクリプト追加 |
| `dff57bf` | Relocate research files | `setup-research/` → `memo/` へ移動 |

### 7.2 開発の転換点

1. **日本語→英語への移行**（`12d4ba6`）
   - 最初は日本語ファイル名（`計画書.md`）で始めた
   - 国際化を考慮して英語名に統一

2. **ディレクトリ構造の試行錯誤**
   - `research/` → `setup-research/` → `memo/`
   - `test-organic-flow/` → `sample/` → `my-app/`

3. **マルチプラットフォーム対応**（`26c15e5`）
   - 当初はBashのみ
   - Windows環境への対応要求から PowerShell/Batch を追加

4. **デザインワークフローの追加**（`bae6d93`）
   - Nano Banana（Gemini Pro）との連携を後付けで追加

---

## 8. うまくいかなかったこと・課題

### 8.1 技術的課題

#### 8.1.1 コンテキストウィンドウの限界

```
問題: Claude Codeの200,000トークン制限
影響: 複雑なプロジェクトでは途中でコンパクト化が発生
対策: サブエージェント活用で軽減（完全解決ではない）
```

- 大規模プロジェクトでは依然としてコンテキスト枯渇のリスク
- コンパクト化時に重要な文脈が失われる可能性

#### 8.1.2 エージェント間連携の手動設計

```
問題: エージェント間の連携プロンプトを人間が設計する必要がある
影響: 最適なオーケストレーションには経験が必要
対策: PM_ORCHESTRATION.md でテンプレート化（部分的解決）
```

#### 8.1.3 Windows環境でのターミナル起動

```
問題: macOSのosascriptのようなシームレスな自動化が困難
影響: Windowsユーザーは手動でターミナルを開く場面がある
対策: PowerShell版スクリプトを提供（完全ではない）
```

### 8.2 開発プロセスの課題

#### 8.2.1 曖昧なコミットメッセージ

Gitログに "update" が複数存在：
- `172d97d update`
- `9cd47f2 update`
- `25a39f0 update`

**教訓**: コミットメッセージは具体的に書くべきだった

#### 8.2.2 ディレクトリ構造の迷走

| 変遷 | 問題 |
|------|------|
| `research/` → `setup-research/` → `memo/` | 役割が不明確だった |
| `test-organic-flow/` → `sample/` | 命名規則が統一されていなかった |

**教訓**: 最初に明確なディレクトリ設計を行うべきだった

#### 8.2.3 後付けの機能追加

- デザインワークフロー（Nano Banana）
- Windows対応スクリプト
- PMオーケストレーション

**教訓**: 最初から想定していれば、より統合的な設計ができた

### 8.3 運用上の課題

#### 8.3.1 学習コスト

- 11エージェントの役割を理解する必要がある
- プロンプト設計のスキルが求められる
- Claude Codeの並列実行（Ctrl+B）を習得する必要がある

#### 8.3.2 再現性

- 同じプロンプトでも結果が異なる場合がある
- モデルの更新によって挙動が変わるリスク

#### 8.3.3 デバッグの困難さ

- 並列実行中に問題が発生した場合、どのエージェントが原因かの特定が難しい
- バックグラウンドエージェントのログ追跡

---

## 9. 今後の展望

### 9.1 短期目標

1. **エージェント自動選択機能**: タスク内容に応じて最適なエージェントを自動で選択
2. **MCPサーバー連携**: Playwright MCP等との統合によるブラウザテスト自動化
3. **エラーハンドリング強化**: エージェント失敗時の自動リトライとフォールバック

### 9.2 中長期目標

1. **GUI ダッシュボード**: エージェントの進捗を視覚的に確認
2. **ナレッジグラフ連携**: プロジェクト間の知見共有
3. **音声入力インボックス**: 音声メモからの自動プロジェクト立案

---

## 10. 使い方クイックスタート

### Step 1: プロジェクト作成

```bash
./scripts/init-project.sh my-app --type dev
cd projects/my-app
```

### Step 2: PRP作成

`docs/PRP.md` に要件を記載

### Step 3: PMに全体を任せる

```
あなたは Project-Manager です。
docs/PRP.md を読み、全フェーズを実行してください：
RA → Researcher → Architect → Designer → Coder → Review → Marketing
```

### Step 4: 並列エージェント起動

```bash
# 並列コーダー起動
./scripts/launch-agents.sh my-app --agents parallel-coders

# 全エージェント起動
./scripts/launch-agents.sh my-app --agents full-team
```

---

## 参考資料

### 研究インサイトの出典

本システムは以下の動画・資料を参考に設計しました：

1. **Claude Code Multi-Agent Orchestration** - サブエージェントと並列実行の概念
2. **"Ralph Wiggum" Loop** - 粘り強さは洗練に勝るアプローチ
3. **Agent Harness** - エージェントの自律実行における信頼性担保

### 統計情報

| 項目 | 数値 |
|------|------|
| システムドキュメント | 20+ ファイル |
| エージェント数 | 11個 |
| プロジェクト管理スクリプト | 6個 |
| テンプレート | 8個 |
| 総コミット数 | 14 |
| 開発期間 | 2026-01-24（v1.4） |

---

## 結論

Antigravity Life OSは、Claude Codeを基盤とした**企業レベルのマルチエージェント・ワークフロー・エンジン**です。

### 達成できたこと

- 11エージェントの協調動作による効率的なプロジェクト管理
- コンテキスト保護による品質維持
- マルチプラットフォーム対応
- PRP駆動の再現可能な開発プロセス

### 残された課題

- コンテキストウィンドウの根本的な制限
- エージェント間連携の自動最適化
- 学習コストの低減

---

*Last Updated: 2026-01-24*
*Version: 1.0*
*Author: Antigravity*
