#!/usr/bin/env bash
# PreToolUse хук (Edit|Write): блокирует правку защищённых файлов проекта.

FILE_PATH=$(jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

BASENAME=$(basename "$FILE_PATH")

if [ "$BASENAME" = ".env" ] || [ "$BASENAME" = ".env.local" ] || [ "$BASENAME" = "package-lock.json" ] || [[ "$FILE_PATH" == *"apps/backend/prisma/migrations/"* ]]; then
  echo "Заблокировано: $FILE_PATH — защищённый файл" >&2
  exit 2
fi

exit 0
