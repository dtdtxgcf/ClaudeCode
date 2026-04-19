---
date: 2026-04-19
type: conversation-archive-index
tags:
  - Claude对话
  - 存档
---

# Claude 对话历史存档指南（Mac 本地）

## 1. Mac 本地 Claude Code（跑脚本）

在 Mac 上：
```bash
bash ~/ClaudeCode/.infra/scripts/export-all-sessions.sh
```

默认输出：`~/Downloads/claude-archive-YYYY-MM-DD/`（同时生成同名 `.zip`）

### 输出结构

```
~/Downloads/claude-archive-2026-04-19/
├── README.md
├── summary.txt                 # 索引：每个 session 一行（日期/时间/id/首条用户消息）
├── jsonl/
│   └── <project>/
│       └── *.jsonl             # Claude Code 原始 transcript（完整，含 tool_use/thinking）
└── markdown/
    └── <project>/
        └── YY-MM-DD-HH-MM-sid.md  # 易读 MD（仅 user/assistant 文本）
```

### 可选参数

```bash
OUTPUT_DIR=~/some-other-path bash .../export-all-sessions.sh   # 自定义输出路径
SKIP_ZIP=1 bash ...                                            # 只留文件夹，不打包 ZIP
INCLUDE_HEADLESS=1 bash ...                                    # 包含 claude -p 自产的子会话
```

### 依赖

- `jq` — `brew install jq`

## 2. claude.ai 网页版 + Claude 桌面 app

两者共用同一 Anthropic 账户，任选其一即可。

### 方案 A：脚本直抓（推荐，即时）

```bash
# 一次性拿 sessionKey cookie（详见脚本注释）
# 然后跑：
CLAUDE_SESSION_KEY='sk-ant-sid01-...' bash ~/ClaudeCode/.infra/scripts/export-claude-chats.sh
```

脚本会调 claude.ai 内部 API，**所有 chat 全部抓下来**，输出到 `~/Downloads/claude-chats-YYYY-MM-DD/`：
- `json/` — 每个 chat 的完整 API 响应（含所有 messages 树）
- `markdown/` — 每个 chat 的易读 MD
- `index.json` / `summary.txt` — 总索引
- 同名 ZIP 在同级目录

**怎么拿 sessionKey**：
1. 浏览器打开 https://claude.ai（已登录状态）
2. DevTools（Cmd+Opt+I）→ Application → Cookies → https://claude.ai
3. 复制 `sessionKey` 的 value（以 `sk-ant-sid01-` 开头）

**保存以便后续复用**：
```bash
mkdir -p ~/.claude
echo 'sk-ant-sid01-...' > ~/.claude/claude-ai-session
chmod 600 ~/.claude/claude-ai-session
# 之后直接跑（不用 CLAUDE_SESSION_KEY=）
bash ~/ClaudeCode/.infra/scripts/export-claude-chats.sh
```

### 方案 B：官方 Export data（邮件，全量最可靠）

1. 登录 https://claude.ai
2. Settings → **Privacy** → **Export data**
3. 点击 **Export**
4. 几分钟到一小时后邮箱收到 ZIP 下载链接
5. ZIP 里每个对话是一个 JSON

### 方案 C：单个对话手动导出

进入某个对话 → 右上角 **"..."** 菜单 → **Export chat**（Markdown/JSON 可选）

## 下一步建议

- 长期存档：把 Downloads 里的 ZIP 转存到 iCloud Drive / Google Drive / 外置硬盘
- 并入知识库：解压后挑需要的 MD，移到 `~/Documents/KnowledgeHub/<3>library/`
- 全文搜索：把 `markdown/` 目录临时加为 Obsidian vault 即可检索
