#!/bin/bash
# ClaudeCode ntfy.sh 监听脚本
# 长连接监听 ntfy 频道，收到 push 事件后立即触发同步

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CHANNEL_FILE="$SCRIPT_DIR/.ntfy-channel"
SYNC_SCRIPT="$SCRIPT_DIR/sync-knowledge.sh"

if [ ! -f "$CHANNEL_FILE" ]; then
    echo "错误：未找到频道配置文件 $CHANNEL_FILE"
    echo "请先运行 install-realtime-sync.sh"
    exit 1
fi

CHANNEL=$(cat "$CHANNEL_FILE")
NTFY_URL="https://ntfy.sh/$CHANNEL/raw"

echo "$(date): 开始监听频道 $CHANNEL ..."

while true; do
    curl -s --no-buffer "$NTFY_URL" | while read -r message; do
        echo "$(date): 收到推送通知，开始同步..."
        bash "$SYNC_SCRIPT"
    done
    echo "$(date): 连接断开，2秒后重连..."
    sleep 2
done
