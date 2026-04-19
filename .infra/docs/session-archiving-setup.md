# Claude Code 对话自动归档设置

每次 Claude Code 会话结束时，自动生成 MD 文件到 Obsidian vault，包含用户输入、Claude 输出和摘要。

## 架构

```
Claude Code 会话结束
  ↓ SessionEnd hook (~/.claude/settings.json)
archive-session.sh
  ├─ 读 stdin: session_id / transcript_path / cwd
  ├─ jq 过滤 JSONL → 只保留 user/assistant 的 text 内容
  ├─ claude -p (Haiku) → 生成中文摘要
  └─ 写 MD → ~/ClaudeCode/notes/sessions/YYYY-MM-DD-HH-MM-{cwd}-{session前8位}.md
  ↓
Obsidian 识别（vault = ~/ClaudeCode）
```

## 前置条件

- `jq` 已安装：`brew install jq` / `apt install jq`
- `claude` CLI 已登录（`claude -p` 能正常使用）
- Obsidian vault 路径 = `~/ClaudeCode`（如不同请改 `CLAUDE_SESSIONS_DIR`）

## 安装

已通过 `update-config` skill 自动配置 `~/.claude/settings.json` 的 `SessionEnd` hook，指向：
```
~/ClaudeCode/.infra/scripts/archive-session.sh
```

## 可选环境变量

| 变量 | 默认 | 说明 |
|------|------|------|
| `CLAUDE_SESSIONS_DIR` | `~/ClaudeCode/notes/sessions` | 输出目录 |
| `CLAUDE_SESSIONS_SUMMARY_MODEL` | `claude-haiku-4-5` | 摘要使用的模型 |
| `CLAUDE_SESSIONS_DISABLE` | `0` | 设为 `1` 临时禁用归档 |

在 shell rc 里导出，或一次性使用：
```bash
CLAUDE_SESSIONS_DISABLE=1 claude  # 本次不归档
```

## 成本

- Haiku 调用一次 ~$0.0005-$0.002（取决于对话长度）
- 超时 45s，失败时摘要字段写 `[summary unavailable]`，不影响归档

## 隐私

- `notes/sessions/` 已加入 `.gitignore`，**不会进入 git 仓库**
- Obsidian 直接读本地文件系统，不经网络
- transcript 可能含敏感信息（token、密钥等），请勿手动 push 该目录

## 测试

**干跑**（用已有 transcript 模拟一次 hook）：
```bash
# 找一个现有 session transcript
TRANSCRIPT=$(ls ~/.claude/sessions/*.jsonl 2>/dev/null | head -1)
echo "{\"session_id\":\"test-0000\",\"transcript_path\":\"$TRANSCRIPT\",\"cwd\":\"$PWD\",\"hook_event_name\":\"SessionEnd\"}" \
  | ~/ClaudeCode/.infra/scripts/archive-session.sh

# 查看输出
ls ~/ClaudeCode/notes/sessions/
```

**实测**：
```bash
claude           # 随便聊两句
/exit            # 退出
ls ~/ClaudeCode/notes/sessions/  # 应该多一个文件
```

**查看日志**：
```bash
tail -f ~/.claude/hooks/archive-session.log
```

## 排查

| 现象 | 原因 | 解决 |
|------|------|------|
| 没生成文件 | `jq` 未装 | 装 jq，看日志确认 |
| 摘要为 `[summary unavailable]` | `claude -p` 失败或超时 | 看日志，检查 `claude` 登录态和网络 |
| 文件名乱码 | cwd 路径含非 ASCII | 已处理，非法字符会替换为 `-` |
| hook 阻塞了 Claude Code 退出 | 不应该发生（脚本 `exit 0`） | 把 hook 的 command 改成 `bash -c '... &'` 异步 |

## 后续优化方向

- [ ] 支持按标签/项目筛选是否归档（目前是全局）
- [ ] 周报 / 月报：/loop 定时汇总本周 session 摘要
- [ ] 敏感信息自动脱敏（正则过滤 token、密钥）
- [ ] Obsidian dataview 查询：按项目、按天聚合 session 记录
