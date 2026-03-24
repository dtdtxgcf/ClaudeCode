# OpenClaw AGENTS.md 追加片段 — Inbox 快速记录

> 将以下内容追加到你的 `~/.openclaw/workspace/AGENTS.md` 中

## Inbox 快速记录工作流

### 触发
用户通过微信/飞书发送想法、待办、链接或投资速记时自动触发。

### 流程
1. 判断类型：idea / todo / snippet / invest-note
2. 提取标题（10字内）和标签（1-3个）
3. 按模板生成 Markdown 文件
4. 通过 GitHub API 写入 `notes/inbox/` 目录
5. 回复用户确认

### 文件命名
`YYYY-MM-DD-HH-MM-简短标题.md`

### GitHub API 配置
- Token 存放：`~/.openclaw/credentials/github-token`
- Repo：在 TOOLS.md 中配置 `GITHUB_REPO` 变量
- 只需 Contents (read/write) 权限

### 回复格式
成功：`✅ 已记录到 inbox：{标题}` + 类型和标签
失败：说明原因，暂存到本地 memory

### 规则
- 内容太短（<5字）时先确认再保存
- invest-note 类型提示关联 research-db
- 不要过度整理原始输入——快速记录优先，后续整理交给心跳任务
