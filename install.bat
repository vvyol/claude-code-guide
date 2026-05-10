@echo off
setlocal enabledelayedexpansion
title Claude Code Windows 一键安装（国内优化版）

echo.
echo ============================================
echo   Claude Code for Windows - 一键安装
echo   国内镜像加速 ^| 全程自动
echo ============================================
echo.

:: ============================================
:: Step 1: 检查 Git Bash
:: ============================================
echo [1/5] 检测 Git Bash...

set GIT_BASH=
if exist "%USERPROFILE%\scoop\apps\git\current\bin\bash.exe" set GIT_BASH=%USERPROFILE%\scoop\apps\git\current\bin\bash.exe
if exist "C:\Program Files\Git\bin\bash.exe" set GIT_BASH=C:\Program Files\Git\bin\bash.exe
if exist "C:\Program Files (x86)\Git\bin\bash.exe" set GIT_BASH=C:\Program Files (x86)\Git\bin\bash.exe

:: Also check PATH
where bash.exe >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%i in ('where bash.exe') do set GIT_BASH=%%i
)

if defined GIT_BASH (
    echo 已找到 Git Bash: %GIT_BASH%
) else (
    echo 未找到 Git Bash！这是运行 Claude Code 的必要组件。
    echo.
    echo 正在打开 Git 下载页面...
    start "" "https://git-scm.com/download/win"
    echo.
    echo 请下载安装 Git for Windows（64-bit），安装时一直点"下一步"。
    echo 装完后按任意键继续...
    pause >nul
)

:: ============================================
:: Step 2: 检查 Node.js
:: ============================================
echo.
echo [2/5] 检测 Node.js...

set NODE_OK=0
where node >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%i in ('node -v') do set NODE_VER=%%i
    :: 提取主版本号
    for /f "tokens=1,2 delims=v." %%a in ("!NODE_VER!") do (
        if %%b geq 18 (
            echo 已安装 Node.js !NODE_VER! ^(符合要求^)
            set NODE_OK=1
        ) else (
            echo Node.js !NODE_VER! 版本过低 ^(需要 ^>= 18^)
        )
    )
) else (
    echo 未检测到 Node.js
)

:: ============================================
:: Step 3: 安装 Node.js（如需要）
:: ============================================
if %NODE_OK% equ 1 (
    echo.
    echo [3/5] Node.js 已满足要求，跳过安装。
    goto install_claude
)

echo.
echo [3/5] 安装 Node.js...

:: 方案 A: winget
where winget >nul 2>&1
if %errorlevel% equ 0 (
    echo 使用 winget 安装 Node.js LTS...
    winget install OpenJS.NodeJS.LTS --silent --accept-source-agreements --accept-package-agreements
    if %errorlevel% equ 0 (
        echo.
        echo Node.js 安装完成！请关掉此窗口，
        echo 重新打开终端后再运行此脚本。
        echo.
        pause
        exit /b 0
    )
    echo winget 失败，尝试备用方案...
)

:: 方案 B: 打开下载页
echo 正在打开 Node.js 中文官网下载页...
start "" "https://nodejs.org/zh-cn/download/prebuilt-installer"
echo.
echo 请下载安装 Node.js LTS 版本。
echo 装完后按任意键继续...
pause >nul

:: 验证
where node >nul 2>&1
if %errorlevel% neq 0 (
    echo 仍未检测到 Node.js。请确认安装后重新运行脚本。
    pause
    exit /b 1
)
echo Node.js 已就绪。

:: ============================================
:: Step 4: 安装 Claude Code
:: ============================================
:install_claude
echo.
echo [4/5] 安装 Claude Code（使用国内镜像）...

:: 换成淘宝镜像源
echo 设置 npm 镜像为 npmmirror.com...
call npm config set registry https://registry.npmmirror.com

:: 检查是否已安装
where claude >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%i in ('claude --version') do set CC_VER=%%i
    echo 已有 Claude Code: !CC_VER!，更新到最新版...
    call npm install -g @anthropic-ai/claude-code@latest
) else (
    echo 正在安装（约 200MB，请耐心等待）...
    call npm install -g @anthropic-ai/claude-code
)

if %errorlevel% neq 0 (
    echo.
    echo 安装失败！常见原因：
    echo 1. 网络问题 - 确认能访问 registry.npmmirror.com
    echo 2. 权限问题 - 右键"以管理员身份运行"重试
    echo 3. 磁盘空间不足 - 至少需要 500MB
    pause
    exit /b 1
)

:: ============================================
:: Step 5: 验证
:: ============================================
echo.
echo [5/5] 验证安装...

where claude >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%i in ('claude --version') do set CC_VER=%%i
    echo.
    echo ============================================
    echo   安装成功！Claude Code: !CC_VER!
    echo ============================================
    echo.
    echo 下一步：
    echo.
    echo 1. 打开终端，输入 claude 回车
    echo    首次运行会自动打开浏览器引导登录
    echo.
    echo 2. 如果想用国产模型（推荐）：
    echo    下载 cc-switch: https://github.com/farion1231/cc-switch/releases
    echo    支持 DeepSeek / Kimi / 智谱 GLM 等国内 API
    echo.
    echo 3. 如果找不到 claude 命令：
    echo    关掉终端重新打开，或把 %%USERPROFILE%%\.local\bin\ 加到 PATH
    echo.
) else (
    echo.
    echo 安装似乎成功，但当前终端找不到 claude 命令。
    echo 关掉此窗口，重新打开一个新终端，输入 claude 即可。
    echo 如果还不行，重启电脑让环境变量生效。
    echo.
)

pause
