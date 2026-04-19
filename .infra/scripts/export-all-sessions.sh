#!/usr/bin/env bash
# export-all-sessions.sh
# Bulk export of ALL Claude Code transcripts (JSONL source + readable Markdown).
# Designed for one-shot archival — no Haiku calls, no network, just extraction.
#
# Usage on Mac:
#   bash export-all-sessions.sh                           # default: ~/Downloads/claude-archive-<today>/
#   OUTPUT_DIR=~/somewhere bash export-all-sessions.sh    # custom output
#   SKIP_ZIP=1 bash ...                                   # keep folder, don't zip
#   INCLUDE_HEADLESS=1 bash ...                           # include claude -p sub-sessions
#
# Outputs:
#   <OUTPUT_DIR>/
#   ├── README.md
#   ├── summary.txt
#   ├── jsonl/<project>/*.jsonl
#   ├── markdown/<project>/*.md
#   └── (optional) claude-archive-<date>.zip  (sibling of OUTPUT_DIR)

set -u

PROJECTS_DIR="${CLAUDE_PROJECTS_DIR:-$HOME/.claude/projects}"
TODAY="$(date +%Y-%m-%d)"
OUTPUT_DIR="${OUTPUT_DIR:-$HOME/Downloads/claude-archive-$TODAY}"

if [ ! -d "$PROJECTS_DIR" ]; then
  echo "projects dir not found: $PROJECTS_DIR" >&2
  exit 1
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "jq required. Install: brew install jq" >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR/jsonl" "$OUTPUT_DIR/markdown"
: > "$OUTPUT_DIR/summary.txt"

total=0
real=0
headless=0

while IFS= read -r -d '' FILE; do
  case "$FILE" in */subagents/*) continue ;; esac
  total=$((total + 1))

  PROJECT="$(basename "$(dirname "$FILE")")"
  SID="$(basename "$FILE" .jsonl)"
  MTIME="$(stat -c %Y "$FILE" 2>/dev/null || stat -f %m "$FILE" 2>/dev/null || echo 0)"
  DATE_FULL="$(date -d "@$MTIME" +%Y-%m-%d 2>/dev/null || date -r "$MTIME" +%Y-%m-%d 2>/dev/null || echo "$TODAY")"
  DATE_SHORT="$(date -d "@$MTIME" +%y-%m-%d 2>/dev/null || date -r "$MTIME" +%y-%m-%d 2>/dev/null || echo "unknown")"
  TIME="$(date -d "@$MTIME" +%H:%M 2>/dev/null || date -r "$MTIME" +%H:%M 2>/dev/null || echo "00:00")"

  U_COUNT="$(jq -s '[.[] | select(.type=="user")] | length' "$FILE" 2>/dev/null || echo 0)"
  A_COUNT="$(jq -s '[.[] | select(.type=="assistant")] | length' "$FILE" 2>/dev/null || echo 0)"

  IS_HEADLESS=0
  if [ "${U_COUNT:-0}" -le 1 ]; then
    IS_HEADLESS=1
    headless=$((headless + 1))
  else
    real=$((real + 1))
  fi

  if [ "$IS_HEADLESS" = "1" ] && [ "${INCLUDE_HEADLESS:-0}" != "1" ]; then
    continue
  fi

  # 1. Copy raw JSONL
  mkdir -p "$OUTPUT_DIR/jsonl/$PROJECT"
  cp "$FILE" "$OUTPUT_DIR/jsonl/$PROJECT/$SID.jsonl"

  # 2. Extract first user prompt (first 120 chars) for index
  FIRST_USER="$(jq -r '
    select(.type=="user") | (.message.content // "")
    | if type=="string" then . else ([.[]? | select(.type=="text") | .text] | join(" ")) end
    | select(length > 0)
  ' "$FILE" 2>/dev/null | head -1 | tr -d '\n' | head -c 120)"

  printf '%s  %s  %s  user=%s assistant=%s  project=%s  sid=%s\n    %s\n\n' \
    "$DATE_FULL" "$TIME" "$SID" "$U_COUNT" "$A_COUNT" "$PROJECT" "$SID" "$FIRST_USER" \
    >> "$OUTPUT_DIR/summary.txt"

  # 3. Generate readable MD (no Haiku summary — plain dump)
  mkdir -p "$OUTPUT_DIR/markdown/$PROJECT"
  MD_OUT="$OUTPUT_DIR/markdown/$PROJECT/${DATE_SHORT}-${TIME//:/-}-${SID:0:8}.md"

  CONVO="$(jq -r '
    select(.type == "user" or .type == "assistant")
    | . as $ev
    | (.message.content // []) as $c
    | if ($c | type) == "array" then
        [$c[] | select(.type == "text") | .text] | join("\n\n")
      else
        ($c | tostring)
      end
    | select(length > 0)
    | "**\($ev.type | ascii_upcase)**:\n\n\(.)\n"
  ' "$FILE" 2>/dev/null)"

  {
    printf -- '---\n'
    printf 'date: %s\n' "$DATE_FULL"
    printf 'time: "%s"\n' "$TIME"
    printf 'session_id: %s\n' "$SID"
    printf 'project: %s\n' "$PROJECT"
    printf 'user_messages: %s\n' "$U_COUNT"
    printf 'assistant_messages: %s\n' "$A_COUNT"
    printf 'headless: %s\n' "$IS_HEADLESS"
    printf 'type: claude-session-export\n'
    printf -- '---\n\n'
    printf '# %s %s — %s\n\n' "$DATE_FULL" "$TIME" "$SID"
    printf '> project: `%s` | user msgs: %s | assistant msgs: %s%s\n\n' \
      "$PROJECT" "$U_COUNT" "$A_COUNT" \
      "$([ "$IS_HEADLESS" = "1" ] && echo ' | **headless (claude -p sub-session)**' || echo '')"
    printf '## 对话\n\n%s\n' "$CONVO"
  } > "$MD_OUT"

done < <(find "$PROJECTS_DIR" -type f -name '*.jsonl' -print0 2>/dev/null | sort -z)

# README
cat > "$OUTPUT_DIR/README.md" <<README
# Claude Code 对话存档 — $TODAY

- 总 transcript 数：$total
- 真实用户会话（user messages > 1）：$real
- Headless 子会话（\`claude -p\` 调用）：$headless  $([ "${INCLUDE_HEADLESS:-0}" = "1" ] && echo "（已包含）" || echo "（已跳过，如要包含设 INCLUDE_HEADLESS=1）")

## 目录

| 路径 | 说明 |
|------|------|
| \`jsonl/\`     | Claude Code 原始 JSONL transcript，每行一个事件（user/assistant/tool_use/tool_result/thinking）|
| \`markdown/\`  | 可读 Markdown，仅保留 user/assistant 的 text 块（不含 tool_use 细节、thinking）|
| \`summary.txt\`| 所有 session 的索引：日期、时间、session_id、首条用户消息 |

## 项目列表

$(ls "$OUTPUT_DIR/jsonl" 2>/dev/null | sed 's/^/- `/;s/$/`/')

## 源路径

\`$PROJECTS_DIR\`

## 无法本地导出的部分

以下数据不存在于本地，需要手动从 Anthropic 账户导出：

- **claude.ai 网页版对话**
- **Claude 桌面 app 对话**

操作路径（桌面/网页共用同一账户）：

1. 登录 https://claude.ai
2. Settings → Privacy → **Export data**
3. 点击"Export"，Anthropic 会把你账户下所有对话打成 ZIP 发邮件（几分钟到几小时）
4. 下载后解压，每个对话是一个 JSON，里面有完整 messages

如果只要导出**单个对话**：在该对话页面右上角 "..." → "Export chat" → 下载 Markdown/JSON。
README

# Zip
if [ "${SKIP_ZIP:-0}" != "1" ]; then
  ZIP_PATH="$(dirname "$OUTPUT_DIR")/$(basename "$OUTPUT_DIR").zip"
  (cd "$(dirname "$OUTPUT_DIR")" && zip -rq "$ZIP_PATH" "$(basename "$OUTPUT_DIR")" 2>/dev/null) && \
    echo "ZIP: $ZIP_PATH" || echo "(zip command missing — folder kept: $OUTPUT_DIR)"
fi

echo ""
echo "Done. Output: $OUTPUT_DIR"
echo "  total: $total | real: $real | headless: $headless"
