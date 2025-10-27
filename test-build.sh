#!/bin/bash

# 🧪 测试构建脚本 - 验证条件编译是否正常工作

set -e  # 遇到错误立即退出

echo ""
echo "🧪 =========================================="
echo "   M3U8 Downloader - 构建测试"
echo "=========================================="
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 清理函数
cleanup() {
    echo ""
    echo -e "${YELLOW}🧹 清理构建缓存...${NC}"
    cd src-tauri
    cargo clean
    cd ..
    echo -e "${GREEN}✅ 清理完成${NC}"
    echo ""
}

# 检查二进制中是否包含 devtools
check_devtools() {
    local binary_path="$1"
    local should_have_devtools="$2"

    echo -e "${BLUE}🔍 检查二进制文件...${NC}"
    echo "   路径: $binary_path"

    if [ ! -f "$binary_path" ]; then
        echo -e "${RED}❌ 二进制文件不存在！${NC}"
        return 1
    fi

    # 搜索 devtools 相关字符串
    if strings "$binary_path" | grep -q "allow-internal-toggle-devtools"; then
        if [ "$should_have_devtools" = "true" ]; then
            echo -e "${GREEN}✅ 正确：包含 devtools 功能${NC}"
            return 0
        else
            echo -e "${RED}❌ 错误：不应包含 devtools 功能${NC}"
            return 1
        fi
    else
        if [ "$should_have_devtools" = "false" ]; then
            echo -e "${GREEN}✅ 正确：不包含 devtools 功能${NC}"
            return 0
        else
            echo -e "${RED}❌ 错误：应该包含 devtools 功能${NC}"
            return 1
        fi
    fi
}

# 测试 1: 发布版本（无 devtools）
test_release_build() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}📦 测试 1: 发布版本（无 devtools）${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    cleanup

    echo -e "${YELLOW}🔨 构建中...${NC}"
    npm run build

    echo ""
    check_devtools "src-tauri/target/release/bundle/macos/M3U8 Downloader.app/Contents/MacOS/m3u8-downloader" "false"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 测试 1 通过${NC}"
        return 0
    else
        echo -e "${RED}❌ 测试 1 失败${NC}"
        return 1
    fi
}

# 测试 2: 调试版本（有 devtools）
test_debug_build() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}🔧 测试 2: 调试版本（有 devtools）${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    cleanup

    echo -e "${YELLOW}🔨 构建中...${NC}"
    npm run build:debug

    echo ""
    check_devtools "src-tauri/target/release/bundle/macos/M3U8 Downloader.app/Contents/MacOS/m3u8-downloader" "true"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 测试 2 通过${NC}"
        return 0
    else
        echo -e "${RED}❌ 测试 2 失败${NC}"
        return 1
    fi
}

# 主测试流程
main() {
    # 检查是否在项目根目录
    if [ ! -f "package.json" ]; then
        echo -e "${RED}❌ 请在项目根目录运行此脚本${NC}"
        exit 1
    fi

    # 询问用户要运行哪些测试
    echo "请选择测试类型："
    echo "  1) 仅测试发布版本（无 devtools）"
    echo "  2) 仅测试调试版本（有 devtools）"
    echo "  3) 测试两个版本（完整测试）"
    echo "  4) 快速验证（只构建，不检查）"
    echo ""
    read -p "请输入选项 (1-4): " choice

    case $choice in
        1)
            test_release_build
            ;;
        2)
            test_debug_build
            ;;
        3)
            test_release_build
            test1_result=$?

            test_debug_build
            test2_result=$?

            echo ""
            echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${BLUE}📊 测试总结${NC}"
            echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

            if [ $test1_result -eq 0 ]; then
                echo -e "   发布版本: ${GREEN}✅ 通过${NC}"
            else
                echo -e "   发布版本: ${RED}❌ 失败${NC}"
            fi

            if [ $test2_result -eq 0 ]; then
                echo -e "   调试版本: ${GREEN}✅ 通过${NC}"
            else
                echo -e "   调试版本: ${RED}❌ 失败${NC}"
            fi

            if [ $test1_result -eq 0 ] && [ $test2_result -eq 0 ]; then
                echo ""
                echo -e "${GREEN}🎉 所有测试通过！条件编译工作正常！${NC}"
                exit 0
            else
                echo ""
                echo -e "${RED}❌ 部分测试失败，请检查配置${NC}"
                exit 1
            fi
            ;;
        4)
            echo ""
            echo -e "${YELLOW}🔨 快速构建两个版本...${NC}"
            echo ""

            echo -e "${BLUE}➡️  构建发布版本...${NC}"
            npm run build
            echo -e "${GREEN}✅ 发布版本构建完成${NC}"

            echo ""
            cleanup
            echo ""

            echo -e "${BLUE}➡️  构建调试版本...${NC}"
            npm run build:debug
            echo -e "${GREEN}✅ 调试版本构建完成${NC}"

            echo ""
            echo -e "${GREEN}🎉 两个版本都已构建！${NC}"
            echo ""
            echo "📍 构建产物位置："
            echo "   src-tauri/target/release/bundle/macos/M3U8 Downloader.app"
            echo "   src-tauri/target/release/bundle/dmg/*.dmg"
            ;;
        *)
            echo -e "${RED}❌ 无效的选项${NC}"
            exit 1
            ;;
    esac
}

# 运行主函数
main
