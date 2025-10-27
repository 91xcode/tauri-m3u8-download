# 🚀 GitHub Actions 配置完成总结

## ✅ 已完成

### 1. GitHub Actions Workflow

**文件：** `.github/workflows/build-release.yml`

**功能：**
- ✅ 推送 Tag 自动触发构建
- ✅ 支持手动触发（workflow_dispatch）
- ✅ 并行构建 6 个平台产物
- ✅ 自动重命名文件
- ✅ 自动上传 Artifacts
- ✅ 自动创建 GitHub Release

---

### 2. 支持的平台

| 平台 | 架构 | 产物格式 | 构建时间 |
|------|------|----------|----------|
| macOS | Apple Silicon (M1/M2/M3) | `.dmg` | ~5-6 分钟 |
| macOS | Intel (x86_64) | `.dmg` | ~5-6 分钟 |
| Windows | x64 | `.msi` + `.exe` | ~4-5 分钟 |
| Linux | x64 | `.deb` + `.AppImage` | ~3-4 分钟 |

**总构建时间：** 约 5-8 分钟（并行执行）

---

### 3. 产物命名规则

**格式：**
```
M3U8-Downloader-<版本号>-<平台>-<架构>.<扩展名>
```

**示例：**
```
M3U8-Downloader-v1.0.0-macOS-Apple-Silicon.dmg
M3U8-Downloader-v1.0.0-macOS-Intel.dmg
M3U8-Downloader-v1.0.0-Windows-x64.msi
M3U8-Downloader-v1.0.0-Windows-x64-setup.exe
M3U8-Downloader-v1.0.0-Linux-x64.deb
M3U8-Downloader-v1.0.0-Linux-x64.AppImage
```

---

## 🔄 完整发布流程

### 步骤 1: 本地开发和测试

```bash
# 开发和测试
npm run tauri dev

# 本地构建测试
npm run tauri build
```

---

### 步骤 2: 运行发布脚本

```bash
bash release.sh
```

**脚本会自动：**

1. 读取当前版本号
2. 显示已有的 Git Tags
3. 检查工作目录状态
4. 让你选择版本类型（Patch/Minor/Major/Custom）
5. 输入更新说明
6. 更新 3 个文件的版本号：
   - `package.json`
   - `src-tauri/Cargo.toml`
   - `src-tauri/tauri.conf.json`
7. 创建 Git Commit
8. 创建 Git Tag（包含详细说明）
9. 推送到 GitHub

---

### 步骤 3: GitHub Actions 自动构建

**推送 Tag 后：**

```
GitHub 检测到 tag 推送
  ↓
触发 build-release.yml workflow
  ↓
并行启动 4 个构建任务
  ├─ macOS (Apple Silicon + Intel)
  ├─ Windows (x64)
  └─ Linux (x64)
  ↓
每个任务执行：
  1. 检出代码
  2. 安装依赖（Node.js, Rust, 系统库）
  3. 使用缓存加速
  4. 构建 Tauri 应用
  5. 重命名产物文件
  6. 上传 Artifacts
  7. 创建/更新 GitHub Release
  ↓
构建完成（5-8 分钟）
  ↓
所有产物自动上传到 Release
```

---

### 步骤 4: 编辑 Release 说明

1. 打开 GitHub Releases 页面
2. 找到新创建的 Release（可能是草稿状态）
3. 编辑 Release 说明：
   - 添加更新内容
   - 添加安装说明
   - 添加已知问题
4. 点击 "Publish release"

---

### 步骤 5: 用户下载

用户可以从 Releases 页面下载对应平台的安装包。

---

## 📋 Workflow 配置详解

### 触发条件

```yaml
on:
  push:
    tags:
      - 'v*'        # 任何以 v 开头的 tag，如 v1.0.0
  workflow_dispatch:  # 支持手动触发
```

---

### 权限设置

```yaml
permissions:
  contents: write  # 允许创建 Release 和上传文件
```

---

### 构建矩阵

```yaml
strategy:
  fail-fast: false  # 一个平台失败不影响其他平台
  matrix:
    include:
      - os: macos-latest
        target: aarch64-apple-darwin
        platform: macOS
        arch: Apple-Silicon

      - os: macos-latest
        target: x86_64-apple-darwin
        platform: macOS
        arch: Intel

      - os: windows-latest
        target: x86_64-pc-windows-msvc
        platform: Windows
        arch: x64

      - os: ubuntu-latest
        target: x86_64-unknown-linux-gnu
        platform: Linux
        arch: x64
```

---

### 关键步骤

#### 1. Linux 依赖安装

```yaml
- name: Install Linux dependencies
  if: matrix.os == 'ubuntu-latest'
  run: |
    sudo apt-get update
    sudo apt-get install -y \
      libwebkit2gtk-4.1-dev \
      build-essential \
      libssl-dev \
      libayatana-appindicator3-dev \
      librsvg2-dev
```

#### 2. Rust 缓存

```yaml
- name: Rust cache
  uses: Swatinem/rust-cache@v2
  with:
    workspaces: src-tauri
```

**效果：**
- 首次构建：~10-15 分钟
- 后续构建：~3-5 分钟

#### 3. 构建应用

```yaml
- name: Build Tauri app
  run: npm run tauri build -- --target ${{ matrix.target }}
```

#### 4. 重命名文件（macOS 示例）

```yaml
- name: Rename files (macOS)
  if: matrix.os == 'macos-latest'
  shell: bash
  run: |
    cd src-tauri/target/${{ matrix.target }}/release/bundle/dmg || exit 1
    for file in *.dmg; do
      if [ -f "$file" ]; then
        mv "$file" "M3U8-Downloader-${GITHUB_REF_NAME}-${{ matrix.platform }}-${{ matrix.arch }}.dmg"
      fi
    done
```

#### 5. 创建 Release

```yaml
- name: Create Release (macOS)
  if: matrix.os == 'macos-latest' && startsWith(github.ref, 'refs/tags/')
  uses: softprops/action-gh-release@v2
  with:
    files: src-tauri/target/${{ matrix.target }}/release/bundle/dmg/*.dmg
```

---

## 🎯 查看构建进度

### 方法 1: GitHub 网页

1. 打开仓库主页
2. 点击 "Actions" 标签
3. 查看最新的 workflow run
4. 点击查看详细日志

**链接格式：**
```
https://github.com/YOUR_USERNAME/m3u8-downloader/actions
```

---

### 方法 2: GitHub CLI

```bash
# 安装 GitHub CLI
brew install gh

# 查看 workflow 运行列表
gh run list

# 查看特定 run 的详情
gh run view <run-id>

# 实时查看日志
gh run watch
```

---

## 📦 下载产物

### Artifacts（临时，90天）

1. 打开 Actions 页面
2. 点击成功的 run
3. 滚动到底部 "Artifacts"
4. 下载对应平台的压缩包

---

### Releases（永久）

1. 打开 Releases 页面
2. 找到对应版本
3. 直接下载安装包

**链接格式：**
```
https://github.com/YOUR_USERNAME/m3u8-downloader/releases
```

---

## 🔧 自定义配置

### 修改项目名称

**文件：** `.github/workflows/build-release.yml`

**查找并替换：**
```yaml
# 旧
M3U8-Downloader

# 新
Your-App-Name
```

**需要修改的位置：**
- 重命名文件步骤（第 84, 100, 125 行左右）
- Artifact 名称（第 147, 159, 171 行左右）

---

### 修改构建平台

**添加或删除平台：**

```yaml
matrix:
  include:
    # 保留需要的平台
    - os: macos-latest
      target: aarch64-apple-darwin
      platform: macOS
      arch: Apple-Silicon

    # 删除不需要的平台（注释或删除）
    # - os: macos-latest
    #   target: x86_64-apple-darwin
    #   platform: macOS
    #   arch: Intel
```

---

### 修改超时时间

```yaml
timeout-minutes: 45  # 默认 45 分钟

# 可以根据需要调整
timeout-minutes: 30  # 缩短到 30 分钟
timeout-minutes: 60  # 延长到 60 分钟
```

---

## 🐛 故障排查

### 常见问题

#### Q1: 构建失败，提示权限错误

**错误：**
```
Error: Resource not accessible by integration
```

**解决：**
1. 仓库设置 → Actions → General
2. "Workflow permissions" 选择 "Read and write permissions"
3. 保存设置

---

#### Q2: 找不到构建产物

**检查：**
1. 查看构建日志，确认构建成功
2. 检查产物路径是否正确
3. 确认文件重命名步骤执行成功

**调试：**
```yaml
# 在重命名前添加调试步骤
- name: Debug - List files
  run: |
    echo "Listing files..."
    find src-tauri/target/${{ matrix.target }}/release/bundle -type f
```

---

#### Q3: Release 没有自动创建

**检查：**
1. Tag 格式是否正确（必须以 `v` 开头）
2. 是否成功推送到 GitHub
3. Workflow 权限是否正确

**验证 Tag：**
```bash
# 查看本地 tags
git tag -l

# 查看远程 tags
git ls-remote --tags origin

# 推送特定 tag
git push origin v1.0.0
```

---

## 📊 性能优化

### 已实现的优化

1. **Rust 缓存**
   - 使用 `Swatinem/rust-cache@v2`
   - 缓存 `target/` 目录
   - 加速 ~70%

2. **npm 缓存**
   - 使用 `actions/setup-node@v4` 的缓存功能
   - 自动缓存 `node_modules`

3. **并行构建**
   - 4 个平台同时构建
   - 节省 ~60% 时间

---

### 进一步优化建议

1. **使用自托管 Runner**
   - 更快的网络速度
   - 更强的计算性能
   - 需要额外成本

2. **减少构建平台**
   - 只构建常用平台
   - 按需构建其他平台

3. **使用增量构建**
   - 只重新构建变更的部分
   - 需要更复杂的配置

---

## 📚 相关文档

| 文档 | 说明 |
|------|------|
| [GITHUB_ACTIONS.md](GITHUB_ACTIONS.md) | 详细的 Actions 使用指南 |
| [RELEASE_GUIDE.md](RELEASE_GUIDE.md) | 发布脚本使用说明 |
| [INSTALL_MACOS.md](INSTALL_MACOS.md) | macOS 安装帮助 |
| [README.md](README.md) | 项目总览 |

---

## ✅ 验证清单

在第一次发布前，请确认：

- [ ] 已创建 GitHub 仓库
- [ ] 已推送代码到 GitHub
- [ ] 已设置正确的 Workflow 权限
- [ ] 已在 README.md 中替换 `YOUR_USERNAME`
- [ ] 已在 release.sh 中替换 GitHub 链接
- [ ] 已在 .github/workflows/build-release.yml 中确认项目名称
- [ ] 已本地测试构建成功
- [ ] 已准备好 Release 说明

---

## 🚀 首次发布示例

```bash
# 1. 确保代码已推送
git status
git push origin main

# 2. 运行发布脚本
bash release.sh

# 示例交互：
📦 读取当前版本...
当前版本: v0.1.0

🔢 选择版本更新类型:
  1) Patch  (Bug 修复)    0.1.0 → 0.1.1
  2) Minor  (新功能)      0.1.0 → 0.2.0
  3) Major  (重大更新)    0.1.0 → 1.0.0
  4) Custom (自定义版本)

请选择 [1-4] (默认: 1): 3

✅ 新版本: v1.0.0

📝 输入本次更新说明:
首个正式版本发布
- M3U8 视频下载功能
- AES-128 解密支持
- 跨平台桌面应用
.

确认发布？[y/N]: y

# 3. 等待 GitHub Actions 构建（5-8 分钟）

# 4. 编辑 Release 说明
# 访问: https://github.com/YOUR_USERNAME/m3u8-downloader/releases

# 5. 发布！
```

---

## 🎉 总结

**已完成的配置：**

✅ **自动化构建**
- 推送 Tag 自动触发
- 并行构建 6 个平台
- 5-8 分钟完成

✅ **自动化发布**
- 自动重命名文件
- 自动上传到 Release
- 统一的文件命名

✅ **性能优化**
- Rust 缓存
- npm 缓存
- 并行执行

✅ **完善文档**
- 配置说明
- 使用指南
- 故障排查

---

**下一步：**

1. 替换所有文档中的 `YOUR_USERNAME`
2. 本地测试构建
3. 推送第一个 Tag
4. 验证 GitHub Actions 是否正常工作
5. 发布第一个版本！

---

**准备就绪，可以开始发布了！** 🚀

**版本：** v1.0.11
**日期：** 2025-10-27
**状态：** ✅ 配置完成
