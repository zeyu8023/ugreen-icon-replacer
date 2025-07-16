#!/bin/bash

# === 安装配置 ===
INSTALL_PATH="/usr/local/bin/zt"
REMOTE_SCRIPT_URL="https://raw.githubusercontent.com/zeyu8023/ugreen-icon-replacer/main/replace_icons.sh"

# === 权限检查 ===
if [[ $EUID -ne 0 ]]; then
  echo "🚫 请使用 root 权限运行此安装脚本："
  echo "   sudo bash install_zt.sh"
  exit 1
fi

# === 下载主脚本 ===
echo "🌐 正在从 GitHub 下载图标替换脚本..."
curl -fsSL "$REMOTE_SCRIPT_URL" -o "$INSTALL_PATH"
if [[ $? -ne 0 || ! -s "$INSTALL_PATH" ]]; then
  echo "❌ 下载失败，请检查网络或脚本地址是否有效。"
  exit 1
fi

# === 设置执行权限 ===
chmod +x "$INSTALL_PATH"

# === 验证安装 ===
if [[ -x "$INSTALL_PATH" ]]; then
  echo "✅ 安装成功！你现在可以通过命令调用："
  echo ""
  echo "   zt"
  echo ""
  echo "📁 脚本已部署至：$INSTALL_PATH"
else
  echo "❌ 安装失败，请检查权限或路径。"
  exit 1
fi
