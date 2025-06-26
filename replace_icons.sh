#!/bin/bash

LOG_FILE="/var/log/icon_replace_$(date +%Y%m%d_%H%M%S).log"
TARGET_DIR="/ugreen/static/icons"
DEBUG=0

# 可选参数解析
while [[ "$1" =~ ^- ]]; do
  case "$1" in
    --debug)
      DEBUG=1
      shift
      ;;
    *) break ;;
  esac
done

# 图标来源选择
read -p "是否使用 GitHub 项目的默认图标？(y/n): " USE_GITHUB

if [[ "$USE_GITHUB" == "y" || "$USE_GITHUB" == "Y" ]]; then
  echo "🌐 正在从 GitHub 下载默认图标..." | tee -a "$LOG_FILE"
  TMP_DIR="/tmp/ugreen_icons_$(date +%s)"
  mkdir -p "$TMP_DIR"
  cd "$TMP_DIR" || exit 1
  curl -sL https://github.com/zeyu8023/ugreen-icon-replacer/archive/refs/heads/main.zip -o repo.zip
  unzip -q repo.zip
  ICON_SOURCE_DIR=$(find . -type d -name "icons" | head -n1)
  if [ -z "$ICON_SOURCE_DIR" ]; then
    echo "❌ 未找到 icons 目录。" | tee -a "$LOG_FILE"
    exit 1
  fi
else
  read -p "请输入图标目录路径: " ICON_SOURCE_DIR
  if [ ! -d "$ICON_SOURCE_DIR" ]; then
    echo "❌ 找不到目录：$ICON_SOURCE_DIR" | tee -a "$LOG_FILE"
    exit 1
  fi
fi

# 替换确认
read -p "是否继续替换系统图标？(y/n): " CONFIRM
[[ "$CONFIRM" =~ ^[yY]$ ]] || { echo "🚫 已取消。"; exit 0; }

# 替换逻辑 + debug 输出
{
echo "🕒 开始替换：$(date)"
echo "📁 来源：$ICON_SOURCE_DIR"
echo "🎯 目标：$TARGET_DIR"

find "$ICON_SOURCE_DIR" -type f \( -iname "*.png" -o -iname "*.svg" -o -iname "*.jpg" \) | while read -r file; do
  filename=$(basename "$file")
  target="$TARGET_DIR/$filename"

  if [ -f "$target" ]; then
    cp "$file" "$target"
    echo "✅ 替换成功：$filename"
    if [ "$DEBUG" -eq 1 ]; then
      echo "  ➤ 源文件：$file"
      echo "  ➤ 目标文件：$target"
      echo "  ➤ 源大小：$(stat -c%s "$file") 字节"
      echo "  ➤ 新哈希：$(md5sum "$target" | cut -d ' ' -f1)"
    fi
  else
    echo "⚠️ 未匹配图标：$filename"
  fi
done

echo "✅ 替换完成：$(date)"
} | tee -a "$LOG_FILE"
