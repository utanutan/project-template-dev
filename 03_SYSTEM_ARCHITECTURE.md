# Antigravity Life OS - System Architecture

このドキュメントでは、"Antigravity Life OS" におけるシステムアーキテクチャ、ディレクトリ構造、およびエージェントギルド（役割定義）について記述します。

## 1. Core Architecture: Orchestrator & Executor

システム全体の効率とコンテキスト管理を最適化するため、以下の2層アーキテクチャを採用します。

*   **Orchestrator (Antigravity)**
    *   **役割**: 高レベルな計画策定、要件定義 (PRP: Product Requirement Prompt) の作成、プロジェクト全体の進行管理。
    *   **モデル**: Gemini 1.5 Pro / Claude 3.7 Sonnet (High Intelligence)
    *   **責務**: 抽象的な指示を具体的な仕様に落とし込み、Executorに指示を出す。

*   **Executor (OpenCode / Sub-agents)**
    *   **役割**: 具体的な実装タスクの実行、テスト、詳細なコーディング。
    *   **特徴**: **並列実行 (Parallel Execution)** と **コンテキスト分離 (Context Isolation)**。
    *   **モデル**: DeepSeek-V3, Claude 3 Haiku 等（高速・低コスト）
    *   **責務**: 与えられたトラック（タスク群）を完遂するまで自律的に試行錯誤ループを回す。

## 2. Directory Structure

```
/workspace_root/
├── config/                  # システム設定・定義
│   ├── agents.json          # エージェント定義（役割、モデル、性格）
│   └── common_settings.env  # 共通環境変数（APIキー等）
├── library/                 # ナレッジベース & テンプレート
│   ├── dev-templates/       # 開発用テンプレート
│   ├── creative-templates/  # 制作・執筆用テンプレート
│   ├── life-templates/      # 生活・計画用テンプレート
│   └── docs/                # システムドキュメント・プロンプト集
├── spec/                    # アクティブな詳細仕様 (PRPs, Implementation Plans)
├── research/                # リサーチ資料・インサイト
│   ├── 01_CLAUDE_CODE...    # 動画書き起こし・メモ
│   └── RESEARCH_INSIGHTS.md # 統合された知見
├── inbox/                   # マルチモーダル・インボックス
│   ├── voice/               # 音声ファイル -> 自動文字起こしへ
│   └── text/                # テキストメモ
└── projects/                # アクティブなプロジェクト作業場
    ├── [project_name]/      # 個別プロジェクト
    │   ├── src/             # ソースコード
    │   └── tracks/          # 並列実行トラックごとの作業場
    └── ...
```

## 3. Agent Guild (Roles)

| Role | Responsibility | Type | Typical Model |
| :--- | :--- | :--- | :--- |
| **Guild Master** | 全体指揮、戦略策定、PRP作成 | **Orchestrator** | Gemini 1.5 Pro |
| **Solution Architect**| 技術設計、システム仕様策定 | Orchestrator/Sub | Claude 3.5 Sonnet |
| **Lead Developer** | 実装、デバッグ、リファクタリング | **Executor** | DeepSeek-V3 |
| **Minute Taker** | 音声メモの文字起こし・要約 | Executor | Gemini 1.5 Flash |
| **Code Reviewer** | 品質保証、セキュリティチェック | Executor | Claude 3 Haiku |

## 4. Workflow Strategy: Parallel Tracks

1.  **Plan**: Orchestratorがユーザーの意図を汲み取り、詳細な要件定義書 (PRP) を `spec/` に作成する。
2.  **Split**: 作業を依存関係のない独立した「トラック」に分割する（例：Frontend, Backend, Database）。
3.  **Execute**: 各トラックに対してSub-agents (Executors) を割り当て、`projects/[name]/tracks/` 内で並列実行させる。
4.  **Loop**: Executorは「完了条件（Safety Phrase: "DONE"）」を満たすまで、修正と検証のループ (**Ralph Wiggum Loop**) を自律的に回す。
5.  **Merge**: 各トラックの成果物を統合し、Architect/Reviewerが最終チェックを行う。
