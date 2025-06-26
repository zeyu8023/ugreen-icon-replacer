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
