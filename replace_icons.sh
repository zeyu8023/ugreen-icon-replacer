#!/bin/bash

# 日志文件保存路径
LOG_FILE="/var/log/icon_replace_$(date +%Y%m%d_%H%M%S).log"

# 获取脚本实际所在目录（兼容 curl 临时路径）
if [[ -n "${BASH_SOURCE[0]}" && -e "${BASH_SOURCE[0]}" ]]; then
  BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
  BASE_DIR="$(pwd)"  # fallback：以当前路径为准
fi

# 提示用户输入图标目录路径
read -p "请输入图标目录路径（留空则使用脚本目录下的 icons 文件夹）: " USER_INPUT

# 判断使用默认或自定义路径
if [ -z "$USER_INPUT" ]; then
  ICON_SOURCE_DIR="$BASE_DIR/icons"
  echo "🧭 使用默认图标目录：$ICON_SOURCE_DIR" | tee -a "$LOG_FILE"
else
  ICON_SOURCE_DIR="$USER_INPUT"
  echo "📁 使用用户输入的目录：$ICON_SOURCE_DIR" | tee -a "$LOG_FILE"
fi

# 检查路径是否存在
if [ ! -d "$ICON_SOURCE_DIR" ]; then
  echo "❌ 找不到指定目录：$ICON_SOURCE_DIR" | tee -a "$LOG_FILE"
  exit 1
fi

# 替换前确认
read -p "确认将匹配图标替换系统图标吗？该操作不可撤销！(y/n): " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
  echo "🚫 已取消操作。" | tee -a "$LOG_FILE"
  exit 0
fi

# 执行替换逻辑
{
echo "🕒 开始执行：$(date)"
echo "📁 图标来源目录：$ICON_SOURCE_DIR"
echo "🎯 替换目标路径：/ugreen/static/icons"

find "$ICON_SOURCE_DIR" -type f \( -iname "*.png" -o -iname "*.svg" -o -iname "*.jpg" \) | while read -r file; do
  filename=$(basename "$file")
  target="/ugreen/static/icons/$filename"

  if [ -f "$target" ]; then
    cp "$file" "$target"
    echo "✅ 替换成功：$filename"
  else
    echo "⚠️ 未匹配系统图标，已跳过：$filename"
  fi
done

echo "✅ 图标替换完成：$(date)"
} | tee -a "$LOG_FILE"
