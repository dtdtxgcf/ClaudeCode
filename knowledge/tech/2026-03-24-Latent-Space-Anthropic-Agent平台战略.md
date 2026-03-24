---
title: Anthropic Agent 平台战略：为什么 AI 应该拥有自己的电脑
source: https://www.latent.space/p/felix-anthropic
date: 2026-03-17
category: tech
type: podcast
podcast: Latent Space
episode: "Why Anthropic Thinks AI Should Have Its Own Computer"
guest: [Felix Rieseberg]
score: 8.75
duration: 86min
transcript: true
tags:
  - 播客
  - Anthropic
  - Claude-Cowork
  - Agent平台
  - Skills
  - 本地优先
aliases:
  - Felix Rieseberg访谈
  - Claude Cowork架构
  - Anthropic Agent战略
---

# Anthropic Agent 平台战略：为什么 AI 应该拥有自己的电脑

## 播客信息

| 项目 | 内容 |
|------|------|
| 播客 | Latent Space: The AI Engineer Podcast |
| 单集 | Why Anthropic Thinks AI Should Have Its Own Computer |
| 嘉宾 | Felix Rieseberg（Anthropic 技术成员，Cowork 工程负责人） |
| 日期 | 2026-03-17 |
| 时长 | ~86分钟 |
| 评分 | ⭐ 8.75 |

## 摘要

Anthropic Cowork 工程负责人 Felix Rieseberg 在 Latent Space 播客深度阐述了 Anthropic 的 Agent 平台战略。核心主张：硅谷低估了本地计算机的价值——给 Claude 一个沙盒化的 Linux 虚拟机，而非云端执行。访谈覆盖了 Cowork 的意外起源（10天内搭建）、Skills 架构如何用 markdown 文件取代 MCP 服务器、VM 隔离作为自主性与安全性的平衡方案，以及"脚手架终将被模型吸收"的平台风险论断。

## 要点

- **Cowork 自己写了自己**：用多个 Claude Code 实例协同搭建，10天内从现有原型拼装而成，Claude 目前撰写了 Anthropic 约90%的代码
- **本地优先战略**：文件永不离开用户机器，通过 Apple Virtualization Framework / Windows Host Compute 运行独立 Linux VM
- **Skills > MCP**：一个解释 API 的 markdown 文件击败了结构化协议——因为模型足够聪明，能自行推断协议细节
- **脚手架吸收论**：下一次模型升级会吸收第三方脚手架提供的差异化能力——"这是 AWS 打法在 AI 工具层的复刻"
- **模型能力过剩**：Claude 能力远超用户实际使用，瓶颈不是智能而是工具接入
- **对初级岗位的担忧**：入门级任务恰好是 Agent 最先自动化的部分，提出"模拟职业加速"方案

## 详细内容

### 嘉宾背景
Felix Rieseberg，现任 Anthropic 技术成员，领导 Cowork 工程团队。此前担任 Notion 工程经理、Stripe Staff Engineer、Slack Senior Staff Engineer、Microsoft 开源工程师。Electron 框架联合维护者（VS Code、Slack 桌面版、Discord 底层框架）。代表性副项目：将 Windows 95 装进 Electron 应用。

### 1. Cowork 起源：意外发现

团队发现很多 Claude Code 用户其实在做非编程的知识工作——管理开支、整理知识库。即使是深度技术用户也在把 Claude Code 当通用工具使用。这个洞察催生了 Cowork。

Felix 的原话："We built Cowork the same way we want people to use Claude: describing what we needed, letting Claude handle implementation, and steering as we went."

Anthropic 内部是"原型-演示优先"文化，有大量从未公开的内部原型。Cowork 是从众多原型中"挑选正确的组件"拼装而成。

### 2. VM 架构：本地优先的安全模型

**核心论点：硅谷低估了本地计算机的价值。**

- 使用 Apple Virtualization Framework (Mac) / Windows Host Compute (PC) 运行完整 Linux VM
- 不是浏览器沙盒，不是 Docker 容器——是完整虚拟机
- 用户指向文件夹后，该文件夹挂载进 VM，Claude 可自由读写但仅限该目录
- VM 内部 Claude Code 可自由安装任何依赖
- Simon Willison 发布后数天内逆向工程确认了此架构

**Dispatch 功能**（2026-03-16 发布）：一个持久化对话运行在用户电脑上，从手机发送任务，Claude 在 Mac 上执行，回来看完成的工作。

### 3. Skills 架构：Markdown 击败协议

**起源故事**：一个团队想连接 Anthropic 的数据仓库，跳过了构建 MCP 服务器，直接写了一个解释 API 的 markdown 文件给 Claude。效果出奇地好，于是在各处尝试这个模式——这就成了整个 Skills 系统。

- Skills 是"基于 markdown 的轻量级抽象层，用于可复用工作流、个性化自动化和可移植的 Agent 行为"
- Felix 越来越倾向于**基于文件的文本原生接口**，而非将所有东西塞进刚性工具 schema
- 2026 预测："Filesystems will be back with all the rage."

**Plugins 生态**（2026-01-30 发布）：完整包含 Skills、斜杠命令、MCP 连接器和子 Agent 的插件包。例如数据分析师插件可处理 SQL 查询、数据探索、可视化、仪表板。

### 4. 自主性与安全性的平衡

VM 架构是 Anthropic 对自主性/安全性困境的回答：
- "逐条审批"是糟糕的长期 UX
- 无限制访问太危险
- VM 创造了一个中间地带：Agent 在定义好的边界内自由操作

企业安全：IT 部门可独立于宿主机控制 VM 的网络出口和文件系统访问。

Chrome cookie 案例：作为桌面应用，Cowork 理论上可以解密 Chrome cookie 并发送到云端。他们刻意选择不这样做——银行会在检测到异地认证时锁定账户。

### 5. 脚手架吸收论与平台风险

Felix 直言：做精巧 AI 脚手架的公司，下一次模型升级后可能就不存在了。

外部分析（Sakeeb Rahman）："Felix 的脚手架论只有在你是模型提供商时才成立。如果你是初创公司，你的脚手架就是你的产品。当他说下一次模型升级会吸收你的差异化时，他描述的是 Anthropic 夺取第三方目前提供的价值。他把它框定为工程实用主义，市场会把它体验为平台风险。**这是 AWS 打法在 AI 工具层的复刻。**"

### 6. 产品开发哲学

Anthropic 不再写规格文档然后执行，而是并行构建所有候选方案，用焦点小组测试，发布最优方案。内部执行成本趋近于零。

Felix："Don't even write a memo, just build. Let's build all the candidates very quickly."

### 7. 劳动力市场影响

Felix 表达了深切担忧：Anthropic 团队"deeply worried about the impact that the tools are going to have on the labor market, especially for junior employees"。

入门级工程任务——恰好是培训新人的内容——是 Agent 最先自动化的。提出"模拟职业加速"方案：通过 AI 生成的项目序列将三年工程经验压缩到一年。

## 相关笔记
- [[2026-03-22-Karpathy-Code-Agents与AutoResearch]]
- [[2026-03-22-Claude-Code配置技巧]]
- [[2026-03-22-OpenClaw全面解析]]
- [[2026-03-22-Claude-HUD状态栏插件]]

## 评分明细
> 嘉宾分量: 7 | 相关度: 10 | 信息密度: 9 | 时效性: 9 | 形式: 10
> 文字版来源: latent.space 有完整 transcript（Substack 订阅）；Podscan.fm、Podwise 有摘要版
