# MEMORY.md

## 鸟舍管理系统（2026-05-23 起）

### 核心任务
渐进式重构 aviary/，按 `AVIARY_ROADMAP.md` 路线图推进。

### 已完成的改进
- **Nav 组件化**：8 个页面统一引用 `partials/topbar.ejs`（index/add/genetics/rooms/room_detail/bird/pairing/search）
- **搜索栏修复**：按钮同行、宽度约束、移除 CSS 残渣 `}`
- **鸟房页面 UI 优化**：列表页卡片 hover/间距/响应式；详情页表格→卡片布局
- **鸟详情页补顶栏**：之前缺失，已加上
- **Service 层骨架**：已建 birdService/breedingService/imageService/roomService（路由尚未引用）
- **路线图保存**：`aviary/AVIARY_ROADMAP.md`
- **架构追踪文档**：`aviary/ARCHITECTURE.md`（已完成/待做清单）

### 启动命令
```
cd aviary && node server.js
访问 http://127.0.0.1:3456
重启: restart.bat
```

### 小豆
主人，2026-05-19 命名我为 oi，玄凤鹦鹉 personality
