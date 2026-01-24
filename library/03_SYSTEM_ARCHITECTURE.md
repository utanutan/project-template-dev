# Antigravity Life OS - System Architecture

このドキュメントでは、"Antigravity Life OS" におけるシステムアーキテクチャ、ディレクトリ構造、およびエージェントチーム（役割定義）について記述します。

## 1. Core Architecture: Claude Code Multi-Agent Orchestration

Claude Codeを基盤とし、「チーフ・ソフトウェア・アーキテクト」がメインスレッドを担当、複数の特化型サブエージェントを指揮する構成を採用します。

*   **Main Thread (Orchestrator)**
    *   **役割**: 高レベルな計画策定、タスク分割、全体の進行管理。
    *   **責務**: メインスレッドのコンテキスト（トークン）を保護しつつ、効率を最大化する。

*   **Sub-Agents (Executors)**
    *   **役割**: 具体的な実装タスクの実行、テスト、レビュー。
    *   **特徴**: **並列実行 (Parallel Execution)** と **コンテキスト分離 (Context Isolation)**。
    *   **責務**: バックグラウンドで作業を完結させ、メインスレッドには要約のみを報告する。

## 2. Agent Team (Roles)

| エージェント名 | 推奨モデル | 専門領域と責務 |
| :--- | :--- | :--- |
| **Architect-Plan** | Claude Opus | プロジェクト全体の構造、依存関係、技術スタック選定。実装前に詳細なフェーズ分けを行う。 |
| **Senior-Coder** | Claude Sonnet | クリーンコード、DRY原則、パフォーマンスを重視した実装。テストコードも同時に作成する。 |
| **Review-Guardian** | Claude Haiku / Sonnet | セキュリティ、命名規則、アクセシビリティ、バグの検出。Coderの実装を厳格にレビューする。 |
| **Spec-Writer** | Claude Haiku | 変更履歴、実装プラン、APIドキュメントの生成と更新を担当。 |

## 3. Directory Structure

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
├── inbox/                   # マルチモーダル・インボックス
│   ├── voice/               # 音声ファイル -> 自動文字起こしへ
│   └── text/                # テキストメモ
└── projects/                # アクティブなプロジェクト作業場
    ├── [project_name]/      # 個別プロジェクト
    │   ├── src/             # ソースコード
    │   └── tracks/          # 並列実行トラックごとの作業場
    └── ...
```

## 4. Workflow Strategy: 4-Phase Parallel Execution

### Phase 1: プランニング（並列調査）
*   `Architect-Plan` を呼び出し、現在のコードベースと要求仕様を照らし合わせる。
*   `spec/` フォルダに段階的な実装プランを作成させる。
*   依存関係のないタスクを特定し、並列実行可能な「トラック（Track）」に分割する。

### Phase 2: 並列実装とバックグラウンド実行
*   各トラックに対し、個別の `Senior-Coder` をバックグラウンドで起動する。
*   コード変更はサブエージェント内ですべて完結させ、完了報告のみをメインスレッドに返す。

### Phase 3: 相互レビュー・サイクル
*   `Senior-Coder` の成果物を、即座に `Review-Guardian` に渡して検証させる。
*   レビューで指摘された点は、メインスレッドに戻さず、サブエージェント間で修正ループを回させる。

### Phase 4: 最終統合
*   すべてのサブエージェントが完了した後、メインエージェントが最終的な動作確認とビルドチェックを行う。

## 5. Constraints (制約事項)

1.  **コンテキスト節約**: 1,000行を超える調査や冗長なログ出力は、必ずサブエージェントに投げ、メインスレッドには「要約」のみを報告させること。
2.  **並列性の活用**: 独立した作業は同時に3つ以上のエージェントを動かして時間を短縮すること。
3.  **自律性**: 各エージェントには「自分の判断で必要なツールを使い、解決まで持っていくこと」を強調すること。
