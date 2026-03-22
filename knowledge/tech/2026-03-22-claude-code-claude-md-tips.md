---
title: Claude Code CLAUDE.md 配置技巧（Santiago 分享）
source: https://x.com/svpino/status/2018682144361734368
date: 2026-02-03
category: tech
tags:
  - Claude-Code
  - CLAUDE.md
  - AI编程
  - 提示工程
  - 工作流
aliases:
  - Claude Code 配置技巧
  - CLAUDE.md 最佳实践
---

# Claude Code CLAUDE.md 配置技巧

## 摘要

Santiago（@svpino）分享了 5 条添加到 CLAUDE.md 文件中的实用规则，帮助开发者更高效地使用 Claude Code。核心思路是：方案先行、任务拆分、主动测试、测试驱动修 bug、持续自我改进。该推文获得 156.9K+ 浏览。

## 要点

- 写代码前先描述方案，等批准后再动手
- 大任务自动拆分为小任务（超过 3 个文件就停下来）
- 写完代码后主动列出潜在问题并建议测试用例
- 修 bug 时先写复现测试，再迭代修复
- 每次被纠正后自动往 CLAUDE.md 添加新规则

## 详细内容

### 5 条 CLAUDE.md 配置规则

**1. 方案先行（Plan Before Code）**

> "在编写任何代码之前，请先描述你的方案并等待批准。如果需求不明确，在编写任何代码之前务必提出澄清问题。"

这条规则防止 Claude 直接冲进去写代码，确保开发者对方案有控制权。

**2. 任务拆分（Break Down Large Tasks）**

> "如果一项任务需要修改超过 3 个文件，请先停下来，将其分解成更小的任务。"

限制单次修改范围，降低出错风险，也让 code review 更容易。

**3. 主动测试建议（Proactive Testing）**

> "编写代码后，列出可能出现的问题，并建议相应的测试用例来覆盖这些问题。"

让 Claude 不只是写代码，还要主动思考边界情况和潜在风险。

**4. 测试驱动修 Bug（TDD for Bug Fixes）**

> "当发现 bug 时，首先要编写一个能够重现该 bug 的测试，然后不断修复它，直到测试通过为止。"

经典的 TDD 方法论，确保修复是可验证的。

**5. 持续学习（Self-Improving Rules）**

> "每次我纠正你之后，就在 CLAUDE.md 文件中添加一条新规则，这样就不会再发生这种情况了。"

让 CLAUDE.md 成为一个不断进化的规则库，避免重复犯错。

### 延伸：Santiago 的 18 条完整建议

Santiago 后续在 Sonar Summit 演讲中扩展为 18 条建议，额外包括：

- 用 `@filename.py` 或 `@src/classes/` 直接引用文件来约束 Agent 范围
- 创建 `/decompose` 命令将计划拆解为小任务逐个实现
- 在 CLAUDE.md 中描述技术栈、目录结构、编码规范和需避免的反模式
- 用 `/memory` 保存跨项目的个人偏好
- 创建 `.claudeignore` 文件排除不需要读取/修改的文件
- 创建 `/review-xyz` 命令检查正确性、边界情况和代码一致性
- 添加规则：当被告知有错时，先问清楚再重写
- 使用 Git worktree 并行运行多个 Agent 会话
- 在一次性环境中用 `--dangerously-skip-permissions` 加速迭代

## 相关笔记

- [[2026-03-22-ghostty-terminal-claude-code-workflow]]

## 原始信息

> 截图来源：Santiago (@svpino) 的 X/Twitter 推文，发布于 2026-02-03，156.9K 浏览。由"AI肖大叔"账号转发并翻译为中文。
