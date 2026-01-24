AIエージェント・ギルド構築・運用計画書
〜 Antigravity × OpenCode によるハイブリッド・マルチプロジェクト環境 〜
1. プロジェクト概要
本プロジェクトは、Googleの次世代IDE環境 Antigravity と、強力な実行エンジン OpenCode を基盤とし、専門特化したAIエージェント群（ギルド）を用いて複数の開発プロジェクトを並列で実行・管理するローカル開発環境の構築を目的とする。
Geminiとの対話で生まれた「戦略」や「指示書」を資産化し、プロジェクトごとに最適なエージェント（ELYZA、DeepSeek、Claude等）を召喚して自動化サイクルを回す。
2. ギルド・ポートフォリオ：専門エージェントの定義
モデルの特性を活かし、ギルドメンバーを以下のような専門職として定義する。
職種（ロール）
推奨モデル
特色・ミッション
Lead Developer
DeepSeek-V3
圧倒的実装力: 高速かつ低コストでのコード生成、API連携、リファクタリングの実行。
Solution Architect
Claude 3.5 / Gemini
論理・設計: 全体構造の設計、技術選定の妥当性評価、複雑なアルゴリズムの考案。
Growth Marketer
Sakana AI / GPT-4o
市場適応: 文化的文脈を捉えたコピーライティング、トレンド分析、ユーザー体験の設計。
Monetization Lead
Gemini 1.5 Pro
収益化戦略: ビジネスモデルの策定、競合調査、価格戦略のシミュレーション。
Legal & Compliance
ELYZA (最新版)
守護神: 日本の法律・商習慣に即した規約確認、コンプラチェック、堅実な敬語。
Quality & QA
Claude 3.5
品質保証: エッジケースの特定、テストコード生成、コードの安全性と堅牢性の検証。

3. マルチプロジェクト対応ディレクトリ構造
複数のプロジェクトを並列で回すため、ワークスペースをプロジェクトごとに分離管理する。
/my-ai-guild-root/
├── config/
│   ├── agents.json          # 全エージェントの性格・接続定義（後述）
│   └── common_settings.env  # 共有環境変数
├── library/                 # Geminiから提供された汎用プロンプト集
└── projects/                # 並列実行プロジェクト群
    ├── project-X/           # 具体的なプロダクト開発
    │   ├── instructions/    # 各専門職への個別指示書
    │   └── src/             # 成果物
    └── project-Y/           # 技術リサーチ・法務チェックプロジェクト


4. エージェントの性格定義 (config/agents.json)
各エージェントがその職務を全うするための個別設定例。
{
  "agents": {
    "legal_reviewer": {
      "model": "elyza:latest",
      "specialization": "Japanese Law & Business Manner",
      "personality": "非常に保守的でリスク回避的。日本国内の商慣習に厳格。",
      "instructions": "出力は常に日本のリーガル・スタンダードに基づき、曖昧さを排除すること。"
    },
    "growth_hacker": {
      "model": "gpt-4o",
      "specialization": "Viral Marketing & Monetization",
      "personality": "積極的で創造的。データに基づいた攻撃的な成長戦略を好む。",
      "instructions": "収益を最大化するための施策を、心理学的なトリガーを交えて提案すること。"
    }
  }
}


5. 具体的なテストサンプル：並列実行の検証ケース
【ケース：新規SaaSプロダクト「EasyConnect」の同時立ち上げ】
プロジェクト
タスク
担当エージェント
目的
Development
バックエンド実装
Lead Developer
Rust/Axumを用いたAPIの高速実装。
Business
モネタイズプラン案
Monetization Lead
サブスクリプションプランと初期費用の最適化計算。
Legal
利用規約ドラフト作成
Legal & Compliance
日本の個人情報保護法に対応した規約の自動生成。

6. 具体的な作業ステップ：導入と運用
STEP 1: インフラ構築
Ollama で ELYZA (法務担当) と Llama 3 (汎用) を起動。
DeepSeek API を確保（開発担当用）。
STEP 2: Geminiからの戦略移譲
Geminiと話し、プロジェクトの全体図を描く。
Geminiに「Growth Marketer用のコピー案」と「Lead Developer用の実装指示書」を別々のMarkdownで出力させる。
STEP 3: OpenCodeによる並列指揮
Antigravityで3つのターミナルを開く。
タスク投入:
1: opencode --agent lead_dev --task instructions/api_spec.md
2: opencode --agent growth_marketer --task instructions/landing_page.md
3: opencode --agent legal_reviewer --task instructions/tos_draft.md
STEP 4: フィードバックと統合
Quality & QA エージェントを召喚し、lead_dev が書いたコードをチェック。
問題があればGeminiに戻し、修正指示書を再発行。
7. 今後の拡張：自律ギルドへの道
エージェント間レビュー: Architect が Developer のコードを自動レビューし、Legal が問題なしと判断するまでデプロイしないパイプラインの構築。
Gemini Memory同期: Geminiの「指示」設定に「私のギルドには法律に強いELYZAがいる」と教えておくことで、常に適切な役割分担案を得る。
