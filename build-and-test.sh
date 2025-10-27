#!/usr/bin/env bash

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}      🔨 M3U8 Downloader 本地打包和测试脚本${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 项目根目录
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 1. 清理旧的构建产物
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo -e "${YELLOW}📦 步骤 1/6: 清理旧的构建产物...${NC}"
echo ""

if [ -d "src-tauri/target/release" ]; then
    echo -e "${BLUE}  → 删除 src-tauri/target/release${NC}"
    rm -rf src-tauri/target/release
fi

echo -e "${GREEN}  ✓ 清理完成${NC}"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 2. 检查配置文件
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo -e "${YELLOW}📋 步骤 2/6: 检查配置文件...${NC}"
echo ""

# 检查 devtools 配置
if grep -q '"devtools": true' src-tauri/tauri.conf.json; then
    echo -e "${GREEN}  ✓ devtools 已启用${NC}"
else
    echo -e "${RED}  ✗ devtools 未启用${NC}"
    exit 1
fi

# 检查 HTTP 权限
if grep -q '"http:default"' src-tauri/capabilities/default.json; then
    echo -e "${GREEN}  ✓ HTTP 权限已配置${NC}"
else
    echo -e "${RED}  ✗ HTTP 权限未配置${NC}"
    exit 1
fi

# 检查版本号
VERSION=$(grep -o '"version": "[^"]*"' package.json | cut -d'"' -f4)
echo -e "${BLUE}  → 当前版本: ${VERSION}${NC}"

echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 3. 安装依赖（如果需要）
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo -e "${YELLOW}📥 步骤 3/6: 检查依赖...${NC}"
echo ""

if [ ! -d "node_modules" ]; then
    echo -e "${BLUE}  → 安装 npm 依赖...${NC}"
    npm install
    echo -e "${GREEN}  ✓ npm 依赖已安装${NC}"
else
    echo -e "${GREEN}  ✓ npm 依赖已存在${NC}"
fi

echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 4. 开始构建
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo -e "${YELLOW}🔨 步骤 4/6: 开始构建应用...${NC}"
echo -e "${BLUE}  提示: 这可能需要 5-10 分钟，请耐心等待...${NC}"
echo ""

# 记录开始时间
START_TIME=$(date +%s)

# 构建
npm run tauri build

# 记录结束时间
END_TIME=$(date +%s)
BUILD_TIME=$((END_TIME - START_TIME))

echo ""
echo -e "${GREEN}  ✓ 构建完成！耗时: ${BUILD_TIME} 秒${NC}"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 5. 查找构建产物
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo -e "${YELLOW}📦 步骤 5/6: 查找构建产物...${NC}"
echo ""

# 查找 DMG 文件
DMG_FILE=$(find src-tauri/target/release/bundle/dmg -name "*.dmg" 2>/dev/null | head -1)

if [ -n "$DMG_FILE" ]; then
    echo -e "${GREEN}  ✓ 找到 DMG 文件:${NC}"
    echo -e "${BLUE}    $DMG_FILE${NC}"

    # 显示文件大小
    FILE_SIZE=$(du -h "$DMG_FILE" | cut -f1)
    echo -e "${BLUE}    大小: $FILE_SIZE${NC}"
else
    echo -e "${RED}  ✗ 未找到 DMG 文件${NC}"
    exit 1
fi

echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 6. 测试说明
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo -e "${YELLOW}🧪 步骤 6/6: 测试说明${NC}"
echo ""

echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  构建成功！现在可以开始测试${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${BLUE}📋 测试步骤:${NC}"
echo ""
echo -e "  ${YELLOW}1. 打开 DMG 文件${NC}"
echo -e "     ${BLUE}open \"$DMG_FILE\"${NC}"
echo ""
echo -e "  ${YELLOW}2. 拖拽到 Applications 文件夹${NC}"
echo ""
echo -e "  ${YELLOW}3. 打开应用${NC}"
echo -e "     ${BLUE}open /Applications/M3U8\\ Downloader.app${NC}"
echo ""
echo -e "  ${YELLOW}4. 按快捷键打开开发者工具${NC}"
echo -e "     ${GREEN}Cmd + Option + I${NC}"
echo ""
echo -e "  ${YELLOW}5. 测试下载功能${NC}"
echo -e "     测试链接: ${BLUE}https://upyun.luckly-mjw.cn/Assets/media-source/example/media/index.m3u8${NC}"
echo ""
echo -e "  ${YELLOW}6. 在 Console 中检查错误${NC}"
echo -e "     - 查看是否有红色错误信息"
echo -e "     - 查看 Network 标签中的请求状态"
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${BLUE}🔍 调试命令:${NC}"
echo ""
echo -e "  在开发者工具的 Console 中运行:"
echo ""
echo -e "  ${YELLOW}// 检查 Tauri 环境${NC}"
echo -e "  ${BLUE}console.log('Tauri 可用:', typeof window.__TAURI__ !== 'undefined');${NC}"
echo -e "  ${BLUE}console.log('Tauri HTTP 可用:', typeof window.__TAURI__?.http !== 'undefined');${NC}"
echo ""
echo -e "  ${YELLOW}// 测试 HTTP 请求${NC}"
echo -e "  ${BLUE}if (window.__TAURI__?.http) {${NC}"
echo -e "  ${BLUE}  const { fetch } = window.__TAURI__.http;${NC}"
echo -e "  ${BLUE}  fetch('https://upyun.luckly-mjw.cn/Assets/media-source/example/media/index.m3u8')${NC}"
echo -e "  ${BLUE}    .then(res => console.log('✅ 成功:', res))${NC}"
echo -e "  ${BLUE}    .catch(err => console.error('❌ 失败:', err));${NC}"
echo -e "  ${BLUE}}${NC}"
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 询问是否立即测试
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

read -p "是否立即打开 DMG 文件进行测试？[Y/n]: " OPEN_DMG
OPEN_DMG=${OPEN_DMG:-Y}

if [[ "$OPEN_DMG" =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${BLUE}正在打开 DMG 文件...${NC}"
    open "$DMG_FILE"
    echo ""
    echo -e "${GREEN}请按照上述步骤进行测试${NC}"
else
    echo ""
    echo -e "${BLUE}稍后可以手动打开 DMG 文件:${NC}"
    echo -e "${BLUE}open \"$DMG_FILE\"${NC}"
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  完成！${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
