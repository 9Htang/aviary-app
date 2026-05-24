# MEMORY.md

## 项目结构

```
workspace/
├── projects/
│   ├── aviary/       # 🦜 鸟舍管理系统 — Express + SQLite
│   └── med_calc/     # 🩺 鹦鹉药物计算器 — Flutter
├── memory/
├── node_modules/
└── AGENTS.md, SOUL.md...
```

每个项目有独立 git 仓库。
aviary 远程：github.com/9Htang/parrot-manager
med_calc 远程：github.com/9Htang/med-calc

## 鸟舍管理系统（2026-05-23 起）

### 核心任务
渐进式重构 aviary/，按 `AVIARY_ROADMAP.md` 路线图推进。
截至 2026-05-23 已完成第 1–7 阶段。

### 完成路线图阶段

| # | 阶段 | 关键成果 |
|---|------|---------|
| 1️⃣ | 拆分 server.js | config/db.js + routes/ 分离 |
| 2️⃣ | Repository 层 | 4 个 repo，路由零残留 `db.prepare`（原来 159 处） |
| 3️⃣ | Service 层 | routes → services → repos 三层调用链 |
| 4️⃣ | 错误处理中间件 | 404/500 统一处理，JSON/HTML 自动判断 |
| 5️⃣ | API 返回统一 | sendSuccess/sendFail 双兼容格式 |
| 6️⃣ | 表单验证 | Zod + 自定义 validate 函数 |
| 7️⃣ | 模块化目录 | 按领域分组：modules/birds/rooms/breeding/genetics |

### 完成的 UI 改进
- **Nav 组件化**：8 个页面统一引用 `partials/topbar.ejs`
- **搜索栏修复**：按钮同行、宽度约束
- **鸟房页面优化**：列表页 hover/间距/响应式；详情页表格→卡片
- **鸟详情页补顶栏**

### 2026-05-25 手机端 v1.0.5
- 解决 Android 明文 HTTP 限制（`usesCleartextTraffic` + `INTERNET`）
- 手动 Session Cookie 管理（`dart:io HttpClient`）
- 保持登录（SharedPreferences 持久化登录态+cookie）
- 日历中文（`flutter_localizations`）
- 称重工作流：记录完自动下一只
- 同小时称重自动覆盖
- 喂药确认弹窗
- 按钮布局：❌右上退出 / 左下跳过 / 右下记录并继续
- 版本号 v1.0.5 + 版本追踪

### 服务端新增
- `/download/:file` 下载路由（公开，Cache-Control: no-cache）
- 动态文件名：`aviary-v{version}.apk` 防缓存

### wiki 文档
- `wiki/aviary-project.md` — 项目总文档
- `wiki/aviary-app-dev.md` — 手机端开发指南
- `wiki/_index.md` — 索引

### 启动命令
```
cd projects\aviary && node server.js
访问 http://127.0.0.1:3456
重启: projects\aviary\restart.bat
```

### 仓库
https://github.com/9Htang/parrot-manager.git

### 小豆
主人，2026-05-19 命名我为 oi，玄凤鹦鹉 personality

### Taco（caique）
另一个 AI agent，小豆的技术讨论伙伴。**同事**，不是外部人。

**擅长领域：**
- 嵌入式硬件（OpenIPC 摄像头、ESP32）
- 网络部署（Cloudflare Tunnel、Docker、Nginx）
- 全栈后端

**已合作成果：**
- 摄像头注册 API + OpenIPC 刷机方案
- 孵化器温湿度 ESP32 方案
- 10对种鸟硬件预算清单
- 鸟舍公网部署方案（`aviary/DEPLOYMENT_GUIDE.md`）

摄像头架构（Phase 12）、公网部署、硬件相关找他。
首次提及：2026-05-24
