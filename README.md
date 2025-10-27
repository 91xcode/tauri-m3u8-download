# 🎬 M3U8 Downloader

[![Build Release](https://github.com/YOUR_USERNAME/m3u8-downloader/actions/workflows/build-release.yml/badge.svg)](https://github.com/YOUR_USERNAME/m3u8-downloader/actions/workflows/build-release.yml)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Windows%20%7C%20Linux-lightgrey.svg)](https://github.com/YOUR_USERNAME/m3u8-downloader/releases)

> 基于 Tauri 的跨平台 M3U8 视频下载工具

一个功能强大的桌面应用，支持下载和转码 M3U8 格式的在线视频流。

---

## ✨ 主要功能

- 🎥 **M3U8 视频下载** - 支持原格式下载和 MP4 转码
- 🔒 **AES-128 解密** - 自动检测和解密加密视频
- 💾 **流式下载** - 支持大文件边下载边保存
- 🖥️ **原生体验** - 使用系统原生文件保存对话框
- 🌐 **CORS 处理** - 智能绕过跨域限制
- 🚀 **多线程下载** - 6 线程并发下载，速度更快
- ⏸️ **暂停/恢复** - 支持暂停和恢复下载
- 📊 **实时进度** - 详细的下载进度显示
- 🔄 **错误重试** - 自动重试失败的片段

---

## 📦 下载安装

### 最新版本

👉 [前往 Releases 页面下载](https://github.com/YOUR_USERNAME/m3u8-downloader/releases)

### 支持平台

| 平台 | 架构 | 文件格式 | 说明 |
|------|------|----------|------|
| **macOS** | Apple Silicon (M1/M2/M3) | `.dmg` | 适用于搭载 Apple 芯片的 Mac |
| **macOS** | Intel | `.dmg` | 适用于 Intel 处理器的 Mac |
| **Windows** | x64 | `.msi` / `.exe` | Windows 10/11 64 位 |
| **Linux** | x64 | `.deb` / `.AppImage` | Debian/Ubuntu 或通用版本 |

---

## 🚀 快速开始

### macOS

1. 下载对应架构的 `.dmg` 文件
2. 双击打开，拖拽到 `Applications` 文件夹
3. 首次打开如遇到安全提示，请参考 [macOS 安装指南](INSTALL_MACOS.md)

**快速解决方案（推荐）：**
```bash
sudo xattr -cr /Applications/M3U8\ Downloader.app
```

### Windows

1. 下载 `.msi` 或 `.exe` 文件
2. 双击运行安装程序
3. 按照向导完成安装

### Linux

**Debian/Ubuntu (.deb):**
```bash
sudo dpkg -i M3U8-Downloader-v*.deb
```

**通用版本 (.AppImage):**
```bash
chmod +x M3U8-Downloader-v*.AppImage
./M3U8-Downloader-v*.AppImage
```

---

## 📖 使用方法

1. **启动应用**
   - macOS: 从 Launchpad 或 Applications 文件夹启动
   - Windows: 从开始菜单启动
   - Linux: 从应用程序菜单启动

2. **输入 M3U8 链接**
   - 粘贴视频的 M3U8 播放列表链接

3. **选择下载方式**
   - **原格式下载** - 保持原始 .ts 格式
   - **转码为 MP4** - 转换为 MP4 格式（推荐）
   - **流式下载** - 适用于超大视频文件

4. **选择保存位置**
   - 系统会弹出原生文件保存对话框
   - 选择保存位置和文件名

5. **等待下载完成**
   - 查看实时进度
   - 支持暂停/恢复

---

## 🛠️ 技术栈

### 前端
- **框架**: Vue.js 2
- **语言**: JavaScript (ES6+)
- **样式**: CSS3

### 核心库
- **aes-decryptor.js** - AES-128 解密
- **mux.js** - MP4 封装和转码
- **StreamSaver.js** - 流式文件保存

### 后端
- **框架**: Tauri 2.0
- **语言**: Rust
- **平台**: 跨平台（macOS/Windows/Linux）

### 插件
- **tauri-plugin-http** - HTTP 请求（绕过 CORS）
- **tauri-plugin-dialog** - 原生文件对话框
- **tauri-plugin-fs** - 文件系统访问

---

## 🔧 开发指南

### 环境要求

- **Node.js**: 18.x 或更高版本
- **npm**: 9.x 或更高版本
- **Rust**: 1.70 或更高版本
- **操作系统**: macOS 10.15+, Windows 10+, Ubuntu 20.04+

### 本地开发

```bash
# 1. 克隆仓库
git clone https://github.com/YOUR_USERNAME/m3u8-downloader.git
cd m3u8-downloader

# 2. 安装依赖
npm install

# 3. 启动开发服务器
npm run tauri dev
```

### 构建应用

```bash
# 构建当前平台的应用
npm run tauri build

# 构建特定平台（macOS）
npm run tauri build -- --target aarch64-apple-darwin  # Apple Silicon
npm run tauri build -- --target x86_64-apple-darwin   # Intel

# 查看构建产物
ls -la src-tauri/target/release/bundle/
```

### 发布新版本

```bash
# 使用自动发布脚本
bash release.sh

# 选择版本类型（Patch/Minor/Major/Custom）
# 输入更新说明
# 确认发布

# GitHub Actions 会自动构建所有平台的安装包
```

详见：[发布指南](RELEASE_GUIDE.md)

---

## 📚 文档

- **[使用指南](使用指南.md)** - 详细的使用说明
- **[macOS 安装指南](INSTALL_MACOS.md)** - macOS 平台安装帮助
- **[发布指南](RELEASE_GUIDE.md)** - 版本发布流程
- **[GitHub Actions](GITHUB_ACTIONS.md)** - CI/CD 配置说明
- **[调试指南](DEBUG_GUIDE.md)** - 问题排查方法

---

## 🤝 贡献

欢迎贡献！请随时提交 Pull Request 或创建 Issue。

### 贡献步骤

1. Fork 本仓库
2. 创建您的特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交您的更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启一个 Pull Request

---

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

---

## 🙏 致谢

本项目基于原 M3U8 下载器项目，通过 Tauri 封装为跨平台桌面应用。

感谢以下开源项目：
- [Tauri](https://tauri.app/) - 跨平台应用框架
- [Vue.js](https://vuejs.org/) - 前端框架
- [mux.js](https://github.com/videojs/mux.js) - MP4 封装库
- [StreamSaver.js](https://github.com/jimmywarting/StreamSaver.js) - 流式保存库

---

## 📞 联系方式

- **Issue**: [GitHub Issues](https://github.com/YOUR_USERNAME/m3u8-downloader/issues)
- **Discussions**: [GitHub Discussions](https://github.com/YOUR_USERNAME/m3u8-downloader/discussions)

---

## 🎯 路线图

### v1.1.0（计划中）
- [ ] 下载队列管理
- [ ] 自定义请求头
- [ ] 代理设置
- [ ] 下载历史记录

### v1.2.0（计划中）
- [ ] 自动更新功能
- [ ] 系统托盘支持
- [ ] 快捷键支持
- [ ] 主题切换

### v2.0.0（长期）
- [ ] 多语言支持
- [ ] 插件系统
- [ ] 云端同步
- [ ] 移动端支持

---

## 📊 项目统计

![GitHub stars](https://img.shields.io/github/stars/YOUR_USERNAME/m3u8-downloader?style=social)
![GitHub forks](https://img.shields.io/github/forks/YOUR_USERNAME/m3u8-downloader?style=social)
![GitHub watchers](https://img.shields.io/github/watchers/YOUR_USERNAME/m3u8-downloader?style=social)

---

**⭐ 如果这个项目对您有帮助，请给个 Star！**

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/YOUR_USERNAME">YOUR_USERNAME</a>
</p>