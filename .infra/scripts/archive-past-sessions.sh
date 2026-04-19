#!/usr/bin/env bash
# archive-past-sessions.sh
# Retroactively run archive-session.sh on recent Claude Code transcripts.
#
# Usage:
#   bash archive-past-sessions.sh              # past 7 days, all projects
#   DAYS=30 bash archive-past-sessions.sh      # custom window
#   PROJECT_GLOB='*ClaudeCode*' bash ...       # limit to matching project dirs
#   DRY_RUN=1 bash ...                         # show what would be processed
#
# Reads transcripts from ~/.claude/projects/**/*.jsonl. Uses file mtime to filter.
# Dedup is handled by archive-session.sh itself (by session_id).

set -u

DAYS="${DAYS:-7}"
PROJECTS_DIR="${CLAUDE_PROJECTS_DIR:-$HOME/.claude/projects}"
PROJECT_GLOB="${PROJECT_GLOB:-*}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ARCHIVER="$SCRIPT_DIR/archive-session.sh"

if [ ! -x "$ARCHIVER" ]; then
  echo "archive-session.sh not found or not executable: $ARCHIVER" >&2
  exit 1
fi
if [ ! -d "$PROJECTS_DIR" ]; then
  echo "projects dir not found: $PROJECTS_DIR" >&2
  exit 1
fi

# Seconds per day * DAYS ago
SINCE="$(( $(date +%s) - DAYS * 86400 ))"

echo "Scanning $PROJECTS_DIR for transcripts modified in the past $DAYS days..."
count=0
skipped=0

# Collect all eligible transcripts
while IFS= read -r -d '' FILE; do
  MTIME="$(stat -c %Y "$FILE" 2>/dev/null || stat -f %m "$FILE" 2>/dev/null || echo 0)"
  if [ "$MTIME" -lt "$SINCE" ]; then
    skipped=$((skipped + 1))
    continue
  fi

  # Skip subagent transcripts — they are not top-level user sessions
  case "$FILE" in
    */subagents/*) skipped=$((skipped + 1)); continue ;;
  esac

  # Skip headless `claude -p` sub-sessions: real user sessions have >1 user message
  U_COUNT="$(jq -s '[.[] | select(.type=="user")] | length' "$FILE" 2>/dev/null || echo 0)"
  if [ "${U_COUNT:-0}" -le 1 ]; then
    skipped=$((skipped + 1))
    continue
  fi

  # Extract session_id from filename (e.g. abc123.jsonl → abc123)
  BASENAME="$(basename "$FILE" .jsonl)"
  SESSION_ID="$BASENAME"

  # Extract cwd from the first event (best effort)
  CWD="$(head -1 "$FILE" | jq -r '.cwd // empty' 2>/dev/null || echo "")"
  if [ -z "$CWD" ]; then
    # Project dir like "-home-user-ClaudeCode" → "/home/user/ClaudeCode"
    PROJECT_DIR_NAME="$(basename "$(dirname "$FILE")")"
    CWD="$(echo "$PROJECT_DIR_NAME" | sed 's|^-|/|; s|-|/|g')"
  fi

  count=$((count + 1))
  echo "[$count] $(date -d "@$MTIME" +%Y-%m-%d 2>/dev/null || date -r "$MTIME" +%Y-%m-%d)  $SESSION_ID  ($CWD)"

  if [ "${DRY_RUN:-0}" = "1" ]; then
    continue
  fi

  # Synthesize hook input and pipe into archiver
  printf '{"session_id":"%s","transcript_path":"%s","cwd":"%s","hook_event_name":"SessionEnd"}\n' \
    "$SESSION_ID" "$FILE" "$CWD" | "$ARCHIVER"
done < <(find "$PROJECTS_DIR" -type f -name '*.jsonl' -path "*$PROJECT_GLOB*" -print0 2>/dev/null | sort -z)

echo ""
echo "Done. Processed: $count. Skipped (old or subagent): $skipped."
if [ "${DRY_RUN:-0}" = "1" ]; then
  echo "(DRY_RUN was on — no files were written.)"
fi
