#!/bin/bash

# M3U8 Downloader - Tauri Desktop App
# 快速启动脚本

echo "🚀 M3U8 Downloader - Tauri 桌面版"
echo "=================================="
echo ""

# 检查是否在项目目录
if [ ! -f "package.json" ]; then
    echo "❌ 错误：请在项目根目录运行此脚本"
    exit 1
fi

# 检查 npm 是否安装
if ! command -v npm &> /dev/null; then
    echo "❌ 错误：未找到 npm，请先安装 Node.js"
    exit 1
fi

# 检查 cargo 是否安装
if ! command -v cargo &> /dev/null; then
    echo "❌ 错误：未找到 cargo，请先安装 Rust"
    echo "   安装命令：curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    exit 1
fi

# 检查是否已安装依赖
if [ ! -d "node_modules" ]; then
    echo "📦 正在安装 npm 依赖..."
    npm install
    echo "✅ npm 依赖安装完成"
    echo ""
fi

# 询问用户操作
echo "请选择操作："
echo "1) 开发模式运行 (npm run tauri dev)"
echo "2) 打包应用 (npm run tauri build)"
echo "3) 仅安装依赖并退出"
echo ""
read -p "请输入选项 [1-3]: " choice

case $choice in
    1)
        echo ""
        echo "🔧 启动开发模式..."
        echo "⏰ 首次运行需要编译 Rust 依赖，预计需要 5-10 分钟"
        echo "💡 提示：编译完成后会自动打开应用窗口"
        echo ""
        npm run tauri dev
        ;;
    2)
        echo ""
        echo "📦 开始打包应用..."
        echo "⏰ 打包过程需要 10-15 分钟"
        echo ""
        npm run tauri build
        echo ""
        echo "✅ 打包完成！"
        echo "📁 打包文件位置："
        if [ "$(uname)" == "Darwin" ]; then
            echo "   macOS: src-tauri/target/release/bundle/dmg/"
        elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
            echo "   Linux: src-tauri/target/release/bundle/deb/ 或 appimage/"
        fi
        ;;
    3)
        echo "✅ 依赖已安装，退出"
        exit 0
        ;;
    *)
        echo "❌ 无效选项"
        exit 1
        ;;
esac
