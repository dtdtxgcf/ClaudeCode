#!/bin/bash
# ClaudeCode 双向自动同步脚本
# 功能：1) 本地有变更时自动 commit + push  2) 拉取远程最新内容

REPO_DIR="$HOME/ClaudeCode"
LOG_FILE="$REPO_DIR/.infra/scripts/.sync.log"
REPO_URL="https://github.com/dtdtxgcf/ClaudeCode.git"

# 确保日志目录存在
mkdir -p "$(dirname "$LOG_FILE")"

# 只保留最近 500 行日志，防止无限增长
if [ -f "$LOG_FILE" ] && [ "$(wc -l < "$LOG_FILE")" -gt 500 ]; then
    tail -200 "$LOG_FILE" > "${LOG_FILE}.tmp" && mv "${LOG_FILE}.tmp" "$LOG_FILE"
fi

# 确保仓库存在
if [ ! -d "$REPO_DIR/.git" ]; then
    echo "$(date): 仓库不存在，正在克隆..." >> "$LOG_FILE"
    git clone "$REPO_URL" "$REPO_DIR" >> "$LOG_FILE" 2>&1
    cd "$REPO_DIR" || exit 1
    DEFAULT_BRANCH=$(git remote show origin | grep 'HEAD branch' | awk '{print $NF}')
    if [ "$DEFAULT_BRANCH" != "main" ] && [ -n "$DEFAULT_BRANCH" ]; then
        git checkout "$DEFAULT_BRANCH" >> "$LOG_FILE" 2>&1
    fi
    echo "$(date): 克隆完成，当前分支: $(git branch --show-current)" >> "$LOG_FILE"
    exit 0
fi

cd "$REPO_DIR" || exit 1

CURRENT_BRANCH=$(git branch --show-current)

# ========== 第一步：本地变更自动 commit + push ==========

# 检测是否有未跟踪或已修改的文件（排除 .sync 日志）
CHANGES=$(git status --porcelain | grep -v '\.sync' | grep -v '\.DS_Store')

if [ -n "$CHANGES" ]; then
    # 统计变更文件数
    CHANGE_COUNT=$(echo "$CHANGES" | wc -l | tr -d ' ')

    # 生成 commit 消息：列出变更的目录/文件
    CHANGED_DIRS=$(echo "$CHANGES" | awk '{print $2}' | xargs -I{} dirname {} | sort -u | head -5 | tr '\n' ', ' | sed 's/,$//')
    COMMIT_MSG="auto-sync: ${CHANGE_COUNT} files changed in ${CHANGED_DIRS}"

    echo "$(date): 检测到 ${CHANGE_COUNT} 个本地变更，自动提交..." >> "$LOG_FILE"

    # 添加所有变更（排除敏感文件）
    git add -A >> "$LOG_FILE" 2>&1

    # 排除不该提交的文件
    git reset HEAD -- '*.env' '*.credentials*' '.sync*.log' '.DS_Store' >> "$LOG_FILE" 2>&1

    # 提交
    git commit -m "$COMMIT_MSG" >> "$LOG_FILE" 2>&1

    if [ $? -eq 0 ]; then
        echo "$(date): 提交成功: $COMMIT_MSG" >> "$LOG_FILE"
    fi
fi

# ========== 第二步：拉取远程最新内容 ==========

echo "$(date): 开始同步..." >> "$LOG_FILE"

git fetch --all >> "$LOG_FILE" 2>&1

# 如果当前分支有远程追踪，先 pull（用 rebase 避免无意义的 merge commit）
if git rev-parse --abbrev-ref "@{upstream}" > /dev/null 2>&1; then
    git pull --rebase >> "$LOG_FILE" 2>&1
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

# ========== 第三步：推送本地提交到远程 ==========

# 检查是否有未推送的 commit
UNPUSHED=$(git log "@{upstream}..HEAD" --oneline 2>/dev/null)

if [ -n "$UNPUSHED" ]; then
    PUSH_COUNT=$(echo "$UNPUSHED" | wc -l | tr -d ' ')
    echo "$(date): 推送 ${PUSH_COUNT} 个本地提交..." >> "$LOG_FILE"

    # 带重试的 push（最多 3 次，指数退避）
    for i in 1 2 3; do
        git push -u origin "$CURRENT_BRANCH" >> "$LOG_FILE" 2>&1
        if [ $? -eq 0 ]; then
            echo "$(date): 推送成功" >> "$LOG_FILE"
            break
        else
            echo "$(date): 推送失败 (第${i}次)，等待 $((i * 2))秒后重试..." >> "$LOG_FILE"
            sleep $((i * 2))
        fi
    done
fi

echo "$(date): 同步完成 ($(git log --oneline -1))" >> "$LOG_FILE"
