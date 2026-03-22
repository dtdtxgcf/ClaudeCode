# ClaudeCode 个人知识库

通过 iPhone Claude Code 采集信息，自动整理成结构化笔记，同步到 Mac 用 Obsidian 阅读和检索。

## 工作流

```
iPhone 截图/描述 → Claude Code 整理 → GitHub → Mac 自动同步 → Obsidian 阅读
```

1. 在 iPhone Claude Code 中发送截图或描述
2. Claude 自动搜索信息源、阅读原文、生成结构化 MD 笔记
3. 笔记自动 push 到 GitHub
4. Mac 端定时 pull，Obsidian 实时显示

## 目录结构

```
ClaudeCode/
├── knowledge/          # 知识库
│   ├── tech/           # 技术类
│   ├── design/         # 设计类
│   ├── business/       # 商业/产品类
│   └── other/          # 其他
├── notes/              # 快速笔记/灵感
├── index.md            # 知识库总索引
├── CLAUDE.md           # Claude Code 工作流指令
├── .infra/             # 基础设施（Obsidian 不可见）
│   ├── scripts/        # 自动化脚本
│   ├── docs/           # 项目文档 & PRD
│   └── templates/      # MD 模板
└── .gitignore
```

## Mac 端设置

### 1. 克隆仓库

```bash
git clone https://github.com/dtdtxgcf/ClaudeCode.git ~/ClaudeCode
```

### 2. 安装自动同步

每 30 秒自动 pull，零依赖、零配置。

```bash
cd ~/ClaudeCode
bash .infra/scripts/install-auto-sync.sh
```

常用命令：
```bash
# 查看同步日志
cat ~/ClaudeCode/.infra/scripts/.sync.log

# 停止/启动/卸载
launchctl unload ~/Library/LaunchAgents/com.claudecode.autosync.plist
launchctl load ~/Library/LaunchAgents/com.claudecode.autosync.plist
launchctl unload ~/Library/LaunchAgents/com.claudecode.autosync.plist && rm ~/Library/LaunchAgents/com.claudecode.autosync.plist
```

> **迁移提示**：如果之前已安装旧版（5分钟轮询），请重新运行安装脚本更新配置。

### 3. 用 Obsidian 打开

1. 打开 Obsidian → 「打开文件夹作为仓库」→ 选择 `~/ClaudeCode`
2. 推荐安装插件：
   - **Dataview**：用查询语句筛选和展示笔记
   - **Calendar**：按日历浏览笔记
   - **Tag Wrangler**：批量管理标签

### 4. Dataview 查询示例

在 Obsidian 中新建笔记，写入以下代码块可自动生成知识库表格：

````
```dataview
TABLE source AS "来源", date AS "日期", tags AS "标签"
FROM "knowledge"
SORT date DESC
```
````

## 使用方式

在 iPhone Claude Code 中：

- **采集知识**：发送截图或描述，Claude 自动整理存档
- **记录灵感**：告诉 Claude 你的想法，存入 notes/
- **查找内容**：问 Claude「之前存过关于 XX 的笔记吗」
- **更新笔记**：告诉 Claude 需要更新哪篇笔记
