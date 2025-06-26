#!/bin/bash

# 设置日志文件
LOG_FILE="/var/log/icon_replace_$(date +%Y%m%d_%H%M%S).log"

# 提示用户输入图标路径，并说明规则
read -p "请输入包含图标文件的目录路径（示例：/home/yourname/my_icons）： " ICON_SOURCE_DIR

# 检查目录是否存在
if [ ! -d "$ICON_SOURCE_DIR" ]; then
  echo "❌ 找不到该目录：$ICON_SOURCE_DIR" | tee -a "$LOG_FILE"
  exit 1
fi

# 确认替换操作
read -p "将匹配覆盖 /ugreen/static/icons 中的图标，是否继续？(y/n): " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
  echo "🚫 操作已取消。" | tee -a "$LOG_FILE"
  exit 0
fi

# 日志记录开始
{
echo "🔧 开始图标替换：$(date)"
echo "📂 查找目录：$ICON_SOURCE_DIR"

# 遍历源目录中的所有文件
find "$ICON_SOURCE_DIR" -type f \( -iname "*.png" -o -iname "*.svg" -o -iname "*.jpg" \) | while read -r file; do
  filename=$(basename "$file")
  target_path="/ugreen/static/icons/$filename"
  
  if [ -f "$target_path" ]; then
    cp "$file" "$target_path"
    echo "✅ 替换：$filename"
  else
    echo "⚠️ 略过未匹配图标：$filename"
  fi
done

echo "🎉 图标替换完成：$(date)"
} | tee -a "$LOG_FILE"
