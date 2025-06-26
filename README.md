# 🧊 ugreen-icon-replacer

一键自动替换 `/ugreen/static/icons` 系统图标的脚本，支持交互式输入、自定义图标路径、日志记录与安全确认。专为 Debian 系统设计，让图标更新更简单、更可控。

---

## ✨ 功能特色

- ✅ 支持任意路径，只需文件名与系统图标相符即可替换
- 🔄 自动匹配 `/ugreen/static/icons` 目录中的图标文件
- 📦 跳过未匹配文件，保障系统图标完整性
- 📜 自动生成日志文件，记录完整替换过程
- 🛡 替换操作前确认提示，避免误操作

---

## 🚀 快速使用

### 方法一：一键运行（推荐）

\`\`\`bash
bash <(curl -s https://raw.githubusercontent.com/zeyu8023/ugreen-icon-replacer/main/replace_icons.sh)
\`\`\`

### 方法二：手动下载运行

\`\`\`bash
git clone https://github.com/zeyu8023/ugreen-icon-replacer.git
cd ugreen-icon-replacer
chmod +x replace_icons.sh
sudo ./replace_icons.sh
\`\`\`

---

## 🛠️ 使用说明

运行脚本后：

1. 输入包含图标文件的目录路径（不要求目录名为 \`icons\`）
2. 脚本会递归查找该目录中所有 \`.png\`、\`.svg\`、\`.jpg\` 文件
3. 如果文件名与 \`/ugreen/static/icons/\` 中已有图标一致，将进行自动替换
4. 替换过程将写入日志文件，位于 \`/var/log/icon_replace_*.log\`

---

## 📁 示例目录结构

\`\`\`
/home/user/my_icons/
├── custom-logo.png          # 替换系统中的 custom-logo.png
└── nested/
    └── nav.png              # 替换系统中的 nav.png
\`\`\`

---

## 🧩 注意事项

- 替换操作不可撤销，请务必确认图标来源无误
- 仅会替换名称与系统图标相同的文件，其他文件将被自动跳过
- 默认支持 \`.png\`、\`.svg\`、\`.jpg\` 格式，如需扩展其他格式可修改脚本中文件类型过滤逻辑

---

## 📄 License

MIT License © 2025 zeyu8023
EOF
