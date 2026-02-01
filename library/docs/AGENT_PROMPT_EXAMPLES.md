AIエージェント指示書サンプル集
本ドキュメントは、GeminiからローカルのAIギルド（Cloud Code / Antigravity環境）へタスクを移譲する際に使用する、具体的な指示書（Instruction）のテンプレート集です。
パターン1：【技術実装】高効率コーディング（DeepSeek-V3向け）
大量のロジック実装や、ボイラープレートコードの生成を目的とした指示書です。
# ID: 20260124_Deep_Implementation
# TARGET_AGENT: Heavy-Lifter (DeepSeek-V3)
# CONTEXT: 
- Rustによる高並列非同期HTTPクライアントの実装。
- パフォーマンスを最優先し、`tokio`と`reqwest`ライブラリを使用する。
# CONSTRAINTS:
- メモリリークを徹底的に排除すること。
- エラーハンドリングは `thiserror` を使用し、詳細なログ出力を埋め込むこと。
# ACTION:
1. `src/client.rs` を新規作成し、並列リクエストのリミッター機能を実装せよ。
2. 接続タイムアウトとリトライロジック（指数バックオフ）を組み込め。
3. すべてのパブリック関数に、日本語による簡潔なドキュメントコメントを付与せよ。


パターン2：【文化調整】日本的ビジネス推敲（ELYZA向け）
実装された機能やドライな英文ドキュメントを、日本国内のクライアント向けに「おもてなし」の精神を込めて調整する指示書です。
# ID: 20260124_Honorific_Polish
# TARGET_AGENT: Polisher (ELYZA / Sakana AI)
# CONTEXT: 
- `docs/raw_spec.md` に記載された新機能の仕様を、重要顧客（大手企業担当者）への案内文に変換する。
- 文脈として、前回のリクエストから実装が少し遅れたことに対する「さりげないお詫び」を含める。
# CONSTRAINTS:
- 二重敬語を避け、誠実さと技術的な自信が伝わるトーンにすること。
- 「心苦しいのですが」「ご多忙の折」などのクッション言葉を適切に使用せよ。
# ACTION:
1. `workspace/client_email.md` を作成し、件名から署名までを完璧なビジネス敬語で執筆せよ。
2. 機能説明部分は、専門用語を避けつつメリットを強調する表現に変換せよ。
3. 最後に、次回の打ち合わせ（オンライン）の打診を控えめに行え。


パターン3：【技術調査】日中ブリッジリサーチ（GLM-4 + ELYZA連携）
中国の最新技術トレンドを調査し、日本のエンジニアチーム向けに要約する複合タスク用の指示書です。
# ID: 20260125_Global_Research
# AGENTS_FLOW: Researcher (GLM-4) -> Polisher (ELYZA)
# CONTEXT: 
- 中国のAIデータセンター（智算中心）における最新の冷却技術とコスト効率に関する調査。
- ターゲットは自社のインフラエンジニアチーム。
# ACTION (Researcher):
1. 中国国内のテックニュースサイトを検索し、2025年後半から2026年初頭の投資動向を抽出せよ。
2. 主要な3社の具体的数値（PUE値、建設コスト）を比較表にまとめよ。
# ACTION (Polisher):
1. 上記のリサーチ結果を受け取り、日本のエンジニアが読みやすいよう「謙遜を含んだ客観的な技術レポート」として構成せよ。
2. 「日本の現状との比較」というセクションを設け、示唆に富むコメントを付与せよ。


パターン4：【リファクタリング】コードレビューと改善（Claude 3.5向け）
既存のコードに対して、アーキテクチャの視点から修正を依頼する指示書です。
# ID: 20260126_Architect_Review
# TARGET_AGENT: Architect (Claude 3.5)
# CONTEXT: 
- `workspace/legacy_module.py` の技術負債解消。
- 関数が長大化（100行以上）しており、テストが困難な状態。
# CONSTRAINTS:
- SOLID原則に基づき、単一責任の原則を適用して分解せよ。
- インターフェースを変更せず、既存のテストがパスすることを保証せよ。
# ACTION:
1. 該当ファイルを分析し、ロジックをクラスまたは小さな関数に分割せよ。
2. 型ヒントを完璧に付与し、`mypy`でエラーが出ない状態にせよ。
3. 分割後の構造について、なぜそのように設計したかの「設計意図」を日本語でコメント欄に残せ。


指示書の使い分けガイド
**「作れ」**という命令は Heavy-Lifter へ。
**「直せ」**という命令は Architect へ。
**「伝えろ/整えろ」**という命令は Polisher へ。
**「調べろ」**という命令は Researcher へ。
**「教えて/説明して」**という命令は Tech-Educator へ。
Geminiとの対話で「あ、これいいな」と思ったら、上記のいずれかのテンプレートに内容を流し込み、ファイル名をつけて保存してください。


パターン5：【概念解説】技術概念の教育（Tech-Educator向け）
新しい概念やフレームワークをユーザーのスキルレベルに合わせて解説する指示書です。
# ID: 20260201_Concept_Education
# TARGET_AGENT: Tech-Educator (Claude Sonnet)
# CONTEXT: 
- ユーザーが「マイクロサービス」の概念を理解したい。
- `library/config/user_skill_profile.yaml` を参照し、スキルレベルに応じた説明深度を調整。
# CONSTRAINTS:
- 必ずMermaid図を含めて視覚的に説明すること。
- `library/dev-templates/EDUCATION_TEMPLATE.md` の構造に従って出力。
- ユーザーが既に知っている概念（advanced以上）は前提知識として扱う。
# ACTION:
1. `user_skill_profile.yaml` を読み込み、microservicesのスキルレベルを確認せよ。
2. EDUCATION_TEMPLATE.md に沿って、以下のセクションを含む解説資料を作成せよ：
   - 3行まとめ
   - なぜこれが必要なのか
   - 仕組みを図解で理解（Mermaid図必須）
   - 具体例で確認
   - よくある誤解
3. `learning/concepts/microservices.md` に出力せよ。


パターン6：【技術選定解説】設計判断の理由説明（Tech-Educator向け）
プロジェクトで行った技術選定の「なぜ」を解説する指示書です。
# ID: 20260201_Tech_Decision_Education
# TARGET_AGENT: Tech-Educator (Claude Sonnet)
# CONTEXT: 
- プロジェクトでPostgreSQLを選定した理由を説明してほしい。
- `spec/implementation_plan.md` の技術選定セクションを参照。
# CONSTRAINTS:
- 他の選択肢（MySQL, MongoDB等）との比較を含める。
- トレードオフを明確に説明する。
- 図解で選定プロセスを可視化。
# ACTION:
1. `spec/implementation_plan.md` から技術選定の背景を読み取れ。
2. 以下の構造で解説資料を作成せよ：
   - なぜこの技術を選んだのか
   - 他の選択肢との比較（表形式）
   - トレードオフと注意点
   - 将来の拡張性への影響
3. `learning/tech-decisions/database-selection.md` に出力せよ。
