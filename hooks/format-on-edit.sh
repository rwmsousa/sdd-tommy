#!/bin/bash
# Lê o JSON do stdin enviado pelo hook PostToolUse
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

EXT="${FILE_PATH##*.}"

case "$EXT" in
  ts|tsx|js|jsx|mjs|cjs|json|css|scss|html|md|yaml|yml)
    # Tenta usar prettier local ao projeto antes do global
    PRETTIER=$(cd "$(dirname "$FILE_PATH")" && npx --no prettier --version &>/dev/null && echo "npx --no prettier" || command -v prettier 2>/dev/null)
    if [ -n "$PRETTIER" ]; then
      $PRETTIER --write "$FILE_PATH" 2>/dev/null
    fi
    ;;
  py)
    if command -v ruff &>/dev/null; then
      ruff format "$FILE_PATH" 2>/dev/null
    elif command -v black &>/dev/null; then
      black --quiet "$FILE_PATH" 2>/dev/null
    fi
    ;;
  go)
    if command -v gofmt &>/dev/null; then
      gofmt -w "$FILE_PATH" 2>/dev/null
    fi
    ;;
  rs)
    if command -v rustfmt &>/dev/null; then
      rustfmt "$FILE_PATH" 2>/dev/null
    fi
    ;;
esac

exit 0
