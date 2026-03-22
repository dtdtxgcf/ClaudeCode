# ClaudeCode 自动同步升级 — 上下文与配置方案

> 本文档汇总了当前知识库项目的完整上下文，以及自动同步升级方案，供新 Claude Session 参考实施。

## 一、项目概况

### 1.1 项目定位

通过 iPhone Claude Code 采集信息，自动整理成结构化笔记，push 到 GitHub，Mac 端自动 pull 后用 Obsidian 阅读。

```
iPhone 截图/描述 → Claude Code 整理 → GitHub → Mac 自动同步 → Obsidian 阅读
```

### 1.2 仓库信息

- **GitHub 仓库**：`https://github.com/dtdtxgcf/ClaudeCode.git`
- **主要工作分支**：`claude/general-session-*`（每个 Claude Code session 会创建自己的分支）
- **默认分支**：`main`

### 1.3 目录结构

```
ClaudeCode/
├── knowledge/          # 知识库
│   ├── tech/           # 技术类
│   ├── design/         # 设计类
│   ├── business/       # 商业/产品类
│   └── other/          # 其他
├── notes/              # 快速笔记/灵感
│   └── recordings/     # 录音笔记
├── index.md            # 知识库总索引
├── CLAUDE.md           # Claude Code 工作流指令
├── README.md           # 项目说明
├── .infra/             # 基础设施（Obsidian 不可见）
│   ├── scripts/        # 自动化脚本
│   ├── docs/           # 项目文档
│   └── templates/      # 模板文件
└── .gitignore
```

## 二、当前自动同步方案（已部署）

### 2.1 方案

**macOS launchd 轮询**，每 5 分钟执行一次 `git fetch --all && git pull`。

### 2.2 现有脚本

**`.infra/scripts/install-auto-sync.sh`**：一键安装，创建 launchd plist（`com.claudecode.autosync`），每 300 秒执行同步脚本。

**`.infra/scripts/mac-auto-sync.sh`**：同步逻辑，fetch 所有远程分支，pull 当前分支，自动合并新的 `claude/` 分支内容。

### 2.3 launchd plist 位置

```
~/Library/LaunchAgents/com.claudecode.autosync.plist
```

### 2.4 问题

- 延迟最多 5 分钟
- 用户希望"第一时间"收到更新（秒级）

## 三、升级方案：GitHub Webhook + ntfy.sh（秒级同步）

### 3.1 原理

```
GitHub Push → Webhook → ntfy.sh → Mac 长连接监听 → git pull → macOS 通知
```

ntfy.sh 是免费的推送通知服务，支持 HTTP 长轮询/SSE/WebSocket，无需注册。

### 3.2 需要实现的内容

#### 文件 1：`.infra/scripts/sync-knowledge.sh`（同步脚本）✅ 已创建

功能：
- `cd` 到仓库目录
- `git fetch --all`
- 对比本地和远程 HEAD
- 如果有新内容，`git pull` 并合并所有 `claude/` 分支
- 成功后发送 macOS 通知（`osascript -e 'display notification ...'`）

要点：
- 复用现有 `mac-auto-sync.sh` 的合并逻辑（合并所有 `origin/claude/*` 分支）
- 仓库路径：`$HOME/ClaudeCode`
- 日志文件：`$REPO_DIR/.infra/scripts/.sync.log`

#### 文件 2：`.infra/scripts/watch-knowledge.sh`（ntfy 监听脚本）✅ 已创建

功能：
- 使用 `curl` 长连接监听 ntfy.sh 的某个频道
- 收到消息后立即执行 `sync-knowledge.sh`
- 连接断开后自动重连（`while true` + `sleep 2`）

要点：
- 频道名使用随机字符串，格式：`claudecode-sync-<random>`
- 频道名需要写入一个配置文件或作为变量方便修改

#### 文件 3：`.infra/scripts/install-realtime-sync.sh`（一键安装脚本）✅ 已创建

功能：
1. 生成随机频道名（`openssl rand -hex 4`），保存到 `.infra/scripts/.ntfy-channel`
2. 给脚本添加执行权限
3. 创建 launchd plist（`com.claudecode.realtime-sync`），配置 `KeepAlive` + `RunAtLoad`
4. 加载服务
5. 输出频道名和 GitHub Webhook 配置指引

launchd plist 要点：
- Label: `com.claudecode.realtime-sync`
- KeepAlive: true（进程退出后自动重启）
- RunAtLoad: true
- 日志输出到 `.infra/scripts/.realtime-sync-stdout.log` / `.realtime-sync-stderr.log`

#### 文件 4：更新 `README.md`

在 Mac 端设置部分新增"方案二：实时同步（推荐）"，包含：
- 安装命令
- GitHub Webhook 配置步骤（Payload URL、Content type、Events）
- 常用命令（查看日志、停止/启动/卸载服务）

### 3.3 GitHub Webhook 配置（需用户手动操作）

1. 打开 `https://github.com/dtdtxgcf/ClaudeCode/settings/hooks`
2. Add webhook：
   - **Payload URL**：`https://ntfy.sh/<频道名>`
   - **Content type**：`application/json`
   - **Events**：`Just the push event`
3. 保存

### 3.4 可选：保留轮询作为兜底

保留现有 5 分钟轮询方案不删除，作为 ntfy 服务异常时的兜底。两个 launchd 服务可以共存。

## 四、CLAUDE.md 工作流指令（完整）

当前 `CLAUDE.md` 定义了知识采集工作流、分类规则、MD 模板、命名规范等，详见仓库中的 `CLAUDE.md` 文件。关键规则：

- commit 信息格式：`knowledge: add 简短描述`
- 文件命名：`YYYY-MM-DD-简短中文标题.md`
- 分类：tech / design / business / other
- 每次新增笔记后更新 `index.md`
- 所有操作完成后执行 git add、commit、push

## 五、任务清单

请新 Session 完成以下工作：

- [x] 创建 `.infra/scripts/sync-knowledge.sh`
- [x] 创建 `.infra/scripts/watch-knowledge.sh`
- [x] 创建 `.infra/scripts/install-realtime-sync.sh`
- [x] 更新 `README.md` 添加实时同步方案说明
- [x] 目录重构：scripts/docs/templates 移入 `.infra/`
- [x] 测试脚本语法（`bash -n` 检查）
- [x] git commit & push
