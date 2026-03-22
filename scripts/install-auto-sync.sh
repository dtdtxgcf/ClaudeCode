#!/bin/bash
# 一键安装 ClaudeCode 自动同步服务（macOS launchd）
# 用法：在 Mac 终端运行 bash install-auto-sync.sh

REPO_DIR="$HOME/ClaudeCode"
PLIST_NAME="com.claudecode.autosync"
PLIST_PATH="$HOME/Library/LaunchAgents/${PLIST_NAME}.plist"
SYNC_SCRIPT="$REPO_DIR/scripts/mac-auto-sync.sh"

# 1. 如果仓库不存在，先克隆
if [ ! -d "$REPO_DIR/.git" ]; then
    echo "正在克隆仓库..."
    git clone https://github.com/dtdtxgcf/ClaudeCode.git "$REPO_DIR"
fi

# 2. 给同步脚本执行权限
chmod +x "$SYNC_SCRIPT"

# 3. 创建 launchd plist（每 5 分钟同步一次）
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
        <string>${SYNC_SCRIPT}</string>
    </array>
    <key>StartInterval</key>
    <integer>300</integer>
    <key>RunAtLoad</key>
    <true/>
    <key>StandardOutPath</key>
    <string>${REPO_DIR}/scripts/.sync-stdout.log</string>
    <key>StandardErrorPath</key>
    <string>${REPO_DIR}/scripts/.sync-stderr.log</string>
</dict>
</plist>
EOF

# 4. 加载服务
launchctl unload "$PLIST_PATH" 2>/dev/null
launchctl load "$PLIST_PATH"

echo "✅ 自动同步已安装！"
echo "   同步频率：每 5 分钟"
echo "   仓库路径：$REPO_DIR"
echo ""
echo "常用命令："
echo "   停止同步：launchctl unload $PLIST_PATH"
echo "   启动同步：launchctl load $PLIST_PATH"
echo "   查看日志：cat $REPO_DIR/scripts/.sync.log"
echo "   卸载服务：launchctl unload $PLIST_PATH && rm $PLIST_PATH"
