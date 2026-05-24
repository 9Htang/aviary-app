import json, os

base = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
path = os.path.join(base, 'data', 'drug_database.json')

with open(path, 'r', encoding='utf-8') as f:
    db = json.load(f)

db['version'] = '2.0'
db['date'] = '2026-05-25'
db['source'] = "Carpenter's Exotic Animal Formulary, 6th Ed. + 异宠药典鹦鹉篇"
db['note'] = '仅含口服(PO)剂量，鹦鹉相关数据'

with open(path, 'w', encoding='utf-8') as f:
    json.dump(db, f, ensure_ascii=False, indent=2)

print(f"已更新: v{db['version']}, {len(db['drugs'])} 种药品")
