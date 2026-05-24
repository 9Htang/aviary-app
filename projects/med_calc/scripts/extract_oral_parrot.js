const XLSX = require('xlsx');
const path = require('path');
const fs = require('fs');

const wb = XLSX.readFile(path.join(__dirname, '..', 'data', 'Carpenter_Formulary.xlsx'));
const ws = wb.Sheets['Table 1'];

function cv(r, c) {
  const cell = ws[XLSX.utils.encode_cell({r, c})];
  return cell ? String(cell.v).trim() : '';
}

const PARROT = /parrot|psittacine|cockatiel|cockatoo|macaw|conure|lovebird|budgie|budgerigar|amazon|parakeet|eclectus|pionus|senegal|quaker|lory|lorikeet|caique|african grey|most species|all species|psittaciformes/i;
const EXCLUDE = /^[\s,;]*(emu|ostrich|ratite|crane|bustard|penguin)[\s,;\/]/i;

let results = [];

for (let r = 2; r <= 3781; r++) {
  const dose = cv(r, 11);
  const species = cv(r, 23);
  const colA = cv(r, 0);

  if (!dose) continue;
  if (!dose.includes('PO') && !dose.toLowerCase().includes('per os')) continue;

  const sl = species.toLowerCase();
  if (!PARROT.test(sl)) continue;
  if (EXCLUDE.test(sl) && !PARROT.test(sl)) continue;

  // Find parent drug name (look upward for a non-empty col A)
  let drugName = colA;
  if (!drugName) {
    for (let p = r - 1; p >= 2; p--) {
      const pn = cv(p, 0);
      if (pn) { drugName = pn; break; }
    }
  }
  if (!drugName || drugName.startsWith('Table') || drugName.startsWith('Agent') || drugName.startsWith('Measurement')) {
    continue;
  }

  const range = dose.match(/([\d.]+)\s*-\s*([\d.]+)\s*mg\/kg/);
  const single = dose.match(/([\d.]+)\s*mg\/kg/);
  let min = '', max = '';
  if (range) { min = range[1]; max = range[2]; }
  else if (single) { min = single[1]; max = single[1]; }

  const freq = dose.match(/(q\d+h|q\d+d|BID|SID|TID)/i);
  const freqStr = freq ? freq[1] : '';

  results.push({ row: r, drug: drugName, dose: dose, min, max, freq: freqStr, species });
}

// 按药名分组统计
const byDrug = {};
results.forEach(r => {
  if (!byDrug[r.drug]) byDrug[r.drug] = { name: r.drug, entries: [] };
  byDrug[r.drug].entries.push(r);
});

const sorted = Object.values(byDrug).sort((a, b) => a.name.localeCompare(b.name));

console.log('Found ' + results.length + ' PO+parrot rows, ' + sorted.length + ' unique drugs\n');

// 输出详细
const zh = {
  'African grey parrot': '非洲灰鹦鹉', 'Amazon parrot': '亚马逊鹦鹉',
  'Amazon parrots': '亚马逊鹦鹉', 'Blue-fronted Amazon': '蓝顶亚马逊鹦鹉',
  'cockatiel': '玄凤鹦鹉', 'cockatoo': '凤头鹦鹉', 'macaw': '金刚鹦鹉',
  'Blue and gold macaw': '蓝黄金刚鹦鹉', 'Hyacinth macaw': '风信子金刚鹦鹉',
  'conure': '锥尾鹦鹉', 'lovebird': '牡丹鹦鹉',
  'budgerigar': '虎皮鹦鹉', 'budgie': '虎皮鹦鹉', 'parakeet': '鹦鹉',
  'eclectus': '折衷鹦鹉', 'senegal': '塞内加尔鹦鹉',
  'quaker': '和尚鹦鹉', 'monk parakeet': '和尚鹦鹉',
  'lory': '吸蜜鹦鹉', 'lorikeet': '吸蜜鹦鹉',
  'caique': '凯克鹦鹉', 'parrot': '鹦鹉', 'parrots': '鹦鹉',
  'psittacine': '鹦鹉类', 'psittacines': '鹦鹉类',
  'passerine': '雀形目', 'passerines': '雀形目',
  'canary': '金丝雀', 'canaries': '金丝雀', 'finch': '雀', 'finches': '雀',
  'raptor': '猛禽', 'raptors': '猛禽',
  'pigeon': '鸽', 'pigeons': '鸽', 'dove': '鸽',
  'most species': '大多数鸟类', 'all species': '所有鸟类',
  'including': '包括', 'PK': '药动学',
  'q8h': '每8小时', 'q12h': '每12小时', 'q24h': '每24小时', 'q48h': '每48小时',
  'PO': '口服',
};

function toCn(t) {
  if (!t) return '';
  let r = String(t);
  const entries = Object.entries(zh).sort((a, b) => b[0].length - a[0].length);
  for (const [en, cn] of entries) {
    r = r.replace(new RegExp(en.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'gi'), cn);
  }
  return r.replace(/\s+/g, ' ').trim();
}

const drugCn = {
  'Amikacin': '阿米卡星', 'Gentamicin': '庆大霉素', 'Kanamycin': '卡那霉素',
  'Neomycin': '新霉素', 'Tobramycin': '妥布霉素', 'Spectinomycin': '大观霉素',
  'Streptomycin': '链霉素',
  'Amoxicillin sodium': '阿莫西林钠', 'Amoxicillin trihydrate': '阿莫西林',
  'Amoxicillin/clavulanate': '阿莫西林克拉维酸',
  'Ampicillin sodium': '氨苄西林钠', 'Ampicillin trihydrate': '氨苄西林',
  'Penicillin G': '青霉素G',
  'Cephalexin': '头孢氨苄', 'Cefadroxil': '头孢羟氨苄', 'Cefazolin': '头孢唑林',
  'Cephradine': '头孢拉定', 'Cefotaxime': '头孢噻肟', 'Ceftiofur': '头孢噻呋',
  'Cloxacillin': '氯唑西林',
  'Doxycycline': '多西环素', 'Tetracycline': '四环素', 'Chlortetracycline': '金霉素',
  'Azithromycin': '阿奇霉素', 'Erythromycin': '红霉素', 'Tylosin': '泰乐菌素',
  'Tiamulin': '泰妙菌素', 'Tilmicosin': '替米考星', 'Lincomycin': '林可霉素',
  'Clindamycin': '克林霉素', 'Clarithromycin': '克拉霉素', 'Clofazimine': '氯法齐明',
  'Enrofloxacin': '恩诺沙星', 'Ciprofloxacin': '环丙沙星', 'Marbofloxacin': '马波沙星',
  'Pradofloxacin': '普拉多沙星', 'Danofloxacin': '达氟沙星', 'Difloxacin': '二氟沙星',
  'Chloramphenicol': '氯霉素', 'Chloramphenicol palmitate': '氯霉素棕榈酸酯',
  'Metronidazole': '甲硝唑', 'Fenbendazole': '芬苯达唑',
  'Meloxicam': '美洛昔康', 'Carprofen': '卡洛芬',
  'Dexamethasone': '地塞米松', 'Prednisolone': '泼尼松龙',
  'Tramadol': '曲马多', 'Butorphanol': '布托啡诺',
  'Diazepam': '地西泮', 'Midazolam': '咪达唑仑',
  'Rifampin': '利福平', 'Rifabutin': '利福布丁',
  'Toltrazuril': '妥曲珠利', 'Ponazuril': '泊那珠利',
  'Vitamin A': '维生素A', 'Vitamin D3': '维生素D3', 'Vitamin E': '维生素E',
};

function getNameCn(en) {
  for (const [k, v] of Object.entries(drugCn)) {
    if (en.startsWith(k)) return v;
  }
  return en;
}

function classify(name) {
  const map = [
    ['Amikacin', '氨基糖苷类'], ['Gentamicin', '氨基糖苷类'], ['Kanamycin', '氨基糖苷类'],
    ['Neomycin', '氨基糖苷类'], ['Tobramycin', '氨基糖苷类'], ['Spectinomycin', '氨基糖苷类'], ['Streptomycin', '氨基糖苷类'],
    ['Amoxicillin', '青霉素类'], ['Ampicillin', '青霉素类'], ['Penicillin', '青霉素类'], ['Cloxacillin', '青霉素类'],
    ['Cephalexin', '头孢菌素类'], ['Cefadroxil', '头孢菌素类'], ['Cefazolin', '头孢菌素类'], ['Cephradine', '头孢菌素类'],
    ['Cefotaxime', '头孢菌素类'], ['Ceftiofur', '头孢菌素类'],
    ['Doxycycline', '四环素类'], ['Tetracycline', '四环素类'], ['Chlortetracycline', '四环素类'],
    ['Azithromycin', '大环内酯类'], ['Erythromycin', '大环内酯类'], ['Tylosin', '大环内酯类'],
    ['Tiamulin', '大环内酯类'], ['Tilmicosin', '大环内酯类'], ['Clarithromycin', '大环内酯类'],
    ['Lincomycin', '林可胺类'], ['Clindamycin', '林可胺类'],
    ['Enrofloxacin', '喹诺酮类'], ['Ciprofloxacin', '喹诺酮类'], ['Marbofloxacin', '喹诺酮类'],
    ['Pradofloxacin', '喹诺酮类'], ['Danofloxacin', '喹诺酮类'], ['Difloxacin', '喹诺酮类'],
    ['Chloramphenicol', '氯霉素类'],
    ['Metronidazole', '抗寄生虫类'], ['Fenbendazole', '抗寄生虫类'],
    ['Toltrazuril', '抗寄生虫类'], ['Ponazuril', '抗寄生虫类'],
    ['Meloxicam', '抗炎(NSAIDs)'], ['Carprofen', '抗炎(NSAIDs)'],
    ['Dexamethasone', '皮质类固醇'], ['Prednisolone', '皮质类固醇'],
    ['Tramadol', '镇痛类'], ['Butorphanol', '镇痛类'],
    ['Diazepam', '镇静类'], ['Midazolam', '镇静类'],
    ['Rifampin', '抗结核类'], ['Rifabutin', '抗结核类'], ['Clofazimine', '抗结核类'],
    ['Vitamin A', '营养补充'], ['Vitamin D3', '营养补充'], ['Vitamin E', '营养补充'],
  ];
  for (const [k, v] of map) {
    if (name.startsWith(k)) return v;
  }
  return '其他';
}

// 输出 Excel
const XLSX2 = require('xlsx');
const rows = [['药品(英文)', '中文名', '分类', '剂量原文', 'mg/kg下限', 'mg/kg上限', '频次', '适用物种原文', '适用物种中文', '说明']];

sorted.forEach(d => {
  const cn = getNameCn(d.name);
  const cat = classify(d.name);
  d.entries.forEach(e => {
    // Extract main species and notes
    const parts = e.species.split(/[;/]/);
    const mainSpp = parts[0].trim();
    const notes = parts.slice(1).join('; ').trim();
    rows.push([d.name, cn, cat, e.dose, e.min, e.max, e.freq, e.species, toCn(mainSpp), notes ? toCn(notes.substring(0, 100)) : '']);
  });
});

const outWb = XLSX2.utils.book_new();
const outWs = XLSX2.utils.aoa_to_sheet(rows);
outWs['!cols'] = [{wch:32},{wch:18},{wch:12},{wch:40},{wch:10},{wch:10},{wch:10},{wch:55},{wch:40},{wch:40}];
XLSX2.utils.book_append_sheet(outWb, outWs, '口服鹦鹉用药');
const outPath = path.join(__dirname, '..', 'data', '口服鹦鹉用药_Carpenter_审核.xlsx');
XLSX2.writeFile(outWb, outPath);

console.log('✅ 完成！');
console.log('总剂量行数: ' + (rows.length - 1));
console.log('药品种类: ' + sorted.length);
console.log('输出: ' + outPath + '\n');

sorted.forEach(d => {
  const cn = getNameCn(d.name);
  const cat = classify(d.name);
  const entries = d.entries;
  const mins = entries.filter(e => e.min).map(e => parseFloat(e.min));
  const maxs = entries.filter(e => e.max).map(e => parseFloat(e.max));
  const min = mins.length ? Math.min(...mins) : '?';
  const max = maxs.length ? Math.max(...maxs) : '?';
  // Collect bird names
  const birds = new Set();
  entries.forEach(e => toCn(e.species).split(/[,，、]/).forEach(b => {
    const t = b.replace(/\([^)]*\)/g, '').trim();
    if (t && t.length > 1 && !/^[\d./]/.test(t)) birds.add(t);
  }));
  console.log(cn.padEnd(16) + ' ' + String(min).padStart(5) + '-' + String(max).padEnd(5) + ' mg/kg  ' + cat + '  ' + [...birds].slice(0, 3).join('、'));
});
