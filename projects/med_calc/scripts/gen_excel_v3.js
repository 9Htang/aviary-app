const XLSX = require('xlsx');
const path = require('path');
const fs = require('fs');

const db = JSON.parse(fs.readFileSync(path.join(__dirname, '..', 'data', 'drug_database.json'), 'utf-8'));

function fmtFreq(f) {
  if (!f) return '';
  return f
    .replace(/q(\d+)h/g, (m, n) => '每' + n + '小时')
    .replace(/q(\d+)d/g, (m, n) => '每' + n + '天')
    .replace('q48h', '每48小时')
    .replace('x ', '连用')
    .replace('×', '连用');
}

const rows = [['药品名', '分类', 'mg/kg下限', 'mg/kg上限', '喂食间隔', '适用鸟种', '备注']];
db.drugs.forEach(d => {
  const route = d.route || '';
  const birds = d.birds || '';
  const isOral = route === '口服' || route.startsWith('PO');
  const hasParrot = /鹦鹉|玄凤|金刚|虎皮|牡丹|凤头/.test(birds);
  if (!isOral || !hasParrot) return;
  let cleanBirds = birds.replace(/[、,]\s*鸽子/g, '').replace(/^鸽子[、,]?\s*/g, '').replace(/鸽子/g, '');
  cleanBirds = cleanBirds.replace(/[、,]+$/, '').replace(/、+/g, '、');
  if (!cleanBirds) return;
  rows.push([d.name, d.category, d.dose_min, d.dose_max, fmtFreq(d.freq || ''), cleanBirds, d.note || '']);
});

const wb = XLSX.utils.book_new();
const ws = XLSX.utils.aoa_to_sheet(rows);
ws['!cols'] = [{wch:12},{wch:14},{wch:10},{wch:10},{wch:18},{wch:24},{wch:24}];
XLSX.utils.book_append_sheet(wb, ws, '口服鹦鹉用药');
XLSX.writeFile(wb, path.join(__dirname, '..', 'data', '口服鹦鹉用药_v3.xlsx'));
console.log('OK: ' + (rows.length - 1) + ' drugs');
