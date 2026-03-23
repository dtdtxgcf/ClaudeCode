---
title: Anthropic 为何认为 AI 需要独立的计算机——Felix Rieseberg 谈 Claude Cowork
source: https://www.latent.space/p/felix-anthropic
date: 2026-03-23
category: tech
type: podcast
podcast: Latent Space
episode: Why Anthropic Thinks AI Should Have Its Own Computer — Felix Rieseberg of Claude Cowork & Claude Code Desktop
guest: [Felix Rieseberg]
score: 9.05
duration: 75min
transcript: true
tags:
  - 播客
  - AI-Agent
  - Claude-Cowork
  - Anthropic
  - 本地优先
  - VM沙盒
  - AI工程
aliases:
  - Latent Space Felix
  - Claude Cowork 架构
---

# Anthropic 为何认为 AI 需要独立的计算机——Felix Rieseberg 谈 Claude Cowork

## 播客信息

| 项目 | 内容 |
|------|------|
| 播客 | Latent Space: The AI Engineer Podcast |
| 单集 | Why Anthropic Thinks AI Should Have Its Own Computer |
| 嘉宾 | Felix Rieseberg（Anthropic MTS，Claude Cowork 负责人） |
| 日期 | 2026-03-17 |
| 时长 | ~75分钟 |
| 评分 | ⭐ 9.05 |

## 摘要

Anthropic 内部工程师 Felix Rieseberg 首次深度拆解 Claude Cowork 的设计哲学：为什么 AI 需要在自己的虚拟机里运行、为什么技能（Skills）比 MCP 连接器更强大、以及 Cowork 的核心理念——"先问清楚，再执行"。揭示了 Anthropic 对本地优先 Agent 架构的完整产品战略。

## 要点

- **执行成本归零**：Anthropic 建造多个候选方案同时测试，而非依赖冗长的规格说明文档
- **VM 即安全边界**：Claude 在隔离虚拟机中运行，既防止意外破坏宿主系统，又赋予 AI "自己的电脑"进行合法操作
- **本地计算的价值**：隐私保护、离线工作能力、规避复杂权限链条，云端无法完全替代
- **Skills 优于 MCP**：基于文本的 Skill 指令比复杂的 MCP 连接器更灵活，让 Claude 解决个性化工作流
- **计划先于执行**：Cowork 的核心 UX——多步骤计划展示给用户可编辑，对知识类长任务至关重要
- **AI 垂直应用压缩**：随着基础模型增强，专化包装层可能被吸收，更强的 primitive 取代窄功能应用

## 详细内容

### 1. Claude Cowork 诞生故事
Felix 的背景横跨 Slack 桌面客户端、Electron 框架、JS 运行 Windows 95 等项目。加入 Anthropic 后，他注意到一个意外：大量用户在用 Claude Code 做**知识工作**而非编程。这个观察直接催生了 Cowork——10天内用多个 Claude Code 实例协作搭建完成，Claude Cowork 在某种意义上是"自己写了自己"。

### 2. 为什么 AI 需要自己的计算机
核心论点：AI Agent 需要一个安全的执行沙盒。VM 提供两层价值：
- **安全**：防止 Agent 意外删除文件、修改系统配置
- **能力**：AI 可以在自己的环境里自由安装软件、运行长任务，无需向宿主系统申请权限

对比 OpenClaw 运行在宿主机上的方式，Anthropic 选择了 VM 隔离路线。

### 3. Skills 系统架构
Skills 是 Markdown 文本文件，描述多步骤自动化流程。Felix 认为这比 MCP JSON 连接器更有效，因为：
- 人类可读可编辑
- Claude 可以自主组合多个 Skills
- 适应用户个性化工作流，而非仅对接固定 API

### 4. 计划-执行循环（Plan-Execute Loop）
Cowork 的核心 UX 设计：在执行长任务前，先生成带有可编辑步骤的多步计划，用户确认后执行。这解决了 Agent 长任务中的"幽灵跑偏"问题。

### 5. 劳动力市场影响
Felix 对入门级白领工作的替代持保守但严肃的态度：某些重复性知识工作确实面临高度自动化风险，Anthropic 内部讨论这个话题时没有回避。

## 相关笔记
- [[2026-03-22-Karpathy-Code-Agents与AutoResearch]]
- [[2026-03-22-OpenClaw全面解析]]
- [[2026-03-22-OpenClaw-Workspace配置最佳实践]]
- [[2026-03-22-Claude-Code榜一大哥刘小排]]

## 评分明细
> 嘉宾分量: 8 | 相关度: 10 | 信息密度: 9 | 时效性: 9 | 形式: 10
> 文字版来源: latent.space 官方 Substack 有完整文字版，podscan.fm 有逐字稿
