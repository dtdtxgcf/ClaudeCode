---
title: Ghostty 终端 — Claude Code 团队推荐的终端模拟器
sources:
  - https://x.com/bcherny/status/2017742753971769626
  - https://ghostty.org/
  - https://gist.github.com/joyrexus/e20ead11b3df4de46ab32b4a7269abe0
  - https://howborisusesclaudecode.com
date: 2026-03-22
category: tech
tags:
  - 终端
  - Ghostty
  - Claude-Code
  - 效率工具
  - 开发环境
aliases:
  - Ghostty终端
  - Claude Code终端配置
  - Boris终端推荐
---

# Ghostty 终端 — Claude Code 团队推荐的终端模拟器

## 摘要

Claude Code 创始人 Boris Cherny 在推文中分享团队最爱的终端是 Ghostty，凭借 GPU 加速渲染、24-bit 色彩和 Unicode 支持成为 Claude Code 开发的首选终端。Ghostty 由 HashiCorp 联合创始人 Mitchell Hashimoto 开发，是一款跨平台、原生 UI 的现代终端模拟器。

## 要点

- Claude Code 团队最爱终端是 **Ghostty**，多位成员喜欢其同步渲染、24-bit 色彩和 Unicode 支持
- 用 `/statusline` 自定义状态栏，始终显示 context 用量和当前 git 分支
- 团队成员会给终端 tab 上色和命名，有些用 tmux，一个 tab 对应一个任务/worktree
- macOS 上按两次 fn 键启用语音输入，说话速度是打字的 3 倍，prompts 更详细
- 推荐工作流：左边 Claude Code，右上 yazi 看文件，右下 lazygit 管代码

## 详细内容

### 为什么选 Ghostty

Ghostty 是 Mitchell Hashimoto（Vagrant、Terraform、HashiCorp 创始人）从 2021 年开始开发的个人项目，2024 年底发布 1.0 版本。

**核心优势：**

| 特性 | 说明 |
|------|------|
| GPU 加速渲染 | macOS 用 Metal，Linux 用 OpenGL，渲染流畅 |
| 原生 UI | macOS 用 Swift/AppKit，非 Electron，资源占用极低 |
| 24-bit 色彩 | 真彩色支持，配色方案效果完美 |
| Unicode/Ligature | 完整 Unicode 支持 + 字体连字 |
| 终端协议 | 支持比 xterm 之外任何终端都多的转义序列 |
| Kitty 图形协议 | 支持在终端内显示图片 |
| 分屏 | 原生 tabs + splits，无需 tmux 也能分屏 |

**性能对比：** 两个 VS Code 窗口 + Claude Code 扩展消耗 8GB 内存且有输入延迟；同样两个项目在 Ghostty 终端 tab 中总共不到 500MB，响应即时。

### Boris 的 Claude Code 工作流建议

这些建议来自 Boris Cherny 分享的团队 Tips（完整 53 条可在 Claude Code 中输入 `/boris` 查看）：

1. **终端配置**：用 Ghostty，配置简单（可以直接让 Claude Code 帮你配 Ghostty）
2. **状态栏**：`/statusline` 始终显示 context 用量和 git 分支
3. **分屏工作流**：左边 Claude Code + 右上文件浏览 (yazi) + 右下 Git 管理 (lazygit)
4. **语音输入**：macOS 按两次 fn，用说的比用打的快 3 倍
5. **并行工作**：开 3-5 个 git worktree，每个跑一个 Claude Code 实例
6. **Tab 管理**：按任务/worktree 命名和上色 tab

### Ghostty 安装

- 官网：[ghostty.org](https://ghostty.org/)
- GitHub：[ghostty-org/ghostty](https://github.com/ghostty-org/ghostty)
- 支持 macOS 和 Linux（Windows 暂不支持）
- 无需配置文件即可使用，默认设置已经很好
- 终端内可预览数百个配色主题，一行命令切换

### 相关工具

- **yazi**：终端文件管理器，快速浏览文件
- **lazygit**：终端 Git 客户端，可视化管理代码
- **tmux**：终端复用器，可选搭配使用
- **cmux**：基于 libghostty 构建的终端，添加了垂直 tab 等功能

## 信息源 (Sources)

| # | 来源 | 链接 | 说明 |
|---|------|------|------|
| 1 | Boris Cherny 推文 - Terminal Setup | [X/Twitter](https://x.com/bcherny/status/2017742753971769626) | Claude Code 创始人分享的团队终端配置建议，原始信息源 |
| 2 | Ghostty 官网 | [ghostty.org](https://ghostty.org/) | Ghostty 终端模拟器官方网站，含下载和文档 |
| 3 | Boris Team Tips 完整版 | [GitHub Gist](https://gist.github.com/joyrexus/e20ead11b3df4de46ab32b4a7269abe0) | Boris 分享的 Claude Code 团队使用技巧完整整理 |
| 4 | How Boris Uses Claude Code | [howborisusesclaudecode.com](https://howborisusesclaudecode.com) | Boris 的 53 条 Claude Code 使用建议合集 |
| 5 | Ghostty GitHub 仓库 | [github.com/ghostty-org/ghostty](https://github.com/ghostty-org/ghostty) | 开源代码仓库，含安装说明和 issue 讨论 |
| 6 | Mitchell Hashimoto 博客 | [mitchellh.com/ghostty](https://mitchellh.com/ghostty) | Ghostty 作者的项目介绍和开发背景 |

## 相关笔记

- [[2026-03-22-claude-code-claude-md-tips]]

## 原始信息

> 小红书帖子，作者「张司机在路上」，湖南，约 2026 年 3 月中旬发布。
> 内容：作者从 iTerm2 切换到 Ghostty 的体验。起因是看到 Claude Code 负责人 Boris 的推文说团队最爱的终端是 Ghostty。三个爽点：1）配置简单，让 Claude Code 帮配一句话搞定；2）好看，终端内一行命令预览几百个配色主题；3）分屏，左边 Claude Code 右上 yazi 右下 lazygit，GPU 渲染滚日志流畅感极好。配置已放 GitHub。
