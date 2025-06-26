#!/bin/bash

LOG_FILE="/var/log/icon_replace_$(date +%Y%m%d_%H%M%S).log"
TARGET_DIR="/ugreen/static/icons"

# GitHub 仓库及镜像地址配置
REPO_MAIN="https://github.com/zeyu8023/ugreen-icon-replacer"
REPO_MIRROR="https://download.fastgit.org/zeyu8023/ugreen-icon-replacer"
ZIP_PATH="/archive/refs/heads/main.zip"
ZIP_FILE="icons.zip"

# 用户选择图标来源
echo "请选择图标来源："
echo "1) 使用 GitHub 项目中的图标（推荐）"
echo "2) 使用本地图标目录"
read -p "请输入数字 [1/2]：" SOURCE_CHOICE

if [[ "$SOURCE_CHOICE" == "1" ]]; then
  # 用户选择风格
  echo "🎨 请选择图标风格："
  echo "1) iOS 26 液态玻璃（乐小宇制作）"
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
    *) echo "❌ 风格编号无效，已取消操作。"; exit 1 ;;
  esac

  # 下载 ZIP 包（支持主站 / 镜像）
  TMP_DIR="/tmp/ugreen_icons_$(date +%s)"
  mkdir -p "$TMP_DIR"
  cd "$TMP_DIR" || exit 1

  echo "🌐 正在从 GitHub 主站下载图标包..."
  curl -sL --max-time 20 "$REPO_MAIN$ZIP_PATH" -o "$ZIP_FILE"
  if [[ $? -ne 0 || ! -s "$ZIP_FILE" ]]; then
    echo "⚠️ 主站失败，尝试使用镜像源..."
    curl -sL --max-time 20 "$REPO_MIRROR$ZIP_PATH" -o "$ZIP_FILE"
    if [[ $? -ne 0 || ! -s "$ZIP_FILE" ]]; then
      echo "❌ 无法下载图标资源，可能是网络或镜像访问问题。" | tee -a "$LOG_FILE"
      exit 1
    else
      echo "✅ 已通过镜像源成功下载 ZIP 包。"
    fi
  else
    echo "✅ ZIP 包下载成功。"
  fi

  # 解压并定位风格目录
  unzip -q "$ZIP_FILE"
  ICON_SOURCE_DIR=$(find . -type d -path "*/icons/$STYLE_FOLDER" | head -n1)
  if [ ! -d "$ICON_SOURCE_DIR" ]; then
    echo "❌ 解压成功但未找到 icons/$STYLE_FOLDER 目录。" | tee -a "$LOG_FILE"
    exit 1
  fi

elif [[ "$SOURCE_CHOICE" == "2" ]]; then
  read -p "请输入本地图标目录路径: " ICON_SOURCE_DIR
  if [ ! -d "$ICON_SOURCE_DIR" ]; then
    echo "❌ 目录不存在：$ICON_SOURCE_DIR" | tee -a "$LOG_FILE"
    exit 1
  fi
else
  echo "❌ 输入无效，已退出。"
  exit 1
fi

# 替换确认
read -p "是否继续替换图标？此操作不可撤销 (y/n): " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
  echo "🚫 已取消操作。" | tee -a "$LOG_FILE"
  [[ "$SOURCE_CHOICE" == "1" ]] && rm -rf "$TMP_DIR"
  exit 0
fi

# 开始替换
{
echo "🕒 开始替换：$(date)"
echo "📁 图标源目录：$ICON_SOURCE_DIR"
echo "🎯 替换目标路径：$TARGET_DIR"

find "$ICON_SOURCE_DIR" -type f \( -iname "*.png" -o -iname "*.svg" -o -iname "*.jpg" \) | while read -r file; do
  filename=$(basename "$file")
  target="$TARGET_DIR/$filename"
  if [ -f "$target" ]; then
    cp "$file" "$target"
    echo "✅ 替换：$filename"
  else
    echo "⚠️ 未匹配：$filename"
  fi
done

echo "✅ 图标替换完成：$(date)"
} | tee -a "$LOG_FILE"

[[ "$SOURCE_CHOICE" == "1" ]] && rm -rf "$TMP_DIR"
