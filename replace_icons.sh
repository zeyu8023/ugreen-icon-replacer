#!/bin/bash

LOG_FILE="/var/log/icon_replace_$(date +%Y%m%d_%H%M%S).log"
TARGET_DIR="/ugreen/static/icons"
REPO_MAIN="https://github.com/zeyu8023/ugreen-icon-replacer"
REPO_MIRROR="https://download.fastgit.org/zeyu8023/ugreen-icon-replacer"
ZIP_PATH="/archive/refs/heads/main.zip"
ZIP_FILE="icons.zip"
CONFIG_FILE="$HOME/.ugreen_icon_config"

echo "请选择图标来源："
echo "1) 使用 GitHub 项目中的图标（推荐）"
echo "2) 使用本地图标目录"
read -p "请输入数字 [1/2]：" SOURCE_CHOICE

if [[ "$SOURCE_CHOICE" == "1" ]]; then
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
    5) STYLE_FOLDER="default" ;;
    *) echo "❌ 风格编号无效，已退出。"; exit 1 ;;
  esac

  TMP_DIR="/tmp/ugreen_icons_$(date +%s)"
  mkdir -p "$TMP_DIR"
  cd "$TMP_DIR" || exit 1

  echo "🌐 正在尝试从主站下载 ZIP 包..."
  curl -sL --max-time 10 "$REPO_MAIN$ZIP_PATH" -o "$ZIP_FILE"
  if [[ $? -ne 0 || ! -s "$ZIP_FILE" ]]; then
    echo "⚠️ 主站失败，尝试镜像源..."
    curl -sL --max-time 20 "$REPO_MIRROR$ZIP_PATH" -o "$ZIP_FILE"
  fi

  if [[ $? -ne 0 || ! -s "$ZIP_FILE" ]]; then
    echo "⚠️ 下载失败，可能网络受限或 GitHub 被阻断。"

    [[ -f "$CONFIG_FILE" ]] && LAST_PROXY=$(grep "^proxy=" "$CONFIG_FILE" | cut -d '=' -f2)

    while true; do
      if [[ -n "$LAST_PROXY" ]]; then
        echo "🧩 检测到上次使用的代理：$LAST_PROXY"
        read -p "是否继续使用该代理？(y/n): " USE_LAST
        if [[ "$USE_LAST" =~ ^[yY]$ ]]; then
          PROXY="$LAST_PROXY"
        fi
      fi

      while [[ -z "$PROXY" ]]; do
        read -p "🌐 请输入代理地址（如 http://127.0.0.1:7890，留空取消）: " PROXY
        [[ -z "$PROXY" ]] && echo "🚫 未输入代理地址，已退出。" && exit 1
        [[ "$PROXY" =~ ^(http|socks5h):// ]] || { echo "⚠️ 格式无效，请重新输入。"; PROXY=""; }
      done

      echo "🔁 使用代理 $PROXY 下载..."
      curl -x "$PROXY" -sL --max-time 30 "$REPO_MAIN$ZIP_PATH" -o "$ZIP_FILE"
      if [[ $? -eq 0 && -s "$ZIP_FILE" ]]; then
        echo "✅ 下载成功，保存代理地址..."
        echo "proxy=$PROXY" > "$CONFIG_FILE"
        break
      else
        echo "❌ 下载失败，请确认代理是否可用。"
        read -p "是否重新输入代理地址？(y/n): " RETRY
        [[ "$RETRY" =~ ^[yY]$ ]] || exit 1
        PROXY=""
      fi
    done
  else
    echo "✅ ZIP 包下载成功！"
  fi

  # 🔍 检查 unzip 是否存在
  if ! command -v unzip &> /dev/null; then
    echo "❗ 缺少 unzip 解压工具。"
    read -p "是否尝试安装 unzip？(y/n): " INSTALL
    if [[ "$INSTALL" =~ ^[yY]$ ]]; then
      if command -v apt &> /dev/null; then
        sudo apt update && sudo apt install -y unzip
      elif command -v dnf &> /dev/null; then
        sudo dnf install -y unzip
      elif command -v pacman &> /dev/null; then
        sudo pacman -Sy unzip
      else
        echo "⚠️ 未识别的包管理器，请手动安装 unzip。" | tee -a "$LOG_FILE"
        exit 1
      fi
    else
      echo "🚫 未安装 unzip，脚本无法继续执行。" | tee -a "$LOG_FILE"
      exit 1
    fi
  fi

  unzip -q "$ZIP_FILE"
  ICON_SOURCE_DIR=$(find . -type d -path "*/icons/$STYLE_FOLDER" | head -n1)
  if [ ! -d "$ICON_SOURCE_DIR" ]; then
    echo "❌ 未找到 icons/$STYLE_FOLDER 目录。" | tee -a "$LOG_FILE"
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

read -p "是否继续替换图标？此操作不可撤销 (y/n): " CONFIRM
[[ "$CONFIRM" =~ ^[yY]$ ]] || { echo "🚫 操作取消。"; [[ "$SOURCE_CHOICE" == "1" ]] && rm -rf "$TMP_DIR"; exit 0; }

{
echo "🕒 替换开始：$(date)"
echo "📁 图标源目录：$ICON_SOURCE_DIR"
echo "🎯 替换目标目录：$TARGET_DIR"

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

[[ "$SOURCE_CHOICE" == "1" ]] && rm -rf "$TMP_DIR"
