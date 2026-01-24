# Antigravity Life OS - Development Plan

**Project Name:** Personal Agent Guild "Antigravity Life OS"
**Date:** 2026-01-24
**Version:** 2.0 (Japanese Edition)
**Author:** Antigravity (Assistant)

---

## 1. 開発方針 (Development Policy)

### 1.1 技術選定とエージェント構成 (Technology Stack & Agent Team)

本プロジェクトは、Claude Codeを基盤としたマルチエージェント・オーケストレーションを採用する。「チーフ・ソフトウェア・アーキテクト」がメインスレッドを担当し、特化型サブエージェントを指揮する。

*   **Core Platform**: Claude Code (Orchestration & Parallel Execution)
*   **Agent Team**:

| エージェント名 | 推奨モデル | 専門領域 |
| :--- | :--- | :--- |
| **Architect-Plan** | Claude Opus | プロジェクト構造、依存関係、技術スタック選定 |
| **Senior-Coder** | Claude Sonnet | クリーンコード、DRY原則、パフォーマンス重視の実装 |
| **Review-Guardian** | Claude Haiku / Sonnet | セキュリティ、命名規則、バグ検出 |
| **Spec-Writer** | Claude Haiku | 変更履歴、実装プラン、APIドキュメント |

### 1.2 アーキテクチャ設計 (Architecture Design)
詳細は `03_SYSTEM_ARCHITECTURE.md` を参照。
重要コンセプト: **計画 (`spec/`) と実行 (`projects/`) の分離**、**コンテキスト保護**。

## 2. 運用ワークフロー (Operation Workflow)

### Phase 1: プランニング（並列調査）
*   `Architect-Plan` を呼び出し、現在のコードベースと要求仕様を照らし合わせ、`/spec` フォルダに段階的な実装プランを作成させる。
*   依存関係のないタスクを特定し、並列実行可能な「トラック（Track）」に分割する。

### Phase 2: 並列実装とバックグラウンド実行
*   各トラックに対し、個別の `Senior-Coder` をバックグラウンド（`Ctrl+B`）で起動する。
*   **指示のコツ:** 「メインスレッドを汚さないよう、コード変更はサブエージェント内ですべて完結させ、完了報告のみを返せ」と命じる。

### Phase 3: 相互レビュー・サイクル
*   `Senior-Coder` の成果物を、即座に `Review-Guardian` に渡して検証させる。
*   レビューで指摘された点は、メインスレッドに戻さず、サブエージェント間で修正ループを回させる。

### Phase 4: 最終統合
*   すべてのサブエージェントが完了した後、メインエージェントが最終的な動作確認とビルドチェックを行う。

## 3. 制約事項 (Constraints)

1.  **コンテキスト節約**: 1,000行を超える調査や冗長なログ出力は、必ずサブエージェントに投げ、メインスレッドには「要約」のみを報告させる。
2.  **並列性の活用**: 独立した作業は同時に3つ以上のエージェントを動かして時間を短縮する。
3.  **自律性**: 各エージェントには「自分の判断で必要なツールを使い、解決まで持っていくこと」を強調する。

## 4. テスト・検証計画 (Verification Plan)

### 4.1 Scenario: "The Loop" Test
1.  **Input**: 単純な「Todoアプリ機能」のPRPを `spec/` に作成。
2.  **Execute**: `Senior-Coder` を用いて実装ループを起動。
3.  **Verify**: エージェントがエラー修正やリファクタリングを自律的に繰り返し、最終的に完了報告を出力するか検証。

### 4.2 Scenario: Parallel Tracks
1.  **Input**: 「フロントエンドUI」と「バックエンドAPI」の同時構築を指示。
2.  **Verify**: 2つのサブエージェントが、互いのコンテキストを衝突させずに並列動作するか検証。

## 5. デプロイ・運用戦略 (Deployment Strategy)
*   **Local-First**: ObsidianやローカルGitとの深い統合。
*   **Git Strategy**: `library/` のテンプレート群はバージョン管理し、`projects/` は成果物が確定するまでの一時的なワークスペースとして扱う。

---
*承認者:*
*承認日:*
