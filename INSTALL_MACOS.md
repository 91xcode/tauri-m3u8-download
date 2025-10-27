# 🍎 macOS 安装指南

## 下载与安装

### 1. 下载安装包

从 [Releases](https://github.com/YOUR_USERNAME/m3u8-downloader/releases) 页面下载对应您 Mac 的版本：

- **Apple Silicon (M1/M2/M3)**: `M3U8-Downloader-vX.X.X-macOS-Apple-Silicon.dmg`
- **Intel**: `M3U8-Downloader-vX.X.X-macOS-Intel.dmg`

### 2. 安装应用

1. 双击下载的 `.dmg` 文件
2. 将 `M3U8 Downloader.app` 拖拽到 `Applications` 文件夹
3. 弹出 DMG 镜像

---

## ⚠️ 首次打开遇到安全提示

由于应用未在 App Store 发布，macOS 会显示安全提示。

### 方法 1: 通过系统设置允许（简单）

**步骤：**

1. **首次打开应用时**，会弹出提示：
   ```
   "M3U8 Downloader.app" 无法打开，因为无法验证开发者。
   ```
   点击 **"好"** 关闭提示

2. **打开系统设置**
   - macOS Ventura 及更高版本：`系统设置` → `隐私与安全性`
   - macOS Monterey 及更低版本：`系统偏好设置` → `安全性与隐私`

3. **在"安全性与隐私"页面**，找到：
   ```
   "M3U8 Downloader.app" 已被阻止使用，因为来自身份不明的开发者。
   ```
   点击 **"仍要打开"** 按钮

4. **再次确认**
   - 在弹出的对话框中，点击 **"打开"**
   - 应用成功启动！✅

**截图示例：**

```
┌──────────────────────────────────────────┐
│  隐私与安全性                            │
├──────────────────────────────────────────┤
│  "M3U8 Downloader.app" 已被阻止使用，     │
│  因为来自身份不明的开发者。              │
│                                          │
│            [仍要打开] ← 点击这里         │
└──────────────────────────────────────────┘
```

---

### 方法 2: 移除隔离属性（推荐，一劳永逸）

**优点：**
- ✅ 一次操作，永久生效
- ✅ 无需每次都去系统设置
- ✅ 适用于经常使用的应用

**步骤：**

1. **打开终端（Terminal）**
   - 按 `Cmd + 空格`，搜索 `终端` 或 `Terminal`
   - 或从 `应用程序` → `实用工具` → `终端`

2. **执行以下命令：**

   ```bash
   sudo xattr -cr /Applications/M3U8\ Downloader.app
   ```

3. **输入 Mac 登录密码**
   - 输入时不会显示任何字符（这是正常的）
   - 输入完成后按 `回车`

4. **完成！**
   - 现在双击应用即可正常打开
   - 不再有任何安全提示 ✅

**命令详解：**

```bash
sudo xattr -cr /Applications/M3U8\ Downloader.app
│    │     │  └─ 应用路径
│    │     └─ 递归处理（所有文件）
│    └─ 清除扩展属性
└─ 管理员权限
```

**注意事项：**
- `\` 是转义字符，因为应用名称中有空格
- 如果应用不在 Applications 文件夹，需要修改路径

---

### 方法 3: 右键菜单打开（临时）

**步骤：**

1. 在 Finder 中找到 `M3U8 Downloader.app`
2. 按住 `Control` 键并点击应用图标（或右键点击）
3. 在菜单中选择 **"打开"**
4. 在弹出对话框中点击 **"打开"**

**缺点：**
- ⚠️ 只对当次打开有效
- ⚠️ 下次还需要重复操作

---

## 常见问题

### Q1: 为什么会有安全提示？

**A:** 因为应用没有通过 Apple 的公证（Notarization）流程。

**公证需要：**
- Apple 开发者账号（$99/年）
- 应用签名
- 提交到 Apple 服务器验证

对于开源项目，使用上述方法 2（移除隔离属性）是最便捷的解决方案。

---

### Q2: 移除隔离属性安全吗？

**A:** 是安全的，前提是您信任应用来源。

**建议：**
- ✅ 从官方 GitHub Releases 下载
- ✅ 验证文件完整性（如提供 checksum）
- ✅ 开源项目可以查看源代码

**`xattr -cr` 命令只是移除 macOS 的隔离标记，不会修改应用本身。**

---

### Q3: 执行命令后还是无法打开？

**A:** 尝试以下步骤：

1. **检查应用路径是否正确**
   ```bash
   ls -la /Applications/M3U8\ Downloader.app
   ```
   如果显示 "No such file or directory"，说明路径错误

2. **检查应用权限**
   ```bash
   ls -ld /Applications/M3U8\ Downloader.app
   ```
   应该显示类似：`drwxr-xr-x`

3. **重新安装应用**
   - 删除旧的应用
   - 重新从 DMG 拖拽安装
   - 再次执行 `xattr -cr` 命令

4. **查看系统日志**
   ```bash
   sudo log show --predicate 'process == "M3U8 Downloader"' --last 5m
   ```

---

### Q4: 如何验证隔离属性已移除？

**A:** 使用以下命令检查：

```bash
xattr /Applications/M3U8\ Downloader.app
```

**移除前：**
```
com.apple.quarantine
```

**移除后：**
```
(无输出或不包含 com.apple.quarantine)
```

---

### Q5: 应用安装在其他位置怎么办？

**A:** 修改路径即可。

**示例：**

```bash
# 安装在下载文件夹
sudo xattr -cr ~/Downloads/M3U8\ Downloader.app

# 安装在桌面
sudo xattr -cr ~/Desktop/M3U8\ Downloader.app

# 安装在自定义位置
sudo xattr -cr /path/to/M3U8\ Downloader.app
```

**提示：** 可以直接拖拽应用到终端窗口，自动填充完整路径：

```bash
sudo xattr -cr   # 输入到这里，然后拖拽应用图标到终端
```

---

## 卸载应用

### 完全卸载

```bash
# 1. 删除应用
sudo rm -rf /Applications/M3U8\ Downloader.app

# 2. 删除应用数据（可选）
rm -rf ~/Library/Application\ Support/com.m3u8-downloader.*
rm -rf ~/Library/Preferences/com.m3u8-downloader.*
rm -rf ~/Library/Caches/com.m3u8-downloader.*
```

---

## 更新应用

### 方法 1: 覆盖安装

1. 下载新版本的 DMG
2. 双击打开
3. 将新的 `M3U8 Downloader.app` 拖拽到 `Applications`，选择 **"替换"**
4. 如果之前执行过 `xattr -cr`，可能需要再次执行

### 方法 2: 删除后重新安装

```bash
# 1. 删除旧版本
sudo rm -rf /Applications/M3U8\ Downloader.app

# 2. 安装新版本（从 DMG 拖拽）

# 3. 移除隔离属性
sudo xattr -cr /Applications/M3U8\ Downloader.app
```

---

## 快速参考

### 一键安装命令（适合熟悉终端的用户）

```bash
# 安装后直接移除隔离属性
sudo xattr -cr /Applications/M3U8\ Downloader.app && open /Applications/M3U8\ Downloader.app
```

**效果：**
- 移除隔离属性
- 立即打开应用

---

### 检查应用信息

```bash
# 查看应用版本
/Applications/M3U8\ Downloader.app/Contents/MacOS/m3u8-downloader --version

# 查看应用签名信息
codesign -dv /Applications/M3U8\ Downloader.app

# 查看应用架构（Intel/Apple Silicon）
lipo -info /Applications/M3U8\ Downloader.app/Contents/MacOS/m3u8-downloader
```

---

## 总结

**推荐安装流程：**

```bash
# 1. 下载 DMG 并安装（拖拽到 Applications）

# 2. 移除隔离属性（一劳永逸）
sudo xattr -cr /Applications/M3U8\ Downloader.app

# 3. 打开应用
open /Applications/M3U8\ Downloader.app
```

**或使用 GUI 方式：**

```
1. 安装应用（拖拽到 Applications）
2. 双击打开 → 看到安全提示
3. 系统设置 → 隐私与安全性 → 仍要打开
4. 确认打开
```

---

**如有问题，请在 GitHub Issues 中反馈！**

**项目地址：** https://github.com/YOUR_USERNAME/m3u8-downloader

---

**版本：** v1.0.10
**日期：** 2025-10-27
**适用于：** macOS 10.15 (Catalina) 及更高版本
