# Claude Code 对话自动归档到 Obsidian

每次 Claude Code 会话结束时，自动生成**一个** MD 文件到 Obsidian KnowledgeHub vault，含用户输入、Claude 文本输出和 Haiku 生成的主题/标题/摘要。

## 架构

```
Claude Code 会话结束
  ↓ SessionEnd hook (~/.claude/settings.json)
archive-session.sh
  ├─ 读 stdin: session_id / transcript_path / cwd
  ├─ dedup: 目标目录已有该 session_id → 跳过
  ├─ jq 过滤 JSONL → 只保留 user/assistant 的 text 内容
  ├─ claude -p (Haiku) → 结构化 JSON: { topic, title, summary }
  └─ 写 MD → ~/Documents/KnowledgeHub/<3>library/
             YY-MM-DD【Claude对话】【topic】title.md
```

## 默认路径 & 命名

- **目录**：`~/Documents/KnowledgeHub/<3>library/`
- **文件名**：`YY-MM-DD【Claude对话】【{topic}】{title}.md`
  - `YY-MM-DD` = 两位年份（与 KnowledgeHub 现有文件命名一致）
  - `topic` = Haiku 生成的 2-6 字中文主题（如 `OpenClaw`、`Inbox功能`、`对话归档`）
  - `title` = Haiku 生成的 10-18 字一句话摘要

示例：`26-04-19【Claude对话】【对话归档】实现SessionEnd钩子自动写入Obsidian.md`

## 前置条件

- `jq` 已安装：`brew install jq`
- `claude` CLI 已登录（`claude -p` 能正常使用，用于 Haiku 摘要）
- Obsidian vault = `~/Documents/KnowledgeHub`

## 安装

已通过 `update-config` skill 自动配置 `~/.claude/settings.json` 的 `SessionEnd` hook，指向：
```
~/ClaudeCode/.infra/scripts/archive-session.sh
```

## 可选环境变量

| 变量 | 默认 | 说明 |
|------|------|------|
| `CLAUDE_SESSIONS_DIR` | `~/Documents/KnowledgeHub/<3>library` | 输出目录 |
| `CLAUDE_SESSIONS_SUMMARY_MODEL` | `claude-haiku-4-5` | Haiku 模型 |
| `CLAUDE_SESSIONS_DISABLE` | `0` | 设为 `1` 临时禁用 |

```bash
CLAUDE_SESSIONS_DISABLE=1 claude                  # 本次不归档
CLAUDE_SESSIONS_DIR=~/tmp/preview claude          # 临时改到其它目录
```

## 批量处理过去会话（retroactive）

一次性把过去 N 天的 session 都归档到 KnowledgeHub：

```bash
# 过去 7 天（默认）
bash ~/ClaudeCode/.infra/scripts/archive-past-sessions.sh

# 过去 30 天
DAYS=30 bash ~/ClaudeCode/.infra/scripts/archive-past-sessions.sh

# 先 dry-run 看看会处理哪些
DRY_RUN=1 bash ~/ClaudeCode/.infra/scripts/archive-past-sessions.sh

# 只处理某类项目（匹配 ~/.claude/projects/ 下目录名）
PROJECT_GLOB='*ClaudeCode*' bash ~/ClaudeCode/.infra/scripts/archive-past-sessions.sh
```

批量脚本：
- 扫描 `~/.claude/projects/**/*.jsonl`（含所有项目的 transcript）
- 按 mtime 过滤 N 天内
- 跳过 subagent 子目录的 transcript
- Dedup 由 archive-session.sh 负责——重复运行不会覆盖已有文件
- 每个 session 文件用 transcript 的 mtime 决定日期（不是当前时间）

## 成本

- 每个 session 调 Haiku 一次：约 $0.0005-$0.002（对话越长越贵，一般在 1 分钱以内）
- 批量处理 100 个 session ≈ $0.05-$0.20
- 超时 60s，失败时 topic 填 `未分类`，title 填 `{项目}-{session前8位}`，不会阻塞

## 隐私

- **对话内容写入 Obsidian vault**（vault 一般只在本地，但要注意备份/同步策略）
- 会包含完整对话文本，可能含 token、API key、内部信息
- 建议：
  - vault 不要推到公开 git 仓库
  - 敏感会话用 `CLAUDE_SESSIONS_DISABLE=1 claude` 跳过归档
  - 事后可以手动删除

## 测试

```bash
# 找一条真实 transcript，当作 SessionEnd 的输入模拟一次 hook
TRANSCRIPT=$(ls ~/.claude/projects/*/*.jsonl 2>/dev/null | head -1)
SESSION_ID=$(basename "$TRANSCRIPT" .jsonl)
echo "{\"session_id\":\"$SESSION_ID\",\"transcript_path\":\"$TRANSCRIPT\",\"cwd\":\"$PWD\",\"hook_event_name\":\"SessionEnd\"}" \
  | ~/ClaudeCode/.infra/scripts/archive-session.sh

ls "$HOME/Documents/KnowledgeHub/<3>library/" | tail -1
tail -f ~/.claude/hooks/archive-session.log
```

## 排查

| 现象 | 原因 | 解决 |
|------|------|------|
| 没生成文件 | `jq` 未装 | `brew install jq`，看 `~/.claude/hooks/archive-session.log` |
| topic=未分类, title=项目名-id | `claude -p` 失败或超时 | 检查 `claude` 登录态、网络、模型名；看日志 |
| 文件名乱码 | macOS 文件名字符限制 | 脚本已过滤 `/ \ : * ? " < > \|`；中文保留 |
| hook 阻塞退出 | 不应该发生 | 脚本只会 `exit 0`；若需彻底异步，在 settings.json 的 hook 配置加 `"async": true` |
| Obsidian 看不到新文件 | vault 路径不对 | 确认 Obsidian 打开的 vault = `~/Documents/KnowledgeHub` |

## 后续优化方向

- [ ] 周报：把一周内的 session 聚合成一份周摘要（用 `/loop` + Haiku）
- [ ] 敏感信息正则过滤（token、mnemonic phrase、API key）
- [ ] Dataview 查询：在 Obsidian 里按 topic 标签聚合展示
- [ ] 与 research-db 联动：检测 topic 匹配某公司/赛道时，自动添加 [[双链]]
