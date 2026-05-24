const XLSX = require('xlsx');
const path = require('path');

const wb = XLSX.readFile(path.join(__dirname, '..', 'data', 'Carpenter_Formulary.xlsx'));
const ws = wb.Sheets['Table 1'];

const zh = {
  'African grey parrot': '非洲灰鹦鹉', 'Amazon parrot': '亚马逊鹦鹉',
  'cockatiel': '玄凤鹦鹉', 'cockatoo': '凤头鹦鹉',
  'macaw': '金刚鹦鹉', 'conure': '锥尾鹦鹉',
  'lovebird': '牡丹鹦鹉', 'budgerigar': '虎皮鹦鹉',
  'parakeet': '鹦鹉', 'eclectus': '折衷鹦鹉',
  'pionus': '派翁尼斯鹦鹉', 'senegal': '塞内加尔鹦鹉',
  'quaker': '和尚鹦鹉', 'lory': '吸蜜鹦鹉', 'lorikeet': '吸蜜鹦鹉',
  'caique': '凯克鹦鹉', 'parrot': '鹦鹉',
  'psittacine': '鹦鹉类', 'passerine': '雀形目',
  'raptor': '猛禽', 'pigeon': '鸽', 'dove': '鸽',
  'ratite': '平胸鸟类', 'emu': '鸸鹋', 'ostrich': '鸵鸟',
  'crane': '鹤', 'bustard': '鸨',
  'most species': '大多数鸟类', 'all species': '所有鸟类',
  'PK': '药动学', 'PO': '口服',
  'q8h': '每8小时', 'q12h': '每12小时', 'q24h': '每24小时', 'q48h': '每48小时',
};

function translate(s) {
  if (!s) return '';
  let t = s;
  const entries = Object.entries(zh).sort((a, b) => b[0].length - a[0].length);
  for (const [en, cn] of entries) {
    t = t.replace(new RegExp(en.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'gi'), cn);
  }
  return t.replace(/\s+/g, ' ').trim();
}

const drugMap = {
  'Amikacin': '阿米卡星', 'Gentamicin': '庆大霉素', 'Kanamycin': '卡那霉素',
  'Neomycin': '新霉素', 'Tobramycin': '妥布霉素', 'Spectinomycin': '大观霉素',
  'Streptomycin': '链霉素',
  'Amoxicillin sodium': '阿莫西林钠', 'Amoxicillin trihydrate': '阿莫西林',
  'Amoxicillin/clavulanate': '阿莫西林克拉维酸',
  'Ampicillin sodium': '氨苄西林钠', 'Ampicillin trihydrate': '氨苄西林',
  'Penicillin G': '青霉素G',
  'Doxycycline': '多西环素', 'Tetracycline': '四环素',
  'Chlortetracycline': '金霉素',
  'Azithromycin': '阿奇霉素', 'Erythromycin': '红霉素',
  'Tylosin': '泰乐菌素', 'Tiamulin': '泰妙菌素', 'Tilmicosin': '替米考星',
  'Lincomycin': '林可霉素', 'Clindamycin': '克林霉素',
  'Enrofloxacin': '恩诺沙星', 'Ciprofloxacin': '环丙沙星',
  'Marbofloxacin': '马波沙星', 'Pradofloxacin': '普拉多沙星',
  'Levofloxacin': '左氧氟沙星', 'Danofloxacin': '达氟沙星',
  'Chloramphenicol': '氯霉素', 'Chloramphenicol palmitate': '氯霉素棕榈酸酯',
  'Metronidazole': '甲硝唑', 'Fenbendazole': '芬苯达唑',
  'Meloxicam': '美洛昔康', 'Carprofen': '卡洛芬',
  'Dexamethasone': '地塞米松', 'Prednisolone': '泼尼松龙',
};

let rows = [['药品英文', '中文名', '剂量原文', '剂量下限(mg/kg)', '剂量上限(mg/kg)', '适用物种', '适用物种中文', '备注']];

for (let r = 2; r <= 1000; r++) { // 只查前1000行就够了
  const nameCell = ws[XLSX.utils.encode_cell({r, c: 0})];
  const doseCell = ws[XLSX.utils.encode_cell({r, c: 11})];
  const specCell = ws[XLSX.utils.encode_cell({r, c: 23})];
  if (!doseCell) continue;

  const n = nameCell ? ('' + nameCell.v).trim() : '';
  const d = ('' + doseCell.v).trim();
  const s = specCell ? ('' + specCell.v).trim() : '';

  if (!d || d === '—') continue;
  if (!d.includes('PO')) continue;

  const sl = s.toLowerCase();
  const isParrot = /parrot|psittacine|cockatiel|cockatoo|macaw|conure|lovebird|budgie|budgerigar|parakeet|most species|all species/i.test(sl);
  const onlyNonParrot = /^[\s,;]*(emu|ostrich|ratite|crane|bustard)[\s,;\/]?/i.test(sl.replace(/PK;.*/g, '').trim());
  if (!isParrot && onlyNonParrot) continue;

  const range = d.match(/([\d.]+)\s*-\s*([\d.]+)\s*mg\/kg/);
  const single = d.match(/([\d.]+)\s*mg\/kg/);
  let min = '', max = '';
  if (range) { min = range[1]; max = range[2]; }
  else if (single) { min = single[1]; max = single[1]; }

  const knownDrug = Object.keys(drugMap).find(k => n.startsWith(k));
  const cnName = knownDrug ? drugMap[knownDrug] : n;

  rows.push([n, cnName, d, min, max, s, translate(s.split('/')[0].replace(/^most species,?\s*/i, '')), '']);
}

const outWb = XLSX.utils.book_new();
const outWs = XLSX.utils.aoa_to_sheet(rows);
outWs['!cols'] = [
  {wch: 35}, {wch: 16}, {wch: 42}, {wch: 12}, {wch: 12},
  {wch: 55}, {wch: 35}, {wch: 30}
];
XLSX.utils.book_append_sheet(outWb, outWs, '口服鹦鹉用药');
XLSX.writeFile(outWb, path.join(__dirname, '..', 'data', '口服鹦鹉用药_待审核.xlsx'));

console.log('已生成：' + (rows.length - 1) + ' 条记录 → data/口服鹦鹉用药_待审核.xlsx');
