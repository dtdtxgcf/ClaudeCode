#!/bin/bash
# ClaudeCode 实时同步 一键安装脚本
# 基于 GitHub Webhook + ntfy.sh 实现秒级同步

REPO_DIR="$HOME/ClaudeCode"
SCRIPT_DIR="$REPO_DIR/.infra/scripts"
CHANNEL_FILE="$SCRIPT_DIR/.ntfy-channel"
PLIST_NAME="com.claudecode.realtime-sync"
PLIST_PATH="$HOME/Library/LaunchAgents/${PLIST_NAME}.plist"
WATCH_SCRIPT="$SCRIPT_DIR/watch-knowledge.sh"

# 1. 生成随机频道名（或使用已有）
if [ -f "$CHANNEL_FILE" ]; then
    CHANNEL=$(cat "$CHANNEL_FILE")
    echo "使用已有频道：$CHANNEL"
else
    CHANNEL="claudecode-sync-$(openssl rand -hex 4)"
    echo "$CHANNEL" > "$CHANNEL_FILE"
    echo "生成新频道：$CHANNEL"
fi

# 2. 设置执行权限
chmod +x "$SCRIPT_DIR/sync-knowledge.sh"
chmod +x "$SCRIPT_DIR/watch-knowledge.sh"

# 3. 创建 launchd plist（KeepAlive + RunAtLoad）
cat > "$PLIST_PATH" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${PLIST_NAME}</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>${WATCH_SCRIPT}</string>
    </array>
    <key>KeepAlive</key>
    <true/>
    <key>RunAtLoad</key>
    <true/>
    <key>StandardOutPath</key>
    <string>${SCRIPT_DIR}/.realtime-sync-stdout.log</string>
    <key>StandardErrorPath</key>
    <string>${SCRIPT_DIR}/.realtime-sync-stderr.log</string>
</dict>
</plist>
EOF

# 4. 加载服务
launchctl unload "$PLIST_PATH" 2>/dev/null
launchctl load "$PLIST_PATH"

echo ""
echo "实时同步已安装！"
echo ""
echo "下一步：配置 GitHub Webhook"
echo "  1. 打开 https://github.com/dtdtxgcf/ClaudeCode/settings/hooks"
echo "  2. Add webhook："
echo "     Payload URL: https://ntfy.sh/$CHANNEL"
echo "     Content type: application/json"
echo "     Events: Just the push event"
echo "  3. 保存"
echo ""
echo "常用命令："
echo "  查看日志：tail -f $SCRIPT_DIR/.realtime-sync-stdout.log"
echo "  停止服务：launchctl unload $PLIST_PATH"
echo "  启动服务：launchctl load $PLIST_PATH"
echo "  卸载服务：launchctl unload $PLIST_PATH && rm $PLIST_PATH"
