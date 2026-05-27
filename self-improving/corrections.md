# Corrections Log

| Date | What I Got Wrong | Correct Answer | Status |
|------|-----------------|----------------|--------|
| 2026-05-25 | CSS \n 换行符：Node.js `\\n` 存成文字反斜杠+n，浏览器跳过整个媒体查询 | 文件内必须用真实 LF (0x0A)。正确方式：`replace(/\n/g, '\n')`（文字`\n`→真实换行） | Active |
| 2026-05-25 | 二进制替换 `\n`→LF 时移了字节位置（2→1字节），炸了 UTF-8 编码 | 不要用二进制替换改文本文件！用 Node.js 字符串 `.replace()`，编码由引擎处理 | Active |
| 2026-05-25 | Node.js 正则 `/\\\\n/g` 匹配了两个反斜杠+n | `/\\n/g` 才匹配一个反斜杠+n | Active |
| 2026-05-26 | EJS 模板用 `fix-*.js` 脚本修改，CRLF 差异导致模板被替换成破损内容，裸露 `<%` 输出为文本 | 编辑 EJS 模板只用 `edit` 工具（文本层面），不用 Node.js 脚本字符串替换。必须改 HTML 时，确保 `\r\n` vs `\n` 精确匹配 | Active |
| 2026-05-26 | 在 PowerShell 中写 Node.js inline `-e` 脚本，引号和转义字符反复导致脚本失败 | 复杂 Node.js 操作写文件执行（`write → node file.js`），不用 `-e` inline | Active |
