# 🦜 鸟舍任务系统 & 病历系统 — 计划

## 目标

新建 Flutter App `aviary_app`，配合 aviary 后端扩展，实现：
1. **任务制度** — 手机端主页，每日鹦鹉任务管理
2. **自动选鸟** — 雏鸟/病鸟自动入任务
3. **体重管理** — 空腹/未空腹区分，曲线展示
4. **病历系统** — Web 端，带时间轴
5. **批量选择** — 手动批处理加入任务计划
6. **未来算法优化** — 任务执行顺序调控

## 架构

```
aviary_app (Flutter)
    │ HTTP │
    ▼
aviary (Express + SQLite)
    │
    ├── 新增 API 路由
    ├── 新增 数据库表
    └── 新增 Web 页面 (病历)
```

## 数据库新增

### 1. weight_records 加 is_fasting
```sql
ALTER TABLE weight_records ADD COLUMN is_fasting INTEGER DEFAULT 1;
```

### 2. medical_records 表
```sql
CREATE TABLE medical_records (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  bird_id INTEGER NOT NULL REFERENCES birds(id),
  onset_date TEXT NOT NULL,       -- 发病日期
  diagnosis TEXT,                  -- 诊断结果
  treatment TEXT,                  -- 治疗方案
  outcome TEXT DEFAULT '治疗中',   -- 治疗中/痊愈/死亡
  death_date TEXT,                 -- 死亡日期
  death_cause TEXT,                -- 死亡原因
  necropsy TEXT,                   -- 解剖记录
  is_active INTEGER DEFAULT 1,     -- 是否活跃病历
  created_at TEXT DEFAULT datetime('now','localtime'),
  updated_at TEXT DEFAULT datetime('now','localtime')
);
```

### 3. medical_timeline 表
```sql
CREATE TABLE medical_timeline (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  record_id INTEGER NOT NULL REFERENCES medical_records(id),
  entry_date TEXT NOT NULL,
  content TEXT NOT NULL,           -- 症状/进展/用药等文本
  entry_type TEXT DEFAULT 'symptom', -- symptom / treatment / note / test
  created_at TEXT DEFAULT datetime('now','localtime')
);
```

### 4. tasks 表
```sql
CREATE TABLE tasks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  task_date TEXT NOT NULL,          -- 任务日期
  title TEXT,                      -- 任务标题
  status TEXT DEFAULT 'pending',   -- pending / in_progress / completed
  auto_generated INTEGER DEFAULT 0, -- 是否自动生成
  created_at TEXT DEFAULT datetime('now','localtime')
);
```

### 5. task_items 表
```sql
CREATE TABLE task_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  task_id INTEGER NOT NULL REFERENCES tasks(id),
  bird_id INTEGER NOT NULL REFERENCES birds(id),
  task_type TEXT NOT NULL,          -- weigh / feed / medicate / check / other
  medication TEXT,                  -- 用药信息
  dosage TEXT,                      -- 剂量
  notes TEXT,
  is_fasting INTEGER,               -- 称重时是否空腹（仅称重任务）
  priority INTEGER DEFAULT 0,       -- 优先级
  status TEXT DEFAULT 'pending',    -- pending / done / skipped
  sort_order INTEGER DEFAULT 0,     -- 执行顺序
  completed_at TEXT,
  created_at TEXT DEFAULT datetime('now','localtime')
);
```

## API 新增

### 任务系统
- `GET /api/tasks?date=YYYY-MM-DD` — 获取某天任务
- `POST /api/tasks` — 创建新任务
- `PATCH /api/tasks/:id` — 更新任务状态
- `POST /api/tasks/:id/items` — 添加单个任务项
- `POST /api/tasks/:id/items/batch` — 批量添加任务项
- `POST /api/tasks/generate` — 自动生成今日任务
- `PATCH /api/task-items/:id` — 更新任务项状态
- `GET /api/birds/task-candidates` — 获取自动选鸟候选人

### 体重
- `GET /api/weights/:birdId?includeFasting=1` — 含空腹状态的体重
- `POST /api/bird/:id/weight` — 加 is_fasting 参数

### 病历
- `GET /api/birds/:id/medical-records` — 病历列表
- `POST /api/birds/:id/medical-records` — 创建病历
- `PATCH /api/medical-records/:id` — 更新病历
- `GET /api/medical-records/:id/timeline` — 时间轴
- `POST /api/medical-records/:id/timeline` — 添加时间轴条目
- `DELETE /api/medical-records/:id` — 删除病历

## Flutter 页面

```
lib/
├── main.dart
├── config/
│   └── api.dart                 # API 配置
├── models/
│   ├── bird.dart                # 鸟只模型
│   ├── task.dart                # 任务模型
│   ├── task_item.dart           # 任务项模型
│   ├── weight_record.dart       # 体重记录模型（含空腹）
│   └── medical_record.dart      # 病历模型
├── services/
│   ├── api_client.dart          # HTTP 客户端
│   ├── task_service.dart        # 任务服务
│   └── bird_service.dart        # 鸟只服务
├── screens/
│   ├── home_task_screen.dart    # 首页 - 今日任务
│   ├── task_detail_screen.dart  # 任务详情
│   ├── weight_record_screen.dart # 记录体重
│   ├── batch_select_screen.dart # 批量选鸟
│   ├── bird_detail_screen.dart  # 鸟只详情
│   └── weight_chart_screen.dart # 体重曲线
└── widgets/
    ├── bird_card.dart
    ├── task_item_card.dart
    ├── weight_chart.dart
    └── fasting_indicator.dart
```
