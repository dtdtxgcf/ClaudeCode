#!/usr/bin/env bash
# archive-session.sh
# Claude Code SessionEnd hook: archive one conversation to Obsidian as Markdown.
#
# Input (stdin JSON): { "session_id", "transcript_path", "cwd", "hook_event_name" }
# Output: writes ONE file per session to $CLAUDE_SESSIONS_DIR
#         Filename: YY-MM-DD【Claude对话】【{topic}】{title}.md
#         Default dir: ~/Documents/KnowledgeHub/<3>library/
# Logs errors to ~/.claude/hooks/archive-session.log. Never blocks hook exit.

set -u

SESSIONS_DIR="${CLAUDE_SESSIONS_DIR:-$HOME/Documents/KnowledgeHub/<3>library}"
SUMMARY_MODEL="${CLAUDE_SESSIONS_SUMMARY_MODEL:-claude-haiku-4-5}"
LOG_DIR="$HOME/.claude/hooks"
LOG_FILE="$LOG_DIR/archive-session.log"

mkdir -p "$LOG_DIR"
log() { echo "[$(date -Iseconds)] $*" >> "$LOG_FILE"; }

# Early exit paths — must not fail the hook
[ "${CLAUDE_SESSIONS_DISABLE:-0}" = "1" ] && { log "disabled via env"; exit 0; }
command -v jq >/dev/null 2>&1 || { log "jq missing, skip"; exit 0; }

INPUT="$(cat)"
SESSION_ID="$(echo "$INPUT" | jq -r '.session_id // empty')"
TRANSCRIPT="$(echo "$INPUT" | jq -r '.transcript_path // empty')"
CWD="$(echo "$INPUT" | jq -r '.cwd // empty')"

if [ -z "$SESSION_ID" ] || [ -z "$TRANSCRIPT" ] || [ ! -f "$TRANSCRIPT" ]; then
  log "missing session_id/transcript_path or transcript not found: $TRANSCRIPT"
  exit 0
fi

mkdir -p "$SESSIONS_DIR"

# Prefer transcript mtime for the date so retroactive runs use the real date,
# not today. Falls back to now if stat is unavailable.
if MTIME="$(stat -c %Y "$TRANSCRIPT" 2>/dev/null)" || MTIME="$(stat -f %m "$TRANSCRIPT" 2>/dev/null)"; then
  DATE_FULL="$(date -d "@$MTIME" +%Y-%m-%d 2>/dev/null || date -r "$MTIME" +%Y-%m-%d)"
  DATE_SHORT="$(date -d "@$MTIME" +%y-%m-%d 2>/dev/null || date -r "$MTIME" +%y-%m-%d)"
  TIME="$(date -d "@$MTIME" +%H:%M 2>/dev/null || date -r "$MTIME" +%H:%M)"
else
  DATE_FULL="$(date +%Y-%m-%d)"
  DATE_SHORT="$(date +%y-%m-%d)"
  TIME="$(date +%H:%M)"
fi

CWD_BASE="$(basename "${CWD:-unknown}")"
SHORT_ID="$(echo "$SESSION_ID" | cut -c1-8)"

# Dedup: skip if any existing file already mentions this session_id.
if ls "$SESSIONS_DIR"/*"$SHORT_ID"*.md >/dev/null 2>&1; then
  log "session $SHORT_ID already archived, skipping"
  exit 0
fi
if grep -rlFq "session_id: \`$SESSION_ID\`" "$SESSIONS_DIR" 2>/dev/null; then
  log "session $SESSION_ID already present in sessions dir, skipping"
  exit 0
fi

# Extract user/assistant text from JSONL. Skip tool_use/tool_result/thinking.
# User messages: content is a plain string. Assistant messages: content is array.
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
' "$TRANSCRIPT" 2>/dev/null)"

if [ -z "$CONVO" ]; then
  log "no user/assistant text extracted from $TRANSCRIPT"
  exit 0
fi

# Ask Haiku for structured metadata: topic tag + title + summary.
# Returns a single-line JSON so we can parse robustly.
META_PROMPT='下面是一次 Claude Code 对话记录。请输出一行 JSON（不要代码块，不要其他任何文字），严格格式：

{"topic":"<2-6字的中文主题标签，如 OpenClaw、Inbox功能、对话归档、知识库>","title":"<10-18字的中文一句话摘要，不含书名号/引号/斜杠>","summary":"<中文摘要 100-150字，含：用户需求1句 + 实际做了什么2-3条 + 产出文件或决策 + 遗留问题>"}

对话内容：

'

META_RAW="$(
  {
    printf '%s' "$META_PROMPT"
    printf '%s' "$CONVO"
  } | timeout 60s claude -p --model "$SUMMARY_MODEL" 2>>"$LOG_FILE"
)" || META_RAW=""

# Parse JSON; fallback to safe defaults if it fails.
TOPIC=""
TITLE=""
SUMMARY=""
if [ -n "$META_RAW" ]; then
  # Extract the first {...} block in case Haiku wraps it.
  META_JSON="$(echo "$META_RAW" | tr -d '\r' | grep -oE '\{.*\}' | head -1)"
  if [ -n "$META_JSON" ]; then
    TOPIC="$(echo "$META_JSON" | jq -r '.topic // empty' 2>/dev/null)"
    TITLE="$(echo "$META_JSON" | jq -r '.title // empty' 2>/dev/null)"
    SUMMARY="$(echo "$META_JSON" | jq -r '.summary // empty' 2>/dev/null)"
  fi
fi

[ -z "$TOPIC" ] && TOPIC="未分类"
[ -z "$TITLE" ] && TITLE="$CWD_BASE-$SHORT_ID"
[ -z "$SUMMARY" ] && SUMMARY="[summary unavailable: claude -p failed — see $LOG_FILE]"

# Sanitize topic/title for filesystem: remove / \ : * ? " < > | and newlines.
sanitize() { echo "$1" | tr -d '/\\:*?"<>|\n\r' | sed -E 's/[[:space:]]+/ /g; s/^ //; s/ $//'; }
TOPIC_SAFE="$(sanitize "$TOPIC")"
TITLE_SAFE="$(sanitize "$TITLE")"

OUT="$SESSIONS_DIR/${DATE_SHORT}【Claude对话】【${TOPIC_SAFE}】${TITLE_SAFE}.md"

# Render MD
{
  printf -- '---\n'
  printf 'title: "%s"\n' "$TITLE_SAFE"
  printf 'date: %s\n' "$DATE_FULL"
  printf 'type: claude-session\n'
  printf 'topic: "%s"\n' "$TOPIC_SAFE"
  printf 'cwd: "%s"\n' "$CWD"
  printf 'tags:\n  - Claude对话\n  - %s\n' "$TOPIC_SAFE"
  printf -- '---\n\n'
  printf '# %s【Claude对话】【%s】%s\n\n' "$DATE_SHORT" "$TOPIC_SAFE" "$TITLE_SAFE"
  printf '> %s  %s  `%s`\n\n' "$DATE_FULL" "$TIME" "$CWD_BASE"
  printf '## 摘要\n\n%s\n\n' "$SUMMARY"
  printf '## 对话\n\n%s\n\n' "$CONVO"
  printf -- '---\n\n'
  printf -- '- session_id: `%s`\n' "$SESSION_ID"
  printf -- '- cwd: `%s`\n' "$CWD"
  printf -- '- transcript: `%s`\n' "$TRANSCRIPT"
} > "$OUT"

log "wrote $OUT"
exit 0
