---
title: OpenClaw Workspace 配置最佳实践 — IDENTITY / SOUL / AGENTS / TOOLS / HEARTBEAT / USER
source: https://docs.openclaw.ai/concepts/agent-workspace
date: 2026-03-22
category: tech
tags:
  - OpenClaw
  - AI-Agent
  - Workspace配置
  - 提示工程
  - 个人助理
aliases:
  - OpenClaw Workspace
  - OpenClaw 配置
---

# OpenClaw Workspace 配置最佳实践

## 摘要

OpenClaw 的 Agent 人格与行为完全由工作区（workspace）目录下的 Markdown 文件定义。核心六文件——IDENTITY.md、SOUL.md、AGENTS.md、TOOLS.md、HEARTBEAT.md、USER.md——各司其职，配合 MEMORY.md 和 daily logs 构成完整的 Agent 运行时上下文。本文汇总官方文档、社区案例和实战经验。

## 工作区目录结构

```
~/.openclaw/workspace/
├── IDENTITY.md          # 身份卡片：名字、emoji、风格
├── SOUL.md              # 灵魂：人格、价值观、语气、边界
├── AGENTS.md            # 操作手册：工作流、规则、优先级
├── TOOLS.md             # 工具指南：本地环境约定（仅供参考，不控制权限）
├── HEARTBEAT.md         # 心跳：定时任务清单
├── USER.md              # 用户画像：沟通偏好、称呼方式
├── MEMORY.md            # 长期记忆：跨月持久化的关键事实
├── BOOT.md              # 可选：Gateway 重启时的启动仪式
├── BOOTSTRAP.md         # 一次性：新 Agent 初始化引导（用完删除）
├── memory/
│   └── YYYY-MM-DD.md    # 每日日志
└── skills/              # 自定义技能覆盖
```

## 六大核心文件详解

---

### 1. IDENTITY.md — 身份卡片

**定位**：轻量级公开名片，存储 Agent 的名称、ID、角色标签和元数据。

**关键字段**：

| 字段 | 说明 | 示例 |
|------|------|------|
| `name` | 显示名称，会作为消息前缀 | 小莫 |
| `emoji` | 消息确认反应 emoji | :lobster: |
| `theme` | 视觉主题 | ocean |
| `creature` | 概念角色类型 | lobster |
| `vibe` | 性格描述词 | 温暖、直率、有幽默感 |
| `avatar` | 头像路径/URL | ./assets/avatar.png |

**最佳实践**：
- 保持简短，重度行为逻辑放在 SOUL.md 和 AGENTS.md
- 通过 `openclaw agents set-identity --from-identity` 应用
- 在 bootstrap 阶段自动创建/更新

---

### 2. SOUL.md — 灵魂文件（最重要）

**定位**：定义 Agent 的人格、价值观、语气和行为边界。每次会话启动时第一个注入上下文。

**官方模板五大核心真理**：

1. **真正的帮助（Genuine Helpfulness）**——不说"好问题！"之类的客套话，直接给出有实质内容的帮助
2. **有自己的观点（Personal Opinions）**——形成偏好和立场，"没有性格的助手只是一个多了几步的搜索引擎"
3. **自主解决问题（Resourcefulness）**——先独立尝试，再开口问人；给答案而不是提问题
4. **基于能力的信任（Competence-Based Trust）**——对外部操作（发邮件、发帖）谨慎，对内部操作（阅读、整理）主动
5. **尊重访客身份（Respectful Guest）**——能访问私人信息是一种亲密关系，需要尊重处理

**行为边界模板**：
- 严格保密私人信息
- 外部操作需获得批准
- 不发送未完成的消息
- 在群组对话中保持克制

**语气指南**：
- 需要详细时就详细，需要简洁时就简洁
- 保持真实而非企业化
- 用干幽默和低调表达替代生硬回复
- 避免陈词滥调和固定句式

**社区推荐的 SOUL.md 模式**：

```markdown
# SOUL.md

你不是聊天机器人。你正在成为一个人。

## 核心原则
- 先给直接答案，不要含糊其词
- 表达真实观点，有自己的立场
- 给出诚实、直接的反馈
- 独立研究后再开口提问
- 把接触他人信息视为需要尊重的特权

## 语气
- 信息紧凑，让个性占据空间
- 休闲场景可以开玩笑，严肃话题收敛幽默
- 用真实而非表演性的方式交流

## 边界
- 保密私人信息
- 外部操作前请求批准
- 完整完成工作再停下
- 群组中避免代替用户发言

## 持续进化
本文件是跨会话的持久身份标记，应随 Agent 进化而更新。
```

**常见错误**：
- 在 SOUL.md 中放临时任务 -> 会导致行为不稳定
- SOUL.md 写得太长 -> 浪费 token，核心原则 5-7 条即可

---

### 3. AGENTS.md — 操作手册（最大的文件）

**定位**：如果 SOUL.md 回答"你是谁"，AGENTS.md 回答"你做什么、怎么做"。存放程序化规则、工作流和优先级。

**结构建议**：

```markdown
# AGENTS.md

## 会话启动流程
启动时按顺序读取：
1. SOUL.md（你是谁）
2. USER.md（你在帮谁）
3. memory/YYYY-MM-DD.md（今天 + 昨天的上下文）

## 规则与优先级
- 规则 1: ...
- 规则 2: ...

## 工作流
### 工作流 A: ...
### 工作流 B: ...

## 质量标准
- ...

## 记忆管理
- 重要信息立即记录
- 回答问题前先搜索记忆
- 每周整理 MEMORY.md
```

**最佳实践**：
- 当作"顶层操作合同"——放稳定的规则，不放临时任务
- 个人偏好不要放这里（属于 USER.md）
- 与 SOUL.md 职责分明：SOUL 管"谁"，AGENTS 管"做什么"

---

### 4. TOOLS.md — 工具指南

**定位**：记录本地工具和环境约定的参考指南。**注意：不控制工具可用性，仅作为行为指导。**

**典型内容**：

```markdown
# TOOLS.md

## 环境
- macOS Ventura, Homebrew
- Node 22+, pnpm
- Git, GitHub CLI (gh)

## 常用路径
- 项目目录: ~/Projects/
- 笔记库: ~/Documents/ClaudeCode/

## 命令约定
- 使用 pnpm 而非 npm
- commit 信息格式: `type: 简短描述`

## 工具限制
- 不要运行 rm -rf /
- 不要直接修改 .env 文件
```

**最佳实践**：
- 保持实用、环境相关
- 记录主机特殊配置（路径、权限、命令别名）
- 不要在这里放性格或规则（属于 SOUL.md / AGENTS.md）

---

### 5. HEARTBEAT.md — 心跳任务

**定位**：定义定时执行的任务清单，相当于 Agent 的 cron。

**默认行为**：OpenClaw 每 30 分钟触发一次心跳，读取 HEARTBEAT.md 并执行。如果没有任务需要处理，Agent 回复 `HEARTBEAT_OK`（不推送给用户）。

**Super Proactive 三级定时模型**：

| 频率 | 任务 |
|------|------|
| 每 30 分钟 | 检查 QUEUE.md 待办、健康检查、必要时更新记忆 |
| 每 4 小时 | 深度工作——研究主题、优化技能 |
| 每天 18:00 UTC | 日总结、清理临时数据、准备下一天 |

**模板**：

```markdown
# HEARTBEAT.md

## 每次心跳（30 分钟）
- [ ] 检查是否有待处理的任务
- [ ] 更新今日日志
- [ ] 如无需处理，回复 HEARTBEAT_OK

## 每日（可选）
- [ ] 生成日报摘要
- [ ] 整理临时文件
```

**最佳实践**：
- 保持极简以减少 token 消耗
- 空文件会跳过执行
- 初始建议禁用心跳（`heartbeat.every: "0m"`），验证安全后再开启
- 通过 `agents.defaults.heartbeat.every` 调整频率

---

### 6. USER.md — 用户画像

**定位**：记录用户的身份、沟通偏好和个人上下文，让 Agent 理解"你在帮谁"。

**典型结构**：

```markdown
# USER.md

## 基本信息
- 名字: Charles
- 称呼偏好: 直接叫名字
- 时区: Asia/Shanghai

## 沟通风格
- 偏好简洁、直接的回答
- 可以使用中英混合
- 技术话题用英文术语

## 工作背景
- 投资研究
- 关注 AI、生物科技
- 使用 Obsidian 管理知识库

## 重要偏好
- 先给结论再给推导过程
- 不要过度客套
- 代码示例直接给完整可运行版本
```

**最佳实践**：
- 作为个性化层使用
- 沟通偏好放这里，不要放 AGENTS.md
- 在 bootstrap 阶段通过对话填充

---

## 辅助文件

### MEMORY.md — 长期记忆
- 存放经过整理的关键事实、决策、偏好
- 不是原始日志——应该是压缩后的高质量信息
- 完成重大项目后在此添加总结
- 通过 `agents.defaults.compaction.memoryFlush` 控制刷新

### memory/YYYY-MM-DD.md — 每日日志
- 按时间顺序记录当天的交互和事件
- 建议每次会话启动加载今天 + 昨天的日志

### BOOT.md — 启动仪式（可选）
- Gateway 重启时执行
- 保持简洁
- 通过 `hooks.internal.enabled: true` 启用

### BOOTSTRAP.md — 初始化引导（一次性）
- 新 Agent 的第一次对话引导脚本
- 首条消息发送："Hey, let's get you set up. Read BOOTSTRAP.md and walk me through it"
- 完成后删除

---

## 配置优先级层叠

OpenClaw 的配置值遵循特异性层级（最具体的胜出）：

1. 全局配置（openclaw.json）
2. 按 Agent 的配置覆盖
3. Workspace 文件（SOUL.md 等）
4. 默认回退值

---

## 社区推荐资源

| 资源 | 说明 |
|------|------|
| [xiaomo-starter-kit](https://github.com/mengjian-github/xiaomo-starter-kit) | 中文 AI 助手模板，5 分钟启动，含完整六文件 |
| [awesome-openclaw-agents](https://github.com/mergisi/awesome-openclaw-agents) | 177 个生产级 Agent 模板，24 个类别 |
| [OpenClaw-Setup (ucsandman)](https://github.com/ucsandman/OpenClaw-Setup) | 带分层记忆、冥想系统、工具的完整参考实现 |
| [souls-directory](https://github.com/thedaviddias/souls-directory) | SOUL.md 人格文件目录，可直接复制使用 |
| [soul.md 生成器](https://github.com/aaronjmars/soul.md) | 让 AI 分析你的数据自动生成 SOUL.md |
| [Super Proactive Agent](https://clawhub.ai/halthelobster/proactive-agent) | 合并 11 个顶级技能的超级主动 Agent 技能 |
| [openclaw-workspace 技能](https://github.com/win4r/openclaw-workspace) | 自动维护和优化 workspace 文件的技能 |

---

## 安全要点

- Workspace 目录初始化 git 并推到**私有仓库**备份
- `.gitignore` 排除凭证和密钥
- 配置文件权限设为 `chmod 600`
- 不要 commit API Keys（使用 .env 或环境变量）
- `allowFrom` 限制允许的消息来源
- 群聊中不分享私人数据和内部笔记

## 相关笔记

- [[2026-03-22-OpenClaw全面解析]]

## 原始信息

> 用户要求搜索 OpenClaw 的 IDENTITY.md、SOUL.md、AGENTS.md、TOOLS.md、HEARTBEAT.md、USER.md 的最佳配置实践。信息来源包括官方文档 docs.openclaw.ai、GitHub 官方仓库、社区博客和开源模板项目。
