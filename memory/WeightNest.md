# WeightNest 项目记忆

## 基本信息
- **仓库：** github.com/9Htang/WeightNest
- **技术栈：** Flutter + Drift (SQLite) + Riverpod
- **用途：** 鹦鹉体重记录与管理 App
- **当前版本：** 1.7.5+21

## Build / 发布
- 构建命令：`flutter build apk --release`
- APK 输出：`build/app/outputs/flutter-apk/app-release.apk`
- **发布目录：** `C:\Users\Cwb\.openclaw\workspace\releases\`
- 命名规范：`鹦鹉体重记录_v{版本号}.apk`（build.gradle 自动复制）
- Java/Kotlin JVM target: 17

## 核心模块
- `lib/database/` — Drift 数据库（Species, Users, Rooms, Birds, Weights 等表）
- `lib/repositories/` — 数据仓库扩展（weight/bird/room/species/user/task）
- `lib/services/` — Excel导出、同步、网络发现
- `lib/screens/` — 各页面（settings/weigh/birds/home/rooms 等）

## 导出功能
- `ExcelExportService.exportMonthly(year, month)` 按月导出体重宽表
- 文件名：`{年}年{月}月体重记录.xlsx`
- 表结构：脚环 | 品种 | 1日~31日（动态列）
- 同一天多条记录升序排列，当前月份未来日期用 `\` 占位
