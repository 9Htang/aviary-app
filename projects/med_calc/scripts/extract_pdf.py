import sys
import fitz

sys.stdout.reconfigure(encoding='utf-8')

doc = fitz.open('C:/Users/Cwb/.openclaw/workspace/projects/med_calc/异宠药典鹦鹉篇.pdf')
print(f'Total pages: {len(doc)}')

for i in range(min(5, len(doc))):
    text = doc[i].get_text()
    if text.strip():
        print(f'\n=== Page {i+1} ===')
        # extract to file to avoid encoding issues
        with open(f'page_{i+1}.txt', 'w', encoding='utf-8') as f:
            f.write(text[:2000])
        print(f'Wrote page_{i+1}.txt ({len(text)} chars)')
    else:
        print(f'\n=== Page {i+1} === (no text - possible scanned image)')

# Save all text to a file
text_file = '异宠药典_全文.txt'
with open(text_file, 'w', encoding='utf-8') as f:
    for i in range(len(doc)):
        text = doc[i].get_text()
        f.write(f'\n=== 第{i+1}页 ===\n')
        f.write(text)
print(f'\nAll text saved to: {text_file}')
print(f'File size: {__import__("os").path.getsize(text_file) / 1024:.0f} KB')
