#!/bin/bash
# 個人セッション記録の新規作成
#
# Usage:
#   ./scripts/new-session-note.sh <project-name>
#   ./scripts/new-session-note.sh my-app
#
# 保存先:
#   1. Obsidian vault (優先): ~/.obsidian-vault/Sanctum/30_Insight/
#   2. フォールバック:        ~/logs/notes/

set -euo pipefail

PROJECT_NAME="${1:-general}"
DATE=$(date +%Y-%m-%d)
TEMPLATE_DIR="$(cd "$(dirname "$0")/../templates" && pwd)"
FALLBACK_DIR="$HOME/logs/notes"
OBSIDIAN_DIR="$HOME/.obsidian-vault/Sanctum/30_Insight"

# Obsidian vault が使えるか判定（存在 + 書き込み権限）
if [ -d "$OBSIDIAN_DIR" ] && [ -w "$OBSIDIAN_DIR" ]; then
  NOTE_DIR="$OBSIDIAN_DIR"
else
  NOTE_DIR="$FALLBACK_DIR"
  if [ -d "$OBSIDIAN_DIR" ]; then
    echo "Obsidian vault not writable, using fallback: $NOTE_DIR"
  else
    echo "Obsidian vault not found, using fallback: $NOTE_DIR"
  fi
fi

NOTE_FILE="$NOTE_DIR/${DATE}_${PROJECT_NAME}_session.md"

mkdir -p "$NOTE_DIR"
mkdir -p "$FALLBACK_DIR"

if [ -f "$NOTE_FILE" ]; then
  echo "Already exists: $NOTE_FILE"
else
  sed "s/{{DATE}}/$DATE/g; s/{{PROJECT_NAME}}/$PROJECT_NAME/g" \
    "$TEMPLATE_DIR/session-note.md" > "$NOTE_FILE"
  echo "Created: $NOTE_FILE"

  # Obsidianに保存した場合、フォールバック先にもコピー
  if [ "$NOTE_DIR" = "$OBSIDIAN_DIR" ]; then
    cp "$NOTE_FILE" "$FALLBACK_DIR/"
    echo "Backup:  $FALLBACK_DIR/$(basename "$NOTE_FILE")"
  fi
fi

# エディタが設定されていれば開く
if [ -n "${EDITOR:-}" ]; then
  "$EDITOR" "$NOTE_FILE"
fi
