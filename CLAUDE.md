# Antigravity Life OS - Claude Code Configuration

このプロジェクトはマルチエージェント・オーケストレーションを採用しています。

---

## Agent Roles

| Role | Mission | 呼び出し例 |
|------|---------|-----------|
| **Architect-Plan** | 設計・計画・タスク分割 | 「Architectとして設計して」 |
| **Senior-Coder** | 実装・テスト作成 | 「Coderとして実装して」 |
| **Review-Guardian** | コードレビュー・品質保証 | 「Guardianとしてレビューして」 |
| **Spec-Writer** | ドキュメント作成 | 「Writerとしてドキュメント化」 |

---

## Workflow Rules

1. **バックグラウンドタスク** (`Ctrl+B`)
   - 「メインスレッドを汚さないよう、このセッション内で完結させてください」
   - 完了時は「要約のみ報告」

2. **並列実行**
   - 独立したタスクは同時に3つ以上起動可能
   - Trackで分けて管理（Track A: Frontend, Track B: Backend など）

3. **レビューサイクル**
   - Coder → Guardian → 修正 → Guardian（サブエージェント間で完結）

---

## Directory Structure

```
config/agents.json       # エージェント定義（リファレンス）
library/docs/            # ドキュメント・テンプレート
spec/                    # 実装プラン
projects/                # アクティブプロジェクト
```

---

## Quick Commands

```bash
# 新規プロジェクト作成
./scripts/init-project.sh <name> --type dev|creative|life
```

---

## References

- [GUILD_REFERENCE.md](library/docs/GUILD_REFERENCE.md) - 詳細仕様
- [QUICKSTART.md](library/docs/QUICKSTART.md) - 実行手順
- [WORKFLOW_EXAMPLES.md](library/docs/WORKFLOW_EXAMPLES.md) - プロンプト例
