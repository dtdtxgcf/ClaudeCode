#!/usr/bin/env bash
# export-claude-chats.sh
# Export ALL your claude.ai / Claude Desktop conversations via the internal API.
#
# Auth: claude.ai session cookie `sessionKey` (starts with sk-ant-sid01-...)
#
# How to get the cookie:
#   1. Open claude.ai in a browser where you're logged in
#   2. DevTools (Cmd+Opt+I on Mac) → Application → Cookies → https://claude.ai
#   3. Copy value of `sessionKey`
#
# Usage:
#   CLAUDE_SESSION_KEY='sk-ant-sid01-...' bash export-claude-chats.sh
#   # or save to ~/.claude/claude-ai-session (just the key, no quotes)
#
# Optional env:
#   OUTPUT_DIR=/some/path        (default ~/Downloads/claude-chats-<YYYY-MM-DD>)
#   SKIP_ZIP=1                   don't zip at the end
#   RATE_SLEEP=0.3               seconds between chat fetches (be nice to API)

set -u

OUTPUT_DIR="${OUTPUT_DIR:-$HOME/Downloads/claude-chats-$(date +%Y-%m-%d)}"
SESSION_KEY="${CLAUDE_SESSION_KEY:-}"
RATE_SLEEP="${RATE_SLEEP:-0.3}"
SESSION_FILE="$HOME/.claude/claude-ai-session"

if [ -z "$SESSION_KEY" ] && [ -f "$SESSION_FILE" ]; then
  SESSION_KEY="$(tr -d '\n\r ' < "$SESSION_FILE")"
fi

if [ -z "$SESSION_KEY" ]; then
  cat >&2 <<'MSG'
ERROR: no session key.

Get your claude.ai sessionKey cookie:
  1. Open https://claude.ai in a browser where you're logged in
  2. DevTools (Cmd+Opt+I on Mac) → Application tab → Cookies → https://claude.ai
  3. Copy the value of `sessionKey` (starts with sk-ant-sid01-)

Then either:
  CLAUDE_SESSION_KEY='sk-ant-sid01-...' bash export-claude-chats.sh

Or save once for reuse:
  mkdir -p ~/.claude && echo 'sk-ant-sid01-...' > ~/.claude/claude-ai-session
  bash export-claude-chats.sh
MSG
  exit 1
fi

for bin in curl jq; do
  command -v "$bin" >/dev/null 2>&1 || { echo "missing: $bin (brew install $bin)" >&2; exit 1; }
done

API="https://claude.ai"
UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
CURL_ARGS=(
  -sS --compressed --fail
  -H "User-Agent: $UA"
  -H "Accept: application/json"
  -H "Cookie: sessionKey=$SESSION_KEY"
)

mkdir -p "$OUTPUT_DIR/json" "$OUTPUT_DIR/markdown"

echo "→ Fetching orgs..."
ORGS_JSON="$(curl "${CURL_ARGS[@]}" "$API/api/organizations")" || {
  echo "ERROR: org fetch failed. Session key might be invalid or expired." >&2
  exit 1
}
ORG_ID="$(echo "$ORGS_JSON" | jq -r '.[0].uuid // empty')"
if [ -z "$ORG_ID" ]; then
  echo "ERROR: no org_id. Response: $ORGS_JSON" >&2
  exit 1
fi
echo "  org_id: $ORG_ID"

echo "→ Fetching chat list..."
CHATS_JSON="$(curl "${CURL_ARGS[@]}" "$API/api/organizations/$ORG_ID/chat_conversations")" || {
  echo "ERROR: chat list fetch failed" >&2
  exit 1
}
CHAT_COUNT="$(echo "$CHATS_JSON" | jq 'length')"
echo "  found $CHAT_COUNT chats"

# Save the index
echo "$CHATS_JSON" | jq '.' > "$OUTPUT_DIR/index.json"

# Summary for humans
: > "$OUTPUT_DIR/summary.txt"

i=0
fail=0
while IFS= read -r chat; do
  i=$((i + 1))
  UUID="$(echo "$chat" | jq -r '.uuid')"
  NAME="$(echo "$chat" | jq -r '.name // "untitled"')"
  CREATED="$(echo "$chat" | jq -r '.created_at // empty')"
  UPDATED="$(echo "$chat" | jq -r '.updated_at // empty')"

  # Date: use updated_at if available (most recent), else created_at
  RAW_DATE="${UPDATED:-$CREATED}"
  if [ -n "$RAW_DATE" ]; then
    DATE="$(date -d "$RAW_DATE" +%Y-%m-%d 2>/dev/null || date -jf "%Y-%m-%dT%H:%M:%S" "${RAW_DATE%.*}" +%Y-%m-%d 2>/dev/null || echo "undated")"
  else
    DATE="undated"
  fi

  # Sanitize name for filesystem
  SAFE_NAME="$(echo "$NAME" | tr -d '/\\:*?"<>|\n\r' | sed -E 's/[[:space:]]+/ /g; s/^ //; s/ $//' | head -c 80)"
  [ -z "$SAFE_NAME" ] && SAFE_NAME="untitled"

  BASE="${DATE}-${SAFE_NAME}-${UUID:0:8}"
  JSON_OUT="$OUTPUT_DIR/json/${BASE}.json"
  MD_OUT="$OUTPUT_DIR/markdown/${BASE}.md"

  printf '[%d/%d] %s  %s\n' "$i" "$CHAT_COUNT" "$DATE" "$NAME"
  printf '%s  %s  %s\n' "$DATE" "$UUID" "$NAME" >> "$OUTPUT_DIR/summary.txt"

  DETAIL="$(curl "${CURL_ARGS[@]}" "$API/api/organizations/$ORG_ID/chat_conversations/$UUID?tree=True&rendering_mode=messages" 2>/dev/null)" || {
    echo "    ! fetch failed" >&2
    fail=$((fail + 1))
    continue
  }

  echo "$DETAIL" | jq '.' > "$JSON_OUT" 2>/dev/null || {
    echo "    ! bad JSON response" >&2
    fail=$((fail + 1))
    continue
  }

  # Render Markdown
  {
    printf '---\n'
    printf 'title: %s\n' "$(jq -r '.name' "$JSON_OUT" | tr -d '\n')"
    printf 'uuid: %s\n' "$UUID"
    printf 'created_at: %s\n' "$CREATED"
    printf 'updated_at: %s\n' "$UPDATED"
    printf 'source: claude.ai\n'
    printf -- '---\n\n'
    printf '# %s\n\n' "$(jq -r '.name' "$JSON_OUT")"
    printf '> created: %s | updated: %s\n\n' "$CREATED" "$UPDATED"
    jq -r '
      .chat_messages[]? |
      "## \(.sender | ascii_upcase)\n\n" +
      (
        [.content[]? | select(.type=="text") | .text] | join("\n\n")
      ) + "\n"
    ' "$JSON_OUT"
  } > "$MD_OUT"

  sleep "$RATE_SLEEP"
done < <(echo "$CHATS_JSON" | jq -c '.[]')

# README
cat > "$OUTPUT_DIR/README.md" <<README
# claude.ai / Claude Desktop 对话导出

- 导出时间：$(date -Iseconds 2>/dev/null || date)
- Chat 总数：$CHAT_COUNT
- 失败数：$fail
- 账户 org_id：$ORG_ID

## 文件

| 路径 | 说明 |
|------|------|
| \`index.json\`      | 所有 chat 的元信息（name/uuid/created_at/updated_at） |
| \`summary.txt\`     | 人类可读索引 |
| \`json/*.json\`     | 每个 chat 的完整 API 响应（含所有 messages 树） |
| \`markdown/*.md\`   | 每个 chat 的易读 Markdown |

## 文件命名

\`YYYY-MM-DD-<chat名称>-<uuid前8位>.md\`

日期取 updated_at（最近编辑时间），fallback 到 created_at。

## 源

Internal API: \`https://claude.ai/api/organizations/{org}/chat_conversations\`
README

# Zip
if [ "${SKIP_ZIP:-0}" != "1" ]; then
  ZIP_PATH="$(dirname "$OUTPUT_DIR")/$(basename "$OUTPUT_DIR").zip"
  if command -v zip >/dev/null 2>&1; then
    (cd "$(dirname "$OUTPUT_DIR")" && zip -rq "$ZIP_PATH" "$(basename "$OUTPUT_DIR")")
    echo "→ ZIP: $ZIP_PATH"
  fi
fi

echo ""
echo "Done."
echo "  Output: $OUTPUT_DIR"
echo "  Total: $CHAT_COUNT, Failed: $fail"
