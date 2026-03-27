---
title: Claude HUD — Claude Code 实时状态栏插件
source: https://github.com/jarrodwatts/claude-hud
date: 2026-03-22
category: tech
tags:
  - Claude-Code
  - 效率工具
  - 开源
  - 插件
aliases:
  - Claude HUD
---

# Claude HUD — Claude Code 实时状态栏插件

## 摘要

Claude HUD 是一个 Claude Code 原生插件，在终端输入框下方实时显示 context 用量、工具活动、Agent 状态和 Todo 进度。GitHub 10.9k stars，MIT 开源，零依赖，3 步安装。

## 要点

- 基于 Claude Code 原生 statusline API，不需要 tmux 或额外窗口
- 约每 300ms 刷新一次，实时显示会话状态
- 10.9k GitHub stars，活跃维护（v0.0.9，2026-03-05）
- 3 步安装，零依赖

## 详细内容

### 显示信息

| 行 | 内容 |
|----|------|
| 第 1 行 | 模型名称、项目路径、Git 分支 |
| 第 2 行 | Context 进度条 + 用量百分比（绿→黄→红）、速率限制消耗 |
| 第 3 行 | 工具活动状态（Edit / Read / Grep 等） |
| 第 4 行 | Agent 运行状态、Todo 完成进度 |

### 安装

```bash
/plugin marketplace add jarrodwatts/claude-hud
/plugin install claude-hud
/claude-hud:setup
```

> Linux 用户需设置 `TMPDIR` 环境变量（tmpfs 限制）

### 配置

- 3 种预设：Full / Essential / Minimal
- 可逐个开关显示元素
- 配置文件：`~/.claude/plugins/claude-hud/config.json`
- 支持 expanded（多行）和 compact（单行）布局
- 路径显示深度：1-3 级目录

### 技术细节

- 语言：TypeScript (40.9%) + JavaScript (59.1%)
- 要求：Claude Code v1.0.80+，Node.js 18+ 或 Bun
- 作者：jarrodwatts
- 协议：MIT
- 最新版本：v0.0.9（2026-03-05）

## 相关笔记

- [[2026-03-22-Claude-Code配置技巧]] — Claude Code 配置与使用技巧
- [[2026-03-22-Ghostty终端与Claude-Code工作流]] — 终端与 Claude Code 工作流优化

## 原始信息

> 用户分享了小红书截图：作者"张司机在路上"介绍 Claude HUD，称其为"GitHub 上 4000 多 star 的 Claude Code 状态栏插件，限额、上下文、模型信息一眼看完，三条命令装好。"（注：截图时为 4000+ stars，搜索时已增长至 10.9k stars）
