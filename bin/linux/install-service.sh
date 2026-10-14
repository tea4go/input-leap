#!/bin/bash
# 安装 input-leap 客户端为 systemd user service
# 用法: bash /opt/input-leap/install-service.sh
# 须以拥有图形会话的用户身份运行 (不要用 sudo)

set -euo pipefail

if [ "$(id -u)" = "0" ]; then
    echo "错误: 请以普通用户身份运行 (不要用 sudo), user service 属于当前用户"
    exit 1
fi

if [ ! -x /opt/input-leap/run-client.sh ]; then
    echo "错误: /opt/input-leap/run-client.sh 不存在或不可执行"
    exit 1
fi

UNIT_DIR="$HOME/.config/systemd/user"
UNIT_FILE="$UNIT_DIR/input-leap-client.service"

mkdir -p "$UNIT_DIR"

cat > "$UNIT_FILE" <<'UNIT_EOF'
[Unit]
Description=Input Leap client (connects to 10.68.8.73:24800)
After=graphical-session.target
PartOf=graphical-session.target
StartLimitIntervalSec=500
StartLimitBurst=10

[Service]
# 等待桌面完全就绪后再连接
ExecStartPre=/bin/sleep 5
ExecStart=/opt/input-leap/run-client.sh
Restart=always
RestartSec=5s

[Install]
WantedBy=graphical-session.target
UNIT_EOF

echo "已写入: $UNIT_FILE"

systemctl --user daemon-reload
systemctl --user enable input-leap-client.service
systemctl --user restart input-leap-client.service

sleep 7

echo
echo "=== 服务状态 ==="
systemctl --user status input-leap-client.service --no-pager | head -10

if pgrep -x input-leapc > /dev/null; then
    echo
    echo "✓ 安装完成, input-leap 客户端已运行"
else
    echo
    echo "⚠ 进程未起来, 请查看日志: journalctl --user -u input-leap-client -n 30"
    exit 1
fi
