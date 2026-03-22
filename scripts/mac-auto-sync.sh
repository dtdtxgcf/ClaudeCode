#!/bin/bash
# ClaudeCode 自动同步脚本
# 每次执行时从 GitHub 拉取最新内容

REPO_DIR="$HOME/ClaudeCode"
LOG_FILE="$REPO_DIR/scripts/.sync.log"

# 确保仓库存在
if [ ! -d "$REPO_DIR/.git" ]; then
    echo "$(date): 仓库不存在，正在克隆..." >> "$LOG_FILE"
    git clone https://github.com/dtdtxgcf/ClaudeCode.git "$REPO_DIR"
    exit 0
fi

cd "$REPO_DIR" || exit 1

# 拉取最新内容
echo "$(date): 开始同步..." >> "$LOG_FILE"
git pull origin main >> "$LOG_FILE" 2>&1

if [ $? -eq 0 ]; then
    echo "$(date): 同步成功" >> "$LOG_FILE"
else
    echo "$(date): 同步失败" >> "$LOG_FILE"
fi
