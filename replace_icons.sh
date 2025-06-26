#!/bin/bash

# 设置日志路径
LOG_FILE="/var/log/icon_replace_$(date +%Y%m%d_%H%M%S).log"
TARGET_DIR="/ugreen/static/icons"
REPO_URL="https://github.com/zeyu8023/ugreen-icon-replacer"
ZIP_URL="https://github.com/zeyu8023/ugreen-icon-replacer/archive/refs/heads/main.zip"

# 询问用户来源
read -p "是否使用 GitHub 项目的默认图标？(y/n): " USE_GITHUB

if [[ "$USE_GITHUB" == "y" || "$USE_GITHUB" == "Y" ]]; then
  echo "🌐 正在从 GitHub 下载默认图标..." | tee -a "$LOG_FILE"
  TMP_DIR="/tmp/ugreen_icons_$(date +%s)"
  mkdir -p "$TMP_DIR"
  cd "$TMP_DIR" || exit 1
  curl -sL "$ZIP_URL" -o repo.zip
  unzip -q repo.zip
  ICON_SOURCE_DIR=$(find . -type d -name "icons" | head -n1)
  if [ -z "$ICON_SOURCE_DIR" ]; then
    echo "❌ 下载的项目中未找到 icons 目录。" | tee -a "$LOG_FILE"
    exit 1
  fi
else
  read -p "请输入包含图标的本地目录路径: " ICON_SOURCE_DIR
  if [ ! -d "$ICON_SOURCE_DIR" ]; then
    echo "❌ 找不到目录：$ICON_SOURCE_DIR" | tee -a "$LOG_FILE"
    exit 1
  fi
fi

# 替换确认
read -p "将匹配替换系统图标，是否继续？(y/n): " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
  echo "🚫 已取消操作。" | tee -a "$LOG_FILE"
  exit 0
fi

# 替换逻辑
{
echo "🕒 替换开始：$(date)"
echo "📁 源路径：$ICON_SOURCE_DIR"
echo "🎯 目标路径：$TARGET_DIR"

find "$ICON_SOURCE_DIR" -type f \( -iname "*.png" -o -iname "*.svg" -o -iname "*.jpg" \) | while read -r file; do
  filename=$(basename "$file")
  target="$TARGET_DIR/$filename"
  if [ -f "$target" ]; then
    cp "$file" "$target"
    echo "✅ 替换：$filename"
  else
    echo "⚠️ 跳过未匹配图标：$filename"
  fi
done

echo "✅ 图标替换完成：$(date)"
} | tee -a "$LOG_FILE"
