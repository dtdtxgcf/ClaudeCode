#!/usr/bin/env bash
# archive-session.sh
# Claude Code SessionEnd hook: append conversation to a daily Markdown log.
#
# Input (stdin JSON): { "session_id", "transcript_path", "cwd", "hook_event_name" }
# Output: appends to $CLAUDE_SESSIONS_DIR/YYYY-MM-DD.md (default ~/ClaudeCode/notes/sessions/)
# Logs errors to ~/.claude/hooks/archive-session.log. Never blocks hook exit.

set -u

SESSIONS_DIR="${CLAUDE_SESSIONS_DIR:-$HOME/ClaudeCode/notes/sessions}"
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

DATE="$(date +%Y-%m-%d)"
TIME="$(date +%H:%M)"
CWD_BASE="$(basename "${CWD:-unknown}" | tr -c 'A-Za-z0-9._-' '-' | sed 's/-\+/-/g; s/^-//; s/-$//')"
[ -z "$CWD_BASE" ] && CWD_BASE="unknown"
SHORT_ID="$(echo "$SESSION_ID" | cut -c1-8)"
OUT="$SESSIONS_DIR/${DATE}.md"

# Dedup: if this session is already recorded in today's file, skip.
# SessionEnd can fire multiple times if a session is resumed and closed again.
if [ -f "$OUT" ] && grep -Fq "session_id: \`$SESSION_ID\`" "$OUT"; then
  log "session $SESSION_ID already archived in $OUT, skipping"
  exit 0
fi

# Extract user/assistant text from JSONL transcript. Skip tool_use/tool_result/thinking.
# User messages: content is a plain string. Assistant messages: content is an array.
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

# Generate summary via claude -p (Haiku). Timeout bounds cost + latency.
SUMMARY_PROMPT='以下是一次 Claude Code 对话记录。用中文简洁总结（总共不超过 150 字）：
1. 用户的核心需求（1 句）
2. 实际做了什么（2-3 条要点）
3. 产出的关键文件/决策（如有）
4. 遗留问题或下一步（如有）

对话内容如下：

'

SUMMARY="$(
  {
    printf '%s' "$SUMMARY_PROMPT"
    printf '%s' "$CONVO"
  } | timeout 45s claude -p --model "$SUMMARY_MODEL" 2>>"$LOG_FILE"
)" || SUMMARY=""

if [ -z "$SUMMARY" ]; then
  SUMMARY="[summary unavailable: claude -p failed — see $LOG_FILE]"
  log "summary failed for $SESSION_ID"
fi

# If daily file doesn't exist yet, write YAML header + title.
if [ ! -f "$OUT" ]; then
  {
    printf -- '---\n'
    printf 'date: %s\n' "$DATE"
    printf 'type: session-log\n'
    printf 'tags:\n  - claude-code\n  - session-log\n'
    printf -- '---\n\n'
    printf '# %s Claude Code 对话\n\n' "$DATE"
  } > "$OUT"
fi

# Append this session's block.
{
  printf '## %s — %s `%s`\n\n' "$TIME" "$CWD_BASE" "$SHORT_ID"
  printf '### 摘要\n\n%s\n\n' "$SUMMARY"
  printf '### 对话\n\n%s\n' "$CONVO"
  printf -- '- session_id: `%s`\n' "$SESSION_ID"
  printf -- '- cwd: `%s`\n' "$CWD"
  printf -- '- transcript: `%s`\n\n' "$TRANSCRIPT"
  printf -- '---\n\n'
} >> "$OUT"

log "appended session $SHORT_ID to $OUT"
exit 0
