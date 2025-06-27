#!/bin/bash

# === 配置 ===
LOG_FILE="/var/log/icon_replace_$(date +%Y%m%d_%H%M%S).log"
TARGET_DIR="/ugreen/static/icons"
REPO_MAIN="https://github.com/zeyu8023/ugreen-icon-replacer"
REPO_MIRROR="https://download.fastgit.org/zeyu8023/ugreen-icon-replacer"
ZIP_PATH="/archive/refs/heads/main.zip"
ZIP_FILE="icons.zip"
CONFIG_FILE="$HOME/.ugreen_icon_config"

# 🗃️ 缓存配置
CACHE_DIR="${UGREEN_ICON_CACHE_DIR:-$HOME/.ugreen_icon_cache}"
CACHE_ZIP="$CACHE_DIR/main.zip"
CACHE_TIMESTAMP="$CACHE_DIR/main.zip.timestamp"

# === 主功能菜单 ===
echo "🧩 请选择操作功能："
echo "1) 从 GitHub 下载并替换图标"
echo "2) 使用本地图标目录替换图标"
echo "3) 清理图标缓存目录（当前缓存：$(du -sh "$CACHE_DIR" 2>/dev/null | cut -f1 || echo 0B)）"
echo "4) 退出程序"
read -p "请输入数字 [1-4]：" MENU_CHOICE

case "$MENU_CHOICE" in
  1) SOURCE_CHOICE="1" ;;
  2) SOURCE_CHOICE="2" ;;
  3)
    if [[ -d "$CACHE_DIR" ]]; then
      SIZE=$(du -sh "$CACHE_DIR" 2>/dev/null | cut -f1)
      echo "🧺 当前缓存大小：$SIZE"
      read -p "是否确认清空缓存目录？(y/n): " CONFIRM
      if [[ "$CONFIRM" =~ ^[yY]$ ]]; then
        rm -rf "$CACHE_DIR"
        echo "✅ 缓存已清空。"
      else
        echo "🚫 已取消清理操作。"
      fi
    else
      echo "📁 当前无缓存，无需清理。"
    fi
    exit 0
    ;;
  4) echo "👋 程序已退出。"; exit 0 ;;
  *) echo "❌ 输入无效，程序已退出。"; exit 1 ;;
esac

# === 图标来源选择 ===
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
    5) STYLE_FOLDER="default" ;;
    *) echo "❌ 风格编号无效，已退出。"; exit 1 ;;
  esac

  TMP_DIR="/tmp/ugreen_icons_$(date +%s)"
  mkdir -p "$TMP_DIR"
  cd "$TMP_DIR" || exit 1

  mkdir -p "$CACHE_DIR"
  USE_CACHE=false

  if [[ -f "$CACHE_ZIP" ]]; then
    echo "💡 检测到缓存：$CACHE_ZIP"
    read -p "是否使用本地缓存图标包？(y/n): " USE_CACHE_ANSWER
    if [[ "$USE_CACHE_ANSWER" =~ ^[yY]$ ]]; then
      USE_CACHE=true
      cp "$CACHE_ZIP" "$ZIP_FILE"
    fi
  fi

  if [[ "$USE_CACHE" == false ]]; then
    echo "🌐 正在下载 ZIP 包..."
    curl -sL --max-time 20 "$REPO_MAIN$ZIP_PATH" -o "$CACHE_ZIP"
    if [[ $? -ne 0 || ! -s "$CACHE_ZIP" ]]; then
      echo "⚠️ 主站失败，尝试镜像源..."
      curl -sL --max-time 20 "$REPO_MIRROR$ZIP_PATH" -o "$CACHE_ZIP"
    fi

    if [[ $? -ne 0 || ! -s "$CACHE_ZIP" ]]; then
      [[ -f "$CONFIG_FILE" ]] && LAST_PROXY=$(grep "^proxy=" "$CONFIG_FILE" | cut -d '=' -f2)
      while true; do
        if [[ -n "$LAST_PROXY" ]]; then
          echo "🧩 上次代理：$LAST_PROXY"
          read -p "是否复用该代理？(y/n): " USE_LAST
          [[ "$USE_LAST" =~ ^[yY]$ ]] && PROXY="$LAST_PROXY"
        fi

        while [[ -z "$PROXY" ]]; do
          read -p "🌐 输入代理地址（http://127.0.0.1:7890）： " PROXY
          [[ -z "$PROXY" ]] && echo "🚫 未输入，退出。" && exit 1
          [[ "$PROXY" =~ ^(http|socks5h):// ]] || { echo "⚠️ 格式无效"; PROXY=""; }
        done

        echo "🔁 使用代理 $PROXY 下载..."
        curl -x "$PROXY" -sL --max-time 30 "$REPO_MAIN$ZIP_PATH" -o "$CACHE_ZIP"
        if [[ $? -eq 0 && -s "$CACHE_ZIP" ]]; then
          echo "✅ 下载成功"
          echo "proxy=$PROXY" > "$CONFIG_FILE"
          break
        else
          echo "❌ 下载失败。"
          read -p "重试输入代理地址？(y/n): " RETRY
          [[ "$RETRY" =~ ^[yY]$ ]] || exit 1
          PROXY=""
        fi
      done
    fi
    cp "$CACHE_ZIP" "$ZIP_FILE"
    date +%s > "$CACHE_TIMESTAMP"
  fi

  # 检查 unzip
  if ! command -v unzip &> /dev/null; then
    echo "❗ 缺少 unzip"
    read -p "是否安装 unzip？(y/n): " INSTALL
    if [[ "$INSTALL" =~ ^[yY]$ ]]; then
      if command -v apt &> /dev/null; then
        sudo apt update && sudo apt install -y unzip
      elif command -v dnf &> /dev/null; then
        sudo dnf install -y unzip
      elif command -v pacman &> /dev/null; then
        sudo pacman -Sy unzip
      else
        echo "⚠️ 未知系统，请手动安装 unzip。" && exit 1
      fi
    else
      echo "🚫 未安装 unzip，终止脚本。" && exit 1
    fi
  fi

  unzip -q "$ZIP_FILE"
  ICON_SOURCE_DIR=$(find . -type d -path "*/icons/$STYLE_FOLDER" | head -n1)
  [[ ! -d "$ICON_SOURCE_DIR" ]] && echo "❌ 找不到图标目录。" && exit 1

elif [[ "$SOURCE_CHOICE" == "2" ]]; then
  read -p "请输入本地图标目录路径: " ICON_SOURCE_DIR
  [[ ! -d "$ICON_SOURCE_DIR" ]] && echo "❌ 目录不存在。" && exit 1
fi

# === 确认替换 ===
read -p "是否继续替换图标？(y/n): " CONFIRM
[[ "$CONFIRM" =~ ^[yY]$ ]] || { echo "🚫 已取消操作。"; [[ "$SOURCE_CHOICE" == "1" ]] && rm -rf "$TMP_DIR"; exit 0; }

{
echo "🕒 开始替换：$(date)"
echo "📁 图标源目录：$ICON_SOURCE_DIR"
echo "🎯 目标目录：$TARGET_DIR"

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

# 🧹 清理临时目录（仅 GitHub 下载模式下）
[[ "$SOURCE_CHOICE" == "1" ]] && rm -rf "$TMP_DIR"

echo ""
echo "🎉 所有操作已完成！你现在可以刷新界面，查看新的图标样式效果啦～"
