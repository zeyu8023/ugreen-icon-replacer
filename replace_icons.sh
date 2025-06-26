#!/bin/bash

LOG_FILE="/var/log/icon_replace_$(date +%Y%m%d_%H%M%S).log"
TARGET_DIR="/ugreen/static/icons"
REPO_URL="https://github.com/zeyu8023/ugreen-icon-replacer"
ZIP_URL="$REPO_URL/archive/refs/heads/main.zip"

# 🌐 选择图标来源
echo "请选择图标来源："
echo "1) 使用 GitHub 项目中的图标（推荐）"
echo "2) 使用本地图标目录"
read -p "请输入数字 [1/2]：" SOURCE_CHOICE

if [[ "$SOURCE_CHOICE" == "1" ]]; then
  echo "🎨 请选择图标风格："
  echo "1) iOS 26 液态玻璃（乐小宇）"
  echo "2) 锤子 OS（Sunny 整理）"
  echo "3) 拟物毛玻璃（Sunny 制作）"
  echo "4) 绿联毛玻璃（Sunny 制作）"
  echo "5) 官方默认图标"
  read -p "请输入数字 [1-5]：" STYLE_CHOICE

  case "$STYLE_CHOICE" in
    1) STYLE_FOLDER="IOS26" ;;
    2) STYLE_FOLDER="SmartisanOS" ;;
    3) STYLE_FOLDER="glass" ;;
    4) STYLE_FOLDER="ugreenglass" ;;
    5) STYLE_FOLDER="defaslt" ;;
    *) echo "❌ 风格编号无效，已取消。"; exit 1 ;;
  esac

  echo "🌐 正在从 GitHub 下载图标资源..."
  TEMP_DIR="/tmp/ugreen_icons_$(date +%s)"
  mkdir -p "$TEMP_DIR"
  cd "$TEMP_DIR" || exit 1
  curl -sL "$ZIP_URL" -o icons.zip
  unzip -q icons.zip
  ICON_SOURCE_DIR=$(find . -type d -path "*/icons/$STYLE_FOLDER" | head -n1)

  if [ ! -d "$ICON_SOURCE_DIR" ]; then
    echo "❌ 未找到所选风格对应目录：$STYLE_FOLDER" | tee -a "$LOG_FILE"
    exit 1
  fi

elif [[ "$SOURCE_CHOICE" == "2" ]]; then
  read -p "请输入本地图标目录路径: " ICON_SOURCE_DIR
  if [ ! -d "$ICON_SOURCE_DIR" ]; then
    echo "❌ 路径不存在：$ICON_SOURCE_DIR" | tee -a "$LOG_FILE"
    exit 1
  fi
else
  echo "❌ 输入无效，已取消。"
  exit 1
fi

# ⚠️ 替换确认
read -p "是否继续替换图标？此操作不可撤销 (y/n): " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
  echo "🚫 已取消操作。" | tee -a "$LOG_FILE"
  exit 0
fi

# 🔁 执行替换逻辑
{
echo "🕒 替换开始：$(date)"
echo "📁 来源目录：$ICON_SOURCE_DIR"
echo "🎯 替换目标：$TARGET_DIR"

find "$ICON_SOURCE_DIR" -type f \( -iname "*.png" -o -iname "*.svg" -o -iname "*.jpg" \) | while read -r file; do
  filename=$(basename "$file")
  target="$TARGET_DIR/$filename"
  if [ -f "$target" ]; then
    cp "$file" "$target"
    echo "✅ 替换：$filename"
  else
    echo "⚠️ 未匹配系统图标，跳过：$filename"
  fi
done

echo "✅ 图标替换完成：$(date)"
} | tee -a "$LOG_FILE"

# 清理临时目录
[[ "$SOURCE_CHOICE" == "1" ]] && rm -rf "$TEMP_DIR"
