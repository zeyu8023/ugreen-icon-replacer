# 🧊 ugreen-icon-replacer 绿联NAS图标一键更换

![image](https://github.com/zeyu8023/ugreen-icon-replacer/blob/879fe65d50d90eb1333f8286a299d9596f14287c/icons/feiniu2.png)

本项目是一个用于快速替换绿联NAS UGPSPRO系统图标的终端脚本工具，支持多套图标风格、联网自动下载、代理加速、自动解压和覆盖替换。适用于绿联NAS（UGOSPRO） 图标目录管理或定制替换。

## 开始执行脚本前，请一定sudo -i 获取root权限！！！否则会替换失败！

---

## ✨ 功能特色

- ✅ 图标风格选择：5 套风格任意切换
- ✅ 一键执行：自动拉取图标并完成覆盖替换
- ✅ 多源下载：支持主站、镜像（FastGit）与用户代理
- ✅ 代理记忆：首次输入代理后自动保存，下次运行自动加载
- ✅ 格式校验：代理地址格式检测，支持多次重输
- ✅ unzip 依赖自动检测与安装提示
- ✅ 本地图标目录支持：无需联网也可本地替换
- ✅ 操作日志记录：自动生成日志文件 /var/log/iconreplace*.log
- ✅ 脚本容错机制完善，适合初学者和高级用户使用

## 🎨 图标主题支持

本项目内置 多套图标风格，用户在执行替换脚本时可自由选择：

- 1  iOS 26 液态玻璃（乐小宇） 高光玻璃质感风格

- 2  锤子 OS（Sunny 整理）   极简细腻

- 3  拟物毛玻璃（Sunny 制作）  冰感拟物

- 4  绿联毛玻璃（Sunny 制作）   更绿、更毛、更玻璃

- 5  官方默认图标  icons/defaslt  恢复原始图标样式

脚本执行过程中会提供图形化选项，选择对应风格即可一键替换系统图标。


## ☁ 支持代理访问 GitHub

- 脚本首次下载失败后将自动提示输入代理，例如：

`bash
http://127.0.0.1:7890
socks5h://127.0.0.1:1080
`

- 脚本将保存代理至 ~/.ugreeniconconfig
- 再次运行时会自动提示是否复用上次的代理

---

## 📦 unzip 自动安装说明

- 脚本下载图标后会自动检测系统是否安装 unzip
- 若未安装，则会提示用户是否安装，并根据系统自动选择以下管理器：

系统  管理器
Ubuntu/Debian  apt
Fedora/CentOS  dnf
Arch/Manjaro  pacman

---

## 🚀 快速使用
![image](https://github.com/zeyu8023/ugreen-icon-replacer/blob/main/icons/wechat_2025-06-26_212946_207.png)

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

1. 当前项目包含 icons/ 文件夹，且其中包含多套图标文件，可自由选择图标来源，无需手动输入路径。
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
- 系统更新后图标会恢复默认，如需更改可重新执行本脚本即可

---

## 📄 License

MIT License © 2025 zeyu8023
`
