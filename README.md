# 🧊 ugreen-icon-replacer

一键自动替换 `/ugreen/static/icons` 系统图标的脚本，支持交互式输入、自定义图标路径、日志记录和安全确认。专为 Debian 系统设计，轻松完成图标更新！

---

## ✨ 功能特色

- ✅ 支持任意目录路径，只需文件名匹配即可替换
- 🔄 自动匹配已有系统图标，无需手动对齐
- 📦 自动跳过未匹配文件，避免误操作
- 📜 全过程生成日志文件，操作透明可追踪
- 🛡 替换前交互式确认，安全可控

---

## 🚀 快速使用

### 1. 一键运行（推荐）

在目标机器上运行以下命令：

```bash
bash <(curl -s https://raw.githubusercontent.com/zeyu8023/ugreen-icon-replacer/main/replace_icons.sh)
---

2. 自行下载使用

`bash
git clone https://github.com/zeyu8023/ugreen-icon-replacer.git
cd ugreen-icon-replacer
chmod +x replace_icons.sh
sudo ./replace_icons.sh
`

---

🛠️ 使用说明

运行脚本后：
1. 输入包含图标的自定义路径（不要求目录名为 icons）
2. 脚本会查找该目录及其子目录内所有 .png、.svg、.jpg 文件
3. 与 /ugreen/static/icons 中已有图标按名称匹配后进行替换
4. 生成详细日志于 /var/log/iconreplace*.log

---

📁 示例

目录结构参考：

`
/home/user/my_icons/
└── custom-logo.png      # 替换系统中的 custom-logo.png
└── other-icons/
    └── nav.png          # 替换系统中的 nav.png
`

---

🧩 注意事项

- 替换过程不可撤销，请仔细确认
- 仅匹配系统已有图标名称，其他文件会跳过
- 默认支持 .png、.svg、.jpg 格式，如需支持更多扩展名可修改脚本

---

📄 License

MIT License © 2025
