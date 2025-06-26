#!/bin/bash

LOG_FILE="/var/log/icon_replace_$(date +%Y%m%d_%H%M%S).log"
TARGET_DIR="/ugreen/static/icons"
REPO_MAIN="https://github.com/zeyu8023/ugreen-icon-replacer"
REPO_MIRROR="https://download.fastgit.org/zeyu8023/ugreen-icon-replacer"
ZIP_PATH="/archive/refs/heads/main.zip"
ZIP_FILE="icons.zip"

# 步骤一：选择图标来源
echo "请选择图标来源："
echo "1) 使用 GitHub 项目中的图标（推荐）"
echo "2) 使用本地图标目录"
read -p "请输入数字 [1/2]：" SOURCE_CHOICE

if [[ "$SOURCE_CHOICE" == "1" ]]; then
  # 步骤二：选择图标风格
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
    5) STYLE_FOLDER="default" ;;
    *) echo "❌ 风格编号无效，已退出。"; exit 1 ;;
  esac

  # 步骤三：下载 ZIP 包（含主站 + 镜像 + 代理）
  TMP_DIR="/tmp/ugreen_icons_$(date +%s)"
  mkdir -p "$TMP_DIR"
  cd "$TMP_DIR" || exit 1

  echo "🌐 正在尝试从 GitHub 主站下载..."
  curl -sL --max-time 20 "$REPO_MAIN$ZIP_PATH" -o "$ZIP_FILE"
  if [[ $? -ne 0 || ! -s "$ZIP_FILE" ]]; then
    echo "⚠️ 主站失败，尝试镜像源..."
    curl -sL --max-time 20 "$REPO_MIRROR$ZIP_PATH" -o "$ZIP_FILE"
  fi

  # 如仍失败，提示使用代理
  if [[ $? -ne 0 || ! -s "$ZIP_FILE" ]]; then
    echo "⚠️ 下载失败，可能网络受限或 GitHub 被阻断。"

    read -p "🌐 请输入代理服务器地址（如 http://127.0.0.1:7890 或 socks5h://127.0.0.1:1080）：" PROXY
    if [ -z "$PROXY" ]; then
      echo "🚫 未配置代理，操作中止。" | tee -a "$LOG_FILE"
      exit 1
    fi

    echo "🔁 正在使用代理 $PROXY 下载..."
    curl -x "$PROXY" -sL --max-time 30 "$REPO_MAIN$ZIP_PATH" -o "$ZIP_FILE"
    if [[ $? -ne 0 || ! -s "$ZIP_FILE" ]]; then
      echo "❌ 使用代理仍无法下载图标资源。" | tee -a "$LOG_FILE"
      exit 1
    else
      echo "✅ 代理下载成功！"
    fi
  else
    echo "✅ ZIP 文件下载成功！"
  fi

  # 步骤四：解压并查找风格目录
  unzip -q "$ZIP_FILE"
  ICON_SOURCE_DIR=$(find . -type d -path "*/icons/$STYLE_FOLDER" | head -n1)
  if [ ! -d "$ICON_SOURCE_DIR" ]; then
    echo "❌ 解压成功但未找到 icons/$STYLE_FOLDER 目录。" | tee -a "$LOG_FILE"
    exit 1
  fi

elif [[ "$SOURCE_CHOICE" == "2" ]]; then
  read -p "请输入本地图标目录路径: " ICON_SOURCE_DIR
  if [ ! -d "$ICON_SOURCE_DIR" ]; then
    echo "❌ 图标目录不存在：$ICON_SOURCE_DIR" | tee -a "$LOG_FILE"
    exit 1
  fi
else
  echo "❌ 输入无效，程序已退出。"
  exit 1
fi

# 步骤五：确认替换
read -p "是否继续替换图标？此操作不可撤销 (y/n): " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
  echo "🚫 用户已取消替换操作。" | tee -a "$LOG_FILE"
  [[ "$SOURCE_CHOICE" == "1" ]] && rm -rf "$TMP_DIR"
  exit 0
fi

# 步骤六：执行替换
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
    echo "⚠️ 跳过未匹配图标：$filename"
  fi
done

echo "✅ 图标替换完成：$(date)"
} | tee -a "$LOG_FILE"

# 清理
[[ "$SOURCE_CHOICE" == "1" ]] && rm -rf "$TMP_DIR"
