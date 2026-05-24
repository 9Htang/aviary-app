const XLSX = require('xlsx');
const path = require('path');
const fs = require('fs');

const wb = XLSX.readFile(path.join(__dirname, '..', 'data', 'Carpenter_Formulary.xlsx'));
const ws = wb.Sheets['Table 1'];

// ===== 检测每张表的列结构 =====
const tables = [];
for (let r = 0; r < 3781; r++) {
  const cell = ws[XLSX.utils.encode_cell({r, c: 0})];
  if (cell && String(cell.v).startsWith('Table ')) tables.push({ row: r, title: String(cell.v).trim() });
}
tables.push({ row: 3782, title: '' });

// 对每个表格区间，找 Agent 行 -> 确定剂量列和物种列
const sections = [];
for (let i = 0; i < tables.length - 1; i++) {
  const t = tables[i];
  const start = t.row;
  const end = tables[i + 1].row;
  let doseCol = -1, speciesCol = -1, agentRow = -1;

  for (let r = start; r < Math.min(start + 40, end); r++) {
    const agentCell = ws[XLSX.utils.encode_cell({r, c: 0})];
    if (agentCell && String(agentCell.v).trim() === 'Agent') {
      agentRow = r;
      for (let c = 0; c < 70; c++) {
        const cell = ws[XLSX.utils.encode_cell({r, c})];
        if (!cell) continue;
        const v = String(cell.v).trim().toLowerCase();
        if (v.startsWith('dosage')) doseCol = c;
        if (v.includes('species')) speciesCol = c;
      }
      break;
    }
  }

  if (doseCol >= 0) {
    sections.push({
      title: t.title,
      startRow: t.row,
      endRow: end,
      agentRow,
      doseCol,
      speciesCol,
    });
  }
}

// ===== 翻译 =====
const zh = {
  'African grey parrot': '非洲灰鹦鹉', 'Amazon parrot': '亚马逊鹦鹉',
  'Amazon parrots': '亚马逊鹦鹉', 'Blue-fronted Amazon': '蓝顶亚马逊鹦鹉',
  'cockatiel': '玄凤鹦鹉', 'cockatoo': '凤头鹦鹉', 'macaw': '金刚鹦鹉',
  'Blue and gold macaw': '蓝黄金刚鹦鹉', 'Hyacinth macaw': '风信子金刚鹦鹉',
  'Scarlet macaw': '绯红金刚鹦鹉',
  'conure': '锥尾鹦鹉', 'lovebird': '牡丹鹦鹉', 'budgerigar': '虎皮鹦鹉',
  'budgie': '虎皮鹦鹉', 'parakeet': '鹦鹉', 'eclectus': '折衷鹦鹉',
  'senegal': '塞内加尔鹦鹉', 'quaker': '和尚鹦鹉', 'monk parakeet': '和尚鹦鹉',
  'lory': '吸蜜鹦鹉', 'lorikeet': '吸蜜鹦鹉', 'caique': '凯克鹦鹉',
  'parrot': '鹦鹉', 'parrots': '鹦鹉', 'Psittaciformes': '鹦鹉目',
  'psittacine': '鹦鹉类', 'psittacines': '鹦鹉类', 'Psittacines': '鹦鹉类',
  'passerine': '雀形目', 'canary': '金丝雀', 'finch': '雀',
  'raptor': '猛禽', 'raptors': '猛禽',
  'pigeon': '鸽', 'dove': '鸽', 'most species': '大多数鸟类',
  'all species': '所有鸟类', 'including': '包括',
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

const drugNames = [
  ['Amikacin', '阿米卡星'], ['Gentamicin', '庆大霉素'], ['Kanamycin', '卡那霉素'],
  ['Neomycin', '新霉素'], ['Tobramycin', '妥布霉素'], ['Spectinomycin', '大观霉素'], ['Streptomycin', '链霉素'],
  ['Amoxicillin sodium', '阿莫西林钠'], ['Amoxicillin trihydrate', '阿莫西林'],
  ['Amoxicillin/clavulanate', '阿莫西林克拉维酸'],
  ['Ampicillin sodium', '氨苄西林钠'], ['Ampicillin trihydrate', '氨苄西林'],
  ['Penicillin G', '青霉素G'],
  ['Cephalexin', '头孢氨苄'], ['Cefadroxil', '头孢羟氨苄'], ['Cefazolin', '头孢唑林'],
  ['Cephradine', '头孢拉定'], ['Cloxacillin', '氯唑西林'],
  ['Doxycycline', '多西环素'], ['Tetracycline', '四环素'], ['Chlortetracycline', '金霉素'],
  ['Azithromycin', '阿奇霉素'], ['Erythromycin', '红霉素'], ['Tylosin', '泰乐菌素'],
  ['Tiamulin', '泰妙菌素'], ['Tilmicosin', '替米考星'], ['Lincomycin', '林可霉素'],
  ['Clindamycin', '克林霉素'], ['Clarithromycin', '克拉霉素'], ['Clofazimine', '氯法齐明'],
  ['Enrofloxacin', '恩诺沙星'], ['Ciprofloxacin', '环丙沙星'], ['Marbofloxacin', '马波沙星'],
  ['Pradofloxacin', '普拉多沙星'], ['Danofloxacin', '达氟沙星'], ['Difloxacin', '二氟沙星'],
  ['Chloramphenicol', '氯霉素'], ['Chloramphenicol palmitate', '氯霉素棕榈酸酯'],
  ['Amphotericin B', '两性霉素B'], ['Clotrimazole', '克霉唑'], ['Enilconazole', '恩康唑'],
  ['Fluconazole', '氟康唑'], ['Itraconazole', '伊曲康唑'], ['Ketoconazole', '酮康唑'],
  ['Terbinafine', '特比萘芬'], ['Voriconazole', '伏立康唑'], ['Nystatin', '制霉菌素'],
  ['Metronidazole', '甲硝唑'], ['Fenbendazole', '芬苯达唑'], ['Ivermectin', '伊维菌素'],
  ['Praziquantel', '吡喹酮'], ['Toltrazuril', '妥曲珠利'], ['Ponazuril', '泊那珠利'],
  ['Meloxicam', '美洛昔康'], ['Carprofen', '卡洛芬'], ['Flunixin', '氟尼辛'],
  ['Ketoprofen', '酮洛芬'],
  ['Dexamethasone', '地塞米松'], ['Prednisolone', '泼尼松龙'], ['Prednisone', '泼尼松'],
  ['Acyclovir', '阿昔洛韦'], ['Famciclovir', '泛昔洛韦'],
  ['Sulfadiazine', '磺胺嘧啶'], ['Sulfadimethoxine', '磺胺二甲氧嘧啶'],
  ['Trimethoprim', '甲氧苄啶'],
  ['Colistin', '黏菌素'], ['Vancomycin', '万古霉素'], ['Bacitracin', '杆菌肽'],
  ['Rifampin', '利福平'], ['Rifabutin', '利福布丁'],
  ['Butorphanol', '布托啡诺'], ['Tramadol', '曲马多'],
  ['Midazolam', '咪达唑仑'], ['Diazepam', '地西泮'],
  ['Vitamin A', '维生素A'], ['Vitamin D3', '维生素D3'], ['Vitamin E', '维生素E'],
  ['Atropine', '阿托品'], ['Furosemide', '呋塞米'],
  ['Calcium gluconate', '葡萄糖酸钙'],
  ['Doxycycline hyclate', '多西环素盐酸盐'],
];

function getCn(en) {
  for (const [k, v] of drugNames) {
    if (en && en.startsWith(k)) return v;
  }
  return en || '';
}

function classify(name) {
  const c = {
    'Amikacin': '氨基糖苷类', 'Gentamicin': '氨基糖苷类', 'Kanamycin': '氨基糖苷类',
    'Neomycin': '氨基糖苷类', 'Tobramycin': '氨基糖苷类', 'Spectinomycin': '氨基糖苷类', 'Streptomycin': '氨基糖苷类',
    'Amoxicillin': '青霉素类', 'Ampicillin': '青霉素类', 'Penicillin': '青霉素类', 'Cloxacillin': '青霉素类',
    'Cephalexin': '头孢菌素类', 'Cefadroxil': '头孢菌素类', 'Cefazolin': '头孢菌素类', 'Cephradine': '头孢菌素类',
    'Doxycycline': '四环素类', 'Tetracycline': '四环素类', 'Chlortetracycline': '四环素类',
    'Azithromycin': '大环内酯类', 'Erythromycin': '大环内酯类', 'Tylosin': '大环内酯类',
    'Tiamulin': '大环内酯类', 'Tilmicosin': '大环内酯类', 'Clarithromycin': '大环内酯类',
    'Lincomycin': '林可胺类', 'Clindamycin': '林可胺类',
    'Enrofloxacin': '喹诺酮类', 'Ciprofloxacin': '喹诺酮类', 'Marbofloxacin': '喹诺酮类',
    'Pradofloxacin': '喹诺酮类', 'Danofloxacin': '喹诺酮类', 'Difloxacin': '喹诺酮类',
    'Chloramphenicol': '氯霉素类',
    'Amphotericin B': '抗真菌类', 'Clotrimazole': '抗真菌类', 'Enilconazole': '抗真菌类',
    'Fluconazole': '抗真菌类', 'Itraconazole': '抗真菌类', 'Ketoconazole': '抗真菌类',
    'Terbinafine': '抗真菌类', 'Voriconazole': '抗真菌类', 'Nystatin': '抗真菌类',
    'Metronidazole': '抗寄生虫类', 'Fenbendazole': '抗寄生虫类', 'Ivermectin': '抗寄生虫类',
    'Praziquantel': '抗寄生虫类', 'Toltrazuril': '抗寄生虫类', 'Ponazuril': '抗寄生虫类',
    'Meloxicam': '抗炎(NSAIDs)', 'Carprofen': '抗炎(NSAIDs)', 'Flunixin': '抗炎(NSAIDs)', 'Ketoprofen': '抗炎(NSAIDs)',
    'Dexamethasone': '皮质类固醇', 'Prednisolone': '皮质类固醇', 'Prednisone': '皮质类固醇',
    'Acyclovir': '抗病毒类', 'Famciclovir': '抗病毒类',
    'Butorphanol': '镇痛类', 'Tramadol': '镇痛类',
    'Midazolam': '镇静类', 'Diazepam': '镇静类',
    'Sulfadiazine': '磺胺类', 'Sulfadimethoxine': '磺胺类', 'Trimethoprim': '磺胺类',
    'Colistin': '多肽类', 'Vancomycin': '多肽类', 'Bacitracin': '多肽类',
    'Rifampin': '抗结核类', 'Rifabutin': '抗结核类', 'Clofazimine': '抗结核类',
    'Vitamin A': '营养补充', 'Vitamin D3': '营养补充', 'Vitamin E': '营养补充',
    'Furosemide': '利尿剂', 'Atropine': '抗胆碱类',
    'Calcium gluconate': '电解质',
  };
  for (const [k, v] of Object.entries(c)) {
    if (name && name.startsWith(k)) return v;
  }
  return '其他';
}

function hasParrot(s) {
  if (!s) return false;
  const sl = s.toLowerCase();
  return /parrot|psittacine|cockatiel|cockatoo|macaw|conure|lovebird|budgie|budgerigar|parakeet|eclectus|pionus|senegal|quaker|lory|lorikeet|caique|amazon|african grey|most species|all species|psittaciformes/i.test(sl);
}
function onlyNonParrot(s) {
  if (!s) return false;
  const sl = s.toLowerCase();
  return /^[\s,;]*(?:emu|ostrich|ratite|crane|bustard|penguin|heron|falcon|hawk|eagle|owl)/i.test(sl) && !hasParrot(s);
}

// ===== 提取每个表格的数据 =====
let outRows = [['所属表格', '药品(英文)', '中文名', '分类', '剂量原文', 'mg/kg下限', 'mg/kg上限', '给药途径', '频次', '适用物种原文', '适用物种中文', '备注']];
const drugSet = new Map();

for (const sec of sections) {
  if (!sec.title.includes('Antimicrobial') && !sec.title.includes('Antifungal') && !sec.title.includes('Antiviral') && !sec.title.includes('Antiparasitic') && !sec.title.includes('Anesthetic') && !sec.title.includes('Chemical Restraint') && !sec.title.includes('Antiinflammatory') && !sec.title.includes('Nonsteroidal') && !sec.title.includes('Hormones') && !sec.title.includes('Steroids') && !sec.title.includes('Psychotropic') && !sec.title.includes('Antiepileptic') && !sec.title.includes('Miscellaneous Agents') && !sec.title.includes('Toxicologic')) continue;

  const titleShort = sec.title.replace(/\s+/g, ' ').substring(0, 50);
  let currentDrug = '';

  for (let r = sec.agentRow + 1; r < sec.endRow; r++) {
    const nameCell = ws[XLSX.utils.encode_cell({r, c: 0})];
    const doseCell = ws[XLSX.utils.encode_cell({r, c: sec.doseCol})];
    const specCell = sec.speciesCol >= 0 ? ws[XLSX.utils.encode_cell({r, c: sec.speciesCol})] : null;

    if (!doseCell) continue;

    const doseRaw = String(doseCell.v).trim();
    const specRaw = specCell ? String(specCell.v).trim() : '';

    if (!doseRaw || doseRaw === '—') continue;

    // 检测药名行
    if (nameCell && String(nameCell.v).trim() && String(nameCell.v).trim() !== currentDrug) {
      const cnName = getCn(String(nameCell.v).trim());
      if (cnName || String(nameCell.v).trim().length < 40) {
        currentDrug = String(nameCell.v).trim();
      }
      if (!doseRaw.includes('PO')) continue;
      if (!hasParrot(specRaw)) continue;
      if (onlyNonParrot(specRaw)) continue;
    }

    // 药名行时先过筛
    if (nameCell && String(nameCell.v).trim() && String(nameCell.v).trim() !== currentDrug) {
      const n = String(nameCell.v).trim();
      if (n === 'Agent' || n.startsWith('Agent ')) continue;
    }

    if (!doseRaw.includes('PO')) continue;
    if (!hasParrot(specRaw)) continue;
    if (onlyNonParrot(specRaw)) continue;

    // 解析剂量
    const range = doseRaw.match(/([\d.]+)\s*[-–]\s*([\d.]+)\s*mg\/kg/);
    const single = doseRaw.match(/([\d.]+)\s*mg\/kg/);
    let min = '', max = '';
    if (range) { min = range[1]; max = range[2]; }
    else if (single) { min = single[1]; max = single[1]; }

    const freq = doseRaw.match(/(q\d+h|q\d+d|BID|SID|TID)/i);
    const freqStr = freq ? freq[1] : '';

    // 物种和备注分开
    if (!min && !max) continue; // 跳过没有mg/kg的条目
    if (!getCn(currentDrug) || getCn(currentDrug) === currentDrug) continue; // 只保留有中文名的药

    const speciesParts = specRaw.split(/[;/]/);
    const mainSpp = speciesParts[0].trim();
    const notes = speciesParts.slice(1).join('; ').trim();

    outRows.push([
      titleShort, currentDrug, getCn(currentDrug), classify(currentDrug),
      doseRaw, min, max, '口服',
      freqStr, specRaw, toCn(mainSpp),
      notes ? toCn(notes.substring(0, 150)) : '',
    ]);

    if (!drugSet.has(currentDrug)) drugSet.set(currentDrug, { min: 999, max: 0, entries: 0 });
    const d = drugSet.get(currentDrug);
    if (min) d.min = Math.min(d.min, parseFloat(min));
    if (max) d.max = Math.max(d.max, parseFloat(max));
    d.entries++;
  }
}

// ===== 输出 =====
const outWb = XLSX.utils.book_new();
const outWs = XLSX.utils.aoa_to_sheet(outRows);
outWs['!cols'] = [
  {wch: 42}, {wch: 32}, {wch: 18}, {wch: 14},
  {wch: 40}, {wch: 10}, {wch: 10}, {wch: 8},
  {wch: 10}, {wch: 55}, {wch: 40}, {wch: 50},
];
XLSX.utils.book_append_sheet(outWb, outWs, '口服鹦鹉用药');
const outPath = path.join(__dirname, '..', 'data', '口服鹦鹉用药_Carpenter_审核.xlsx');
XLSX.writeFile(outWb, outPath);

console.log('✅ 全部完成！');
console.log('总记录数: ' + (outRows.length - 1));
console.log('药品种类: ' + drugSet.size + '\n');

const sorted = [...drugSet.entries()].filter(([name]) => name !== 'Agent').sort((a, b) => a[0].localeCompare(b[0]));
sorted.forEach(([name, info]) => {
  const cn = getCn(name);
  const cat = classify(name);
  console.log(cn.padEnd(16) + ' ' + String(info.min).padStart(5) + '-' + String(info.max).padEnd(5) + ' mg/kg  ' + cat + '  (' + info.entries + '条)');
});
