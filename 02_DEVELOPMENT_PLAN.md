# Antigravity Life OS - Development Plan

**Project Name:** Personal Agent Guild "Antigravity Life OS"
**Date:** 2026-01-24
**Version:** 2.0 (Japanese Edition)
**Author:** Antigravity (Assistant)

---

## 1. 開発方針 (Development Policy)

### 1.1 技術選定とギルド構成 (Technology Stack & Guild Members)

本プロジェクトは、賢明な「指揮官 (Orchestrator)」と、強力な「実行部隊 (Executor)」によるハイブリッド構成を採用する。

*   **Core Platform**: Google Antigravity (Orchestration & Planning)
*   **Execution Engine**: OpenCode (Parallel Execution & Sub-agents)
*   **Agent Models**:
    *   **Orchestrator**: Gemini 1.5 Pro (戦略、高レベル判断、Inbox振り分け)
    *   **Implementation**: DeepSeek-V3 (実装、コーディングループ)
    *   **Review/Safety**: Claude 3.5 Sonnet (論理整合性), ELYZA (国内法・日本語対応)
    *   **Creative**: GPT-4o, Sakana AI (トレンド分析・発信)

### 1.2 アーキテクチャ設計 (Architecture Design)
詳細は `03_SYSTEM_ARCHITECTURE.md` を参照。
重要コンセプト: **計画 (`spec/`) と実行 (`projects/`) の分離**。

## 2. 実装計画 (Implementation Steps)

### Phase 1: Foundation Setup (基盤構築)
*   [x] **Directory Structure**: `config`, `library`, `spec` ディレクトリの整備。
*   [ ] **Configuration**: `config/agents.json` にギルドメンバー（役割定義）を作成。
*   [ ] **Environment**: 複数のAPIキー (Gemini, Anthropic, OpenRouter) を `.env` に設定。

### Phase 2: Agent Harness & Loop Implementation (自律ループの実装)
*   [ ] **Ralph Wiggum Loop Integration**: エージェントが完了条件 ("DONE") を満たすまで自律的に修正を繰り返すスクリプト/Hookの実装。
*   [ ] **PRP Template**: ループへの入力品質を担保するための「要件定義シート (PRP)」テンプレートを `library/docs/PRP_TEMPLATE.md` に作成。
*   [ ] **Multimodal Inbox**: 音声メモ (`inbox/voice/`) を自動でテキスト化するパイプラインの構築。

### Phase 3: Workflow Automation (ワークフロー自動化)
*   [ ] **Parallel Track Script**: 複数のOpenCodeインスタンス（サブエージェント）を並列トラックとして起動するワークフローの作成。
*   [ ] **Review Pipeline**: ExecutorからReviewerエージェントへ成果物を自動で引き渡すパイプラインの構築。

## 3. テスト・検証計画 (Verification Plan)

### 3.1 Scenario: "The Loop" Test
1.  **Input**: 単純な「Todoアプリ機能」のPRPを `spec/` に作成。
2.  **Execute**: 汎用のCoding Modelを用いて "Ralph Wiggum Loop" を起動。
3.  **Verify**: エージェントがエラー修正やリファクタリングを自律的に繰り返し、最終的に "DONE" を出力するか検証。

### 3.2 Scenario: Parallel Tracks
1.  **Input**: 「フロントエンドUI」と「バックエンドAPI」の同時構築を指示。
2.  **Verify**: 2つのサブエージェントが、互いのコンテキスト（変数やファイル操作）を衝突させずに並列動作するか検証。

## 4. デプロイ・運用戦略 (Deployment Strategy)
*   **Local-First**: ObsidianやローカルGitとの深い統合。
*   **Git Strategy**: `library/` のテンプレート群はバージョン管理し、`projects/` は成果物が確定するまでの一時的なワークスペースとして扱う（確定後にGit化）。

---
*承認者:*
*承認日:*
