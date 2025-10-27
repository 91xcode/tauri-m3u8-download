# 🐛 生产环境下载失败问题排查

## 问题描述

- **开发环境 (npm run tauri dev):** ✅ 下载正常
- **生产环境 (打包后的 .app/.dmg):** ❌ 下载失败

**测试链接：**
```
https://upyun.luckly-mjw.cn/Assets/media-source/example/media/index.m3u8
```

---

## 🔍 可能的原因

### 1. 控制台权限 (Console/DevTools)

**问题：** 生产环境默认禁用开发者工具，无法查看错误日志

**解决方案 1: 临时启用开发者工具**

编辑 `src-tauri/tauri.conf.json`：

```json
{
  "app": {
    "windows": [
      {
        "devtools": true  // 添加这一行
      }
    ]
  }
}
```

然后重新构建：
```bash
npm run tauri build
```

**在应用中打开开发者工具：**
- macOS: `Cmd + Option + I`
- Windows: `Ctrl + Shift + I`
- 或右键点击页面 → "检查元素"

---

### 2. HTTP 权限范围问题

**问题：** 生产环境的 HTTP 权限可能没有正确配置

**检查 `src-tauri/capabilities/default.json`：**

```bash
cat src-tauri/capabilities/default.json
```

**确保包含正确的 HTTP 权限：**

```json
{
  "permissions": [
    {
      "identifier": "http:default",
      "allow": [
        { "url": "https://**" },
        { "url": "http://**" }
      ]
    }
  ]
}
```

---

### 3. 资源加载路径问题

**问题：** 生产环境的资源路径与开发环境不同

**检查 `index.html` 中的资源引用：**

```bash
grep -n 'src=' src/index.html | head -10
```

**确保使用相对路径（不要以 / 开头）：**

```html
<!-- ✅ 正确 -->
<script src="vue.js"></script>
<script src="aes-decryptor.js"></script>

<!-- ❌ 错误 -->
<script src="/vue.js"></script>
<script src="/aes-decryptor.js"></script>
```

---

### 4. CSP (Content Security Policy) 问题

**问题：** 即使设置了 `csp: null`，某些平台仍可能有限制

**当前配置：**
```json
{
  "app": {
    "security": {
      "csp": null
    }
  }
}
```

**如果还是有问题，尝试明确配置：**

```json
{
  "app": {
    "security": {
      "csp": "default-src 'self' https: http: data: blob:; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'"
    }
  }
}
```

---

### 5. Service Worker 在生产环境不可用

**问题：** macOS 的 WKWebView 可能不支持 Service Worker

**检查方法：**

在打包的应用中，打开开发者工具，运行：

```javascript
console.log('Service Worker 支持:', 'serviceWorker' in navigator);
console.log('Secure Context:', window.isSecureContext);
```

**如果 Service Worker 不支持：**
- StreamSaver 会自动降级到 Blob 模式（应该已经实现）
- 检查 `stream-saver.js` 的降级逻辑

---

## 🛠️ 详细排查步骤

### 步骤 1: 启用开发者工具

1. **编辑配置文件**

```bash
cd /Users/sai/good_tool/xxxxx/m3u8-downloader
```

编辑 `src-tauri/tauri.conf.json`：

```json
{
  "app": {
    "windows": [
      {
        "title": "M3U8 视频下载器",
        "width": 1200,
        "height": 900,
        "resizable": true,
        "center": true,
        "fullscreen": false,
        "devtools": true  // 添加这一行
      }
    ]
  }
}
```

2. **重新构建**

```bash
npm run tauri build
```

3. **打开应用，按 Cmd + Option + I**

4. **查看 Console 标签的错误信息**

---

### 步骤 2: 检查网络请求

在开发者工具中：

1. **切换到 Network 标签**
2. **尝试下载 M3U8**
3. **查看失败的请求**
4. **点击失败的请求，查看详细信息**

**常见错误：**
- `net::ERR_BLOCKED_BY_CLIENT` - 被权限阻止
- `CORS error` - CORS 问题
- `404 Not Found` - 资源路径错误
- `net::ERR_CERT_AUTHORITY_INVALID` - HTTPS 证书问题

---

### 步骤 3: 检查 HTTP 权限配置

```bash
cat src-tauri/capabilities/default.json
```

**应该看到：**

```json
{
  "identifier": "default",
  "description": "Capability for the main window",
  "windows": ["main"],
  "permissions": [
    "core:default",
    "shell:allow-open",
    {
      "identifier": "http:default",
      "allow": [
        { "url": "https://**" },
        { "url": "http://**" }
      ]
    },
    {
      "identifier": "dialog:allow-save",
      "allow": [
        {
          "path": "**"
        }
      ]
    },
    "dialog:allow-message",
    "dialog:allow-ask",
    "dialog:allow-confirm",
    {
      "identifier": "fs:allow-write-file",
      "allow": [
        {
          "path": "**"
        }
      ]
    }
  ]
}
```

**如果没有 HTTP 权限，添加：**

```json
{
  "identifier": "http:default",
  "allow": [
    { "url": "https://**" },
    { "url": "http://**" }
  ]
}
```

---

### 步骤 4: 检查 Tauri HTTP 插件

编辑 `src-tauri/src/lib.rs`：

```rust
#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_dialog::init())
        .plugin(tauri_plugin_fs::init())
        .plugin(tauri_plugin_http::init())  // 确保有这一行
        .plugin(tauri_plugin_shell::init())
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

---

### 步骤 5: 添加调试日志

在 `src/index.html` 中，找到 `tauriHttpRequest` 函数，添加更多日志：

```javascript
async tauriHttpRequest(url, type = 'text') {
  console.log('🌐 Tauri HTTP 请求:', url);
  console.log('📦 请求类型:', type);

  try {
    const { fetch, ResponseType } = window.__TAURI__.http;
    console.log('✅ Tauri HTTP 模块已加载');

    const response = await fetch(url, {
      method: 'GET',
      responseType: type === 'file' ? ResponseType.Binary : ResponseType.Text
    });

    console.log('📡 Tauri HTTP 响应:', {
      ok: response.ok,
      status: response.status,
      dataType: typeof response.data,
      dataLength: response.data?.length || 0
    });

    if (response.ok) {
      if (type === 'file') {
        // Binary data
        return response.data;
      } else {
        // Text data
        if (typeof response.data === 'string') {
          console.log('✅ 返回字符串数据, 长度:', response.data.length);
          return response.data;
        } else if (response.data instanceof Uint8Array) {
          const decoder = new TextDecoder('utf-8');
          const text = decoder.decode(response.data);
          console.log('✅ Uint8Array 转换为字符串, 长度:', text.length);
          return text;
        } else {
          console.error('❌ 意外的数据类型:', typeof response.data);
          return String(response.data || '');
        }
      }
    } else {
      throw new Error(`HTTP ${response.status}`);
    }
  } catch (error) {
    console.error('❌ Tauri HTTP 请求失败:', error);
    throw error;
  }
}
```

---

### 步骤 6: 测试 XMLHttpRequest 降级

确保 XMLHttpRequest 降级逻辑正常工作：

```javascript
ajax(options) {
  console.log('🌐 开始 AJAX 请求:', options.url);

  let xhr = new XMLHttpRequest()
  xhr.timeout = options.timeout || 60000
  xhr.open(options.type || 'GET', options.url, true)

  if (options.dataType === 'arraybuffer') {
    xhr.responseType = 'arraybuffer'
  }

  xhr.onload = function () {
    console.log('✅ XMLHttpRequest 成功:', {
      status: xhr.status,
      responseType: xhr.responseType,
      dataLength: xhr.response?.length || xhr.response?.byteLength || 0
    });

    if (xhr.status >= 200 && xhr.status < 300) {
      options.success && options.success(xhr.response)
    } else {
      console.error('❌ XMLHttpRequest HTTP 错误:', xhr.status);
      options.fail && options.fail(xhr.status)
    }
  }.bind(this)

  xhr.onerror = function () {
    console.error('❌ XMLHttpRequest 网络错误, URL:', options.url);

    // 🔥 降级到 Tauri HTTP
    if (this.hasTauriHttp()) {
      console.log('🔄 尝试使用 Tauri HTTP 客户端重试...');
      this.tauriAjax(options);
    } else {
      console.error('❌ Tauri HTTP 不可用');
      options.fail && options.fail(0);
    }
  }.bind(this)

  xhr.send()
}
```

---

## 🔧 快速修复方案

### 方案 1: 确保开发者工具可用（临时）

```bash
# 编辑 tauri.conf.json
cat > src-tauri/tauri.conf.json.patch << 'EOF'
{
  "app": {
    "windows": [
      {
        "devtools": true
      }
    ]
  }
}
EOF

# 重新构建
npm run tauri build
```

---

### 方案 2: 完整的权限配置

编辑 `src-tauri/capabilities/default.json`，确保包含所有必要权限：

```json
{
  "identifier": "default",
  "description": "Capability for the main window",
  "windows": ["main"],
  "permissions": [
    "core:default",
    "shell:allow-open",
    {
      "identifier": "http:default",
      "allow": [
        { "url": "https://**" },
        { "url": "http://**" }
      ]
    },
    {
      "identifier": "dialog:allow-save",
      "allow": [{ "path": "**" }]
    },
    "dialog:allow-message",
    "dialog:allow-ask",
    "dialog:allow-confirm",
    {
      "identifier": "fs:allow-write-file",
      "allow": [{ "path": "**" }]
    }
  ]
}
```

---

### 方案 3: 使用系统控制台查看日志

macOS 上可以使用系统控制台查看应用日志：

```bash
# 打开系统控制台
open /Applications/Utilities/Console.app

# 或使用命令行
log stream --predicate 'process == "M3U8 Downloader"' --level debug
```

在另一个终端运行你的应用，系统控制台会显示所有日志。

---

## 📋 完整的修复流程

```bash
# 1. 启用开发者工具
# 编辑 src-tauri/tauri.conf.json，添加 "devtools": true

# 2. 重新构建
npm run tauri build

# 3. 安装并运行
open src-tauri/target/release/bundle/dmg/*.dmg

# 4. 打开开发者工具
# Cmd + Option + I

# 5. 尝试下载，查看控制台错误

# 6. 根据错误修复相应的配置

# 7. 重新构建测试
```

---

## 🎯 最可能的问题

基于你的描述，最可能的问题是：

1. **HTTP 权限未正确应用到生产环境**
   - 检查 `capabilities/default.json`
   - 确保 HTTP scope 包含目标 URL

2. **Tauri HTTP 插件未正确初始化**
   - 检查 `src-tauri/src/lib.rs`
   - 确保调用了 `.plugin(tauri_plugin_http::init())`

3. **开发环境和生产环境的 URL 处理不同**
   - 开发环境可能使用了不同的代码路径
   - 检查 `hasTauriHttp()` 函数的判断逻辑

---

## 💡 立即可以尝试的

**步骤 1:** 启用开发者工具并查看错误

**步骤 2:** 提供以下信息：
- 控制台的完整错误信息
- Network 标签中失败的请求详情
- 应用是否能检测到 `window.__TAURI__`

这样我可以更准确地帮你定位问题！

---

**需要更多帮助，请提供：**
1. 打包应用的控制台日志
2. 具体的错误信息
3. Network 请求失败的详情

---

**版本：** v1.0.0
**日期：** 2025-10-27
