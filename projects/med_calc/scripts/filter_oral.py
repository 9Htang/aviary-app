import json

with open('data/drug_database.json', encoding='utf-8') as f:
    db = json.load(f)

oral = []
for d in db['drugs']:
    r = d.get('route', '')
    b = d.get('birds', '')
    if ('PO' in r or r == '口服') and ('鹦鹉' in b or '玄凤' in b or '鸽' in b):
        oral.append(d)

print(f'口服+鹦鹉: {len(oral)} 种')
for d in oral:
    print(d['name'].ljust(12), str(d['dose_min']).ljust(5), '-', str(d['dose_max']).ljust(5), 'mg/kg', d['route'].ljust(10), d['birds'])
