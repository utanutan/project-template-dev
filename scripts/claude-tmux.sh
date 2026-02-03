#!/bin/bash
# ============================================
# Claude Tmux Wrapper
# ============================================
# claudeコマンドを自動的にtmuxセッション内で起動する
#
# インストール:
#   sudo ln -sf $(pwd)/scripts/claude-tmux.sh /usr/local/bin/claude-tmux
#   # または claude コマンド自体を置き換える場合:
#   sudo mv /usr/local/bin/claude /usr/local/bin/claude-original
#   sudo ln -sf $(pwd)/scripts/claude-tmux.sh /usr/local/bin/claude
#
# Usage: claude-tmux [claude options...]
# Example: claude-tmux --dangerously-skip-permissions "your prompt"

# オリジナルの claude コマンドのパス
CLAUDE_CMD="${CLAUDE_ORIGINAL:-claude-original}"

# claude-original が存在しない場合は claude を使用
if ! command -v "$CLAUDE_CMD" &> /dev/null; then
    CLAUDE_CMD="claude"
fi

# 既にtmux内にいる場合はそのまま実行
if [ -n "$TMUX" ]; then
    exec "$CLAUDE_CMD" "$@"
fi

# tmux がインストールされていない場合はそのまま実行
if ! command -v tmux &> /dev/null; then
    echo "Warning: tmux not found, running claude directly"
    exec "$CLAUDE_CMD" "$@"
fi

# セッション名を生成（現在のディレクトリ名ベース）
DIR_NAME=$(basename "$(pwd)")
BASE_SESSION_NAME="claude-${DIR_NAME}"

# 一意のセッション名を生成する関数
generate_unique_session_name() {
    local base_name="$1"
    local session_name="$base_name"
    local counter=2

    # 同名セッションが存在する場合は連番を付ける
    while tmux has-session -t "$session_name" 2>/dev/null; do
        session_name="${base_name}-${counter}"
        counter=$((counter + 1))
    done

    echo "$session_name"
}

# 一意のセッション名を取得
SESSION_NAME=$(generate_unique_session_name "$BASE_SESSION_NAME")

# 新しいセッションを作成してアタッチ
exec tmux new-session -s "$SESSION_NAME" -n "claude" "$CLAUDE_CMD $*; exec bash"
