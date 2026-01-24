# Antigravity Life OS - クイックスタートガイド

11エージェント構成のマルチエージェントシステムを動かす手順。

---

## 🚀 Step 1: プロジェクト作成

```bash
./projects/scripts/init-project.sh my-app --type dev
cd projects/my-app
```

---

## 📋 Step 2: PRP作成

`docs/PRP.md` に要件を記載

---

## 🎯 Step 3: PMに全体を任せる（推奨）

```
あなたは Project-Manager です。
docs/PRP.md を読み、全フェーズを実行してください：
RA → Researcher → Architect → Designer → Coder → Review → Marketing
```

---

## ⚡ Step 4: 並列エージェント起動（別ターミナルで管理）

```bash
# 並列コーダー起動（Track A, B + Reviewer）
./projects/scripts/launch-agents.sh my-app --agents parallel-coders

# 全エージェント起動
./projects/scripts/launch-agents.sh my-app --agents full-team

# 個別指定
./projects/scripts/launch-agents.sh my-app --agents coder-a,coder-b,reviewer
```

各エージェントは**別々のTerminalウィンドウ**で起動されます。

---

## 📌 クイックリファレンス

| 操作 | コマンド |
|------|----------|
| プロジェクト作成 | `./projects/scripts/init-project.sh <name>` |
| 並列エージェント起動 | `./projects/scripts/launch-agents.sh <name> --agents <agents>` |
| バックグラウンド起動 | `Ctrl+B` |

### 利用可能エージェント

| Agent | 役割 | launch-agents引数 |
|-------|------|-------------------|
| PM | 統括 | `pm` |
| RA | 要件分析 | `ra` |
| Researcher | 調査 | `researcher` |
| Architect | 技術設計 | `architect` |
| Designer | UIデザイン | `designer` |
| Coder A | 実装 (Frontend) | `coder-a` |
| Coder B | 実装 (Backend) | `coder-b` |
| Guardian | レビュー | `reviewer` |
| Marketing | SEO/マーケ | `marketing` |

### プリセット

| Preset | 内容 |
|--------|------|
| `parallel-coders` | coder-a, coder-b, reviewer |
| `full-team` | 全エージェント |

---

*See: [GUILD_REFERENCE](library/docs/GUILD_REFERENCE.md) | [PM_ORCHESTRATION](library/docs/PM_ORCHESTRATION.md)*
