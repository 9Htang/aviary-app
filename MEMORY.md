# MEMORY.md

## 项目结构

```
workspace/
├── projects/
│   ├── aviary/       # 🦜 鸟舍管理系统 — Express + SQLite
│   ├── aviary_app/   # 📱 鸟舍管理手机端 — Flutter
│   ├── med_calc/     # 🩺 鹦鹉药物计算器 — Flutter
│   └── WeightNest/   # ⚖️ 体重记录 App — Flutter (Codemagic iOS+Android)
├── memory/
├── node_modules/
└── AGENTS.md, SOUL.md...
```

每个项目有独立 git 仓库。
aviary 远程：github.com/9Htang/parrot-manager
aviary_app 远程：github.com/9Htang/aviary-app
med_calc 远程：github.com/9Htang/med-calc
WeightNest 远程：github.com/9Htang/WeightNest

- 单个 session 只处理一个功能
- 超过20轮必须新建 session
- 不允许回传完整文件
- 不允许回传完整 build log
- 修改代码优先 summary 而不是 full diff
- 失败后停止，不要自动重试

### wiki 文档
- `wiki/aviary-project.md` — 项目总文档
- `wiki/aviary-app-dev.md` — 手机端开发指南
- `wiki/_index.md` — 索引

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

## 计划变更
遇到问题需要改变计划先问小豆，不要擅自修改方案

## ⛔ 铁律：禁止擅自改方案
遇到任何障碍（包冲突、编译失败、环境问题等），必须先：
1. 列出 2-3 个可行选项
2. 等小豆选择
3. 再动手
严禁自己替小豆做决定。
今天已犯两次（PG→SQLite、砍扫码），记在这里永久提醒。

