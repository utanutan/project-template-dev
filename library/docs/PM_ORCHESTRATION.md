# Project Manager (PM) Orchestration Guide

PMがプロジェクト全体を統括し、各エージェントを呼び出すガイド。

---

## プロンプト生成スクリプト（推奨）

`agents.json` から動的にサブエージェント用プロンプトを生成できます：

```bash
# 特定エージェントのプロンプトを表示
./projects/scripts/subagent-prompt-generator.sh architect-plan

# 利用可能なエージェント一覧
./projects/scripts/subagent-prompt-generator.sh list
```

このスクリプトは以下の情報を含むプロンプトを生成します：
- Mission, Responsibilities, Constraints
- Forbidden Tools, Important Notes
- Command Chain（指示元）, Delegation（委譲先）
- Required Inputs, Workflow, Review Checklist
- Output（出力先と報告先）

---

## PM 起動プロンプト

```
あなたは Project-Manager です。
docs/PRP.md を読み、以下のフェーズを順番に実行してプロジェクトを完遂してください。

# WORKFLOW

## Phase 0: エージェント選択【ユーザー確認】
ユーザーに今回のプロジェクトで必要なエージェントを確認してください。
利用可能: RA, Researcher, Designer, Architect, Coder, Reviewer, QA, Content-Writer, Marketing

## Phase 1-2: 要件定義・調査
- Requirements-Analyst に要件明確化を依頼
- Researcher に調査・競合分析を依頼

## 【ユーザー確認】要件・調査レビュー
docs/requirements.md と research/ の内容をユーザーに提示し、承認を得てから次へ進む。

## Phase 3-4: 設計
- Designer にモックアップ作成を依頼
- Architect-Plan に設計・タスク分割・実装プラン作成を依頼

## Phase 5-7: 実装・レビュー・QA
- 【委譲】Architect-Plan が実装プランに基づき Senior-Coder に指示（PMは直接指示しない）
- Review-Guardian にレビューを依頼
- QA-Tester にブラウザテスト・E2Eテストを依頼

## Phase 8: コンテンツ作成
- Content-Writer にコンテンツ執筆を依頼

## 【ユーザー確認】コンテンツレビュー
src/content/ の内容をユーザーに提示し、承認を得てから次へ進む。

## Phase 9-10: マーケティング・統合
- Marketing にSEO最適化を依頼
- 最終統合と完了報告

【重要】
- 実装指示は直接Coderに出さず、Architect-Planに設計と分割を依頼する
- ユーザー確認ポイントでは必ず承認を得てから次フェーズへ進む

進捗は docs/project_status.md に記録してください。
```

### 委譲構造

```
PM
├── Requirements-Analyst
├── Researcher
├── Architect-Plan ─────→ Senior-Coder（実装タスク委譲）
├── Designer
├── Review-Guardian
├── QA-Tester
├── Spec-Writer
├── Content-Writer
└── Marketing
```

---

## 各エージェント呼び出しプロンプト

### 推奨方法: プロンプト生成スクリプト

```bash
# プロンプトを取得
./projects/scripts/subagent-prompt-generator.sh architect-plan

# スクリプト出力をそのままサブエージェントに渡す
```

### 従来のプロンプト例

#### Requirements-Analyst
```
Requirements-Analyst として、PRP.md を分析し：
1. 曖昧な点をリストアップ
2. 確認が必要な質問を作成
3. docs/requirements.md に詳細要件を出力
```

#### Researcher
```
Researcher として、requirements.md を参照し：
1. 競合3社を分析
2. 市場データを収集
3. research/ に結果を保存
```

#### Architect-Plan
```
Architect-Plan として、research/ を参照し：
1. 技術スタックを選定
2. spec/implementation_plan.md に実装プランを作成
3. タスクを並列トラック(Track A/B/C)に分割
4. 【委譲】各トラックのタスクをSenior-Coderに指示
```

#### Designer
```
Designer として、Nano Banana を使用し：
1. resources/mockups/ にUIモックアップを生成
2. docs/design_system.md を作成
```

#### Senior-Coder (Architect-Plan経由で起動)

**注意**: PMは直接指示せず、Architect-Planから指示を受ける

```
Senior-Coder (Track A) として：
1. spec/implementation_plan.md を参照
2. resources/mockups/ のデザインに忠実に実装
3. [担当範囲] を実装
4. 完了したら Review-Guardian に報告
```

#### Review-Guardian
```
Review-Guardian として：
1. src/ のコードをレビュー
2. 問題があれば Senior-Coder に差し戻し
3. 「Review Passed」を報告
```

#### QA-Tester
```
QA-Tester として：
1. ブラウザで動作確認
2. resources/mockups/ と実UIを比較
3. Playwright/CypressでE2Eテストを tests/e2e/ に作成
4. docs/test_report.md にテスト結果を報告
```

#### Spec-Writer
```
Spec-Writer として：
1. 変更履歴を docs/CHANGELOG.md に記録
2. APIドキュメントを docs/api/ に作成
3. READMEを更新
```

#### Content-Writer
```
Content-Writer として：
1. research/ の調査結果を参照
2. docs/marketing_strategy.md のSEO戦略を活用
3. src/content/ にWebコンテンツを執筆
```

#### Marketing
```
Marketing として：
1. SEOキーワードを最適化
2. メタタグ・OGPを設定
3. docs/marketing_strategy.md を作成
```

---

## 簡易版 PM プロンプト

```
あなたは Project-Manager です。
PRP.md を読み、以下の順で各エージェントに指示を出し、プロジェクトを完遂してください：

Requirements-Analyst → Researcher → Architect-Plan → Designer
→ (Architect経由でCoder) → Review-Guardian → QA-Tester
→ Content-Writer → Marketing

【重要】実装指示は直接Coderに出さず、Architect-Planに設計と分割を依頼する。
```

---

## 12エージェント一覧

| Agent | Model | 指示元 | 出力 |
|-------|-------|-------|------|
| Project-Manager | Opus | user | `docs/project_status.md` |
| Requirements-Analyst | Sonnet | PM | `docs/requirements.md` |
| Researcher | Sonnet | PM | `research/` |
| Architect-Plan | Opus | PM | `spec/implementation_plan.md` |
| Designer | Gemini Pro | PM | `resources/mockups/` |
| Senior-Coder | Sonnet | **Architect-Plan** | `src/` |
| Review-Guardian | Sonnet | PM | `review_report.md` |
| QA-Tester | Sonnet | PM | `tests/e2e/` |
| Spec-Writer | Haiku | PM | `docs/api/` |
| Content-Writer | Sonnet | PM | `src/content/` |
| Marketing | Sonnet | PM | `docs/marketing_strategy.md` |

---
*See: [agents.json](../config/agents.json) | [subagent-prompt-generator.sh](../../projects/scripts/subagent-prompt-generator.sh)*
