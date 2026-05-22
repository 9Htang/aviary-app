# 鸟舍管理系统 - 用户体验设计原则

## 核心原则：操作后不跳页

一切操作（新增、编辑、删除）都应该**原地完成**，不整页刷新、不跳回顶端。

### 已落地的实现

| 操作 | 实现方式 | 状态 |
|---|---|---|
| 新增蛋 | fetch POST → 后端返回JSON → JS插入蛋卡片 | ✅ |
| 编辑蛋 | fetch POST → 后端返回JSON → JS替换蛋卡片 | ✅ |
| 删除蛋 | fetch POST → 后端返回JSON → JS移除蛋卡片 | ✅ |
| 新增一窝 | 表单提交（整页刷新不可避免，因为窝结构变化大） | ⚠️ 可接受 |

### 回退机制

AJAX 请求失败时自动回退到传统表单提交（`.catch(() => form.submit())`），保证功能可用性。

## 页面导航原则

### 锚点定位

跳转到页面特定位置时使用 `#event-{id}` 锚点：

- 新增/编辑/删除蛋后 → `#event-{breedingEventId}`
- 新增一窝后 → `#event-{newEventId}`
- 从鸟详情页跳转来源蛋 → `?highlight_egg={eggId}` + 自动 `scrollIntoView`

### 滚动优化

```javascript
// 高亮蛋时自动滚动并居中
document.querySelector('.egg-card.highlight')?.scrollIntoView({ 
  behavior: 'smooth', block: 'center' 
});

// 新增蛋后滚动到新蛋
grid.lastElementChild.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
```

## 服务端注意事项

### 端口管理

每次启动新服务前必须杀掉旧进程，否则新进程静默失败，用户看到的永远是旧代码：

```
restart.bat:
  netstat 查 3456 端口 → taskkill /F → timeout 2s → node server.js
```

### 多进程堆积的教训

测试过程中累计了 50+ 旧 node 进程，每次 `Start-Process` 新进程因端口被占静默失败，用户看到的始终是旧代码。

**以后每次改完代码重启服务的标准流程：** `restart.bat` 一步到位。

## AJAX 格式规范

### 请求

```
POST /pairing/{id}/egg/{eggId}     ← 编辑蛋
POST /pairing/{id}/event/{eid}/egg  ← 新增蛋
POST /pairing/{id}/egg/{eggId}/delete ← 删除蛋
```

头部: `X-Requested-With: XMLHttpRequest`

### 响应 (JSON)

```json
// 编辑蛋成功
{ "ok": true, "egg": { "id": 6, "egg_number": 1, ... } }

// 编辑蛋 + 出壳生鸟
{ "ok": true, "egg": { ... }, "offspring": [{ ... }] }

// 删除蛋成功
{ "ok": true, "deleted": 6 }

// 新增蛋成功
{ "ok": true, "egg": { "id": 19, ... } }
```

## 模板注意事项

### EJS 缓存

Express 5 + EJS 需要 `_with: true` 才能使模板变量直接可用：

```javascript
app.engine('ejs', function(filePath, options, callback) {
  options._with = true;
  ejs.renderFile(filePath, options, callback);
});
```

否则模板中 `locals.variableName` 才能访问到数据。

### 蛋卡片 HTML（JS 端渲染）

`renderEggCard(egg)` 函数在 pairing.ejs 中维护，与 EJS 模板里的蛋卡片结构保持同步。修改蛋卡片样式时两者都要更新。
