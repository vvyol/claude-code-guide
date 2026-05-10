# ============================================
# Claude Code Windows 一键安装（国内优化版）
# 用法: irm https://你的域名/install.ps1 | iex
# ============================================

$ErrorActionPreference = "Stop"
$host.ui.RawUI.WindowTitle = "Claude Code 安装"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Claude Code for Windows - 一键安装" -ForegroundColor White
Write-Host "  国内镜像加速 · 全程自动" -ForegroundColor Gray
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# ============================================
# Step 0: 解决 PowerShell 路径问题
# ============================================
# 中文用户名可能导致路径异常，统一用 $env:USERPROFILE
$homePath = $env:USERPROFILE
if (-not $homePath) { $homePath = "$env:HOMEDRIVE$env:HOMEPATH" }

# ============================================
# Step 1: 检查 Git Bash（Windows 依赖）
# ============================================
Write-Host "[1/5] 检测 Git Bash..." -ForegroundColor Yellow

$gitBashPath = ""
$gitPaths = @(
    "$homePath\scoop\apps\git\current\bin\bash.exe",
    "C:\Program Files\Git\bin\bash.exe",
    "C:\Program Files (x86)\Git\bin\bash.exe"
)

foreach ($p in $gitPaths) {
    if (Test-Path $p) { $gitBashPath = $p; break }
}

if (-not $gitBashPath) {
    # 也试试 where
    try { $gitBashPath = (Get-Command bash.exe -ErrorAction Stop).Source } catch {}
}

if ($gitBashPath) {
    Write-Host "  已找到 Git Bash: $gitBashPath" -ForegroundColor Green
} else {
    Write-Host "  未找到 Git Bash，这是运行 Claude Code 的必要组件。" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  正在打开 Git 下载页面..." -ForegroundColor White
    Start-Process "https://git-scm.com/download/win"
    Write-Host ""
    Write-Host "  请下载安装 Git for Windows（64-bit），安装时一直点"下一步"即可。" -ForegroundColor Yellow
    Write-Host "  装完后按任意键继续..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# ============================================
# Step 2: 检查 Node.js
# ============================================
Write-Host ""
Write-Host "[2/5] 检测 Node.js..." -ForegroundColor Yellow

$nodeOk = $false

try {
    $nodeVer = (node -v) 2>$null
    if ($nodeVer) {
        $verNum = [int]($nodeVer -replace 'v','' -split '\.')[0]
        if ($verNum -ge 18) {
            Write-Host "  已安装 Node.js $nodeVer (符合要求)" -ForegroundColor Green
            $nodeOk = $true
        } else {
            Write-Host "  Node.js $nodeVer 版本过低 (需要 >= 18)" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "  未检测到 Node.js" -ForegroundColor Yellow
}

# ============================================
# Step 3: 安装 Node.js（如需要）
# ============================================
if (-not $nodeOk) {
    Write-Host ""
    Write-Host "[3/5] 安装 Node.js..." -ForegroundColor Yellow

    # 方案 A: winget
    $winget = Get-Command winget -ErrorAction SilentlyContinue
    if ($winget) {
        Write-Host "  使用 winget 安装 Node.js LTS..." -ForegroundColor White
        winget install OpenJS.NodeJS.LTS --silent --accept-source-agreements --accept-package-agreements

        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "  Node.js 安装完成！请关掉此窗口，" -ForegroundColor Green
            Write-Host "  重新打开 PowerShell 后再次运行安装命令。" -ForegroundColor Green
            Write-Host ""
            pause
            exit 0
        }
        Write-Host "  winget 失败，尝试备用方案..." -ForegroundColor Yellow
    }

    # 方案 B: 打开国内下载页
    Write-Host "  正在打开 Node.js 中文官网下载页..." -ForegroundColor White
    Start-Process "https://nodejs.org/zh-cn/download/prebuilt-installer"
    Write-Host ""
    Write-Host "  请下载安装 Node.js LTS 版本。" -ForegroundColor Yellow
    Write-Host "  装完后按任意键继续..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

    # 验证
    try {
        node -v | Out-Null
        Write-Host "  Node.js 已就绪" -ForegroundColor Green
    } catch {
        Write-Host "  仍未检测到 Node.js。请确认已安装后重新运行脚本。" -ForegroundColor Red
        pause
        exit 1
    }
} else {
    Write-Host ""
    Write-Host "[3/5] Node.js 已满足要求，跳过安装。" -ForegroundColor Gray
}

# ============================================
# Step 4: 配置 npm 镜像 + 安装 Claude Code
# ============================================
Write-Host ""
Write-Host "[4/5] 安装 Claude Code（使用国内镜像）..." -ForegroundColor Yellow

# 配置国内加速：npm 镜像 + Git HTTPS + 超时
Write-Host "  配置国内加速..." -ForegroundColor Gray
npm config set registry https://registry.npmmirror.com
npm config set disturl https://npmmirror.com/dist
npm config set sass_binary_site https://npmmirror.com/mirrors/node-sass
npm config set electron_mirror https://npmmirror.com/mirrors/electron/
npm config set timeout 120000

# 强制 Git 走 HTTPS（国内 git:// 协议被封）
git config --global url."https://github.com/".insteadOf git@github.com:
git config --global url."https://".insteadOf git://

# 检查是否已安装
$alreadyInstalled = Get-Command claude -ErrorAction SilentlyContinue

if ($alreadyInstalled) {
    $ccVer = (claude --version) 2>$null
    Write-Host "  已有 Claude Code: $ccVer，更新到最新版..." -ForegroundColor White
    npm install -g @anthropic-ai/claude-code@latest --registry=https://registry.npmmirror.com
} else {
    Write-Host "  正在安装（约 200MB，请耐心等待）..." -ForegroundColor White
    npm install -g @anthropic-ai/claude-code --registry=https://registry.npmmirror.com
}

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "  安装失败！" -ForegroundColor Red
    Write-Host "  常见原因：" -ForegroundColor Yellow
    Write-Host "  1. 网络问题 → 确认能访问 registry.npmmirror.com" -ForegroundColor Gray
    Write-Host "  2. 权限问题 → 右键 PowerShell 选"以管理员身份运行"重试" -ForegroundColor Gray
    Write-Host "  3. 磁盘空间不足 → 至少需要 500MB 可用空间" -ForegroundColor Gray
    pause
    exit 1
}

# ============================================
# Step 5: 验证
# ============================================
Write-Host ""
Write-Host "[5/5] 验证安装..." -ForegroundColor Yellow

try {
    $ccVerFinal = (claude --version) 2>$null
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Green
    Write-Host "  安装成功！" -ForegroundColor White
    Write-Host "  Claude Code 版本: $ccVerFinal" -ForegroundColor White
    Write-Host "============================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "  下一步：" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  1. 打开终端，输入 claude 回车" -ForegroundColor White
    Write-Host "     首次运行会自动打开浏览器引导登录" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  2. 如果想用国产模型（推荐）：" -ForegroundColor White
    Write-Host "     下载 cc-switch: https://github.com/farion1231/cc-switch/releases" -ForegroundColor Gray
    Write-Host "     支持 DeepSeek / Kimi / 智谱 GLM 等国内 API" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  3. 如果运行时报错找不到命令：" -ForegroundColor White
    Write-Host "     关掉终端重新打开，或者把以下路径加到 PATH:" -ForegroundColor Gray
    Write-Host "     $homePath\.local\bin\" -ForegroundColor Gray
    Write-Host ""
} catch {
    Write-Host ""
    Write-Host "  安装似乎成功，但当前终端找不到 claude 命令。" -ForegroundColor Yellow
    Write-Host "  关掉此窗口，重新打开一个新终端，输入 claude 即可。" -ForegroundColor White
    Write-Host "  如果还不行，重启电脑让环境变量生效。" -ForegroundColor Gray
    Write-Host ""
}

pause
