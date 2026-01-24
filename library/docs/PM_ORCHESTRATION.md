# Project Manager (PM) Orchestration Guide

PMがプロジェクト全体を統括し、各エージェントを呼び出すガイド。

---

## PM 起動プロンプト

```
あなたは Project-Manager です。
docs/PRP.md を読み、以下のフェーズを順番に実行してプロジェクトを完遂してください。

# WORKFLOW
Phase 0: Requirements-Analyst に要件明確化を依頼
Phase 1: Researcher に調査を依頼
Phase 2: Architect-Plan に設計を依頼
Phase 3: Designer にモックアップ作成を依頼
Phase 4: Senior-Coder に並列実装を依頼
Phase 5: Review-Guardian にレビューを依頼
Phase 6: Content-Writer にコンテンツ執筆を依頼
Phase 7: Marketing にSEO最適化を依頼
Phase 8: 最終統合と完了報告

進捗は docs/project_status.md に記録してください。
```

---

## 各エージェント呼び出しプロンプト

### Requirements-Analyst
```
Requirements-Analyst として、PRP.md を分析し：
1. 曖昧な点をリストアップ
2. 確認が必要な質問を作成
3. docs/requirements.md に詳細要件を出力
```

### Researcher  
```
Researcher として、requirements.md を参照し：
1. 競合3社を分析
2. 市場データを収集
3. research/ に結果を保存
```

### Architect-Plan
```
Architect-Plan として、research/ を参照し：
1. 技術スタックを選定
2. spec/implementation_plan.md に実装プランを作成
3. 並列トラックに分割
```

### Designer
```
Designer として、Nano Banana を使用し：
1. resources/mockups/ にUIモックアップを生成
2. docs/design_system.md を作成
```

### Senior-Coder (並列起動 Ctrl+B)
```
Senior-Coder (Track A) として：
1. resources/mockups/ を参照
2. [担当範囲] を実装
3. 完了したら「Track A: Complete」と報告
```

### Review-Guardian
```
Review-Guardian として：
1. src/ のコードをレビュー
2. 問題があればCoderに差し戻し
3. 「Review Passed」を報告
```

### Content-Writer
```
Content-Writer として：
1. research/ の調査結果を参照
2. src/content/ にWebコンテンツを執筆
```

### Marketing
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
PRP.md を読み、Requirements-Analyst → Researcher → Architect → Designer
→ Coder → Review → Content-Writer → Marketing の順で
各エージェントに指示を出し、プロジェクトを完遂してください。
```

---
*See: [agents.json](../config/agents.json)*
