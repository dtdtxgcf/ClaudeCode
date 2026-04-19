---
date: 2026-04-19
type: conversation-archive-index
tags:
  - Claude对话
  - 存档
---

# Claude 对话历史存档索引

## 目录里有什么

| 文件 | 说明 |
|------|------|
| `claude-archive-sandbox-2026-04-19.zip` | **iPhone/Linux sandbox 侧** 所有 Claude Code transcripts（17 个，~4MB） |

解压后结构：
```
claude-archive-sandbox-2026-04-19/
├── README.md
├── summary.txt                 # 索引：每个 session 一行
├── jsonl/
│   └── -home-user-ClaudeCode/
│       └── *.jsonl             # 原始 transcript（Claude Code 内部格式）
└── markdown/
    └── -home-user-ClaudeCode/
        └── YY-MM-DD-HH-MM-sid.md  # 易读 MD（仅 user/assistant 文本）
```

## 三类 Claude 对话的存档方法

### 1. iPhone Claude Code（已存档）
ZIP 就在本目录，拖到 `~/Downloads` 即可。

### 2. Mac 本地 Claude Code（你自己跑脚本）
在 Mac 上：
```bash
bash ~/ClaudeCode/.infra/scripts/export-all-sessions.sh
```

默认输出：`~/Downloads/claude-archive-YYYY-MM-DD/`（同时生成 .zip）

可选：
```bash
OUTPUT_DIR=~/wherever bash ~/ClaudeCode/.infra/scripts/export-all-sessions.sh   # 自定义路径
SKIP_ZIP=1 bash ...                                                             # 只留文件夹
INCLUDE_HEADLESS=1 bash ...                                                     # 带上 claude -p 子会话
```

脚本会扫 Mac 的 `~/.claude/projects/**/*.jsonl`，按项目分目录，生成 JSONL + MD 两份。

### 3. claude.ai 网页版 + Claude 桌面 app（手动导出）

**Claude 账户数据导出**（网页和桌面 app 共用同一账户）：

1. 登录 https://claude.ai
2. Settings → **Privacy** → **Export data**
3. 点击 **Export**
4. Anthropic 会把账户下所有对话打包成 ZIP 发到你注册邮箱（几分钟到几小时，取决于历史量）
5. 下载后解压：每个对话一个 JSON，含完整 messages 数组

**只导出单个对话**：
- 进入该对话 → 右上角 "..." 菜单 → **Export chat**
- 可选 Markdown 或 JSON 格式

**Claude 桌面 app**：
- 直接用上面 claude.ai 的导出，两者共享账户
- 或进入任一对话，右上角菜单也有 Export

## 下一步建议

- 如果要**持久存档**：把 ZIP 上传到 iCloud Drive / Google Drive / 外置硬盘
- 如果要**并入知识库**：解压后选择需要的 MD，移到 `~/Documents/KnowledgeHub/<3>library/`
- 如果要**全文搜索**：Obsidian 打开 markdown/ 目录即可全文检索
