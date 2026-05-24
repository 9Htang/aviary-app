# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## QQ Bot 用户信息

```json
{
  "chat_id": "qqbot:c2c:AB586DEAD7326851A4E58525A6CCF01F",
  "sender_id": "AB586DEAD7326851A4E58525A6CCF01F",
  "sender": "AB586DEAD7326851A4E58525A6CCF01F",
  "label": "小豆"
}
```

## ⚠️ 生死线：永远别杀所有 node 进程

```
# ❌ 自杀指令！会杀死包括 OpenClaw 网关在内的所有 node 进程
Get-Process -Name "node" | Stop-Process -Force

# ✅ 正确做法：按端口杀
$pid = (Get-NetTCPConnection -LocalPort 3456 -ErrorAction SilentlyContinue).OwningProcess
if ($pid) { Stop-Process -Id $pid -Force }
```

## 项目目录

```
projects/
├── aviary/       # 🦜 鸟舍管理系统 (Express + EJS + SQLite)
│   ├── 端口 3456
│   └── 独立 git → https://github.com/9Htang/parrot-manager.git
└── med-calc/     # 🩺 鹦鹉药物计算器 (Flutter)
```

> 每个项目有自己的独立 git 仓库。workspace 级 git 只跟踪目录结构。

## 🔄 Git Workflow（⛔ 每次代码变更后必须执行）

**改了代码就必须 commit + push，不留未推送的改动！**

1. `git status` — 查看变更
2. `git add -A` — 暂存所有变更
3. `git commit -m "<有意义的信息>"` — 描述本轮改了什么
4. `git push` — 推送到远程

**不合格的状态（任一不可）：**
- ❌ 变更未提交
- ❌ 提交未推送
- ❌ 工作区有未暂存的改动

> med_calc 推 → github.com/9Htang/med-calc
> aviary 推 → github.com/9Htang/parrot-manager

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

Add whatever helps you do your job. This is your cheat sheet.

## Related

- [Agent workspace](/concepts/agent-workspace)
