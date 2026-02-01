#!/bin/bash
# =============================================================================
# claude-watcher.sh - Claude出力監視・通知スクリプト
# =============================================================================
# PMエージェント起動時にユーザー確認が発生した場合、Slack通知+音声で知らせる
#
# 使用方法:
#   ./claude-watcher.sh [claude引数...]
#
# 例:
#   ./claude-watcher.sh
#   ./claude-watcher.sh -p "あなたはPMです..."
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/../library/config/notification.env"

# 設定読み込み
if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
else
  echo "⚠️  設定ファイルが見つかりません: $CONFIG_FILE"
  echo "   notification.env を作成してください"
fi

# デフォルト値
SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL:-}"
NOTIFICATION_SOUND="${NOTIFICATION_SOUND:-/mnt/c/Windows/Media/notify.wav}"
NOTIFICATION_ENABLED="${NOTIFICATION_ENABLED:-true}"

# 通知パターン（これらを検知したら通知）
NOTIFY_PATTERNS=(
  "(y/n)"
  "(Y/n)"
  "?"
  "【ユーザー確認】"
  "approval"
  "waiting for"
  "Please confirm"
  "続行しますか"
  "よろしいですか"
)

# 通知関数
send_notification() {
  local message="$1"
  
  if [[ "$NOTIFICATION_ENABLED" != "true" ]]; then
    return
  fi
  
  # Slack通知
  if [[ -n "$SLACK_WEBHOOK_URL" ]]; then
    curl -s -X POST -H 'Content-type: application/json' \
      --data "{\"text\":\"🤖 Claude確認依頼:\\n\`\`\`${message}\`\`\`\"}" \
      "$SLACK_WEBHOOK_URL" > /dev/null 2>&1 &
  fi
  
  # Windows音声（WSL2の場合のみ）
  if [[ -f "/mnt/c/Windows/System32/cmd.exe" ]] && [[ -n "$NOTIFICATION_SOUND" ]]; then
    powershell.exe -c "(New-Object Media.SoundPlayer '$NOTIFICATION_SOUND').PlaySync()" > /dev/null 2>&1 &
  fi
}

# パターンマッチ関数
should_notify() {
  local line="$1"
  for pattern in "${NOTIFY_PATTERNS[@]}"; do
    if [[ "$line" == *"$pattern"* ]]; then
      return 0
    fi
  done
  return 1
}

# メイン処理
main() {
  echo "🔔 Claude Watcher 起動"
  echo "   Slack通知: ${SLACK_WEBHOOK_URL:+有効}${SLACK_WEBHOOK_URL:-無効（URL未設定）}"
  echo "   音声通知: $([ -f "/mnt/c/Windows/System32/cmd.exe" ] && echo "有効(WSL2)" || echo "無効")"
  echo "---"
  
  # Claude実行＆出力監視
  claude "$@" 2>&1 | while IFS= read -r line; do
    echo "$line"
    
    # 確認待ちパターン検知
    if should_notify "$line"; then
      send_notification "$line"
    fi
  done
}

main "$@"
