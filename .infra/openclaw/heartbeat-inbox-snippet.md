# OpenClaw HEARTBEAT.md 追加片段 — Inbox 扫描

> 将以下内容追加到你的 `~/.openclaw/workspace/HEARTBEAT.md` 中

## 每日 18:00 — Inbox 整理

- [ ] 通过 GitHub API 列出 `notes/inbox/` 目录下所有文件
- [ ] 按类型统计：idea / todo / snippet / invest-note
- [ ] 对每个条目生成整理建议：
  - idea → 是否展开为知识笔记（存入 knowledge/）？
  - todo → 是否已完成？是否加入 QUEUE.md？
  - snippet → 是否需要 WebSearch 找原文、生成完整笔记？
  - invest-note → 是否新建/更新 research-db/ 条目？
- [ ] 汇总为 inbox 日报，发送给用户
- [ ] 用户确认后，将已处理的条目移出 inbox（更新 status: processed）
