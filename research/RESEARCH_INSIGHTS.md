# 研究インサイト: 次世代エージェント開発基盤

提供された動画資料に基づき、プロジェクトに取り入れるべき重要なアーキテクチャとワークフローの要素を整理しました。

## 1. Core Architecture: Orchestrator & Executor

システムを「計画・指揮」と「実行」の2層に明確に分離します。

*   **Orchestrator (Antigravity)**
    *   **役割**: 高レベルな計画策定、PRP (Product Requirement Prompt) の作成、全体の進行管理。
    *   **得意領域**: 抽象的な指示の具体化、複雑な判断、コンテキストの維持。
    *   **使用モデル**: Gemini 1.5 Pro, Claude 3.7 Sonnet (High Intelligence).

*   **Executor (OpenCode / Sub-agents)**
    *   **役割**: 具体的タスクの実行、コーディング、テスト。
    *   **特徴**: **並列実行 (Parallel Execution)** と **コンテキスト分離**。
    *   **メリット**: Main Threadのコンテキスト枯渇を防ぎ、安価・高速なモデル (DeepSeek, Haiku, Flash) を大量投入可能。

## 2. Agent Harness & "Ralph Wiggum" Loop

エージェントの自律実行における信頼性を担保するための仕組み（Harness）を導入します。

*   **Iterative Execution (The Loop)**:
    *   単発の指示ではなく、「完了条件（Safety Phrase: "DONE"）」が満たされるまで試行錯誤を繰り返させるループ構造。
    *   *Ralph Wiggum* アプローチ: "Persistence beats sophistication"（粘り強さは洗練に勝る）。
*   **Structured Planning (PRP)**:
    *   ループに入る前に、厳密な「要件定義書（PRP）」を作成し、それを入力としてループを回すことで、"Vibe Coding"（雰囲気コーディング）の低品質化を防ぐ。

## 3. Workflow: Parallel Tracks

動画3で示された「並列実装トラック」を標準フローとして採用します。

1.  **Planning Phase**:
    *   Orchestratorが `spec/implementation_plan.md` を作成。
    *   フェーズごとに詳細な技術仕様をドキュメント化。
2.  **Wave / Track Creation**:
    *   依存関係のないタスク（例：UIコンポーネント実装、DBスキーマ定義、API定義）を独立した「トラック」に分割。
3.  **Parallel Execution**:
    *   各トラックに **Specialized Sub-agents** (UI Expert, Coder, Reviewer) を割り当て、バックグラウンドで同時並行に実行。
    *   Main Contextを汚さず、各エージェントは自身のコンテキスト内で作業完結。
4.  **Integration & Review**:
    *   全トラック完了後、**Reviewer Agent** が統合されたコードを監査。

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
このインサイトに基づき、既存の `開発計画書.md` を更新し、「OpenCode連携」「サブエージェント並列実行」の項目を追加しますか？
