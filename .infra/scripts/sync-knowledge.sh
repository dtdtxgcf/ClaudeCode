#!/bin/bash
# ClaudeCode 知识同步脚本（增强版）
# 对比远程后 pull，合并所有 claude/ 分支，成功时发送 macOS 通知

REPO_DIR="$HOME/ClaudeCode"
LOG_FILE="$REPO_DIR/.infra/scripts/.sync.log"
REPO_URL="https://github.com/dtdtxgcf/ClaudeCode.git"

mkdir -p "$(dirname "$LOG_FILE")"

# 确保仓库存在
if [ ! -d "$REPO_DIR/.git" ]; then
    echo "$(date): 仓库不存在，正在克隆..." >> "$LOG_FILE"
    git clone "$REPO_URL" "$REPO_DIR" >> "$LOG_FILE" 2>&1
    cd "$REPO_DIR" || exit 1
    DEFAULT_BRANCH=$(git remote show origin | grep 'HEAD branch' | awk '{print $NF}')
    if [ "$DEFAULT_BRANCH" != "main" ] && [ -n "$DEFAULT_BRANCH" ]; then
        git checkout "$DEFAULT_BRANCH" >> "$LOG_FILE" 2>&1
    fi
    echo "$(date): 克隆完成" >> "$LOG_FILE"
    osascript -e 'display notification "仓库克隆完成" with title "知识库已就绪" sound name "Glass"'
    exit 0
fi

cd "$REPO_DIR" || exit 1

echo "$(date): 开始同步..." >> "$LOG_FILE"

# 记录同步前的 HEAD
LOCAL_HEAD=$(git rev-parse HEAD)

# 获取所有远程更新
git fetch --all >> "$LOG_FILE" 2>&1

# 当前分支有远程追踪时 pull
CURRENT_BRANCH=$(git branch --show-current)
if git rev-parse --abbrev-ref "@{upstream}" > /dev/null 2>&1; then
    git pull --ff-only >> "$LOG_FILE" 2>&1
fi

# 合并所有新的远程 claude/ 分支内容
for REMOTE_BRANCH in $(git branch -r | grep 'origin/claude/' | sed 's/origin\///'); do
    LOCAL_EXISTS=$(git branch --list "$REMOTE_BRANCH")
    if [ -z "$LOCAL_EXISTS" ]; then
        echo "$(date): 发现新分支 $REMOTE_BRANCH，合并内容..." >> "$LOG_FILE"
        git merge "origin/$REMOTE_BRANCH" --no-edit >> "$LOG_FILE" 2>&1
    else
        git fetch origin "$REMOTE_BRANCH" >> "$LOG_FILE" 2>&1
    fi
done

# 检查是否有新内容并通知
NEW_HEAD=$(git rev-parse HEAD)
if [ "$LOCAL_HEAD" != "$NEW_HEAD" ]; then
    COMMIT_MSG=$(git log --oneline -1)
    echo "$(date): 同步成功 ($COMMIT_MSG)" >> "$LOG_FILE"
    osascript -e "display notification \"$COMMIT_MSG\" with title \"知识库已更新\" sound name \"Glass\""
else
    echo "$(date): 已是最新" >> "$LOG_FILE"
fi
