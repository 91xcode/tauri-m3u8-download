# 🔧 GitHub Actions 故障排查

## 问题：推送 Tag 后 Actions 没有触发

如果你已经配置了 `.github/workflows/build-release.yml`，但推送 Tag 后 GitHub Actions 没有自动构建，请按以下步骤排查：

---

## ✅ 检查清单

### 1. 确认 Tag 已推送到 GitHub

```bash
# 查看本地 tags
git tag -l

# 查看远程 tags
git ls-remote --tags origin

# 应该能看到你推送的 tag，如：
# refs/tags/v2.0.0
```

**如果远程没有 tag：**
```bash
# 手动推送 tag
git push origin v2.0.0
```

---

### 2. 确认 `.github/workflows/` 文件已推送

```bash
# 检查远程仓库中是否有 workflows 文件
git ls-remote --heads origin
git ls-tree -r origin/main --name-only | grep .github/workflows
```

**如果没有：**
```bash
# 确保 .github 文件夹已提交
git add .github/
git commit -m "feat: 添加 GitHub Actions 配置"
git push origin main
```

---

### 3. 检查 GitHub Actions 权限

1. **打开 GitHub 仓库页面**
   ```
   https://github.com/91xcode/tauri-m3u8-download
   ```

2. **进入设置**
   - 点击 **Settings（设置）**

3. **配置 Actions 权限**
   - 左侧菜单：**Actions** → **General**
   - 找到 **"Workflow permissions"**
   - 选择：**Read and write permissions** ✅
   - 勾选：**Allow GitHub Actions to create and approve pull requests** ✅
   - 点击 **Save（保存）**

**截图示例：**
```
┌──────────────────────────────────────────┐
│  Workflow permissions                    │
├──────────────────────────────────────────┤
│  ● Read and write permissions  ← 选这个   │
│  ○ Read repository contents and          │
│    packages permissions                  │
│                                          │
│  ✅ Allow GitHub Actions to create and   │
│     approve pull requests                │
└──────────────────────────────────────────┘
```

---

### 4. 检查 Workflow 文件格式

**查看文件内容：**
```bash
cat .github/workflows/build-release.yml
```

**确认触发条件：**
```yaml
on:
  push:
    tags:
      - 'v*'        # 确保这一行存在
  workflow_dispatch:
```

**确认 YAML 格式正确：**
- 使用空格缩进（不是 Tab）
- 每级缩进 2 个空格
- 冒号后有空格

---

### 5. 检查 Tag 格式

**GitHub Actions 只会在 tag 匹配 `v*` 时触发：**

✅ **正确格式：**
```bash
v1.0.0
v2.0.0
v1.2.3-beta
```

❌ **错误格式：**
```bash
1.0.0        # 缺少 v 前缀
release-1.0  # 不以 v 开头
```

**验证 tag 格式：**
```bash
git tag -l
# 应该看到 v2.0.0，而不是 2.0.0
```

---

### 6. 查看 GitHub Actions 页面

1. **打开 Actions 页面**
   ```
   https://github.com/91xcode/tauri-m3u8-download/actions
   ```

2. **检查是否有 workflow 运行记录**
   - 如果完全没有记录 → 说明 workflow 文件未正确推送或未启用
   - 如果有失败记录 → 点击查看详细日志

3. **检查 workflow 是否启用**
   - 在 Actions 页面，左侧应该能看到 "Build Release"
   - 如果显示为禁用状态，点击启用

---

## 🔍 详细排查步骤

### 步骤 1: 验证文件是否在 GitHub 上

访问：
```
https://github.com/91xcode/tauri-m3u8-download/tree/main/.github/workflows
```

应该能看到 `build-release.yml` 文件。

**如果看不到：**
```bash
# 检查文件是否已提交
git status

# 如果未提交
git add .github/
git commit -m "feat: 添加 GitHub Actions 配置"

# 推送到 GitHub
git push origin main
```

---

### 步骤 2: 手动触发 Workflow

1. **打开 Actions 页面**
   ```
   https://github.com/91xcode/tauri-m3u8-download/actions
   ```

2. **选择 "Build Release" workflow**
   - 左侧菜单应该能看到

3. **点击 "Run workflow" 按钮**
   - 如果能看到这个按钮，说明 workflow 文件已正确识别

4. **选择分支（main）**

5. **点击绿色 "Run workflow" 按钮**

6. **查看是否开始执行**

---

### 步骤 3: 检查推送历史

```bash
# 查看推送历史
git log --oneline --graph --all

# 查看最近的推送
git reflog

# 确认 tag 和 main 分支都已推送
git ls-remote origin
```

---

## 🐛 常见问题和解决方案

### Q1: Actions 页面显示 "No workflows"

**原因：**
- workflow 文件未推送到 GitHub
- workflow 文件路径或名称错误
- YAML 格式错误

**解决：**
```bash
# 1. 确认文件路径正确
ls -la .github/workflows/build-release.yml

# 2. 检查 YAML 格式
cat .github/workflows/build-release.yml | head -20

# 3. 推送到 GitHub
git add .github/
git commit -m "fix: 修复 GitHub Actions 配置"
git push origin main

# 4. 等待几秒钟，刷新 GitHub Actions 页面
```

---

### Q2: 推送 Tag 后没有任何反应

**可能原因：**

1. **Tag 格式不正确**
   ```bash
   # 检查 tag
   git tag -l

   # 如果是 "2.0.0" 而不是 "v2.0.0"
   git tag -d 2.0.0
   git tag v2.0.0
   git push origin v2.0.0 --force
   ```

2. **Tag 没有推送到远程**
   ```bash
   # 检查远程 tags
   git ls-remote --tags origin

   # 如果没有，推送
   git push origin v2.0.0
   ```

3. **权限未设置**
   - 参考上面的"检查 GitHub Actions 权限"

---

### Q3: Actions 显示 "Resource not accessible by integration"

**原因：** Workflow 权限不足

**解决：**
1. 仓库设置 → Actions → General
2. Workflow permissions 选择 "Read and write permissions"
3. 保存设置
4. 删除并重新推送 tag：
   ```bash
   git tag -d v2.0.0
   git push origin :refs/tags/v2.0.0
   git tag v2.0.0
   git push origin v2.0.0
   ```

---

### Q4: Workflow 文件有语法错误

**检查语法：**

使用在线工具验证 YAML：
```
https://www.yamllint.com/
```

或使用命令行工具：
```bash
# 安装 yamllint
brew install yamllint

# 检查语法
yamllint .github/workflows/build-release.yml
```

---

## 🚀 完整的重新推送流程

如果以上都检查过了还是不行，尝试完整的重新推送：

```bash
# 1. 确保 .github 文件已提交
git add .github/
git status

# 2. 提交（如果有更改）
git commit -m "fix: 确保 GitHub Actions 配置正确"

# 3. 推送 main 分支
git push origin main

# 4. 删除本地和远程的旧 tag
git tag -d v2.0.0
git push origin :refs/tags/v2.0.0

# 5. 重新创建 tag
git tag -a v2.0.0 -m "Release v2.0.0"

# 6. 推送新 tag
git push origin v2.0.0

# 7. 立即访问 Actions 页面
open https://github.com/91xcode/tauri-m3u8-download/actions
```

**预期结果：**
- 应该能看到新的 workflow run 出现
- 状态为黄色圆圈（进行中）或绿色勾号（成功）

---

## 📊 验证 Actions 是否正常工作

### 方法 1: 手动触发测试

1. GitHub Actions 页面 → Build Release
2. 点击 "Run workflow"
3. 选择 main 分支
4. 点击 "Run workflow"
5. 观察是否开始执行

**如果能手动触发成功：**
- 说明 workflow 配置正确
- 问题在于 tag 触发条件

**如果手动触发失败：**
- 查看错误日志
- 检查权限设置

---

### 方法 2: 查看 Workflow 历史

```bash
# 使用 GitHub CLI
gh run list

# 查看特定 run 的详情
gh run view <run-id>
```

---

## 🎯 最终检查

运行以下命令，确保一切正常：

```bash
# 1. 检查远程仓库
git remote -v
# 应该显示：
# origin  git@github.com:91xcode/tauri-m3u8-download.git

# 2. 检查 workflow 文件
ls -la .github/workflows/build-release.yml
# 应该存在

# 3. 检查文件内容
head -10 .github/workflows/build-release.yml
# 应该以 "name: Build Release" 开头

# 4. 检查远程 tags
git ls-remote --tags origin
# 应该能看到 v2.0.0

# 5. 检查远程 main 分支是否有 .github
git ls-tree -r origin/main --name-only | grep .github
# 应该能看到 .github/workflows/build-release.yml
```

---

## 💡 使用 GitHub CLI 调试

```bash
# 安装 GitHub CLI（如果还没安装）
brew install gh

# 登录
gh auth login

# 查看 workflow 列表
gh workflow list

# 应该能看到：
# Build Release  active  12345

# 查看最近的 runs
gh run list

# 查看特定 workflow 的 runs
gh run list --workflow=build-release.yml

# 手动触发 workflow
gh workflow run build-release.yml

# 查看实时日志
gh run watch
```

---

## 📞 还是不行？

如果以上所有步骤都尝试过了还是不行，请检查：

1. **GitHub 服务状态**
   ```
   https://www.githubstatus.com/
   ```

2. **仓库是否是私有的**
   - 私有仓库的 Actions 有使用限额
   - 检查：Settings → Billing → Actions

3. **账户是否有 Actions 权限**
   - 某些组织账户可能禁用了 Actions

4. **创建 Issue**
   ```
   https://github.com/91xcode/tauri-m3u8-download/issues
   ```

---

## 🎉 成功的标志

当一切正常时，你应该看到：

1. **Actions 页面有运行记录**
   ```
   https://github.com/91xcode/tauri-m3u8-download/actions
   ```

2. **运行状态**
   - 🟡 黄色圆圈 = 进行中
   - ✅ 绿色勾号 = 成功
   - ❌ 红色叉号 = 失败

3. **构建时间**
   - 约 5-8 分钟

4. **Release 自动创建**
   ```
   https://github.com/91xcode/tauri-m3u8-download/releases
   ```

5. **6 个产物文件上传**
   - macOS (Apple Silicon + Intel)
   - Windows (MSI + EXE)
   - Linux (DEB + AppImage)

---

**祝你成功！** 🚀

如果还有问题，请查看详细的构建日志或提交 Issue。
