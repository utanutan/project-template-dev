# AIエージェント・ギルド構築 プロジェクト計画書

**Project Name:** Personal Agent Guild "Antigravity Life OS"
**Date:** 2026-01-24
**Version:** 1.4
**Author:** Antigravity (Assistant)

---

## 1. プロジェクト概要 (Executive Summary)

### 1.1 背景 (Background)
ユーザーは開発業務だけでなく、日々の生活における多種多様なタスクや情報発信など、人生のあらゆる局面で活動している。これらを個別に管理するのではなく、統合的にサポートする「有機的なエージェント群」が必要とされている。

### 1.2 目的 (Objectives)
*   **Life & Workの統合支援**: ソフトウェア開発、執筆、学習、生活管理など、ユーザーのあらゆる活動をサポートする汎用的な「ギルド」を構築する。
*   **有機的なプロジェクト立案**: ユーザーの些細な「気付き」や「メモ」をトリガーに、エージェントが自律的に「これをコンテンツ化しませんか？」「このアイデアを形にしましょうか？」と提案・遂行する体験を作る。
*   **コンテキストフリーな基盤**: 特定の居住地や職種に依存せず、ライフステージの変化に合わせて柔軟に拡張可能な「OS」としてのテンプレートを提供する。

## 2. ユーザー要件と体験 (User Requirements & Experience)

### 2.1 ユーザー（貴方）の期待値
*   **全方位のパートナー**: 仕事中もプライベートでも、同じインターフェースで頼れる存在。
*   **有機的な提案 (Organic Proactivity)**: 指示待ちではなく、蓄積されたメモやログから価値あるアウトプット（ブログ、SNS、コード、To-Do）を能動的に提案してくれる体験。
*   **汎用的なテンプレート**: あらゆる状況（新しい趣味、旅行、学習、ビジネス）に対応できる、柔軟なベースシステム。

### 2.2 想定される利用シナリオ (Usage Scenarios)

#### シナリオ A: ソフトウェア開発 (Dev Mode)
*   新規プロダクト開発。Developerが実装し、Architectが設計、Legalが規約を作成する。

#### シナリオ B: ライフスタイル・発信 (Life & Content Mode)
1.  **Input**: ユーザーが「最近気になっている技術トレンド」や「旅先での体験」などをメモとしてInboxに入れる。
2.  **Trigger**: **Editor Agent** が内容を分析。「これは技術ブログ向きですね」「こちらはエッセイ風にSNSで発信しましょう」と提案。
3.  **Action**:
    *   **Content Creator** が、ターゲット読者に合わせた記事ドラフトを作成。
    *   **SNS Manager** が、拡散を狙った投稿文を作成。
4.  **Review**: ユーザーが確認し、微調整して公開。

## 3. ギルドメンバー構成 (Guild Organization)

Claude Codeのマルチエージェント・オーケストレーションを活用し、以下のエージェントチームを構成する。

| カテゴリ | ロール | 推奨モデル | ミッション |
| :--- | :--- | :--- | :--- |
| **Planning** | **Architect-Plan** | Claude Opus | プロジェクト全体の構造、依存関係、技術スタック選定、詳細なフェーズ分け |
| **Implementation** | **Senior-Coder** | Claude Sonnet | クリーンコード、DRY原則、パフォーマンス重視の実装、テストコード作成 |
| **Quality** | **Review-Guardian** | Claude Haiku / Sonnet | セキュリティ、命名規則、アクセシビリティ、バグ検出、厳格なレビュー |
| **Documentation** | **Spec-Writer** | Claude Haiku | 変更履歴、実装プラン、APIドキュメントの生成と更新 |

詳細は `03_SYSTEM_ARCHITECTURE.md` を参照。

```
/workspace_root/
├── config/
├── library/
├── spec/
├── research/
├── inbox/
└── projects/
```

## 5. 完了要件と受入基準 (Acceptance Criteria)

*   **[AC-1] 汎用フォルダ構造**: 開発、執筆、計画など、全く性質の異なるプロジェクトを同一階層で違和感なく管理できること。
*   **[AC-2] モードの自然な切り替え**: ユーザーが意識せずとも、タスクの内容に応じて最適なエージェント（Dev or Editor or Concierge）が立ち上がること。
*   **[AC-3] コンテキスト非依存**: マレーシアに限らず、どこに住んでいても、何をしていても使える抽象化されたテンプレートであること。

## 6. スケジュール (Schedule)

*   **Phase 1: Guild Foundation**: 汎用ディレクトリ構造と `agents.json` の実装。
*   **Phase 2: Universal Templates**: あらゆるシーンに対応可能な「型（テンプレート）」の整備。
*   **Phase 3: Organic Flow Verify**: ランダムなメモからプロジェクトを立ち上げる動作検証。

---
*承認者:* 
*承認日:* 
