---
title: "42章经：Agent 开发的上半场 — 环境、Tools 和 Context 如何决定 Agent"
source: https://mp.weixin.qq.com/s/42章经-agent开发上半场
date: 2025-04-27
category: tech
type: podcast
podcast: 42章经
episode: "Agent 开发的上半场: 环境、Tools 和 Context 如何决定 Agent"
guest:
  - 王文锋
score: 7.9
duration: ~60:00
transcript: true
tags:
  - 播客
  - AI-Agent
  - Tool-Use
  - MCP
  - Context工程
  - RL
  - AI-Coding
  - Sheet0
aliases:
  - 42章经Agent上半场
  - 王文锋Agent上半场
---

# 42章经：Agent 开发的上半场 — 环境、Tools 和 Context 如何决定 Agent

## 播客信息

| 项目 | 内容 |
|------|------|
| 播客 | 42章经 |
| 单集 | Agent 开发的上半场: 环境、Tools 和 Context 如何决定 Agent |
| 嘉宾 | 王文锋（Sheet0 创始人） |
| 主播 | 曲凯（42章经创始人） |
| 日期 | 2025-04-27 |
| 时长 | ~60 分钟 |
| 评分 | 7.9 |

## 摘要

Sheet0 创始人王文锋与曲凯系统梳理 Agent 开发的核心框架。从 RL 三要素（状态/行动/激励信号）出发，深入讨论 Context 工程、Tool Use 方案对比（Function Call / MCP / A2A / Computer Use / Browser Use）、垂直 vs 通用 Agent 的取舍，以及 AI Coding 作为"大模型灵巧手"的角色。这期是一年后 [[2026-03-22-42章经-OpenClaw之后只想未来3到6个月]] 的前传，对比两期可清晰看到文锋认知的演变。

## 要点

### Agent 定义与框架
- **Anthropic 定义**：Agent 是让模型基于环境反馈去使用工具的程序
- **RL 三要素映射**：状态 → Context，行动 → Tool Use，激励信号 → 结果评估反馈
- 推荐必读：Richard Sutton《Reinforcement Learning: An Introduction》

### 这波 Agent 热为什么不同（vs 2023 AutoGPT）
- 底层模型能力飞跃（o1 带来长思维链）
- 工程侧突破：大家更懂怎么给 Agent 构建合适的 Context

### Tool Use 方案全景对比
| 方案 | 本质 | 特点 |
|------|------|------|
| Function Call | OpenAI 提出的外部函数调用 | 不通用，跨系统需重做 |
| MCP | 统一 Tool Use 度量衡 | 模块化、标准化，极大降低门槛 |
| A2A | Google 推出的 Agent 间交互 | "KPI 工程"，MCP 已能间接实现 |
| Computer Use | 大模型调用电脑作为工具 | — |
| Browser Use | 通过 GUI 与网页交互 | 纯视觉方案不成熟，实际需 MCP 作中间媒介 |

- **两派路线**：代码驱动（Function Call/MCP/A2A）vs 视觉模拟（Computer Use/Browser Use），不互斥可结合
- Browser Use 对用户的价值：营造"可信氛围感"，让用户看到执行过程

### Context 工程
- Context = 大模型执行任务时所需的各种信息总和
- 与 RAG 的区别：Agent 中 Context 由 AI 自动提炼，不需要人工参与
- 起手收集到的 Context 越多越好
- 用户打开 APP 的瞬间已提供海量 Context（张月光观点）
- Google 的用户点击数据是 AI Native 时代最大竞争优势

### 垂直 vs 通用 Agent
- **当时判断：长期处于垂直 Agent 时代**（注：一年后文锋已改变此观点）
- 比喻：五星级大厨 vs 照菜谱做饭的普通人
- 通用性和准确率存在 trade-off

### AI Coding 是大模型的"灵巧手"
- 每步引入 AI Coding → 把难以评估的结果转化为可验证的代码
- 例：每步生成 10 段代码，只保留正确的，保证阶段性结果准确
- AI Coding 和 Agent 可能殊途同归，但 AI Coding 存在难协同、难复用的问题

### 产品设计洞察
- **Chat 是 Agent 最重要的交互入口**：交互自由度 > 准确度
- 准确度不该是用户承担的问题，应由开发者解决
- Human-in-the-loop、用户偏好积累、引导式提问都是解决方案
- 两个信任问题：信任大模型能力（不要过度限制）+ 让用户信任结果（透明化过程）

### 激励信号设计
- 判断环境好坏的关键：能不能基于行动结果提供激励信号
- IDE 是好环境的典型（代码报错 = 天然激励信号）
- Sheet0 的激励信号：表格数据是否为空 + 生成脚本能否成功运行

### Workflow vs Agent
- Workflow 人类驱动：稳定可靠但缺乏泛化
- Agent AI 驱动：灵活泛化但不确定性高
- Agent 适合 20% 开放探索型任务，80% 日常问题用 Workflow 足够
- 两者会长期共存

## 金句摘录

> "AI Coding 是大模型的灵巧手。"

> "Chat 是 Agent 最重要的交互入口——交互自由度第一重要，远高于准确度。"

> "评判环境好不好，关键看它能不能基于行动结果提供激励信号。"

> "你想更好地了解一个人，就要看 Ta 的过去。同理，你想更好地理解用户意图，就要追踪 Ta 从哪里来。"

> "如果你不信任大模型，就会退回到 rule-based 的老路子上去。"

## 相关笔记

- [[2026-03-22-42章经-OpenClaw之后只想未来3到6个月]] — **一年后续集**：文锋从"垂直Agent时代"转变为"所有Agent都是Coding Agent"，从"预判5-10年"转为"只看3-6个月"
- [[2026-03-22-OpenClaw全面解析]] — OpenClaw 平台技术解析
- [[2026-03-22-晚点聊EP151-MuleRun陈宇森谈Agent创作新范式]] — 同为 Agent 创业访谈
- [[2026-03-22-Claude-Code配置技巧]] — Claude Code 使用方法论

## 评分明细

> 嘉宾分量: 7 | 相关度: 9 | 信息密度: 9 | 时效性: 5 | 形式: 10
> 总分: 7×0.30 + 9×0.25 + 9×0.20 + 5×0.15 + 10×0.10 = 7.9
> 文字版来源: 42章经公众号（用户提供全文）

## 原始信息

> 用户提供了 42章经公众号文章全文。标题：Agent 开发的上半场: 环境、Tools 和 Context 如何决定 Agent｜42章经。作者：曲凯。发布时间：2025年4月27日 22:11。阅读量 1.6 万。嘉宾：王文锋（Sheet0 创始人，文中称"文锋"）。这是 2026-03-22 那期"OpenClaw 之后"的前传，两期对比可见文锋一年间认知的显著演变。
