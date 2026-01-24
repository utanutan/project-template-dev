# 研究インサイト: 次世代エージェント開発基盤

提供された動画資料に基づき、プロジェクトに取り入れるべき重要なアーキテクチャとワークフローの要素を整理しました。

## 1. Core Architecture: Claude Code Multi-Agent Orchestration

システムを「計画・指揮」と「実行」の2層に明確に分離します。

*   **Main Thread (Orchestrator)**
    *   **役割**: 高レベルな計画策定、タスク分割、全体の進行管理。
    *   **責務**: メインスレッドのコンテキスト（トークン）を保護しつつ、効率を最大化する。

*   **Sub-Agents (Executors)**
    *   **役割**: 具体的タスクの実行、コーディング、テスト。
    *   **特徴**: **並列実行 (Parallel Execution)** と **コンテキスト分離**。
    *   **メリット**: Main Threadのコンテキスト枯渇を防ぎ、バックグラウンドで作業を完結させる。

## 2. Agent Harness & "Ralph Wiggum" Loop

エージェントの自律実行における信頼性を担保するための仕組み（Harness）を導入します。

*   **Iterative Execution (The Loop)**:
    *   単発の指示ではなく、「完了条件（Safety Phrase: "DONE"）」が満たされるまで試行錯誤を繰り返させるループ構造。
    *   *Ralph Wiggum* アプローチ: "Persistence beats sophistication"（粘り強さは洗練に勝る）。
*   **Structured Planning (PRP)**:
    *   ループに入る前に、厳密な「要件定義書（PRP）」を作成し、それを入力としてループを回すことで、"Vibe Coding"（雰囲気コーディング）の低品質化を防ぐ。

## 3. Workflow: 4-Phase Parallel Execution

1.  **Phase 1: プランニング（並列調査）**:
    *   `Architect-Plan` が `spec/implementation_plan.md` を作成。
    *   依存関係のないタスクを特定し、並列実行可能な「トラック」に分割。
2.  **Phase 2: 並列実装とバックグラウンド実行**:
    *   各トラックに対し、個別の `Senior-Coder` をバックグラウンドで起動。
    *   コード変更はサブエージェント内ですべて完結。
3.  **Phase 3: 相互レビュー・サイクル**:
    *   `Review-Guardian` が成果物を検証。
    *   サブエージェント間で修正ループを回す。
4.  **Phase 4: 最終統合**:
    *   メインエージェントが最終的な動作確認とビルドチェック。

## 4. プロジェクト構造への反映案

`开发計画書.md` と `SYSTEM_ARCHITECTURE.md` に以下の要素を追加することを推奨します。

### New Directory: `spec/`
*   詳細設計書置き場。`library/` とは異なり、プロジェクト固有の実行計画を格納。

### New Concept: "Task Tracks"
*   タスク管理において「直列」だけでなく「並列トラック」を明示的に定義。

### Agent Definitions Update
*   **Sub-agents** の明示的定義（`agents.json` にて `mode: background` や `context_isolation: true` を設定するイメージ）。

---
**Next Step**:
このインサイトに基づき、既存の `開発計画書.md` を更新し、「Claude Code連携」「サブエージェント並列実行」の項目を追加しますか？
