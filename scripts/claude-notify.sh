#!/bin/bash
# =============================================================================
# claude-notify.sh - Claude Code Hook: Slack通知スクリプト
# =============================================================================
# Claude Code Hooks (Notification) から呼ばれ、Slackに通知を送信する。
# stdinからJSONを受け取り、notification_type に応じたメッセージを構築。
#
# 使用方法（テスト）:
#   echo '{"notification_type":"idle_prompt","message":"test","cwd":"/home/user/project"}' | bash scripts/claude-notify.sh
#
# 設定:
#   library/config/notification.env に SLACK_BOT_TOKEN, SLACK_CHANNEL_ID を設定すること
# =============================================================================

set -euo pipefail

# Git Bash from .cmd wrapper may lack PATH setup; ensure standard dirs are available
export PATH="/usr/bin:/usr/local/bin:/bin:$PATH"

SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/../library/config/notification.env"

# 設定読み込み
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
else
    echo "Warning: notification.env not found at $CONFIG_FILE" >&2
    exit 0
fi

# SLACK_BOT_TOKEN / SLACK_CHANNEL_ID が未設定なら何もしない
SLACK_BOT_TOKEN="${SLACK_BOT_TOKEN:-}"
SLACK_CHANNEL_ID="${SLACK_CHANNEL_ID:-}"
if [[ -z "$SLACK_BOT_TOKEN" || -z "$SLACK_CHANNEL_ID" ]]; then
    echo "Warning: SLACK_BOT_TOKEN or SLACK_CHANNEL_ID is not configured" >&2
    exit 0
fi

# 通知が無効なら何もしない
NOTIFICATION_ENABLED="${NOTIFICATION_ENABLED:-true}"
if [[ "$NOTIFICATION_ENABLED" != "true" ]]; then
    exit 0
fi

# jq が必要
if ! command -v jq &> /dev/null; then
    echo "Warning: jq is required but not installed" >&2
    exit 0
fi

# stdin から JSON を読み取り
input=$(cat)

# フィールド抽出
type=$(echo "$input" | jq -r '.notification_type // .type // "unknown"')
message=$(echo "$input" | jq -r '.message // "Claude Code notification"')
session_id=$(echo "$input" | jq -r '.session_id // ""')
cwd=$(echo "$input" | jq -r '.cwd // ""')
transcript_path=$(echo "$input" | jq -r '.transcript_path // ""')

# トランスクリプトから実際の確認内容を抽出
detail=""
if [[ -n "$transcript_path" && -f "$transcript_path" ]]; then
    # 最新のassistantメッセージからツール呼び出しを取得
    last_tool=$(tail -10 "$transcript_path" | \
        jq -r 'select(.type == "assistant") | .message.content[]? | select(.type == "tool_use") | .name + "|||" + (.input | tostring)' 2>/dev/null | \
        tail -1)

    if [[ -n "$last_tool" ]]; then
        tool_name="${last_tool%%|||*}"
        tool_input="${last_tool#*|||}"

        case "$tool_name" in
            Bash)
                detail=$(echo "$tool_input" | jq -r '.command // "" | .[0:200]' 2>/dev/null)
                [[ -n "$detail" ]] && detail="\`${detail}\`"
                ;;
            AskUserQuestion)
                detail=$(echo "$tool_input" | jq -r '.questions[0].question // ""' 2>/dev/null)
                ;;
            Edit|Write)
                file_path=$(echo "$tool_input" | jq -r '.file_path // ""' 2>/dev/null)
                [[ -n "$file_path" ]] && detail="📄 \`$(basename "$file_path")\`"
                ;;
            Read)
                file_path=$(echo "$tool_input" | jq -r '.file_path // ""' 2>/dev/null)
                [[ -n "$file_path" ]] && detail="📖 \`$(basename "$file_path")\`"
                ;;
            *)
                detail="$tool_name"
                ;;
        esac
    fi
fi

# detail が取れなかったらフォールバック
if [[ -z "$detail" ]]; then
    detail="$message"
fi

# notification_type に応じた絵文字とラベル
case "$type" in
    permission_prompt)  emoji="🔐"; label="権限確認" ;;
    idle_prompt)        emoji="⏳"; label="入力待ち" ;;
    elicitation_dialog) emoji="❓"; label="質問" ;;
    *)                  emoji="🔔"; label="通知" ;;
esac

# プロジェクト名: cwd から抽出（Hook入力 > pwd フォールバック）
if [[ -n "$cwd" ]]; then
    project_dir=$(basename "$cwd")
else
    project_dir=$(basename "$(pwd)" 2>/dev/null || echo "unknown")
fi

# セッション識別子: tmuxセッション名 > session_id短縮
if [[ -n "${TMUX:-}" ]]; then
    session_label=$(tmux display-message -p '#S:#W' 2>/dev/null || echo "tmux")
elif [[ -n "$session_id" ]]; then
    session_label="${session_id:0:8}"
else
    session_label="cli"
fi

# Slack メッセージ構築（実改行で組み立て、jq で安全にJSON化）
if [[ -n "${TMUX:-}" ]]; then
    tmux_session=$(tmux display-message -p '#S' 2>/dev/null || echo "")
    text=$(printf '%s *%s*\n📂 %s  |  🏷️ %s\n\n%s\n\n`tmux attach -t %s`' \
        "$emoji" "$label" "$project_dir" "$session_label" "$detail" "$tmux_session")
else
    text=$(printf '%s *%s*\n📂 %s  |  🏷️ %s\n\n%s' \
        "$emoji" "$label" "$project_dir" "$session_label" "$detail")
fi

payload=$(jq -n --arg channel "$SLACK_CHANNEL_ID" --arg text "$text" \
    '{channel: $channel, text: $text}')

# Slack chat.postMessage API で送信
curl -s -X POST "https://slack.com/api/chat.postMessage" \
    -H "Authorization: Bearer $SLACK_BOT_TOKEN" \
    -H 'Content-Type: application/json' \
    -d "$payload" \
    > /dev/null 2>&1 || {
    echo "Warning: Failed to send Slack notification" >&2
}

exit 0
