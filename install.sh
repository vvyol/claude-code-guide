#!/bin/bash
# ============================================
# Claude Code Mac / Linux 一键安装（国内优化版）
# 用法: curl -fsSL https://vvyol.github.io/claude-code-guide/install.sh | sh
# ============================================

set -e

echo ""
echo "============================================"
echo "  Claude Code for Mac / Linux - 一键安装"
echo "  国内镜像加速 · 全程自动"
echo "============================================"
echo ""

# ============================================
# Step 1: 检测 Node.js
# ============================================
echo "[1/4] 检测 Node.js..."

NODE_OK=false

if command -v node &> /dev/null; then
    NODE_VER=$(node -v 2>/dev/null | sed 's/v//')
    NODE_MAJOR=$(echo "$NODE_VER" | cut -d. -f1)
    if [ "$NODE_MAJOR" -ge 18 ] 2>/dev/null; then
        echo "  已安装 Node.js v$NODE_VER (符合要求)"
        NODE_OK=true
    else
        echo "  Node.js v$NODE_VER 版本过低 (需要 >= 18)"
    fi
else
    echo "  未检测到 Node.js"
fi

# ============================================
# Step 2: 安装 Node.js（如需要）
# ============================================
if [ "$NODE_OK" = false ]; then
    echo ""
    echo "[2/4] 安装 Node.js..."
    echo ""

    # 检测系统包管理器
    if command -v brew &> /dev/null; then
        # macOS Homebrew
        echo "  使用 Homebrew 安装 Node.js LTS..."
        brew install node@20 2>/dev/null || brew install node
    elif command -v apt &> /dev/null; then
        # Debian / Ubuntu
        echo "  使用 apt 安装 Node.js..."
        sudo apt update -qq
        sudo apt install -y nodejs npm
    elif command -v dnf &> /dev/null; then
        # Fedora / RHEL
        echo "  使用 dnf 安装 Node.js..."
        sudo dnf install -y nodejs npm
    elif command -v pacman &> /dev/null; then
        # Arch
        echo "  使用 pacman 安装 Node.js..."
        sudo pacman -S --noconfirm nodejs npm
    else
        echo "  未检测到支持的包管理器。"
        echo "  请手动从 https://nodejs.org/zh-cn/download/ 下载安装 Node.js LTS 版本"
        echo "  装完后重新运行此脚本。"
        exit 1
    fi

    if ! command -v node &> /dev/null; then
        echo "  安装失败！请手动安装 Node.js 后重试。"
        exit 1
    fi
    echo "  Node.js 安装完成: $(node -v)"
else
    echo ""
    echo "[2/4] Node.js 已满足要求，跳过安装。"
fi

# ============================================
# Step 3: 安装 Claude Code
# ============================================
echo ""
echo "[3/4] 安装 Claude Code（使用国内镜像）..."
echo "  设置 npm 镜像为 npmmirror.com..."
npm config set registry https://registry.npmmirror.com

if command -v claude &> /dev/null; then
    CC_VER=$(claude --version 2>/dev/null || echo "unknown")
    echo "  已有 Claude Code: $CC_VER，更新到最新版..."
    npm install -g @anthropic-ai/claude-code@latest
else
    echo "  正在安装（约 200MB，请耐心等待）..."
    npm install -g @anthropic-ai/claude-code
fi

# ============================================
# Step 4: 配置 PATH（npm 全局包路径）
# ============================================
echo ""
echo "[4/5] 配置 PATH..."

NPM_PREFIX=$(npm config get prefix 2>/dev/null || echo "")
if [ -z "$NPM_PREFIX" ]; then
    NPM_PREFIX="$HOME/.local"
fi

BIN_DIR="$NPM_PREFIX"
if [ -d "$NPM_PREFIX/bin" ]; then
    BIN_DIR="$NPM_PREFIX/bin"
fi

echo "  npm 全局命令路径: $BIN_DIR"

if echo "$PATH" | grep -q "$BIN_DIR"; then
    echo "  已在 PATH 中，跳过"
else
    export PATH="$PATH:$BIN_DIR"
    echo "  已添加到当前会话 PATH"
fi

# ============================================
# Step 5: 验证
# ============================================
echo ""
echo "[5/5] 验证安装..."

if command -v claude &> /dev/null; then
    CC_VER=$(claude --version 2>/dev/null)
    echo ""
    echo "============================================"
    echo "  安装成功！"
    echo "  Claude Code 版本: $CC_VER"
    echo "============================================"
    echo ""
    echo "  下一步："
    echo ""
    echo "  1. 终端输入 claude 回车启动"
    echo "     首次运行会自动打开浏览器引导登录"
    echo ""
    echo "  2. 如果想用国产模型（推荐）："
    echo "     下载 cc-switch: https://github.com/farion1231/cc-switch/releases"
    echo "     支持 DeepSeek / Kimi / 智谱 GLM 等国内 API"
    echo ""
    echo "  3. 如果提示 command not found："
    echo "     运行 source ~/.zshrc 或 source ~/.bashrc"
    echo "     或关掉终端重新打开"
    echo ""
else
    echo ""
    echo "  安装似乎成功，但当前终端找不到 claude 命令。"
    echo "  请运行: source ~/.zshrc (zsh) 或 source ~/.bashrc (bash)"
    echo "  或关掉终端重新打开。"
    echo ""
fi
