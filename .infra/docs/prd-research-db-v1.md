---
title: 投资研究库系统 — 产品需求 · 架构 · 落地方案
date: 2026-03-22
version: v1.0
status: draft
tags:
  - PRD
  - 投资研究
  - 架构设计
---

# 投资研究库系统 — 产品需求 · 架构 · 落地方案

## 一、核心目标

> **发现好公司、研究理解好公司、持续跟踪好公司。**
> **发现好赛道、研究理解好赛道、持续跟踪好赛道。**

整个系统围绕两个核心实体（公司 + 赛道）和三个阶段（发现 → 研究 → 跟踪）展开，不做任何多余的事。

## 二、设计原则

| 原则 | 说明 |
|------|------|
| **极简结构** | 两个目录 + 两套模板，没有第三个 |
| **模板驱动** | 好模板 = 好研究。模板中的每个字段都在回答一个投资判断所需的关键问题 |
| **状态流转** | 每篇笔记都有生命周期：`watching → researching → archived`，对应"发现→研究→归档" |
| **事件追加** | 跟踪不是另建文件，而是在已有笔记底部追加更新日志 |
| **双链关联** | 赛道 ↔ 公司通过 `[[wikilink]]` 互相引用，Obsidian 自动构建关系图谱 |
| **Claude Code 即入口** | 不需要 inbox、不需要 dashboard 文件。用户发一条消息，Claude Code 直接创建或更新笔记 |

## 三、系统架构

```
research-db/
├── segments/                    # 赛道研究
│   ├── YYYY-MM-DD-赛道名.md
│   └── ...
└── companies/                   # 公司研究
    ├── YYYY-MM-DD-公司名.md
    └── ...
```

就这些。没有 inbox、没有 dashboard 文件、没有 notes 子目录。

### 为什么不需要更多？

| 被砍掉的 | 理由 |
|----------|------|
| `inbox/` | Claude Code 就是收件箱。用户发截图/链接，直接生成结构化笔记，不存在"先扔后整理"的流程 |
| `_dashboard.md` | 手动维护必然过时。Obsidian Dataview 可动态生成仪表盘；需要全局视图时让 Claude Code 临时汇总即可 |
| `notes/` | "专题研究"本质上是赛道分析的一部分或公司对比的一部分，不需要独立目录。真有需要时再加 |
| `_sources.md` | 信息源记录在每篇笔记的 `source` 字段里，哪条信息来自哪里一目了然 |

### 与现有知识库的关系

```
ClaudeCode/                      # Obsidian Vault 根目录
├── knowledge/                   # 已有：通用知识库（tech/design/business/other）
├── notes/                       # 已有：快速笔记 & 灵感
├── research-db/                 # 新增：投资研究库
│   ├── segments/
│   └── companies/
├── index.md                     # 已有：知识库总索引
└── CLAUDE.md                    # 工作流指令
```

`research-db/` 与 `knowledge/` 并列，互不干扰。投资研究有自己的节奏和结构，不应该混入通用知识库的分类体系。但两者之间可以通过 `[[双链]]` 互相引用——比如一篇 `knowledge/tech/` 下的 AI 技术笔记可以被某个公司研究引用。

## 四、核心实体：公司

### 4.1 公司笔记模板

```markdown
---
title: 公司名称
type: company
status: watching | researching | archived
source: https://触发创建这篇笔记的信息来源
date: YYYY-MM-DD
segment:
  - "[[赛道名]]"
tags:
  - 标签1
  - 标签2
aliases:
  - 英文名
  - 中文名
---

# 公司名称

## 一句话

> 用一句话说清楚这家公司做什么、为谁做、怎么做的。

## 基本面

| 维度 | 信息 |
|------|------|
| 官网 | |
| 成立时间 | |
| 总部 | |
| 阶段 | 种子 / A轮 / B轮 / C轮+ / Pre-IPO / 上市 |
| 最新融资 | 金额、时间、领投方 |
| 累计融资 | |
| 核心团队 | 创始人背景 |
| 员工规模 | |

## 它解决什么问题？

谁的问题？问题有多痛？现在怎么解决的？为什么现有方案不够好？

## 它怎么做的？

产品是什么形态？核心技术/方法是什么？有什么独特的地方？

## 壁垒在哪？

技术壁垒？数据壁垒？网络效应？监管壁垒？品牌壁垒？转换成本？

## 商业模式

怎么收费？客户是谁？客单价？复购率？单位经济模型？

## 竞争格局

| 竞争对手 | 差异点 |
|----------|--------|
| [[竞品A]] | |
| [[竞品B]] | |

## 关键指标 / 里程碑

- FDA/NMPA 审批状态
- 客户数 / ARR / 增长率
- 临床数据 / 论文发表
- 重要合作伙伴

## 我的判断

**结论：** 看好 / 观望 / 不看

**理由：**

**风险：**

**下一步：** 需要进一步了解什么？

## 更新日志

| 日期 | 事件 | 来源 |
|------|------|------|
| YYYY-MM-DD | 事件描述 | [来源](URL) |

## 相关笔记

- [[相关赛道]]
- [[相关公司]]
- [[相关知识条目]]
```

### 4.2 模板设计思路

每个章节都在回答一个投资判断的核心问题：

| 章节 | 回答的问题 |
|------|-----------|
| 一句话 | 我能不能 30 秒内向别人说清楚这家公司？ |
| 基本面 | 这家公司的基本信息和当前状态？ |
| 解决什么问题 | 需求真实存在吗？市场有多大？ |
| 怎么做的 | 产品和技术有独特性吗？ |
| 壁垒在哪 | 为什么别人做不了 / 追不上？ |
| 商业模式 | 怎么赚钱？能赚多少？ |
| 竞争格局 | 在市场中处于什么位置？ |
| 关键指标 | 有没有可验证的进展？ |
| 我的判断 | 最终结论和理由 |
| 更新日志 | 后续发生了什么？判断需要修正吗？ |

### 4.3 状态流转

```
watching ──────► researching ──────► archived
 (发现)           (深入研究)          (结论明确/不再关注)
   ▲                                     │
   └─────────── 重新激活 ◄────────────────┘
```

- **watching**：看到了这家公司，初步记录，还没深入。可能只填了"一句话"和"基本面"
- **researching**：正在深入研究，逐步填充各章节
- **archived**：已有明确结论（看好/不看），或公司已不再活跃

状态变更时在更新日志中记录原因。

## 五、核心实体：赛道

### 5.1 赛道笔记模板

```markdown
---
title: 赛道名称
type: segment
status: watching | researching | archived
source: https://触发创建这篇笔记的信息来源
date: YYYY-MM-DD
tags:
  - 标签1
  - 标签2
aliases:
  - 英文名
  - 中文名
---

# 赛道名称

## 一句话

> 用一句话说清楚这个赛道是什么、解决什么问题。

## 赛道概况

| 维度 | 信息 |
|------|------|
| 市场规模 | 当前 / 预测 / CAGR |
| 发展阶段 | 萌芽 / 成长 / 成熟 / 衰退 |
| 关键驱动力 | 技术突破？政策推动？需求变化？ |
| 核心障碍 | 什么在阻碍这个赛道发展？ |

## 为什么现在？

为什么这个赛道在此时此刻值得关注？发生了什么变化（技术突破、政策变化、成本下降、需求爆发）？

## 产业链

```
上游（供给侧）                中游（产品/服务）              下游（需求侧）
──────────────              ────────────────              ──────────────
· 关键要素1                  · 产品形态1                    · 客户群体1
· 关键要素2                  · 产品形态2                    · 客户群体2
```

## 竞争格局

| 公司 | 阶段 | 特点 | 判断 |
|------|------|------|------|
| [[公司A]] | B轮 | ... | 看好 |
| [[公司B]] | C轮 | ... | 观望 |
| [[公司C]] | 上市 | ... | 不看 |

## 投资逻辑

**看好的理由：**

**主要风险：**

**理想标的画像：** 在这个赛道里，什么样的公司最值得投？

## 关键事件 & 趋势

- YYYY-MM-DD 事件描述

## 更新日志

| 日期 | 事件 | 来源 |
|------|------|------|
| YYYY-MM-DD | 事件描述 | [来源](URL) |

## 相关笔记

- [[相关赛道]]
- [[相关公司]]
- [[相关知识条目]]
```

### 5.2 赛道与公司的关联机制

关联完全通过 `[[wikilink]]` 实现，不靠目录结构：

```
赛道笔记                           公司笔记
┌──────────────────┐              ┌──────────────────┐
│ # AI 医学影像     │              │ # 鹰瞳科技        │
│                  │              │                  │
│ ## 竞争格局       │   ◄─────►   │ segment:         │
│ - [[鹰瞳科技]]   │              │   - [[AI医学影像]] │
│ - [[数坤科技]]   │              │                  │
│ - [[推想医疗]]   │              │ ## 竞争格局       │
│                  │              │ - [[数坤科技]]    │
└──────────────────┘              └──────────────────┘
```

Obsidian 的 Graph View 会自动把这些链接可视化为关系图谱。Smart Connections 插件还能发现你没手动链接的语义关联。

## 六、工作流设计

### 6.1 发现 — 新建笔记

**触发方式：** 用户发送截图、链接、或描述给 Claude Code。

**Claude Code 执行流程：**

```
用户输入
  │
  ▼
判断：这是一家公司还是一个赛道？
  │
  ├─► 公司 ──► 检查 research-db/companies/ 是否已存在
  │            ├─► 不存在 → 创建新笔记（status: watching）
  │            └─► 已存在 → 跳转到"更新"流程
  │
  └─► 赛道 ──► 检查 research-db/segments/ 是否已存在
               ├─► 不存在 → 创建新笔记（status: watching）
               └─► 已存在 → 跳转到"更新"流程
```

新建笔记时：
1. WebSearch 搜索公司/赛道信息
2. WebFetch 阅读关键来源
3. 填充模板中能填的字段（不勉强填不确定的信息）
4. 标记 `status: watching`
5. 检查已有笔记，建立 `[[双链]]`
6. 更新 `index.md`
7. git add → commit → push

### 6.2 研究 — 深化笔记

**触发方式：** 用户说"帮我深入研究一下 [[公司名]]"或"把 [[赛道名]] 的分析补充完整"。

**Claude Code 执行流程：**

1. 读取现有笔记，识别空白字段
2. 针对性搜索补充信息
3. 填充空白章节
4. 将 `status` 更新为 `researching`
5. 在更新日志中记录本次研究
6. git add → commit → push

### 6.3 跟踪 — 更新笔记

**触发方式：** 用户发来一条新消息，关于已有公司/赛道的新动态。

**Claude Code 执行流程：**

1. 识别涉及的公司/赛道
2. 读取已有笔记
3. 在 `## 更新日志` 表格中追加新行
4. 如果事件重大（如融资、IPO、重大产品发布），同时更新正文相关章节
5. 如果判断需要修正，更新 `## 我的判断`
6. git add → commit → push

### 6.4 查询 — 汇总视图

用户可以随时要求 Claude Code 生成汇总，例如：

- "我现在在跟踪哪些公司？"→ 扫描所有 `status: watching | researching` 的公司笔记
- "AI 医学影像赛道的公司整理一下"→ 读取赛道笔记 + 关联公司笔记，生成汇总
- "最近两周有什么更新？"→ 扫描所有笔记的更新日志，按时间排序

这些**不需要维护 dashboard 文件**，按需生成即可。

## 七、Obsidian Dataview 动态仪表盘

虽然不需要手动维护 dashboard 文件，但在 Obsidian 中可以创建一个 `research-db/Dashboard.md`，用 Dataview 插件动态生成视图：

````markdown
# 投资研究仪表盘

## 正在关注的公司

```dataview
TABLE status AS "状态", segment AS "赛道", date AS "录入日期"
FROM "research-db/companies"
WHERE status = "watching" OR status = "researching"
SORT date DESC
```

## 正在关注的赛道

```dataview
TABLE status AS "状态", date AS "录入日期"
FROM "research-db/segments"
WHERE status = "watching" OR status = "researching"
SORT date DESC
```

## 最近更新

```dataview
TABLE status AS "状态", type AS "类型"
FROM "research-db"
SORT file.mtime DESC
LIMIT 20
```

## 按赛道分布

```dataview
TABLE length(rows) AS "公司数"
FROM "research-db/companies"
WHERE segment
FLATTEN segment
GROUP BY segment
```
````

这个文件创建一次，永远不需要维护——Dataview 每次打开时自动查询最新数据。

## 八、索引集成

在现有 `index.md` 中新增「投资研究」板块：

```markdown
## 投资研究

### 赛道
- [[赛道名]](research-db/segments/文件名.md) — 简短描述 `#标签`

### 公司
- [[公司名]](research-db/companies/文件名.md) — 简短描述 `#标签`
```

## 九、CLAUDE.md 新增指令

需要在 CLAUDE.md 中追加投资研究相关的工作流指令：

```markdown
## 投资研究工作流

### 核心目标
发现好公司、研究理解好公司、持续跟踪好公司。
发现好赛道、研究理解好赛道、持续跟踪好赛道。

### 处理流程
当用户发送与公司或赛道相关的信息时：

1. **判断类型**：这是一家公司还是一个赛道？
2. **检查是否已存在**：搜索 research-db/ 目录
3. **新建或更新**：
   - 不存在 → 用模板新建笔记，WebSearch 搜索补充信息
   - 已存在 → 在更新日志追加新事件，必要时更新正文
4. **建立关联**：检查已有笔记，添加 [[双链]]
5. **更新索引**：在 index.md 的投资研究板块添加/更新条目
6. **提交推送**：git add → commit → push

### 模板位置
- 公司模板：`.infra/templates/company-template.md`
- 赛道模板：`.infra/templates/segment-template.md`

### 文件命名
- 公司：`research-db/companies/YYYY-MM-DD-公司名.md`
- 赛道：`research-db/segments/YYYY-MM-DD-赛道名.md`

### 状态管理
- `watching`：初步发现，只有基本信息
- `researching`：深入研究中，逐步完善各章节
- `archived`：结论明确或不再关注
```

## 十、落地步骤

### Step 1：创建目录结构

```bash
mkdir -p research-db/segments research-db/companies
```

### Step 2：创建模板文件

- `.infra/templates/company-template.md` — 第四章的公司模板
- `.infra/templates/segment-template.md` — 第五章的赛道模板

### Step 3：创建 Dataview 仪表盘

- `research-db/Dashboard.md` — 第七章的 Dataview 查询

### Step 4：更新 CLAUDE.md

追加第九章的投资研究工作流指令。

### Step 5：更新 index.md

新增「投资研究」板块。

### Step 6：提交推送

```bash
git add research-db/ .infra/templates/company-template.md .infra/templates/segment-template.md
git commit -m "knowledge: add 投资研究库系统"
git push
```

### Step 7（可选）：Obsidian 配置

在 Obsidian 中：
1. 确认 Dataview 插件已安装
2. 打开 `research-db/Dashboard.md` 验证仪表盘正常显示
3. 确认 Smart Connections 已索引 `research-db/` 目录

## 十一、后续扩展（不在本期范围）

以下能力明确**不在本次实施范围**，但架构已预留空间：

| 扩展方向 | 说明 | 触发条件 |
|----------|------|----------|
| 对比分析模板 | A vs B 公司对比 | 当同一赛道有 3+ 家公司时再考虑 |
| 投资 Thesis 文档 | 完整的投资备忘录 | 当需要正式输出时再加 |
| 自动化信息源监控 | 定期扫描特定来源的更新 | 当手动更新成为瓶颈时再考虑 |
| 财务模型模板 | DCF / Comps 等 | 当研究进入量化阶段时再加 |

当前的两个模板 + 两个目录已经能覆盖 90% 的日常研究需求。不要为 10% 的假想场景增加 50% 的复杂度。
