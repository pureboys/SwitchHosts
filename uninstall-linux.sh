#!/bin/bash
# SwitchHosts Linux 卸载脚本

set -e

INSTALL_DIR="${HOME}/Applications"
TARGET_APPIMAGE="$INSTALL_DIR/SwitchHosts.AppImage"
DESKTOP_FILE="${HOME}/.local/share/applications/switchhosts.desktop"
ICON_FILE="${HOME}/.local/share/icons/switchhosts.png"
DATA_DIR="${HOME}/.SwitchHosts"

echo "=========================================="
echo "  SwitchHosts Linux 卸载程序"
echo "=========================================="
echo ""

# 检查是否已安装
if [ ! -f "$TARGET_APPIMAGE" ] && [ ! -f "$DESKTOP_FILE" ]; then
    echo "⚠️  未检测到已安装的 SwitchHosts"
    exit 0
fi

# 关闭正在运行的实例
echo "🔍 检查运行中的进程..."
if pgrep -f "SwitchHosts.AppImage" > /dev/null; then
    echo "⚠️  检测到 SwitchHosts 正在运行"
    read -p "是否关闭正在运行的实例? [y/N] " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "⏹️  关闭 SwitchHosts..."
        pkill -f "SwitchHosts.AppImage" || true
        sleep 1
    else
        echo "❌ 取消卸载"
        exit 1
    fi
fi

# 删除应用文件
if [ -f "$TARGET_APPIMAGE" ]; then
    echo "🗑️  删除应用程序: $TARGET_APPIMAGE"
    rm -f "$TARGET_APPIMAGE"
fi

# 删除桌面快捷方式
if [ -f "$DESKTOP_FILE" ]; then
    echo "🗑️  删除桌面快捷方式: $DESKTOP_FILE"
    rm -f "$DESKTOP_FILE"
fi

# 删除图标
if [ -f "$ICON_FILE" ]; then
    echo "🗑️  删除图标: $ICON_FILE"
    rm -f "$ICON_FILE"
fi

# 询问是否删除数据
if [ -d "$DATA_DIR" ]; then
    echo ""
    echo "⚠️  检测到用户数据目录: $DATA_DIR"
    read -p "是否删除用户数据 (hosts 配置和历史记录)? [y/N] " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🗑️  删除用户数据: $DATA_DIR"
        rm -rf "$DATA_DIR"
        echo "✅ 用户数据已删除"
    else
        echo "ℹ️  保留用户数据: $DATA_DIR"
    fi
fi

# 更新桌面数据库
echo ""
echo "🔄 更新桌面数据库..."
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$(dirname "$DESKTOP_FILE")" 2>/dev/null || true
fi

echo ""
echo "=========================================="
echo "  ✅ 卸载完成！"
echo "=========================================="
echo ""
echo "SwitchHosts 已从您的系统中移除。"
echo ""

