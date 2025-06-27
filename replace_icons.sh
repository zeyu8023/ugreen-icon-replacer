#!/bin/bash

# === 基本配置 ===
LOG_FILE="/var/log/icon_replace_$(date +%Y%m%d_%H%M%S).log"
TARGET_DIR="/ugreen/static/icons"
REPO_MAIN="https://github.com/zeyu8023/ugreen-icon-replacer"
REPO_MIRROR="https://download.fastgit.org/zeyu8023/ugreen-icon-replacer"
ZIP_PATH="/archive/refs/heads/main.zip"
ZIP_FILE="icons.zip"
CONFIG_FILE="$HOME/.ugreen_icon_config"

# === 读取配置文件 ===
# 默认为 ~/.ugreen_icon_cache
if [[ -f "$CONFIG_FILE" ]]; then
  CACHE_DIR=$(grep "^cache_dir=" "$CONFIG_FILE" | cut -d '=' -f2)
  PROXY_ADDR=$(grep "^proxy=" "$CONFIG_FILE" | cut -d '=' -f2)
fi
[[ -z "$CACHE_DIR" ]] && CACHE_DIR="$HOME/.ugreen_icon_cache"
mkdir -p "$CACHE_DIR"
CACHE_ZIP="$CACHE_DIR/main.zip"
CACHE_TIMESTAMP="$CACHE_DIR/main.zip.timestamp"

# === 菜单交互 ===
while true; do
  echo -e "\n🧩 请选择操作功能："
  echo "1) 从 GitHub 下载并替换图标"
  echo "2) 使用本地图标目录替换图标"
  echo "3) 清理图标缓存（当前缓存：$(du -sh "$CACHE_DIR" 2>/dev/null | cut -f1 || echo 0B)）"
  echo "4) 设置图标缓存目录（当前：$CACHE_DIR）"
  echo "5) 退出程序"
  read -p "请输入数字 [1-5]：" MENU_CHOICE

  case "$MENU_CHOICE" in
    1|2) SOURCE_CHOICE="$MENU_CHOICE"; break ;;
    3)
      if [[ -d "$CACHE_DIR" ]]; then
        read -p "是否确认清空缓存目录？(y/n): " CONFIRM
        [[ "$CONFIRM" =~ ^[yY]$ ]] && rm -rf "$CACHE_DIR" && echo "✅ 缓存已清空。" || echo "🚫 取消。"
      else
        echo "📁 无缓存可清理。"
      fi
      ;;
    4)
      read -p "请输入新的缓存目录路径: " NEW_PATH
      [[ -z "$NEW_PATH" ]] && echo "⚠️ 目录为空，未修改。" && continue
      CACHE_DIR="$NEW_PATH"
      CACHE_ZIP="$CACHE_DIR/main.zip"
      CACHE_TIMESTAMP="$CACHE_DIR/main.zip.timestamp"
      mkdir -p "$CACHE_DIR"
      echo "✅ 已设置缓存目录为：$CACHE_DIR"
      # 更新配置文件
      { [[ -n "$PROXY_ADDR" ]] && echo "proxy=$PROXY_ADDR"; echo "cache_dir=$CACHE_DIR"; } > "$CONFIG_FILE"
      ;;
    5) echo "👋 程序已退出。"; exit 0 ;;
    *) echo "❌ 输入无效，请重新选择。" ;;
  esac
done

# === 选择图标来源 ===
if [[ "$SOURCE_CHOICE" == "1" ]]; then
  echo "🎨 请选择图标风格："
  echo "1) iOS 26 液态玻璃"
  echo "2) 锤子 OS"
  echo "3) 拟物毛玻璃"
  echo "4) 绿联毛玻璃"
  echo "5) 官方默认图标"
  read -p "请输入数字 [1-5]：" STYLE_CHOICE
  case "$STYLE_CHOICE" in
    1) STYLE_FOLDER="IOS26" ;;
    2) STYLE_FOLDER="SmartisanOS" ;;
    3) STYLE_FOLDER="glass" ;;
    4) STYLE_FOLDER="ugreenglass" ;;
    5) STYLE_FOLDER="default" ;;
    *) echo "❌ 风格编号无效。"; exit 1 ;;
  esac

  TMP_DIR="/tmp/ugreen_icons_$(date +%s)"
  mkdir -p "$TMP_DIR"
  cd "$TMP_DIR" || exit 1

  USE_CACHE=false
  if [[ -f "$CACHE_ZIP" ]]; then
    echo "💡 检测到缓存图标包：$CACHE_ZIP"
    read -p "是否复用缓存 ZIP？(y/n): " ANSWER
    [[ "$ANSWER" =~ ^[yY]$ ]] && USE_CACHE=true && cp "$CACHE_ZIP" "$ZIP_FILE"
  fi

  if [[ "$USE_CACHE" == false ]]; then
    echo "🌐 正在尝试下载 ZIP 包..."
    curl -sL --max-time 20 "$REPO_MAIN$ZIP_PATH" -o "$CACHE_ZIP"
    [[ $? -ne 0 || ! -s "$CACHE_ZIP" ]] && curl -sL --max-time 20 "$REPO_MIRROR$ZIP_PATH" -o "$CACHE_ZIP"

    if [[ $? -ne 0 || ! -s "$CACHE_ZIP" ]]; then
      while true; do
        [[ -n "$PROXY_ADDR" ]] && echo "🧩 检测到上次代理：$PROXY_ADDR" && read -p "是否继续使用该代理？(y/n): " USE_LAST && [[ "$USE_LAST" =~ ^[yY]$ ]] && PROXY="$PROXY_ADDR"

        while [[ -z "$PROXY" ]]; do
          read -p "🌐 请输入代理地址（http://... 或 socks5h://...）: " PROXY
          [[ -z "$PROXY" ]] && echo "🚫 未输入代理。" && exit 1
          [[ "$PROXY" =~ ^(http|socks5h):// ]] || { echo "⚠️ 格式无效，请重新输入。"; PROXY=""; }
        done

        curl -x "$PROXY" -sL --max-time 30 "$REPO_MAIN$ZIP_PATH" -o "$CACHE_ZIP"
        if [[ $? -eq 0 && -s "$CACHE_ZIP" ]]; then
          echo "✅ 下载成功，保存代理配置。"
          echo "proxy=$PROXY" > "$CONFIG_FILE"
          echo "cache_dir=$CACHE_DIR" >> "$CONFIG_FILE"
          break
        else
          echo "❌ 下载失败，可能代理无效。"
          read -p "是否重新输入代理地址？(y/n): " RETRY
          [[ "$RETRY" =~ ^[yY]$ ]] || exit 1
          PROXY=""
        fi
      done
    fi

    cp "$CACHE_ZIP" "$ZIP_FILE"
    date +%s > "$CACHE_TIMESTAMP"
  fi

  # === 解压并提取目标图标路径 ===
  if ! command -v unzip &>/dev/null; then
    echo "❗ 检测到 unzip 未安装。"
    read -p "是否尝试安装 unzip？(y/n): " INSTALL
    if [[ "$INSTALL" =~ ^[yY]$ ]]; then
      if command -v apt &>/dev/null; then
        sudo apt update && sudo apt install -y unzip
      elif command -v dnf &>/dev/null; then
        sudo dnf install -y unzip
      elif command -v pacman &>/dev/null; then
        sudo pacman -Sy unzip
      else
        echo "⚠️ 未知系统，请手动安装 unzip。" && exit 1
      fi
    else
      echo "🚫 unzip 缺失，脚本终止。" && exit 1
    fi
  fi

  unzip -q "$ZIP_FILE"
  ICON_SOURCE_DIR=$(find . -type d -path "*/icons/$STYLE_FOLDER" | head -n1)
  [[ ! -d "$ICON_SOURCE_DIR" ]] && echo "❌ 未找到 icons/$STYLE_FOLDER。" && exit 1

elif [[ "$SOURCE_CHOICE" == "2" ]]; then
  read -p "请输入本地图标目录路径: " ICON_SOURCE_DIR
  [[ ! -d "$ICON_SOURCE_DIR" ]] && echo "❌ 目录不存在。" && exit 1
fi

# === 替换确认 ===
read -p "是否继续替换系统图标？(y/n): " CONFIRM
[[ "$CONFIRM" =~ ^[yY]$ ]] || { echo "🚫 操作取消。"; [[ "$SOURCE_CHOICE" == "1" ]] && rm -rf "$TMP_DIR"; exit 0; }

{
echo "🕒 开始替换：$(date)"
echo "📁 图标源目录：$ICON_SOURCE_DIR"
echo "🎯 目标图标目录：$TARGET_DIR"

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

# 🧼 清理临时目录
[[ "$SOURCE_CHOICE" == "1" ]] && rm -rf "$TMP_DIR"

echo ""
echo "🎉 图标替换已完成！快刷新界面看看新风格吧～"
