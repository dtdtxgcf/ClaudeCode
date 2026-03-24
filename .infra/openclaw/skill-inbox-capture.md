# Skill: Inbox Capture — 快速记录想法与待办

## 触发条件

当用户发送的消息符合以下任一模式时，自动触发此 skill：

- 明确的想法/灵感（"我想到一个..."、"有个想法"、"记一下"）
- 待办事项（"帮我记个 todo"、"提醒我..."、"要做..."）
- 信息片段（发送链接、截图、引用文字）
- 投资相关速记（"关注一下 XX 公司"、"XX 赛道..."）

## 分类规则

根据内容自动判断 type：

| type | 识别信号 | 标签 |
|------|----------|------|
| `idea` | 想法、灵感、点子、方案 | `#灵感` |
| `todo` | 要做、提醒、待办、跟进、安排 | `#待办` |
| `snippet` | 链接、截图、引用、"看到一个..." | `#信息片段` |
| `invest-note` | 公司名、赛道名、估值、融资 | `#投资速记` |

## 执行流程

### Step 1: 解析内容

从用户消息中提取：
- **标题**：一句话概括（10 字以内）
- **正文**：整理后的内容
- **类型**：idea / todo / snippet / invest-note
- **标签**：除类型标签外，提取 1-3 个内容标签

### Step 2: 生成文件名

格式：`YYYY-MM-DD-HH-MM-{简短标题}.md`

示例：`2026-03-24-14-30-RAG分块策略想法.md`

注意：用当前时间精确到分钟，避免文件名冲突。

### Step 3: 生成 Markdown

```markdown
---
title: {标题}
date: {YYYY-MM-DD}
type: {idea|todo|snippet|invest-note}
source: {wechat|feishu}
status: inbox
tags:
  - inbox
  - {类型标签}
  - {内容标签1}
  - {内容标签2}
---

# {标题}

{整理后的内容}

## 原始消息
> {用户发送的原始文字/截图描述}
```

### Step 4: 保存文件

通过 GitHub API 写入文件：

```
PUT https://api.github.com/repos/{owner}/{repo}/contents/notes/inbox/{文件名}
```

请求体：
```json
{
  "message": "inbox: add {标题}",
  "content": "{base64编码的文件内容}",
  "branch": "main"
}
```

需要环境变量：
- `GITHUB_TOKEN`：GitHub Personal Access Token（fine-grained，仅需 Contents read/write 权限）
- `GITHUB_REPO`：格式 `owner/repo`

### Step 5: 确认回复

保存成功后，回复用户：

```
✅ 已记录到 inbox：{标题}
类型：{type} | 标签：{tags}
```

如果是 `invest-note` 类型，额外提示：
```
💡 检测到投资相关内容。下次整理时会检查 research-db/ 是否有关联条目。
```

## 错误处理

- GitHub API 失败：重试 1 次，仍失败则回复用户"保存失败，已暂存到本地 memory"
- 内容太短（<5字）：直接问用户"想多说两句吗？还是就这样记下？"

## 每日整理提醒

如果 HEARTBEAT.md 中启用了 inbox 扫描，每日 18:00 检查 `notes/inbox/` 中的未处理条目，生成整理建议：
- `idea` → 是否值得展开为知识笔记？
- `todo` → 是否已完成？是否加入 QUEUE.md？
- `snippet` → 是否需要搜索原文、生成完整笔记？
- `invest-note` → 是否需要新建/更新 research-db/ 条目？
