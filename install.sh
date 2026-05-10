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

# 配置国内加速：npm 镜像 + Git HTTPS + 超时
echo "  配置国内加速..."
npm config set registry https://registry.npmmirror.com
npm config set disturl https://npmmirror.com/dist
npm config set timeout 120000

# 强制 Git 走 HTTPS（国内 git:// 协议被封）
git config --global url."https://github.com/".insteadOf git@github.com: 2>/dev/null || true
git config --global url."https://".insteadOf git:// 2>/dev/null || true

if command -v claude &> /dev/null; then
    CC_VER=$(claude --version 2>/dev/null || echo "unknown")
    echo "  已有 Claude Code: $CC_VER，更新到最新版..."
    npm install -g @anthropic-ai/claude-code@latest --registry=https://registry.npmmirror.com
else
    echo "  正在安装（约 200MB，请耐心等待）..."
    npm install -g @anthropic-ai/claude-code --registry=https://registry.npmmirror.com
fi

# ============================================
# Step 4: 安装 cc-switch（国产模型切换工具）
# ============================================
echo ""
echo "[4/5] 安装 cc-switch（国产模型支持）..."

# 检测系统和架构
OS_TYPE=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH_TYPE=$(uname -m)
case "$ARCH_TYPE" in
    x86_64)  ARCH="amd64" ;;
    arm64|aarch64) ARCH="arm64" ;;
    *)       ARCH="amd64" ;;  # 默认
esac

CCSWITCH_DIR="$HOME/.local/bin"
mkdir -p "$CCSWITCH_DIR"
CCSWITCH_BIN="$CCSWITCH_DIR/cc-switch"
CCSWITCH_URL="https://ghproxy.com/https://github.com/farion1231/cc-switch/releases/latest/download/cc-switch-${OS_TYPE}-${ARCH}"

echo "  从 GitHub 镜像下载 cc-switch..."
if curl -fsSL "$CCSWITCH_URL" -o "$CCSWITCH_BIN" --connect-timeout 30 --max-time 60 2>/dev/null; then
    chmod +x "$CCSWITCH_BIN"
    echo "  cc-switch 安装完成"
else
    echo "  下载失败，跳过(可手动下载: https://github.com/farion1231/cc-switch)"
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
    echo "  2. 已自动安装 cc-switch（国产模型切换）："
    echo "     终端输入 cc-switch 即可切换 DeepSeek / Kimi 等"
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
