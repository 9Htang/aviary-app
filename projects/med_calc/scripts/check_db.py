import json
with open('data/drug_database.json', encoding='utf-8') as f:
    db = json.load(f)
print('Version:', db.get('version'))
print('Drugs:', len(db['drugs']))
print()
for d in db['drugs']:
    print(f'{d["name"]:12s} {d["dose_min"]:5g}-{d["dose_max"]:5g} mg/kg  {d["category"]}')
