# 自我优化备忘录

## 测试流程规范（防浪费）

### 1. 改代码 → 测试 → 重启 → 验证

```
改代码 → 编译检查（node --check） →  杀掉旧进程 → 启动新服务 → 测试 → 通知用户
```

每次改动后**必做**：
```bash
# 1. 确认端口空闲
$thePid = (Get-NetTCPConnection -LocalPort 3456 -ErrorAction SilentlyContinue).OwningProcess | Where-Object { $_ -is [int] -and $_ -gt 0 }
if ($thePid) { Stop-Process -Id $thePid -Force }

# 2. 确认编译通过
node --check server.js

# 3. 启动
$env:NODE_PATH = "workspace\node_modules"
Start-Process -NoNewWindow node server.js

# 4. 验证功能可用
node test-script.js
```

**绝对禁止：**
- ❌ 用 `Start-Process` 启动新服务却不杀旧进程
- ❌ 测试代码不写在文件里而用 `node -e "中文"`（PowerShell 编码损坏）
- ❌ `Get-Process -Name "node" | Stop-Process`（自杀指令）
- ❌ `node -e` 内联执行含中文的代码

### 2. 文件损坏时及时止损

文件被错误编码写入后，**不要试图逐字节修复**。正确的做法：
1. 检查 git 是否有未改动的版本（`git checkout -- file`）
2. 检查是否有备份（`.corrupted` 等）
3. 从用户发的原包恢复
4. 重做改动（比修复快 10 倍）

### 3. 测试请求必须用文件，不用内联

```javascript
// ✅ 正确：写文件再执行
write → test.js → node test.js

// ❌ 错误：内联执行
node -e "代码中含中文"    ← PowerShell 会损坏编码
```

### 4. 用户体验自查清单

每个功能上线前检查：
- [ ] 操作后页面会不会跳回顶端？
- [ ] 要不要用 AJAX 避免整页刷新？
- [ ] 跳转到页面特定位置有没有锚点或自动滚动？
- [ ] 新启动的服务是否确保旧进程已死？
- [ ] 提交前是否重启服务验证过？
- [ ] 提交后是否通知用户刷新？

## 编码工具使用

```bash
# 一键修复项目所有文件的编码
node scripts/encoding-tool.js fix-all
```

## 本次积累的教训

1. **旧进程堆积是最大的隐形杀手** — 每次测试前先检查端口
2. **停止用 `node -e` 写中文** — 写文件再执行
3. **PowerShell 的编码陷阱** — 不经过 PS 直接写 UTF-8 文件
4. **用户体验从第一次操作开始** — 不是功能做完了再优化

## 开工前必读

每次改代码前先读一遍：
1. `CLAUDE.md` — 通用编码守则（Think First / Simplicity / Surgical / Goal-Driven）
2. `memory/self-improvement.md` — 之前踩过的坑
3. `memory/UX-principles.md` — 用户体验设计原则

**5 分钟前置阅读，省 5 小时返工。**
