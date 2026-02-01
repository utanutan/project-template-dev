# PM Agent リモート運用ワークフロー

## 概要

PMエージェントをリモートから監視・操作するためのワークフロー。  
Slack通知＋tmux＋SSHで、外出中でもユーザー確認に即座に対応可能。

---

## 事前準備

### 1. Slack Webhook URL設定

```bash
# 設定ファイルを編集
vi library/config/notification.env

# 以下を設定
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/XXXX/XXXX/XXXX"
```

**取得方法**: [Slack API](https://api.slack.com/apps) → Create App → Incoming Webhooks

### 2. tmux確認

```bash
tmux -V  # インストール確認
```

---

## 運用フロー

### 朝の起動

```bash
# tmuxセッション作成
tmux new -s pm

# Claude Watcher経由でPM起動
cd ~/project-template-dev
./scripts/claude-watcher.sh
```

### 外出中の対応

1. **Slack通知を受信**
2. **Termius/SSH接続** → `tmux a -t pm`
3. **回答入力**（y/n など）
4. **デタッチ** → `Ctrl+b` → `d`

---

## 便利コマンド

| 操作 | コマンド |
|------|---------|
| セッション作成 | `tmux new -s pm` |
| セッション一覧 | `tmux ls` |
| アタッチ | `tmux a -t pm` |
| デタッチ | `Ctrl+b` → `d` |
| セッション終了 | `tmux kill-session -t pm` |

---

## トラブルシューティング

| 問題 | 対処 |
|------|------|
| Slack通知が来ない | `notification.env`のURL確認、`curl`インストール確認 |
| tmuxセッションが見つからない | `tmux ls`で確認、サーバー再起動していないか確認 |
