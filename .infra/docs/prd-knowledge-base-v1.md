---
title: 个人知识库系统 — 产品需求文档 (PRD)
date: 2026-03-22
version: v1.0
status: draft
tags:
  - PRD
  - 知识库
  - 架构设计
---

# 个人知识库系统 — 产品需求文档

## 一、愿景

> 把散落在各处的信息碎片，变成一个可搜索、可关联、可创作的私人知识大脑。

你每天通过 RSS、播客、YouTube、录音、网页浏览、社交媒体接触大量有价值的信息。但这些信息散落在不同的 app 和平台上，既无法检索，也无法建立关联。你需要一个系统，让信息「流进来 → 被加工 → 沉淀下来 → 随时取用」。

## 二、核心原则

| 原则 | 说明 |
|------|------|
| **本地优先** | 数据在你的 Mac 上，不依赖任何云服务即可完整运行 |
| **Markdown 原生** | 所有内容都是 .md 文件，20 年后依然可读，不被任何工具绑架 |
| **AI 增强** | 用 AI 做繁重的整理工作（转写、摘要、打标、关联），你只做最终审阅 |
| **多设备同步** | Mac（主力阅读/创作）+ iPhone（随时采集/快速查阅） |
| **渐进式构建** | 不需要一步到位，按优先级分阶段实施 |

## 三、系统架构

```
┌─────────────────────────────────────────────────────────────────┐
│                        信息采集层                                │
│                                                                 │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌───────┐ │
│  │ RSS 订阅  │ │ 播客/YT  │ │ Plaud    │ │ 网页剪藏  │ │ 截图   │ │
│  │          │ │ 转写     │ │ 录音转写  │ │ Web      │ │ Claude │ │
│  │ Local RSS│ │ Whisper  │ │ Plaud.ai │ │ Clipper  │ │ Code   │ │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘ └───┬───┘ │
│       │            │            │            │           │     │
└───────┼────────────┼────────────┼────────────┼───────────┼─────┘
        │            │            │            │           │
        ▼            ▼            ▼            ▼           ▼
┌─────────────────────────────────────────────────────────────────┐
│                     AI 加工层                                    │
│                                                                 │
│  · 转写 (Whisper/Plaud)                                         │
│  · 摘要 & 要点提炼 (Claude/本地 LLM)                              │
│  · 自动分类 & 打标签                                              │
│  · 关联发现 (Smart Connections)                                   │
│  · 信息源追溯 (Claude Code WebSearch)                             │
│                                                                 │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                   存储层 (Obsidian Vault)                        │
│                                                                 │
│  knowledge/                                                     │
│    ├── tech/          设计/          business/        other/     │
│  notes/               快速笔记 & 灵感                            │
│  index.md             总索引                                     │
│  templates/           MD 模板                                    │
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌──────────────────┐        │
│  │ Dataview     │  │ Smart       │  │ Graph View        │        │
│  │ 结构化查询    │  │ Connections │  │ 知识图谱           │        │
│  │              │  │ 语义搜索    │  │                    │        │
│  └─────────────┘  └─────────────┘  └──────────────────┘        │
│                                                                 │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                      同步层                                      │
│                                                                 │
│  ┌──────────┐      ┌──────────┐      ┌──────────┐              │
│  │ Mac      │ ←──→ │ GitHub   │ ←──→ │ iPhone   │              │
│  │ Obsidian │ Git  │ 中转仓库  │ Git  │ Obsidian │              │
│  │ (主力)   │      │          │      │ Mobile   │              │
│  └──────────┘      └──────────┘      └──────────┘              │
│                                                                 │
│  方案 A: Git 同步 (免费，需配置)                                   │
│  方案 B: Obsidian Sync ($8/月，零配置)                            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## 四、信息源 × 工具矩阵

### 4.1 RSS 订阅

| 方案 | 优点 | 缺点 | 推荐度 |
|------|------|------|--------|
| **Local RSS 插件** | 自动拉取 RSS → 直接生成 .md | 功能简单，无阅读体验 | ★★★★ 推荐 |
| Simple RSS 插件 | 轻量，Mustache 模板 | 功能较少 | ★★★ |
| RSS Reader 插件 | Obsidian 内阅读体验好，可选择性保存 | 不自动生成笔记 | ★★★ |
| Miniflux + Readwise | 专业 RSS 阅读 + 划线同步到 Obsidian | 需要自托管 + 付费 ($8/月) | ★★★ |

**推荐方案：Local RSS 插件**
- 直接在 Obsidian 内订阅 RSS，自动生成 Markdown 笔记
- 零成本，本地优先，无需额外服务
- 配合模板自动添加 front matter

### 4.2 播客 & YouTube

| 方案 | 类型 | 特点 |
|------|------|------|
| **YTranscript** | Obsidian 插件 | YouTube 视频侧边栏字幕，时间戳可点击跳转，可拖拽到笔记 |
| **TubeSage** | Obsidian 插件 | LLM 驱动摘要 + 字幕，支持批量处理频道/播放列表，支持 Claude/GPT/Ollama |
| **Social Archiver** | Obsidian 插件 | 本地 Whisper 转写播客，自动添加到笔记 |
| **Podsidian** | CLI 工具 | 播客下载→转写→摘要完整管线，MCP 支持 |

**推荐方案：**
- YouTube：**TubeSage**（AI 摘要 + 字幕，支持本地模型）
- 播客：**Social Archiver**（本地 Whisper，隐私优先）

### 4.3 Plaud 录音

**Plaud.ai 导出能力：**
- 摘要：支持导出为 **Markdown**
- 思维导图：支持导出为 **Markdown**
- 转写：支持导出为 TXT、SRT、DOCX（无原生 MD，但 TXT 可直接重命名为 .md）
- 音频：MP3、WAV

**推荐工作流：**
1. Plaud 录音 → App 内自动转写
2. 导出摘要和思维导图为 Markdown
3. 手动或脚本移入 Obsidian Vault 的 `knowledge/` 目录
4. 可用 Claude Code 进一步加工（重新整理、打标签、添加关联）

### 4.4 网页剪藏

| 方案 | 特点 |
|------|------|
| **Obsidian Web Clipper** | 官方出品，Chrome/Firefox/Safari(含iOS)，AI 摘要，自定义模板，直接存入 Vault |
| Readwise Reader | 专业阅读 + 划线，自动同步高亮到 Obsidian（$8/月）|

**推荐方案：Obsidian Web Clipper**
- 官方出品，免费
- 支持 AI 摘要（可用 Ollama 本地模型、Claude、GPT）
- 自定义模板自动匹配网站
- Safari iOS 也支持，手机端也能剪藏

### 4.5 截图 / 碎片信息（已实现）

**当前方案：Claude Code**
- iPhone 发送截图 → Claude Code 识别内容 → 搜索信息源 → 整理为结构化 MD → push 到 GitHub
- 已部署在本仓库，配合 CLAUDE.md 工作流指令

## 五、Obsidian 核心插件配置

### 5.1 必装插件

| 插件 | 用途 | 优先级 |
|------|------|--------|
| **Dataview** | SQL 风格查询笔记，创建动态表格和仪表盘 | P0 |
| **Smart Connections** | AI 语义搜索，自动发现笔记间的关联（本地嵌入，无需 API） | P0 |
| **Obsidian Web Clipper** | 浏览器剪藏网页到 Vault | P0 |
| **Local RSS** | RSS 订阅，自动生成笔记 | P1 |
| **TubeSage** | YouTube 字幕 + AI 摘要 | P1 |
| **Social Archiver** | 播客本地转写 | P1 |
| **Calendar** | 日历视图浏览笔记 | P2 |
| **Tag Wrangler** | 批量管理标签 | P2 |
| **Templater** | 高级模板引擎 | P2 |

### 5.2 Smart Connections 重点说明

这是知识库的「关联发现引擎」：
- **零配置本地嵌入**：安装即用，自动索引所有笔记，无需 API Key
- **语义搜索**：按含义搜索，不是关键词匹配（搜「终端工具」能找到「Ghostty」的笔记）
- **关联视图**：浏览任何笔记时，侧边栏自动显示语义相关的其他笔记 + 相似度评分
- **MCP Server**：可让 Claude Desktop 直接访问你的知识库进行语义搜索
- 下载量 78 万+，成熟稳定

### 5.3 Dataview 仪表盘示例

在 Obsidian 中创建一个 `Dashboard.md`，写入以下查询：

````markdown
## 最近添加的知识

```dataview
TABLE sources AS "来源", date AS "日期", tags AS "标签"
FROM "knowledge"
SORT date DESC
LIMIT 20
```

## 按分类统计

```dataview
TABLE length(rows) AS "数量"
FROM "knowledge"
GROUP BY category
```

## 未整理的笔记

```dataview
LIST
FROM "notes"
WHERE !contains(tags, "已整理")
SORT date DESC
```
````

## 六、同步方案

### 方案对比

| 维度 | Git 同步 (免费) | Obsidian Sync ($8/月) |
|------|----------------|----------------------|
| Mac 端 | Git 插件自动 commit/push/pull | 内置，零配置 |
| iPhone 端 | Working Copy (付费 app) 或 iSH | 内置，零配置 |
| 版本历史 | 完整 Git 历史 (优势) | 有限历史 |
| 冲突处理 | 需手动 merge | 自动合并 |
| 稳定性 | 桌面端稳定，移动端偶有问题 | 全平台稳定 |
| 隐私 | GitHub (可用私有仓库) | Obsidian 服务器 (端到端加密) |
| 与 Claude Code 配合 | 天然兼容 (同一个 Git 仓库) | 需额外同步 |

### 推荐方案：Git 同步 + Obsidian Sync 混合

**为什么混合：**
- Claude Code 通过 Git push 内容到 GitHub（已实现）
- Mac 端通过 launchd 定时 git pull（已实现）
- iPhone Obsidian 通过 Obsidian Sync 保持同步（最稳定的移动端方案）
- Mac 端同时开启 Git 插件 + Obsidian Sync，两者不冲突

**或者纯 Git 方案（免费）：**
- Mac: Obsidian Git 插件，自动 commit/push/pull
- iPhone: Working Copy app ($29.99 买断) 管理 Git 仓库
- 可行但移动端体验不如 Obsidian Sync 流畅

## 七、iPhone Obsidian 能力

2025 年底 Obsidian Mobile v1.11.0 更新带来了重要能力：

- **锁屏/控制中心/主屏幕 Widget**：快速新建笔记、打开日记、搜索
- **Siri 集成**：「用 Obsidian 记录」「打开我的日记」「在 Obsidian 搜索」
- **Spotlight 集成**：新建笔记、搜索
- **快捷指令 (Shortcuts)**：无需打开 app 即可追加/写入文本
- **社区插件全部可用**（与桌面端一致）

**这意味着：** 你可以在 iPhone 上用 Siri 语音快速记录灵感，通过 Widget 快速搜索知识库，体验接近桌面端。

## 八、与 Claude Code 的融合

Claude Code 在这个系统中扮演两个角色：

### 角色 1：采集加工员（已实现）
- iPhone 截图 → 识别 → 搜索信息源 → 整理 MD → push 到 GitHub
- 通过 CLAUDE.md 定义工作流，确保输出格式一致

### 角色 2：知识库助手（扩展方向）

| 能力 | 说明 |
|------|------|
| **深度整理** | 让 Claude Code 重新整理 Plaud 导出的粗糙转写文本 |
| **批量打标** | 「帮我给 notes/ 下所有未打标的笔记加上标签」 |
| **知识问答** | 「根据我的知识库，总结一下我收集的所有 AI Agent 相关内容」 |
| **创作辅助** | 「基于这 5 篇笔记，帮我写一篇博客草稿」 |
| **索引维护** | 自动更新 index.md，维护知识库结构 |

### Smart Connections MCP 加持

Smart Connections 提供 MCP Server，可以让 Claude Desktop 直接语义搜索你的 Obsidian Vault：
- 不需要手动翻找笔记
- Claude 自动从知识库中检索相关内容作为上下文
- 实现「基于个人知识库的 AI 对话」

## 九、实施路线图

### Phase 1：基础设施（本次会话已基本完成）

- [x] GitHub 仓库 + 目录结构
- [x] CLAUDE.md 工作流指令
- [x] 知识条目模板 (YAML front matter)
- [x] Mac launchd 自动同步脚本
- [x] Claude Code 截图采集流程验证
- [ ] 合并到 main 分支
- [ ] Mac 端 clone 仓库 + 安装自动同步
- [ ] Obsidian 打开仓库

### Phase 2：阅读 & 搜索（1-2 天）

- [ ] 安装 Dataview + Smart Connections
- [ ] 创建 Dashboard.md 仪表盘
- [ ] 安装 Obsidian Web Clipper 浏览器扩展
- [ ] 配置 Web Clipper 模板（匹配知识库 front matter 格式）
- [ ] 测试：剪藏一篇文章 → Obsidian 中查看 → Smart Connections 关联

### Phase 3：信息流接入（1 周）

- [ ] 安装 Local RSS 插件，订阅 3-5 个 RSS 源测试
- [ ] 安装 TubeSage，测试 YouTube 视频摘要
- [ ] 测试 Plaud 导出 → 手动导入 Obsidian 工作流
- [ ] 配置 iPhone 同步（Obsidian Sync 或 Working Copy + Git）

### Phase 4：AI 增强（2 周）

- [ ] 安装 Social Archiver，测试播客本地转写
- [ ] 配置 Smart Connections MCP Server + Claude Desktop
- [ ] 建立 Plaud 录音的半自动化导入流程
- [ ] 用 Dataview 创建更多视图（按标签、按来源、按时间）

### Phase 5：优化 & 习惯养成（持续）

- [ ] 每周 Review：用 Dataview 查看本周新增内容
- [ ] 每月整理：清理 notes/ 中的临时笔记，归入 knowledge/
- [ ] 逐步增加 RSS 订阅源
- [ ] 根据使用体验调优模板和工作流

## 十、成本估算

| 项目 | 费用 | 必要性 |
|------|------|--------|
| Obsidian | 免费 | 必须 |
| Obsidian Web Clipper | 免费 | 必须 |
| Dataview / Smart Connections | 免费 | 必须 |
| Local RSS / TubeSage / Social Archiver | 免费 | 推荐 |
| Claude Code (截图采集) | 已有 | 已实现 |
| Obsidian Sync (移动端同步) | $8/月 | 推荐但可选 |
| Working Copy (iOS Git 替代方案) | $29.99 买断 | Sync 的免费替代 |
| Readwise (如需划线同步) | $8/月 | 可选 |

**最低成本方案：$0/月**（全用免费工具 + Git 同步）
**推荐方案：$8/月**（加 Obsidian Sync 提升移动端体验）

## 十一、关键决策点

在开始实施前，需要你确认以下决策：

1. **同步方案**：纯 Git（免费）vs Obsidian Sync（$8/月）vs 混合？
2. **RSS 是否需要专业阅读体验**：Local RSS（自动生成笔记）vs Miniflux + Readwise（专业阅读 + 划线）？
3. **播客转写优先级**：是否现在就需要？Social Archiver 需要安装本地 Whisper 模型
4. **Plaud 工作流**：手动导出导入是否可接受？还是需要自动化脚本？
