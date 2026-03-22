#!/bin/bash
# ClaudeCode 自动同步脚本
# 每次执行时拉取所有远程分支的最新内容，自动合并到本地

REPO_DIR="$HOME/ClaudeCode"
LOG_FILE="$REPO_DIR/scripts/.sync.log"
REPO_URL="https://github.com/dtdtxgcf/ClaudeCode.git"

# 确保日志目录存在
mkdir -p "$(dirname "$LOG_FILE")"

# 确保仓库存在
if [ ! -d "$REPO_DIR/.git" ]; then
    echo "$(date): 仓库不存在，正在克隆..." >> "$LOG_FILE"
    git clone "$REPO_URL" "$REPO_DIR" >> "$LOG_FILE" 2>&1
    cd "$REPO_DIR" || exit 1
    # 检出远程默认分支（可能不是 main）
    DEFAULT_BRANCH=$(git remote show origin | grep 'HEAD branch' | awk '{print $NF}')
    if [ "$DEFAULT_BRANCH" != "main" ] && [ -n "$DEFAULT_BRANCH" ]; then
        git checkout "$DEFAULT_BRANCH" >> "$LOG_FILE" 2>&1
    fi
    echo "$(date): 克隆完成，当前分支: $(git branch --show-current)" >> "$LOG_FILE"
    exit 0
fi

cd "$REPO_DIR" || exit 1

echo "$(date): 开始同步..." >> "$LOG_FILE"

# 获取所有远程分支的最新内容
git fetch --all >> "$LOG_FILE" 2>&1

# 获取当前分支名
CURRENT_BRANCH=$(git branch --show-current)

# 如果当前分支有远程追踪，直接 pull
if git rev-parse --abbrev-ref "@{upstream}" > /dev/null 2>&1; then
    git pull --ff-only >> "$LOG_FILE" 2>&1
fi

# 自动检出并合并所有新的远程 claude/ 分支内容
for REMOTE_BRANCH in $(git branch -r | grep 'origin/claude/' | sed 's/origin\///'); do
    # 如果远程分支有新内容，合并到当前分支
    LOCAL_EXISTS=$(git branch --list "$REMOTE_BRANCH")
    if [ -z "$LOCAL_EXISTS" ]; then
        # 新分支，直接合并其内容到当前分支
        echo "$(date): 发现新分支 $REMOTE_BRANCH，合并内容..." >> "$LOG_FILE"
        git merge "origin/$REMOTE_BRANCH" --no-edit >> "$LOG_FILE" 2>&1
    else
        # 已有本地分支，更新它
        git fetch origin "$REMOTE_BRANCH" >> "$LOG_FILE" 2>&1
    fi
done

if [ $? -eq 0 ]; then
    echo "$(date): 同步成功 ($(git log --oneline -1))" >> "$LOG_FILE"
else
    echo "$(date): 同步失败" >> "$LOG_FILE"
fi
