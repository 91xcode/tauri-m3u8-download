# 🚀 GitHub Actions 自动构建配置

## 概述

本项目已配置 GitHub Actions，可以自动构建跨平台安装包。

**触发条件：**
- 推送 Git Tag（格式：`v*`，如 `v1.0.0`）
- 手动触发（workflow_dispatch）

**构建平台：**
- ✅ macOS Apple Silicon (.dmg)
- ✅ macOS Intel (.dmg)
- ✅ Windows x64 (.msi, .exe)
- ✅ Linux x64 (.deb, .AppImage)

---

## 配置文件

**位置：** `.github/workflows/build-release.yml`

**主要内容：**

```yaml
name: Build Release

on:
  push:
    tags:
      - 'v*'        # 推送 tag 时触发
  workflow_dispatch:  # 支持手动触发

permissions:
  contents: write    # 允许创建 Release

jobs:
  build:
    strategy:
      matrix:
        include:
          - os: macos-latest
            target: aarch64-apple-darwin    # Apple Silicon
          - os: macos-latest
            target: x86_64-apple-darwin     # Intel
          - os: windows-latest
            target: x86_64-pc-windows-msvc  # Windows
          - os: ubuntu-latest
            target: x86_64-unknown-linux-gnu # Linux
```

---

## 自动化流程

### 1. 发布新版本

使用 `release.sh` 脚本：

```bash
bash release.sh
```

**脚本会自动：**
1. 更新版本号
2. 创建 Git Commit
3. 创建 Git Tag
4. 推送到 GitHub

**推送 Tag 后：**
- GitHub Actions 自动触发
- 开始构建多平台安装包

---

### 2. 构建过程

**时间估计：** 5-8 分钟

**并行构建：**
```
┌─────────────────────────────────────┐
│     GitHub Actions 自动构建         │
├─────────────────────────────────────┤
│  macOS Apple Silicon  (5-6 分钟)   │ ───┐
│  macOS Intel          (5-6 分钟)   │ ───┤
│  Windows x64          (4-5 分钟)   │ ───┼─► 并行执行
│  Linux x64            (3-4 分钟)   │ ───┘
└─────────────────────────────────────┘
```

**每个平台的步骤：**
1. ✅ 检出代码
2. ✅ 安装依赖（Node.js, Rust, 系统库）
3. ✅ 缓存 Rust 编译产物
4. ✅ 构建 Tauri 应用
5. ✅ 重命名产物文件
6. ✅ 上传 Artifacts
7. ✅ 创建 GitHub Release

---

### 3. 产物说明

**文件命名规则：**

```
M3U8-Downloader-v1.0.0-macOS-Apple-Silicon.dmg
M3U8-Downloader-v1.0.0-macOS-Intel.dmg
M3U8-Downloader-v1.0.0-Windows-x64.msi
M3U8-Downloader-v1.0.0-Windows-x64-setup.exe
M3U8-Downloader-v1.0.0-Linux-x64.deb
M3U8-Downloader-v1.0.0-Linux-x64.AppImage
```

**格式：**
```
<项目名>-<版本号>-<平台>-<架构>.<扩展名>
```

---

## 查看构建进度

### 方法 1: GitHub 网页

1. **打开仓库主页**
   ```
   https://github.com/YOUR_USERNAME/m3u8-downloader
   ```

2. **点击 "Actions" 标签**
   ```
   https://github.com/YOUR_USERNAME/m3u8-downloader/actions
   ```

3. **查看构建状态**
   - ✅ 绿色勾号 = 成功
   - ❌ 红色叉号 = 失败
   - 🟡 黄色圆圈 = 进行中

4. **查看详细日志**
   - 点击具体的 workflow
   - 展开每个步骤查看日志

---

### 方法 2: GitHub CLI

```bash
# 安装 GitHub CLI
brew install gh

# 登录
gh auth login

# 查看 workflow 列表
gh workflow list

# 查看最近的运行
gh run list

# 查看特定 run 的详情
gh run view <run-id>

# 查看 run 的日志
gh run view <run-id> --log
```

---

## 发布到 GitHub Releases

### 自动发布

**当推送 Tag 时，GitHub Actions 会自动：**

1. 构建所有平台的安装包
2. 创建 GitHub Release（草稿状态）
3. 上传所有产物到 Release

**Release 页面：**
```
https://github.com/YOUR_USERNAME/m3u8-downloader/releases
```

---

### 编辑 Release 说明

**构建完成后：**

1. **打开 Releases 页面**
   ```
   https://github.com/YOUR_USERNAME/m3u8-downloader/releases
   ```

2. **找到对应版本（草稿状态）**

3. **编辑 Release 说明**
   - 添加更新内容
   - 添加安装说明
   - 添加已知问题

4. **发布 Release**
   - 点击 "Publish release"
   - 用户即可下载

---

### Release 说明模板

```markdown
## 🎉 M3U8 Downloader v1.0.0

### ✨ 主要功能

- M3U8 视频下载（原格式/MP4转码）
- AES-128 加密视频解密
- 流式下载大文件
- 原生文件保存对话框
- CORS 智能处理

### 📦 下载

#### macOS
- [M3U8-Downloader-v1.0.0-macOS-Apple-Silicon.dmg](链接) - Apple Silicon (M1/M2/M3)
- [M3U8-Downloader-v1.0.0-macOS-Intel.dmg](链接) - Intel

#### Windows
- [M3U8-Downloader-v1.0.0-Windows-x64.msi](链接) - MSI 安装包
- [M3U8-Downloader-v1.0.0-Windows-x64-setup.exe](链接) - EXE 安装包

#### Linux
- [M3U8-Downloader-v1.0.0-Linux-x64.deb](链接) - Debian/Ubuntu
- [M3U8-Downloader-v1.0.0-Linux-x64.AppImage](链接) - 通用版本

### 📥 安装说明

#### macOS
1. 双击 `.dmg` 文件
2. 拖拽到 `Applications` 文件夹
3. 首次打开如遇到安全提示：
   - **方法1:** 系统设置 → 隐私与安全性 → 仍要打开
   - **方法2 (推荐):** 终端执行：
     ```bash
     sudo xattr -cr /Applications/M3U8\ Downloader.app
     ```

详见：[INSTALL_MACOS.md](链接)

#### Windows
运行 `.msi` 或 `.exe` 文件，按提示安装

#### Linux
- **Debian/Ubuntu:**
  ```bash
  sudo dpkg -i M3U8-Downloader-v1.0.0-Linux-x64.deb
  ```
- **AppImage:**
  ```bash
  chmod +x M3U8-Downloader-v1.0.0-Linux-x64.AppImage
  ./M3U8-Downloader-v1.0.0-Linux-x64.AppImage
  ```

### 📝 更新内容

- ✅ 首个正式版本发布
- ✅ 完整的 M3U8 下载功能
- ✅ 跨平台支持（macOS/Windows/Linux）
- ✅ 详细的使用文档

### 🐛 已知问题

- 无

### 📚 文档

- [使用指南](链接)
- [macOS 安装指南](链接)
- [发布指南](链接)

### 🙏 致谢

感谢所有贡献者和用户的支持！
```

---

## 手动触发构建

### 在 GitHub 网页

1. **打开 Actions 页面**
   ```
   https://github.com/YOUR_USERNAME/m3u8-downloader/actions
   ```

2. **选择 "Build Release" workflow**

3. **点击 "Run workflow" 按钮**

4. **选择分支**（通常是 main）

5. **点击绿色 "Run workflow" 按钮**

---

### 使用 GitHub CLI

```bash
# 手动触发 workflow
gh workflow run build-release.yml

# 指定分支
gh workflow run build-release.yml --ref main
```

---

## 故障排查

### 常见问题

#### Q1: 构建失败怎么办？

**A:** 查看构建日志：

1. 打开 Actions 页面
2. 点击失败的 run
3. 展开失败的步骤
4. 查看错误信息

**常见错误：**

- **依赖安装失败**
  - 检查 `package.json` 和 `Cargo.toml`
  - 确保版本号正确

- **编译错误**
  - 查看 Rust 编译日志
  - 检查代码语法

- **权限错误**
  - 确保 workflow 有 `contents: write` 权限

---

#### Q2: 为什么没有自动创建 Release？

**A:** 检查以下几点：

1. **Tag 格式是否正确**
   ```bash
   # 正确
   git tag v1.0.0

   # 错误（不以 v 开头）
   git tag 1.0.0
   ```

2. **是否推送了 Tag**
   ```bash
   git push origin v1.0.0
   ```

3. **权限设置**
   - 仓库设置 → Actions → General
   - Workflow permissions 选择 "Read and write permissions"

---

#### Q3: 如何查看构建产物？

**A:** 有两种方式：

**方法1: Artifacts（临时）**
1. 打开 Actions 页面
2. 点击成功的 run
3. 滚动到底部的 "Artifacts" 部分
4. 下载对应平台的压缩包
5. ⚠️ Artifacts 保留 90 天

**方法2: Release（永久）**
1. 打开 Releases 页面
2. 找到对应版本
3. 直接下载

---

#### Q4: 构建时间太长怎么办？

**A:** 优化方法：

1. **使用缓存（已配置）**
   ```yaml
   - uses: Swatinem/rust-cache@v2
     with:
       workspaces: src-tauri
   ```

2. **减少构建目标**
   - 可以暂时注释掉某些平台
   - 只构建需要的平台

3. **使用更快的 Runner**
   - 考虑使用 GitHub 的更大型 Runner（付费）

---

## 本地测试构建

### 在推送前本地测试

```bash
# macOS
npm run tauri build

# 指定目标平台
npm run tauri build -- --target aarch64-apple-darwin  # Apple Silicon
npm run tauri build -- --target x86_64-apple-darwin   # Intel

# 查看产物
ls -la src-tauri/target/release/bundle/
```

---

## 配置自定义

### 修改项目名称

**文件：** `.github/workflows/build-release.yml`

**修改位置：**

```yaml
# 第 84 行左右（macOS）
mv "$file" "M3U8-Downloader-${GITHUB_REF_NAME}-${{ matrix.platform }}-${{ matrix.arch }}.dmg"

# 第 100 行左右（Windows）
mv "$file" "M3U8-Downloader-${GITHUB_REF_NAME}-${{ matrix.platform }}-${{ matrix.arch }}.msi"

# 第 125 行左右（Linux）
mv "$file" "M3U8-Downloader-${GITHUB_REF_NAME}-${{ matrix.platform }}-${{ matrix.arch }}.deb"

# 第 147、159、171 行左右（Artifact 名称）
name: M3U8-Downloader-${{ matrix.platform }}-${{ matrix.arch }}
```

---

### 添加更多平台

**示例：添加 ARM Linux**

```yaml
matrix:
  include:
    # 已有配置...

    # 新增 ARM Linux
    - os: ubuntu-latest
      target: aarch64-unknown-linux-gnu
      platform: Linux
      arch: ARM64
```

**注意：** 需要安装交叉编译工具链。

---

## 总结

**已配置功能：**

✅ **自动触发**
- 推送 Tag 自动构建
- 支持手动触发

✅ **多平台构建**
- macOS (Apple Silicon + Intel)
- Windows (x64)
- Linux (x64)

✅ **自动发布**
- 上传到 GitHub Releases
- 统一的文件命名

✅ **性能优化**
- Rust 缓存
- npm 缓存
- 并行构建

---

**使用流程：**

```bash
# 1. 本地开发和测试
npm run tauri dev

# 2. 运行发布脚本
bash release.sh

# 3. 选择版本类型
# 4. 输入更新说明
# 5. 确认发布

# 6. GitHub Actions 自动构建（5-8 分钟）
# 7. 在 Releases 页面编辑说明
# 8. 发布给用户下载
```

---

**相关链接：**

- GitHub Actions 文档: https://docs.github.com/actions
- Tauri 构建文档: https://tauri.app/v1/guides/building/
- softprops/action-gh-release: https://github.com/softprops/action-gh-release

---

**版本：** v1.0.11
**日期：** 2025-10-27
**状态：** ✅ 配置完成，可以使用
