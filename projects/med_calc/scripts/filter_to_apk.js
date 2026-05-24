const XLSX = require('xlsx');
const path = require('path');
const fs = require('fs');

const dbPath = path.join(__dirname, '..', 'data', 'drug_database.json');
const db = JSON.parse(fs.readFileSync(dbPath, 'utf-8'));

// 只保留口服+鹦鹉的药
const filtered = db.drugs.filter(d => {
  const route = d.route || '';
  const birds = d.birds || '';
  const isOral = route === '口服' || route.startsWith('PO');
  const hasParrot = /鹦鹉|玄凤|金刚|虎皮|牡丹|凤头/.test(birds);
  if (!isOral || !hasParrot) return false;

  // 清理非鹦鹉物种
  let clean = birds.replace(/[、,]\s*鸽子/g, '').replace(/^鸽子[、,]?\s*/g, '').replace(/鸽子/g, '');
  clean = clean.replace(/[、,]+$/, '').replace(/、+/g, '、');
  d.birds = clean.trim();
  d.route = '口服';
  return d.birds.length > 0;
});

const output = {
  version: '2.0',
  date: '2026-05-25',
  source: "Carpenter's Exotic Animal Formulary, 6th Ed. + 异宠药典鹦鹉篇",
  note: '仅含口服(PO)鹦鹉用药，鸽子已排除',
  drugs: filtered,
};

fs.writeFileSync(dbPath, JSON.stringify(output, null, 2), 'utf-8');
console.log('Filtered: ' + filtered.length + ' drugs');
filtered.forEach(d => console.log('  ' + d.name.padEnd(10) + ' ' + d.dose_min + '-' + d.dose_max + ' mg/kg  ' + d.birds));
