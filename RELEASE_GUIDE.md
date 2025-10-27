# 📦 发布指南

## 自动发布脚本

本项目提供了自动发布脚本 `release.sh`，可以自动化完成版本发布流程。

---

## 快速开始

### 运行脚本

```bash
cd /Users/sai/good_tool/xxxxx/m3u8-downloader
bash release.sh
```

或

```bash
./release.sh
```

---

## 功能特性

### ✅ 自动化流程

1. **读取当前版本** - 从 package.json 读取
2. **选择版本类型** - Patch/Minor/Major/Custom
3. **输入更新说明** - 支持多行输入
4. **更新版本号** - 自动更新 3 个文件
5. **提交代码** - Git commit
6. **创建 Tag** - 带详细说明
7. **推送到 GitHub** - 代码 + Tag

### ✅ 智能检测

- **检查工作目录** - 是否有未提交更改
- **显示已有 Tags** - 最近 5 个版本
- **支持重新发布** - 覆盖已有 tag
- **错误处理** - 遇到错误立即退出

### ✅ 版本管理

**支持 4 种版本类型：**

1. **Patch (补丁版本)** - Bug 修复
   - 示例：`1.0.0` → `1.0.1`

2. **Minor (次要版本)** - 新功能
   - 示例：`1.0.0` → `1.1.0`

3. **Major (主要版本)** - 重大更新
   - 示例：`1.0.0` → `2.0.0`

4. **Custom (自定义)** - 任意版本号
   - 示例：`1.0.0` → `1.2.3`

---

## 使用示例

### 示例 1: 发布补丁版本（Bug 修复）

```bash
$ bash release.sh

🚀 M3U8 Downloader 自动发布脚本

📦 读取当前版本...
当前版本: v1.0.0

🏷️  已有的 Git Tags:
v1.0.0

📋 检查 Git 状态...
✅ 检测到代码更改
 M src/index.html

🔢 选择版本更新类型:
  1) Patch  (Bug 修复)    1.0.0 → 1.0.1
  2) Minor  (新功能)      1.0.0 → 1.1.0
  3) Major  (重大更新)    1.0.0 → 2.0.0
  4) Custom (自定义版本)

请选择 [1-4] (默认: 1): 1

✅ 新版本: v1.0.1

📝 输入本次更新说明:
提示: 按回车结束输入，输入 '.' 单独一行表示多行输入结束

修复文件保存功能
.

更新说明:
修复文件保存功能

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 发布摘要
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  项目名称: M3U8 Downloader
  当前版本: v1.0.0
  新版本:   v1.0.1
  更新类型: patch
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

确认发布？[y/N]: y

🚀 开始发布流程...

📝 更新版本号...
  ✓ package.json
  ✓ src-tauri/Cargo.toml
  ✓ src-tauri/tauri.conf.json
✅ 版本号更新完成

📦 提交代码到 Git...
✅ 代码已提交

🏷️  创建 Git Tag...
✅ Tag v1.0.1 已创建

☁️  推送到 GitHub...
✅ 代码已推送到 main
✅ Tag 已推送

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
          ✅ 发布成功！
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📦 版本: v1.0.1
🏷️  Tag:  v1.0.1
```

### 示例 2: 重新发布当前版本

```bash
$ bash release.sh

📋 检查 Git 状态...
✅ 工作目录干净（无未提交更改）

选择操作:
  1) 重新发布当前版本 v1.0.0 (强制覆盖 tag)
  2) 创建新版本
  3) 退出

请选择 [1-3] (默认: 3): 1

⚠️  将重新发布版本 v1.0.0

📝 输入本次更新说明:
提示: 重新发布原因（可选，直接回车跳过）

修复构建问题
.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 发布摘要
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  项目名称: M3U8 Downloader
  当前版本: v1.0.0
  发布版本: v1.0.0 (重新发布，将覆盖 tag)
  更新类型: republish
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

确认发布？[y/N]: y

🚀 开始发布流程...

📦 无需提交（工作目录干净）

🏷️  创建 Git Tag...
  删除旧 tag v1.0.0...
✅ Tag v1.0.0 已创建

☁️  推送到 GitHub...
✅ Tag 已强制推送（覆盖）

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
          ✅ 重新发布成功！
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 脚本功能详解

### 1. 版本号管理

**自动更新以下文件：**

```
package.json                   - "version": "1.0.1"
src-tauri/Cargo.toml          - version = "1.0.1"
src-tauri/tauri.conf.json     - "version": "1.0.1"
```

### 2. Git 提交

**自动生成 commit message：**

```
release: v1.0.1

修复文件保存功能
```

### 3. Git Tag

**自动生成 tag message（包含详细信息）：**

```
Release v1.0.1

## 🎉 支持平台
✅ macOS Apple Silicon (.dmg)
✅ macOS Intel (.dmg)
✅ Windows x64 (.msi, .exe)
✅ Linux x64 (.deb, .AppImage)

## 📝 更新内容
修复文件保存功能

## ✨ 主要功能
- M3U8 视频下载（原格式/MP4转码）
- AES-128 加密视频解密
- 流式下载大文件
- 原生文件保存对话框
- CORS 智能处理

## 📥 安装说明
- macOS: 双击 .dmg，拖拽到 Applications
- Windows: 运行 .msi 或 .exe
- Linux: sudo dpkg -i *.deb 或运行 .AppImage
```

### 4. GitHub 推送

**自动推送：**
- 代码提交到当前分支（如 main）
- Git Tag 到 origin

---

## 注意事项

### ⚠️ 使用前检查

1. **确保在正确的分支**
   ```bash
   git branch
   # 应该在 main 或 master 分支
   ```

2. **确保有 Git 远程仓库**
   ```bash
   git remote -v
   # 应该看到 origin
   ```

3. **确保有推送权限**
   ```bash
   git push origin main --dry-run
   # 测试是否可以推送
   ```

### ⚠️ 错误处理

**如果脚本执行失败：**

```bash
# 查看详细错误
set -x
bash release.sh

# 或手动执行步骤
git status
git add -A
git commit -m "..."
git tag -a v1.0.1 -m "..."
git push origin main
git push origin v1.0.1
```

### ⚠️ 回滚操作

**如果需要撤销发布：**

```bash
# 删除本地 tag
git tag -d v1.0.1

# 删除远程 tag
git push origin :refs/tags/v1.0.1

# 回退版本号（手动编辑 package.json 等文件）

# 回退 commit（如果还未推送）
git reset --soft HEAD~1
```

---

## GitHub Actions 集成

### 配置自动构建

如果配置了 GitHub Actions，推送 tag 后会自动触发构建。

**创建 `.github/workflows/release.yml`：**

```yaml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    strategy:
      matrix:
        os: [macos-latest, windows-latest, ubuntu-latest]

    runs-on: ${{ matrix.os }}

    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: 20

      - name: Setup Rust
        uses: dtolnay/rust-toolchain@stable

      - name: Install dependencies
        run: npm install

      - name: Build
        run: npm run tauri build

      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: ${{ matrix.os }}-build
          path: src-tauri/target/release/bundle/
```

---

## 常见问题

### Q: 如何修改项目名称？

**A:** 编辑脚本中的以下行：

```bash
# 第 35 行左右
echo -e "${BLUE}          🚀 M3U8 Downloader 自动发布脚本${NC}"

# 第 264 行左右
echo -e "  项目名称: ${BLUE}M3U8 Downloader${NC}"

# 第 429-434 行左右（产物名称）
echo -e "  1️⃣  M3U8-Downloader-v${NEW_VERSION}-macOS-Apple-Silicon.dmg"
```

### Q: 如何修改 GitHub 仓库地址？

**A:** 编辑脚本中的以下行：

```bash
# 第 412-416 行左右
echo -e "   https://github.com/YOUR_USERNAME/m3u8-downloader/actions"
echo -e "   https://github.com/YOUR_USERNAME/m3u8-downloader/releases/tag/v${NEW_VERSION}"
```

将 `YOUR_USERNAME` 替换为您的 GitHub 用户名。

### Q: 如何自定义 Tag 说明？

**A:** 编辑脚本中的 `TAG_MSG` 变量（第 361-382 行左右）。

---

## 总结

**发布脚本特点：**

1. ✅ **自动化** - 一键完成所有步骤
2. ✅ **智能** - 自动检测状态，智能决策
3. ✅ **安全** - 确认后才执行，支持回滚
4. ✅ **灵活** - 支持多种版本类型
5. ✅ **友好** - 彩色输出，清晰提示

**推荐工作流：**

```bash
# 1. 开发完成，测试通过
npm run tauri dev

# 2. 提交代码（可选，脚本会自动提交）
git add -A
git commit -m "feat: 添加新功能"

# 3. 运行发布脚本
bash release.sh

# 4. 选择版本类型（1-4）
# 5. 输入更新说明
# 6. 确认发布
# 7. 等待 GitHub Actions 构建（如已配置）
```

---

**祝发布顺利！** 🎉

**版本：** v1.0.10
**日期：** 2025-10-27
