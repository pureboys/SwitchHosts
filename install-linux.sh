#!/bin/bash
# SwitchHosts Linux 安装脚本
# 将 AppImage 安装到系统并创建桌面快捷方式

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$SCRIPT_DIR/dist"
INSTALL_DIR="${HOME}/Applications"
DESKTOP_FILE="${HOME}/.local/share/applications/switchhosts.desktop"
ICON_FILE="${HOME}/.local/share/icons/switchhosts.png"

echo "=========================================="
echo "  SwitchHosts Linux 安装程序"
echo "=========================================="
echo ""

# 检查 AppImage 文件
APPIMAGE=$(find "$DIST_DIR" -name "SwitchHosts_linux_x86_64_*.AppImage" -type f | head -n 1)

if [ -z "$APPIMAGE" ]; then
    echo "❌ 错误: 未找到 AppImage 文件"
    echo "请先运行: npm run build && npm run make:linux"
    exit 1
fi

echo "✅ 找到 AppImage: $(basename "$APPIMAGE")"
echo ""

# 创建安装目录
echo "📁 创建安装目录..."
mkdir -p "$INSTALL_DIR"
mkdir -p "$(dirname "$DESKTOP_FILE")"
mkdir -p "$(dirname "$ICON_FILE")"

# 复制 AppImage
echo "📦 安装应用程序..."
TARGET_APPIMAGE="$INSTALL_DIR/SwitchHosts.AppImage"

if [ -f "$TARGET_APPIMAGE" ]; then
    echo "⚠️  检测到已安装的版本，正在覆盖..."
    rm -f "$TARGET_APPIMAGE"
fi

cp "$APPIMAGE" "$TARGET_APPIMAGE"
chmod +x "$TARGET_APPIMAGE"

echo "✅ 已安装到: $TARGET_APPIMAGE"
echo ""

# 复制图标
echo "🎨 安装图标..."
ICON_SOURCE="$SCRIPT_DIR/assets/app.png"

if [ -f "$ICON_SOURCE" ]; then
    cp "$ICON_SOURCE" "$ICON_FILE"
    echo "✅ 图标已安装"
else
    echo "⚠️  图标文件未找到，跳过"
fi
echo ""

# 创建桌面快捷方式
echo "🔗 创建桌面快捷方式..."
cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=SwitchHosts
Name[zh_CN]=SwitchHosts
Comment=Hosts management and switching tool
Comment[zh_CN]=hosts 文件管理和切换工具
Exec=$TARGET_APPIMAGE --no-sandbox %U
Icon=switchhosts
Terminal=false
Type=Application
Categories=Utility;Development;Network;
StartupWMClass=SwitchHosts
Keywords=hosts;network;dns;
EOF

chmod +x "$DESKTOP_FILE"
echo "✅ 桌面快捷方式已创建: $DESKTOP_FILE"
echo ""

# 更新桌面数据库
echo "🔄 更新桌面数据库..."
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$(dirname "$DESKTOP_FILE")" 2>/dev/null || true
    echo "✅ 桌面数据库已更新"
else
    echo "⚠️  update-desktop-database 未找到，可能需要重新登录才能看到快捷方式"
fi
echo ""

# 显示安装信息
echo "=========================================="
echo "  ✅ 安装完成！"
echo "=========================================="
echo ""
echo "安装位置:"
echo "  应用程序: $TARGET_APPIMAGE"
echo "  快捷方式: $DESKTOP_FILE"
echo "  图标文件: $ICON_FILE"
echo ""
echo "使用方法:"
echo "  1. 从应用菜单搜索 'SwitchHosts' 启动"
echo "  2. 或运行命令: $TARGET_APPIMAGE --no-sandbox"
echo ""
echo "数据目录: ~/.SwitchHosts/"
echo ""

# 询问是否立即启动
read -p "是否立即启动 SwitchHosts? [y/N] " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🚀 启动 SwitchHosts..."
    "$TARGET_APPIMAGE" --no-sandbox &
    echo "✅ 已启动"
fi

echo ""
echo "安装完成！祝使用愉快！🎉"

