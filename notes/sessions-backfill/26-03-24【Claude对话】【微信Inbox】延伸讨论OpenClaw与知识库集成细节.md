---
title: "延伸讨论OpenClaw与知识库集成细节"
date: 2026-03-24
type: claude-session
topic: "微信Inbox"
cwd: "/home/user/ClaudeCode"
tags:
  - Claude对话
  - 微信Inbox
---

# 26-03-24【Claude对话】【微信Inbox】延伸讨论OpenClaw与知识库集成细节

> 2026-03-24  12:29  `ClaudeCode`

## 摘要

在 Inbox 想法记录的基础上继续细化：OpenClaw skill 工作流、GitHub API 写入路径、AGENTS.md/HEARTBEAT.md 的提示词片段、inbox 分类（想法/待办/信息/投资速记）。已生成 .infra/openclaw/ 下的 skill 配置和模板。这个 session 是实际把 Inbox 功能代码落地的主力轮次之一。

## 对话

**USER**:

你帮我做一个深度研究，claude code可以做哪些有意思的事情？

**ASSISTANT**:

我先说下方案：

1. **WebSearch 搜索** Claude Code 的最新功能、有趣用例、社区玩法
2. **WebFetch 阅读**几篇高质量文章获取详细信息
3. **生成结构化笔记**存入 `knowledge/tech/`
4. **更新索引**并提交推送

开始搜索：

**ASSISTANT**:

让我再深入阅读几篇关键文章。

**ASSISTANT**:

我已经收集了大量信息。现在让我整理成结构化笔记，先写一下执行计划。

**ASSISTANT**:

好的，我已经完成了研究。现在让我写执行计划。

**ASSISTANT**:

API Error: 400 {"type":"error","error":{"type":"invalid_request_error","message":"messages.16.content.2.image.source.base64.media_type: Field required"},"request_id":"req_011CZKLHYvezYTSXWqPH7czs"}

**USER**:

是什么原因

**ASSISTANT**:

API Error: 400 {"type":"error","error":{"type":"invalid_request_error","message":"messages.16.content.2.image.source.base64.media_type: Field required"},"request_id":"req_011CZKLK6s4DaV2A2djwVQRV"}

**USER**:

gello

**ASSISTANT**:

这个错误是 Claude Code 在向 API 发送请求时，图片数据缺少了 `media_type` 字段导致的。

**错误信息解析：**
```
messages.16.content.2.image.source.base64.media_type: Field required
```

意思是：第 16 条消息的第 3 个内容块是一张 base64 编码的图片，但缺少必需的 `media_type` 字段（如 `image/png`、`image/jpeg`）。

**可能原因：**
- 你在对话中发送了截图，随着对话变长，Claude Code 在压缩/转发历史消息时，图片的元数据（media_type）丢失了
- 这是 Claude Code 客户端的一个 bug，不是你的操作问题

**解决办法：**
1. **开一个新会话**重新开始研究任务
2. 如果需要发送截图，尽量在对话早期发送，避免对话过长后图片元数据丢失
3. 可以到 https://github.com/anthropics/claude-code/issues 报告这个 bug

**USER**:

我想做一个功能，就是在微信上和open cloud讲一个我的想法或者to do,请你帮我啊，什么地方记录下来

**ASSISTANT**:

我理解你想要一个从微信快速记录想法/to-do 的工作流。在提方案之前，有几个问题想先确认：

**ASSISTANT**:

明白了，你想通过微信和 OpenClaw 聊天，把想法/to-do 记录到 Obsidian。让我先了解一下现有项目结构和 OpenClaw 的情况。

**ASSISTANT**:

好的，我现在了解了全貌。让我整理一下方案：

## 方案：微信 OpenClaw → Obsidian 快速记录

**流程**：微信 ClawBot → OpenClaw → GitHub API → 你的知识库 repo → auto-sync → Obsidian

### 具体实现

**1. 创建收件箱目录** `notes/inbox/`
- 所有从微信发来的想法/to-do 先落到这里
- 格式用简化的快速笔记模板

**2. 写一个 OpenClaw 的 Tool 配置**
- OpenClaw 支持自定义工具，配置一个 `save-note` 工具
- 工具通过 GitHub API（`PUT /repos/.../contents/...`）直接创建 MD 文件到这个 repo
- 需要一个 GitHub Personal Access Token

**3. 写 OpenClaw 的 IDENTITY/SOUL 提示词**
- 告诉 OpenClaw：用户发来想法就调用 save-note 工具
- 自动分类：想法 → `type: idea`，待办 → `type: todo`
- 文件名格式：`YYYY-MM-DD-HH-MM-简短标题.md`

**4. 现有的 auto-sync 脚本**已经会把 repo 变更同步到 Obsidian，不需要改动。

### 需要的东西
- GitHub Personal Access Token（fine-grained，只给这个 repo 的 contents 写权限）
- OpenClaw Workspace 配置文件

你觉得这个方案可以吗？有几个问题：

**ASSISTANT**:

好的，你自己配置了 OpenClaw，那可以完全自定义 Tools。让我看看你之前记录的 OpenClaw 配置文章，参考格式。

**ASSISTANT**:

现在我对你的 OpenClaw 配置很了解了。让我来实现这个「微信/飞书快速记录」功能。

**ASSISTANT**:

我先把 inbox 功能建好，然后再做 Claude Code 深度研究。

先创建 inbox 目录和模板：

**ASSISTANT**:

现在创建 OpenClaw inbox skill 配置文件。这个 skill 让 OpenClaw 收到想法/to-do 时自动保存到你的知识库 repo：

**ASSISTANT**:

Now update index.md to add the inbox section:

**ASSISTANT**:

Inbox 功能已完成并推送。下面是你需要做的配置步骤：

### 你需要做的事

1. **创建 GitHub Token**：Settings → Developer settings → Fine-grained tokens → 只给这个 repo 的 Contents (read/write) 权限
2. **Token 存到 OpenClaw**：`~/.openclaw/credentials/github-token`
3. **复制 AGENTS.md 片段**：把 `.infra/openclaw/agents-inbox-snippet.md` 的内容追加到你的 `~/.openclaw/workspace/AGENTS.md`
4. **复制 HEARTBEAT.md 片段**：把 `.infra/openclaw/heartbeat-inbox-snippet.md` 追加到 HEARTBEAT.md
5. **在 TOOLS.md 中添加**：`GITHUB_REPO: {你的owner/repo}`

---

现在开始做第二个任务：**Claude Code 能做哪些有意思的事情**深度研究。

**ASSISTANT**:

正在后台做 Claude Code 深度研究，搜索各种有趣用法。完成后我会整理成知识笔记存入 `knowledge/tech/`。稍等几分钟。

**ASSISTANT**:

两个后台任务在跑：
1. **深度搜索**：Claude Code 各种有趣用法、高级技巧、创意案例
2. **去重检查**：确认已有笔记覆盖了什么，避免重复

完成后我会整合成一篇完整的知识笔记。

<details>
<summary>已完成的 Inbox 功能文件清单</summary>

| 文件 | 说明 |
|------|------|
| `notes/inbox/` | 快速记录收件箱目录 |
| `.infra/templates/inbox-template.md` | Inbox 笔记模板 |
| `.infra/openclaw/skill-inbox-capture.md` | OpenClaw skill：自动分类+保存 |
| `.infra/openclaw/agents-inbox-snippet.md` | 追加到 AGENTS.md 的工作流片段 |
| `.infra/openclaw/heartbeat-inbox-snippet.md` | 追加到 HEARTBEAT.md 的每日整理任务 |
| `index.md` | 新增 Inbox 板块 |

</details>

Sources:
- [Tencent WeChat launches ClawBot plugin - TechNode](https://technode.com/2026/03/23/tencents-wechat-launches-clawbot-plugin-supporting-openclaw-ai-framework-and-multi-modal-interactions/)
- [Tencent integrates WeChat with OpenClaw AI agent - Yahoo Finance](https://finance.yahoo.com/sectors/technology/articles/tencent-integrates-wechat-openclaw-ai-073640785.html)

**USER**:

<task-notification>
<task-id>a8804a21ac7939dbd</task-id>
<tool-use-id>toolu_01N7PGfp4hEu7Lb3CMLXa7f3</tool-use-id>
<output-file>/tmp/claude-0/-home-user-ClaudeCode/fd2b672b-deaa-462f-9ff2-604262ec527e/tasks/a8804a21ac7939dbd.output</output-file>
<status>completed</status>
<summary>Agent "Search Claude Code existing notes" completed</summary>
<result>Here are the summaries:

1. **2026-03-22-Claude-Code配置技巧.md** — Covers Santiago (@svpino)'s 5 practical rules for CLAUDE.md configuration: plan before coding, break down large tasks, proactive testing suggestions, TDD for bug fixes, and self-improving rules. It also includes his expanded 18-tip version from a Sonar Summit talk, covering topics like file referencing, custom commands, .claudeignore, and Git worktrees.

2. **2026-03-22-Claude-HUD状态栏插件.md** — Documents Claude HUD, an open-source Claude Code plugin (10.9k GitHub stars) that displays a real-time status bar showing context usage, tool activity, agent state, and todo progress directly in the terminal. It covers installation (3 commands), configuration presets (Full/Essential/Minimal), and technical requirements (Claude Code v1.0.80+, Node 18+).

3. **2026-03-22-Claude-Code榜一大哥刘小排.md** — A podcast summary from "十字路口 Crossing" featuring Liu Xiaopai, the world's top Claude Code token consumer who burned ~$50,000 worth of tokens on a $200/month plan (7.7 billion tokens total). It details his philosophy of using Claude Code as a general-purpose agent (not just for coding), his AI startup approach (Raphael AI, AnyVoice, Fast3D) with a 6-7 person team generating revenue for 30-50 people, and practical tips like writing clear requirement docs before coding.</result>
<usage><total_tokens>19238</total_tokens><tool_uses>3</tool_uses><duration_ms>17080</duration_ms></usage>
</task-notification>
Full transcript available at: /tmp/claude-0/-home-user-ClaudeCode/fd2b672b-deaa-462f-9ff2-604262ec527e/tasks/a8804a21ac7939dbd.output

**ASSISTANT**:



好的，去重检查完成了。已有笔记覆盖了：配置技巧、HUD 插件、刘小排的 Agent 用法。深度研究还在跑，等它完成后我会避开这些已有内容，专注写新的发现。

**USER**:

<task-notification>
<task-id>a3fd549379e02cd63</task-id>
<tool-use-id>toolu_01Y7wqpCWUab81JsmiT9JyYh</tool-use-id>
<output-file>/tmp/claude-0/-home-user-ClaudeCode/fd2b672b-deaa-462f-9ff2-604262ec527e/tasks/a3fd549379e02cd63.output</output-file>
<status>completed</status>
<summary>Agent "Research Claude Code features" completed</summary>
<result>研究完成。已创建并推送文件：

**`/home/user/ClaudeCode/knowledge/tech/2026-03-24-Claude-Code创意玩法与高级技巧大全.md`**

共整理出 **35 个** 有趣发现，分为五大类：

**一、病毒级创意项目（9 个）**
- MRI 医学影像查看器（Shopify CEO，600 万浏览）
- DIY 基因组分析
- AI 过夜跑出文明模拟
- AI 制作爱马仕广告片（全流程编排）
- 16 个 Agent 用 Rust 写 C 编译器（编译 Linux 内核，花 $20,000）
- NASA 火星车路线规划
- Firefox 百 Bug 猎手（14 个高危）
- Cowork 自己写自己
- Google 工程师震撼告白

**二、高级功能与工作流（8 个）**
- Hooks 自动化利器（PreToolUse/PostToolUse + MCP 正则匹配）
- Git Worktree 并行开发
- /loop 定时循环任务（最长 3 天）
- Background Agents + /teleport 跨设备接力
- Agent Teams 多 Agent 协作
- Figma MCP 双向联动
- /voice 语音模式
- /security-review 安全扫描

**三、集成模式（5 个）**
- GitHub Actions 自动化
- Docker Sandbox 安全沙箱
- Neon 数据库分支隔离
- Gemini CLI 作为 Web 访问后备
- Agent SDK 跨框架集成

**四、冷门技巧（8 个）**
- 思维层级控制（think → ultrathink）
- 让 Claude 面试你
- 自定义状态栏
- /compact 与 /clear 的区别
- 保存实现计划
- /simplify 二次优化
- Skills 的 context: fork 隔离
- 对话历史搜索

**五、社区生态（5 个）**
- awesome-claude-code（21.6k Stars）
- Agent Farm 并行编排
- context-mode 插件（98% context 节省）
- connect-apps 500+ 应用集成
- frontend-design Skill（27.7 万安装）

索引 `index.md` 已同步更新。</result>
<usage><total_tokens>51926</total_tokens><tool_uses>33</tool_uses><duration_ms>1192127</duration_ms></usage>
</task-notification>
Full transcript available at: /tmp/claude-0/-home-user-ClaudeCode/fd2b672b-deaa-462f-9ff2-604262ec527e/tasks/a3fd549379e02cd63.output

**ASSISTANT**:



Claude Code 深度研究完成！已生成笔记并推送。

**ASSISTANT**:

## 产出总结

### 1. Inbox 快速记录功能
微信/飞书 → OpenClaw → GitHub API → auto-sync → Obsidian 的完整链路。文件在 `.infra/openclaw/` 下，你需要把片段复制到 OpenClaw workspace 并配置 GitHub Token。

### 2. Claude Code 创意玩法深度研究
**`knowledge/tech/2026-03-24-Claude-Code创意玩法与高级技巧大全.md`**

整理了 **35 个有趣发现**，五大分类：

| 分类 | 亮点 |
|------|------|
| **病毒级创意项目** | MRI 查看器、DIY 基因组、16 Agent 写 C 编译器（花 $20K）、Firefox 百 Bug 猎手 |
| **高级功能** | Hooks 自动化、Git Worktree 并行、/loop 3天循环、Background Agents + /teleport |
| **集成模式** | GitHub Actions、Docker Sandbox、Neon 数据库分支、Agent SDK |
| **冷门技巧** | think → ultrathink 思维层级、让 Claude 面试你、/compact vs /clear、Skills context:fork |
| **社区生态** | awesome-claude-code (21.6k Stars)、Agent Farm 并行、context-mode 省 98% context |

两个任务都已 commit 并 push 到 `claude/research-claude-code-mlcL5` 分支。

---

- session_id: `fd2b672b-deaa-462f-9ff2-604262ec527e`
- cwd: `/home/user/ClaudeCode`
- transcript: `/root/.claude/projects/-home-user-ClaudeCode/fd2b672b-deaa-462f-9ff2-604262ec527e.jsonl`
