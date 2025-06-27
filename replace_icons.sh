#!/bin/bash

# === 基本配置 ===
TARGET_DIR="/ugreen/static/icons"
CACHE_DIR="$HOME/.ugreen_icon_cache"
CONFIG_FILE="$HOME/.ugreen_icon_config"
REPO_MAIN="https://github.com/zeyu8023/ugreen-icon-replacer"
REPO_MIRROR="https://download.fastgit.org/zeyu8023/ugreen-icon-replacer"
ZIP_PATH="/archive/refs/heads/main.zip"
ZIP_FILE="icons.zip"
LOG_FILE="/var/log/icon_replace_$(date +%Y%m%d_%H%M%S).log"

# === 加载缓存配置 ===
if [[ -f "$CONFIG_FILE" ]]; then
  CACHE_TMP=$(grep "^cache_dir=" "$CONFIG_FILE" | cut -d '=' -f2)
  PROXY_ADDR=$(grep "^proxy=" "$CONFIG_FILE" | cut -d '=' -f2)
  [[ -n "$CACHE_TMP" ]] && CACHE_DIR="$CACHE_TMP"
fi
[[ -z "$CACHE_DIR" ]] && CACHE_DIR="$HOME/.ugreen_icon_cache"
mkdir -p "$CACHE_DIR" "$TARGET_DIR"
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
      rm -rf "$CACHE_DIR"
      mkdir -p "$CACHE_DIR"
      echo "✅ 缓存已清空。"
      ;;
    4)
      read -p "📁 输入新的缓存目录路径: " NEW_PATH
      [[ -z "$NEW_PATH" ]] && echo "⚠️ 目录为空，未修改。" && continue
      CACHE_DIR="$NEW_PATH"
      CACHE_ZIP="$CACHE_DIR/main.zip"
      CACHE_TIMESTAMP="$CACHE_DIR/main.zip.timestamp"
      mkdir -p "$CACHE_DIR"
      { [[ -n "$PROXY_ADDR" ]] && echo "proxy=$PROXY_ADDR"; echo "cache_dir=$CACHE_DIR"; } > "$CONFIG_FILE"
      echo "✅ 已设置缓存目录为：$CACHE_DIR"
      ;;
    5) echo "👋 程序已退出。"; exit 0 ;;
    *) echo "❌ 输入无效，请重新选择。" ;;
  esac
done

# === 获取图标目录 ===
if [[ "$SOURCE_CHOICE" == "1" ]]; then
  echo -e "\n🎨 请选择图标风格："
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

# === 权限检查 ===
if [[ ! -w "$TARGET_DIR" ]]; then
  echo "🚫 当前用户无权限写入目标目录：$TARGET_DIR"
  echo "💡 请使用 sudo 运行，或赋予权限，例如："
  echo "   sudo chown$(whoami):$(whoami) $TARGET_DIR"
  echo ""
  echo "🚨 请重新赋权后再运行本脚本，或使用 sudo："
  echo "   sudo bash $0"
  exit 1
fi

# === 执行替换 ===
{
echo "🕒 开始替换：$(date)"
echo "📁 图标源目录：$ICON_SOURCE_DIR"
echo "🎯 目标图标目录：$TARGET_DIR"

COUNT=0; SKIP=0
find "$ICON_SOURCE_DIR" -type f \( -iname "*.png" -o -iname "*.svg" -o -iname "*.jpg" \) | while read -r file; do
  fname=$(basename "$file")
  tpath="$TARGET_DIR/$fname"
  if [[ -f "$tpath" ]]; then
    cp "$file" "$tpath"
    echo "✅ 替换：$fname"
    ((COUNT++))
  else
    echo "⏭ 跳过（目标不存在）：$fname"
    ((SKIP++))
  fi
done

echo "✅ 图标替换完成，共 $COUNT 个替换，$SKIP 个跳过"
} | tee -a "$LOG_FILE"

# === 清理临时目录 ===
[[ "$SOURCE_CHOICE" == "1" ]] && rm -rf "$TMP_DIR"

echo ""
echo "🎉 图标替换已完成！如未生效，请尝试重启应用或刷新界面。"
