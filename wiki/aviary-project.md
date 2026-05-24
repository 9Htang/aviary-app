# 🦜 鸟舍管理系统 — Aviary

> Express + EJS + SQLite 后端管理系统，配套 Flutter 手机端

## 项目位置

```
projects/aviary/       ← 后端 (Express + EJS + SQLite)
projects/aviary_app/   ← 手机端 (Flutter)
```

## 后端 (aviary)

### 技术栈
- **运行时**: Node.js (Express)
- **模板**: EJS
- **数据库**: SQLite (better-sqlite3)
- **端口**: 3456
- **权限**: Session + Cookie (express-session + session-file-store)

### 启动

```bash
cd projects/aviary
restart.bat     # 或 node server.js
访问 http://127.0.0.1:3456
```

### 默认账号
- 用户名: `admin`
- 密码: `admin123`

### 目录结构
```
aviary/
├── server.js            # 入口
├── config/              # 数据库配置
├── middleware/           # 认证/错误中间件
├── models/              # 数据模型
├── modules/             # 路由模块（按领域）
│   ├── auth/            # 登录认证
│   ├── admin/           # 管理后台
│   ├── birds/           # 鸟只管理
│   ├── rooms/           # 鸟房管理
│   ├── breeding/        # 繁育管理
│   └── genetics/        # 基因管理
├── repositories/        # 数据访问层
├── services/            # 业务逻辑层
├── routes/              # 路由
├── views/               # EJS 模板
└── public/              # 静态文件
```

### API 接口
| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/login` | 登录 |
| POST | `/api/logout` | 退出 |
| GET | `/api/tasks` | 获取任务列表 |
| GET | `/api/tasks/candidates` | 获取选鸟候选人 |
| POST | `/api/tasks/generate` | 自动生成任务 |
| POST | `/api/tasks` | 创建任务 |
| PATCH | `/api/tasks/:id` | 更新任务 |
| PATCH | `/api/tasks/items/:id` | 更新任务项 |
| GET | `/api/bird/:id/weights` | 获取体重记录 |
| POST | `/api/bird/:id/weight` | 记录体重 |

### 已完成的迁移/重构
- 模块化目录 (2026-05-23)
- Repository + Service 层 (2026-05-23)
- Zod 表单验证 (2026-05-23)
- 统一 API 格式 sendSuccess/sendFail (2026-05-23)
- APK 下载路由 /download/app.apk (2026-05-25)

## 手机端 (aviary_app)

### 技术栈
- Flutter (Dart)
- http + dart:io HttpClient
- SharedPreferences (登录态持久化)
- fl_chart (体重曲线)
- flutter_localizations (中文)

### 构建

```bash
cd projects/aviary_app
flutter build apk --release
# 输出: build/app/outputs/flutter-apk/app-release.apk
```

### 下载
手机连接同一个 WiFi 后访问：
```
http://192.168.10.9:3456/download/aviary-v{version}.apk
```

### 版本历史
| 版本 | 日期 | 变更 |
|------|------|------|
| v1.0.0 | 2026-05-23 | 初始版本 |
| v1.0.3 | 2026-05-25 | 中文 + session 修复 + 称重弹窗 |
| v1.0.4 | 2026-05-25 | 连续称重流程 + 按钮布局 |
| v1.0.5 | 2026-05-25 | 版本号追踪 |

### 功能说明
- **保持登录**: 退出 APP 再进不需要重新登录
- **今日任务**: 自动生成每日任务清单
- **称重**: 点击任务项弹出称重输入，记录后自动下一只
- **同小时覆盖**: 同一只鸟同一小时多次称重自动覆盖
- **喂药**: 点击显示药物剂量，确认完成
- **体重曲线**: 长按查看趋势图
- **批量选鸟**: 手动添加任务项

### 桌面端
- 仓库: [github.com/9Htang/parrot-manager](https://github.com/9Htang/parrot-manager)

## 网络拓扑
- 电脑 IP: `192.168.10.9:3456`
- 手机通过 WiFi 局域网访问
- Windows 防火墙需放行 3456 端口
- Android 需 `usesCleartextTraffic="true"` 支持 HTTP
