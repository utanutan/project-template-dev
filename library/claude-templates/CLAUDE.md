# Antigravity Life OS - Claude Code Configuration

このプロジェクトはマルチエージェント・オーケストレーション（11エージェント構成）を採用。

---

## Agent Team

| Role | Mission | 呼び出し例 |
|------|---------|-----------|
| **Project-Manager** | 統括・進行管理 | 「PMとしてプロジェクト管理して」 |
| **Requirements-Analyst** | 要件明確化 | 「Analystとして要件を整理して」 |
| **Researcher** | 調査・分析 | 「Researcherとして調査して」 |
| **Architect-Plan** | 技術設計 | 「Architectとして設計して」 |
| **Designer** | UIデザイン | 「Designerとしてモックアップ作成」 |
| **Senior-Coder** | 実装 | 「Coderとして実装して」 |
| **Review-Guardian** | レビュー | 「Guardianとしてレビューして」 |
| **Spec-Writer** | 技術ドキュメント | 「Spec-Writerとして仕様書作成」 |
| **Content-Writer** | コンテンツ | 「Content-Writerとして記事作成」 |
| **Marketing** | SEO/マーケ | 「Marketingとして最適化して」 |

---

## Workflow

```
User → PRP → PM → RA → Researcher → Architect → Designer 
                                      → Coder → Review → Marketing → 完了
```

---

## Rules

1. **バックグラウンド起動**: `Ctrl+B`
2. **並列実行**: 独立タスクは3つ以上同時起動
3. **デザイン参照**: Coderは `resources/mockups/` を必ず参照
4. **レビューループ**: Guardian ↔ Coder 間で完結

---

## Project Structure

```
docs/              # PRP, requirements, marketing_strategy
spec/              # 実装プラン
research/          # 調査結果
resources/mockups/ # デザイン
src/               # ソースコード
```

---

## References

- [GUILD_REFERENCE.md](library/docs/GUILD_REFERENCE.md)
- [PM_ORCHESTRATION.md](library/docs/PM_ORCHESTRATION.md)
- [QUICKSTART.md](QUICKSTART.md)
