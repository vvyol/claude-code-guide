# Claude Code 一键安装 · 国内优化版

一行命令，自动装好。简单到只需要复制粘贴。

专为中国大陆用户优化 —— npm 自动切淘宝镜像，蓝奏云分流大文件下载。

---

## 快速开始

打开终端，复制下面一行，回车。等待自动完成。

**Windows**（PowerShell）：

```
irm https://vvyol.github.io/claude-code-guide/cc.ps1 | iex
```

**Mac / Linux**（终端）：

```
curl -fsSL https://vvyol.github.io/claude-code-guide/cc.sh | sh
```

---

## 项目解决了什么问题

Claude Code 官方安装在国内会遇到三个麻烦：

1. npm 官方源下载极慢（甚至超时）
2. Windows 用户需要额外装 Git Bash，很多人不知道
3. npm 全局包的 bin 目录不在 PATH 里，装完敲 `claude` 提示找不到命令

这个项目用一个脚本自动搞定全部 —— 检测系统环境、安装缺失组件、切国内镜像、配好 PATH。

---

## 文件说明

| 文件 | 用途 | 适用系统 |
|------|------|----------|
| `index.html` | 安装教程页面（线上展示） | 通用 |
| `cc.ps1` | 入口安装脚本（一行命令调用） | Windows PowerShell |
| `cc.sh` | 入口安装脚本（一行命令调用） | macOS / Linux |
| `install.ps1` | 独立 PowerShell 安装脚本 | Windows |
| `install.sh` | 独立 Shell 安装脚本 | macOS / Linux |
| `install.bat` | 独立批处理安装脚本 | Windows CMD |

`cc.ps1` 和 `cc.sh` 是面向 `irm | iex` / `curl | sh` 一行命令调用场景的入口脚本。`install.*` 是给下载后双击或本地运行的独立版本。

---

## 脚本做了什么

所有脚本遵循同样的流程，系统差异自动适配：

**Windows（cc.ps1 / install.ps1 / install.bat）**：

1. 检测 Git Bash —— 没装就引导下载（蓝奏云分流 + 官网备用）
2. 检测 Node.js ≥ 18 —— 版本不够就装
3. 安装 Node.js —— 优先 winget，失败就引导去中文官网下载
4. 配置 npm 镜像 —— 自动切到 `registry.npmmirror.com`
5. 安装 Claude Code —— `npm install -g @anthropic-ai/claude-code`
6. 配置 PATH —— 自动把 npm 全局 bin 路径加到用户环境变量
7. 验证 —— 确认 `claude` 命令可用

**Mac / Linux（cc.sh / install.sh）**：

1. 检测 Node.js ≥ 18
2. 安装 Node.js —— Homebrew / apt / dnf / pacman 自动适配
3. 配置 npm 镜像 + 安装 Claude Code
4. 配置 PATH
5. 验证

---

## 前提条件

- Windows 10/11
- macOS 10.15+ / Linux（支持 apt/dnf/pacman/brew 的发行版）
- 网络能访问 `registry.npmmirror.com`（淘宝 npm 镜像）

---

## 装完之后

### 1. 登录 Anthropic

终端输入 `claude` 回车，首次运行会自动打开浏览器引导登录。需要 Anthropic Console 账号。

### 2. 想用国产模型？（推荐）

装完 Claude Code 本体后，搭配 [cc-switch](https://github.com/farion1231/cc-switch/releases) 可以接入国内模型：

- DeepSeek
- Kimi（月之暗面）
- 智谱 GLM
- MiniMax

注册对应平台获取 API Key，在 cc-switch 中配置即可。无需代理，国内直连。

---

## 国内加速策略

| 环节 | 原始地址 | 加速方案 |
|------|----------|----------|
| npm 包安装 | `registry.npmjs.org` | 自动切 `registry.npmmirror.com` |
| Git for Windows 下载 | `git-scm.com` | 蓝奏云分流（提取码页内提供） |
| Node.js 下载 | `nodejs.org` | 自动导向中文官网下载页 |

---

## 常见问题

**PowerShell 提示"在此系统上禁止运行脚本"？**

先运行 `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`，输入 Y 确认，然后重新粘贴安装命令。

**装完终端输入 claude 找不到？**

关掉当前终端，重新打开一个新窗口。脚本已经把路径写入了用户环境变量，新终端会加载。

**Mac 提示 command not found？**

运行 `source ~/.zshrc`（zsh）或 `source ~/.bashrc`（bash），或者关掉终端重开。

**下载特别慢或卡住了？**

npm 已自动切到 npmmirror.com 镜像。如果仍然慢，检查是否开了代理干扰了镜像站访问。

**不装 Git Bash 可以吗？**

Windows 不可以。Claude Code 依赖 Git Bash 提供 Unix 运行环境。

**如何卸载？**

```
npm uninstall -g @anthropic-ai/claude-code
```

然后把用户 PATH 里的 npm 全局 bin 目录删掉即可。

---

## 页面设计

安装教程页面（`index.html`）和 [Hermes 安装引导](https://vvyol.github.io/hermes-install-guide/) 是一套视觉体系：

- 暖白底色 `#FAF9F6`，白色卡片
- 衬线体中文标题（Noto Serif SC）
- 橙色强调色 `#FF6B00`（Hermes 用紫色 `#7C3AED` 做区分）
- 步骤编号圆圈 + 大间距卡片布局
- 深色代码块（Catppuccin Mocha 配色）
- Windows / Mac 双 Tab 一键切换

---

## License

MIT
