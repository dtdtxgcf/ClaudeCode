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

## 2. claude.ai 网页版 + Claude 桌面 app（手动导出）

两者共用同一 Anthropic 账户，一次导出即可。

### 全部对话

1. 登录 https://claude.ai
2. Settings → **Privacy** → **Export data**
3. 点击 **Export**
4. Anthropic 会把你账户下所有对话打成 ZIP 发到你注册邮箱（几分钟到几小时，取决于历史量）
5. 下载后解压：每个对话是一个 JSON，含完整 messages 数组

### 单个对话

- 进入该对话 → 右上角 **"..."** 菜单 → **Export chat**
- 可选 Markdown 或 JSON 格式

## 下一步建议

- 长期存档：把 Downloads 里的 ZIP 转存到 iCloud Drive / Google Drive / 外置硬盘
- 并入知识库：解压后挑需要的 MD，移到 `~/Documents/KnowledgeHub/<3>library/`
- 全文搜索：把 `markdown/` 目录临时加为 Obsidian vault 即可检索
