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

## ⚠️ 生死线：永远别杀所有 node 进程

```
# ❌ 自杀指令！会杀死包括 OpenClaw 网关在内的所有 node 进程
Get-Process -Name "node" | Stop-Process -Force

# ✅ 正确做法：按端口杀
$pid = (Get-NetTCPConnection -LocalPort 3456 -ErrorAction SilentlyContinue).OwningProcess
if ($pid) { Stop-Process -Id $pid -Force }
```

aviary 端口：**3456**

## 🔄 Git Workflow（每项任务完成后必须执行）

每项任务完成后，按以下步骤提交到 GitHub：

1. `git status` — 查看变更
2. `git add .` — 暂存所有变更
3. `git commit -m "<有意义的信息>"` — 描述本轮改了什么
4. `git push` — 推送到远程

**一项任务未完成的标准：**
- ❌ 变更未提交
- ❌ 提交未推送
- ❌ 工作区不干净

任务完成前必须提交并推送，不留未提交的改动。

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

Add whatever helps you do your job. This is your cheat sheet.

## Related

- [Agent workspace](/concepts/agent-workspace)
