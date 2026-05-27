# 🦜 鸟舍管理系统

## 项目概况
Express + EJS + SQLite 鸟舍管理系统。渐进式重构中，已完成 1-12 阶段（截至 2026-05-26）。

## 移动端 UI 状态（2026-05-26）

### 导航栏
- **桌面端**：横向 nav-right（新增/鸟房/基因/登录/管理+退出）
- **移动端**：侧滑抽屉（82vw / max-width: 320px），checkbox hack 零 JS
  - 分组：主功能 / 系统 / 账户
  - 遮罩：`rgba(0,0,0,0.45) + backdrop-filter: blur(4px)`
  - active 高亮：`.nav-link.active { background: #8b7355; color: #fff }`

### 首页卡片
- 3:4 图片比例
- 信息：名字 + `羽色 · 年龄` + pill 标签（成鸟/幼鸟等）
- 性别图标 26px（移动端 22px），右上角覆盖
- 年龄格式：`1.1岁 / 3个月 / N天`

### 鸟详情页
- **布局**：名字+环号→摘要行→按钮→照片→下方卡片
- **摘要行**：`公 · 1.1岁 · 存活` / `绿花桃 · 已配对 · 1号繁殖间`
- **按钮**：`btn-edit`（透明） + `btn-medical`（浅蓝），移动端 36px
- **编辑模式**：`body.editing` 隐藏 overview 和照片，只显示分组表单
  - 分组：基础信息 / 状态信息 / 其他信息
  - 父母选择：`parent-chip` 卡片组件（44px、圆角12px）
  - 按钮层级：删除(outline) / 取消(outline) / 保存(primary)

### 病历页
- 病历卡：折叠/展开、右上角编辑+痊愈按钮
- 时间轴：scroll-snap + 渐隐遮罩 + 横向滑动
- 添加条目：datetime-local 精确到分钟
- T→空格渲染

## 服务端
- 端口 3456
- 启动：`cd projects\aviary && node server.js`
- 重启：`restart.bat`

## 仓库
- [github.com/9Htang/parrot-manager](https://github.com/9Htang/parrot-manager)
