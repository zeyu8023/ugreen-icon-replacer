# 🧊 ugreen-icon-replacer

一键自动替换 `/ugreen/static/icons` 系统图标的脚本，支持默认图标文件夹、自定义路径、日志记录与安全确认。专为 Debian 系统设计，让图标更新更简单、更可控！

---

## ✨ 功能特色

- ✅ 自动使用本项目目录下的 `icons/` 文件夹作为图标源（可选手动输入其他路径）
- 🔄 匹配系统已有图标名进行精准替换
- 📦 跳过未匹配文件，避免误操作
- 📜 自动生成日志文件，记录替换过程
- 🛡 操作前交互确认，安全稳妥

---

## 🚀 快速使用

### 方法一：一键运行（推荐）

```bash
bash <(curl -s https://raw.githubusercontent.com/zeyu8023/ugreen-icon-replacer/main/replace_icons.sh)

```

### 方法二：手动下载运行

```bash
git clone https://github.com/zeyu8023/ugreen-icon-replacer.git
cd ugreen-icon-replacer
chmod +x replace_icons.sh
sudo ./replace_icons.sh

```

## 🛠️ 使用说明

1. 当前项目包含 icons/ 文件夹，且其中包含本人制作的一套图标文件，默认会使用该文件夹作为图标来源，无需手动输入路径。
2. 如需使用其他路径，可在运行脚本时输入自定义目录。
3. 脚本会扫描图标文件（支持 .png .svg .jpg），与 /ugreen/static/icons 中同名文件进行替换。
4. 每次操作都会记录日志文件，保存在 /var/log/iconreplace*.log。

---

## 📁 示例目录结构

`
ugreen-icon-replacer/
├── replace_icons.sh
└── icons/
    ├── nav.png              # 替换系统中的 nav.png
    └── custom-logo.svg      # 替换系统中的 custom-logo.svg
`

---

## 🧩 注意事项

- 替换操作不可撤销，请确认图标内容无误后执行
- 不会修改未匹配的系统文件
- 如需支持更多图片格式，可修改脚本中的文件过滤规则

---

## 📄 License

MIT License © 2025 zeyu8023
`
