# Memory (HOT Tier)

## Rules

### EJS 修改
- **绝对**不要用 Node.js 脚本做正则替换修改 EJS 模板。CRLF/LF 差异、引号逃逸、文件编码都可能导致 EJS 损坏
- 只用 `edit` 工具做精确文本替换（它处理文本层面，不会损坏编码）
- 复杂操作先 `git checkout` 回退到干净状态，再做少量精确修改

### CSS 换行符
- CSS 文件内的 `\n` 必须是真实 LF 字符 (0x0A)，不能是反斜杠+n 文字
- Node.js `'\\n'` 是文字 `\n`（两个字符），`'\n'` 才是换行符
- 正则 `/\\n/g` 匹配文字 `\n`（一个斜杠+n），`/\\\\n/g` 匹配 `\\n`（两个斜杠+n）

### Node.js + PowerShell
- 不要在 PowerShell 中用 `node -e "..."` 写复杂脚本（引号逃逸灾难）
- 写 `.js` 文件 → 执行：`write → node script.js`

## Patterns

- CSS 改动 → `edit` 工具，精确匹配原文
- EJS HTML 改动 → `edit` 工具，小批量多次
- 需要脚本化修改 → 写文件到 `projects/aviary/scripts/` 再执行

## Projects

### aviary (Express + EJS)
- 手机端布局用 `@media (max-width: 768px)` + `display: contents` + `order`
- 编辑态用 `body.editing` CSS class 切换，不毁掉 DOM
- 顶栏抽屉用 checkbox hack，零 JS 依赖
