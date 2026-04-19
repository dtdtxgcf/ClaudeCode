---
title: "{Haiku 生成的 10-18 字中文一句话摘要}"
date: {YYYY-MM-DD}
type: claude-session
topic: "{Haiku 生成的 2-6 字主题标签，如 OpenClaw/Inbox功能/对话归档}"
cwd: "{工作目录}"
tags:
  - Claude对话
  - {topic}
---

# {YY-MM-DD}【Claude对话】【{topic}】{title}

> {YYYY-MM-DD}  {HH:MM}  `{cwd-basename}`

## 摘要

{Haiku 生成 100-150 字中文摘要：用户需求 + 实际做了什么 + 产出 + 遗留}

## 对话

**USER**:

{用户第一轮输入}

**ASSISTANT**:

{Claude 第一轮文本响应（去掉 tool_use / thinking）}

**USER**:

{用户第二轮输入}

**ASSISTANT**:

{Claude 第二轮文本响应}

...

---

- session_id: `{完整 session id}`
- cwd: `{工作目录}`
- transcript: `{transcript 路径}`
