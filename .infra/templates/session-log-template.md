---
date: {YYYY-MM-DD}
time: "{HH:MM}"
session_id: {完整 session id}
cwd: {工作目录绝对路径}
type: session-log
tags:
  - claude-code
  - session-log
  - {cwd-basename}
---

# {cwd-basename} — {YYYY-MM-DD HH:MM}

## 摘要
{claude -p Haiku 生成的 3-5 条要点，中文，≤150 字}

## 对话

### USER

{用户第一轮输入}

### ASSISTANT

{Claude 第一轮文本响应}

### USER

{用户第二轮输入}

### ASSISTANT

{Claude 第二轮文本响应}

...

---

- **Session ID**: `{session_id}`
- **工作目录**: `{cwd}`
- **Transcript**: `{transcript_path}`
