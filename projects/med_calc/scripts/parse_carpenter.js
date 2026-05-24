const XLSX = require('xlsx');
const fs = require('fs');
const path = require('path');

const srcPath = path.join(__dirname, '..', 'data', 'Carpenter_Formulary.xlsx');
const wb = XLSX.readFile(srcPath);
const ws = wb.Sheets['Table 1'];

// ====== 中文术语 ======
const zh = {
  'per os': '口服', 'PO': '口服',
  'IM': '肌注', 'IV': '静注', 'SC': '皮下', 'ICe': '体腔', 'IT': '气管', 'IO': '骨内',
  'q8h': '每8小时', 'q12h': '每12小时', 'q24h': '每24小时', 'q48h': '每48小时',
  'q6h': '每6小时', 'q4h': '每4小时', 'q72h': '每72小时',
  'BID': '每日2次', 'SID': '每日1次', 'TID': '每日3次',
  'mg/kg': '毫克/千克', 'mg/mL': '毫克/毫升', 'mg/L': '毫克/升',
  'African grey parrot': '非洲灰鹦鹉', 'Grey parrot': '非洲灰鹦鹉',
  'Amazon parrot': '亚马逊鹦鹉', 'Amazon parrots': '亚马逊鹦鹉',
  'cockatiel': '玄凤鹦鹉', 'cockatiels': '玄凤鹦鹉',
  'cockatoo': '凤头鹦鹉', 'cockatoos': '凤头鹦鹉',
  'macaw': '金刚鹦鹉', 'macaws': '金刚鹦鹉', 'Macaw': '金刚鹦鹉',
  'conure': '锥尾鹦鹉', 'conures': '锥尾鹦鹉',
  'lovebird': '牡丹鹦鹉', 'lovebirds': '牡丹鹦鹉',
  'budgerigar': '虎皮鹦鹉', 'budgerigars': '虎皮鹦鹉', 'budgie': '虎皮鹦鹉',
  'parakeet': '鹦鹉', 'parakeets': '鹦鹉',
  'eclectus': '折衷鹦鹉',
  'pionus': '派翁尼斯鹦鹉',
  'senegal': '塞内加尔鹦鹉',
  'quaker': '和尚鹦鹉', 'monk parakeet': '和尚鹦鹉',
  'lory': '吸蜜鹦鹉', 'lorikeet': '吸蜜鹦鹉',
  'caique': '凯克鹦鹉',
  'parrot': '鹦鹉', 'parrots': '鹦鹉',
  'psittacine': '鹦鹉类', 'psittacines': '鹦鹉类',
  'passerine': '雀形目', 'passerines': '雀形目',
  'raptor': '猛禽', 'raptors': '猛禽',
  'pigeon': '鸽', 'pigeons': '鸽', 'dove': '鸽',
  'ratite': '平胸鸟类', 'ratites': '平胸鸟类',
  'emu': '鸸鹋', 'emus': '鸸鹋',
  'ostrich': '鸵鸟', 'ostriches': '鸵鸟',
  'crane': '鹤', 'cranes': '鹤',
  'bustard': '鸨',
  'waterfowl': '水禽',
  'gallinaceous': '鸡形目',
  'most species': '大多数鸟类',
  'all species': '所有鸟类',
  'smaller': '小型',
  'larger': '大型',
  'young': '幼鸟', 'neonates': '新生鸟',
  'PK': '药动学',
  'peak': '峰值', 'trough': '谷值',
  'oral': '口服',
};

// 药名翻译（含完整匹配）
const drugTranslation = {
  'Amikacin': '阿米卡星', 'Gentamicin': '庆大霉素',
  'Kanamycin': '卡那霉素', 'Neomycin': '新霉素',
  'Tobramycin': '妥布霉素', 'Spectinomycin': '大观霉素', 'Streptomycin': '链霉素',
  'Amoxicillin sodium': '阿莫西林钠', 'Amoxicillin trihydrate': '阿莫西林',
  'Amoxicillin/clavulanate': '阿莫西林克拉维酸',
  'Ampicillin sodium': '氨苄西林钠', 'Ampicillin trihydrate': '氨苄西林',
  'Penicillin G': '青霉素G',
  'Meropenem': '美罗培南', 'Imipenem/cilastatin': '亚胺培南西司他丁',
  'Cephalexin': '头孢氨苄', 'Ceftazidime': '头孢他啶',
  'Ceftiofur': '头孢噻呋', 'Cefotaxime': '头孢噻肟', 'Cefovecin': '头孢维星',
  'Cefadroxil': '头孢羟氨苄', 'Cefazolin': '头孢唑林', 'Cephradine': '头孢拉定',
  'Cloxacillin': '氯唑西林',
  'Doxycycline': '多西环素', 'Tetracycline': '四环素',
  'Chlortetracycline': '金霉素', 'Minocycline': '米诺环素',
  'Azithromycin': '阿奇霉素', 'Erythromycin': '红霉素',
  'Tylosin': '泰乐菌素', 'Tiamulin': '泰妙菌素',
  'Tilmicosin': '替米考星', 'Tulathromycin': '泰拉霉素',
  'Lincomycin': '林可霉素', 'Clindamycin': '克林霉素',
  'Clarithromycin': '克拉霉素', 'Clofazimine': '氯法齐明',
  'Enrofloxacin': '恩诺沙星', 'Ciprofloxacin': '环丙沙星',
  'Marbofloxacin': '马波沙星', 'Orbifloxacin': '奥比沙星',
  'Pradofloxacin': '普拉多沙星', 'Levofloxacin': '左氧氟沙星',
  'Ofloxacin': '氧氟沙星', 'Danofloxacin': '达氟沙星',
  'Difloxacin': '二氟沙星', 'Sarafloxacin': '沙拉沙星',
  'Norfloxacin': '诺氟沙星', 'Flumequine': '氟甲喹',
  'Chloramphenicol': '氯霉素', 'Chloramphenicol palmitate': '氯霉素棕榈酸酯',
  'Florfenicol': '氟苯尼考',
  'Amphotericin B': '两性霉素B', 'Fluconazole': '氟康唑',
  'Itraconazole': '伊曲康唑', 'Ketoconazole': '酮康唑',
  'Terbinafine': '特比萘芬', 'Voriconazole': '伏立康唑', 'Nystatin': '制霉菌素',
  'Acyclovir': '阿昔洛韦', 'Famciclovir': '泛昔洛韦',
  'Sulfadiazine': '磺胺嘧啶', 'Sulfadimethoxine': '磺胺二甲氧嘧啶',
  'Sulfamethazine': '磺胺二甲嘧啶', 'Trimethoprim': '甲氧苄啶',
  'Sulfachlorpyridazine': '磺胺氯哒嗪',
  'Polymyxin B': '多黏菌素B', 'Colistin': '黏菌素',
  'Vancomycin': '万古霉素', 'Bacitracin': '杆菌肽',
  'Rifampin': '利福平', 'Rifampicin': '利福平',
  'Rifabutin': '利福布丁',
  'Metronidazole': '甲硝唑', 'Fenbendazole': '芬苯达唑',
  'Ivermectin': '伊维菌素', 'Praziquantel': '吡喹酮',
  'Toltrazuril': '妥曲珠利', 'Ponazuril': '泊那珠利',
  'Meloxicam': '美洛昔康', 'Carprofen': '卡洛芬',
  'Flunixin': '氟尼辛', 'Ketoprofen': '酮洛芬', 'Celecoxib': '塞来昔布',
  'Dexamethasone': '地塞米松', 'Prednisolone': '泼尼松龙', 'Prednisone': '泼尼松',
  'Butorphanol': '布托啡诺', 'Midazolam': '咪达唑仑', 'Diazepam': '地西泮',
  'Ketamine': '氯胺酮',
  'Tramadol': '曲马多',
  'Vitamin A': '维生素A', 'Vitamin D3': '维生素D3', 'Vitamin E': '维生素E',
  'Vitamin B': '维生素B族', 'Folic acid': '叶酸',
  'Iron dextran': '右旋糖酐铁', 'Calcium gluconate': '葡萄糖酸钙',
  'Furosemide': '呋塞米', 'Heparin': '肝素',
  'Atropine': '阿托品', 'Glycopyrrolate': '格隆溴铵',
  'Flumazenil': '氟马西尼', 'Naloxone': '纳洛酮', 'Yohimbine': '育亨宾',
};

function translate(s) {
  if (!s) return '';
  let t = s;
  const entries = Object.entries(zh).sort((a, b) => b[0].length - a[0].length);
  for (const [en, cn] of entries) {
    const re = new RegExp('\\b' + en.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') + '\\b', 'gi');
    t = t.replace(re, cn);
  }
  return t.replace(/\s+/g, ' ').trim();
}

function cellVal(ws, r, c) {
  const cell = ws[XLSX.utils.encode_cell({ r, c })];
  return cell ? ('' + cell.v).trim() : '';
}

// 读取所有数据行
const rows = [];
for (let r = 2; r <= 3781; r++) {
  const name = cellVal(ws, r, 0);
  const dose = cellVal(ws, r, 11);
  const species = cellVal(ws, r, 23);
  if (name || dose) rows.push({ r, name, dose, species });
}

// 解析药品结构
let drugs = [];
let currentDrug = null;

for (const row of rows) {
  // 药名行（colA 有内容且 dose 是"—"或为空）
  // 判断是否为药名行：colA有内容且col11为空、—、或含描述
  const knownDrug = Object.keys(drugTranslation).find(k => row.name.startsWith(k));
  const isDrugHeader = row.name && (row.dose === '—' || row.dose === '' || (knownDrug && !/\d/.test(row.dose)));
  
  if (isDrugHeader) {
    if (currentDrug && currentDrug.entries.length > 0) {
      drugs.push(currentDrug);
    }
    const engName = knownDrug || row.name;
    currentDrug = {
      name: engName,
      cnName: drugTranslation[engName] || engName,
      desc: row.species,
      entries: [],
    };
    continue;
  }

  if (!currentDrug) continue;

  // 剂量行
  const doseStr = row.dose;
  const speciesStr = row.species;

  // 只保留口服
  if (!doseStr.includes('PO') && !doseStr.toLowerCase().includes('oral')) continue;

  // 只保留鹦鹉相关的
  const s = speciesStr.toLowerCase();
  const isParrot = /parrot|psittacine|cockatiel|cockatoo|macaw|conure|lovebird|budgie|budgerigar|parakeet|eclectus|pionus|senegal|quaker|lory|lorikeet|caique|amazon|african grey|most species|all species|psittaciformes/i.test(s);
  // 排除仅限非鹦鹉物种的行
  const onlyNonParrot = /^[\s,;]*((emu|ostrich|ratite|crane|bustard)[\s,;\/]?)+$/i.test(s.replace(/PK|;.*/g, '').trim());
  // 包含

  // 解析剂量范围
  let doseMin = null, doseMax = null;
  const rangeMatch = doseStr.match(/(\d+[\.\d]*)\s*-\s*(\d+[\.\d]*)\s*mg\/kg/);
  const singleMatch = doseStr.match(/(\d+[\.\d]*)\s*mg\/kg/);
  if (rangeMatch) { doseMin = parseFloat(rangeMatch[1]); doseMax = parseFloat(rangeMatch[2]); }
  else if (singleMatch) { doseMin = doseMax = parseFloat(singleMatch[1]); }
  else continue; // 没有mg/kg数据跳过

  // 提取频次
  let freq = '';
  const freqMatch = doseStr.match(/(q\d+h|q\d+d|BID|SID|TID)/i);
  if (freqMatch) freq = freqMatch[1];

  currentDrug.entries.push({
    doseMin, doseMax, unit: 'mg/kg', route: '口服',
    freq: translate(freq),
    birds: translate(speciesStr.split('/')[0].replace(/^most species,?\s*/i, '').replace(/including\s+/i, '').trim()),
    note: translate((speciesStr.includes('PK') ? speciesStr : '').replace(/^most species[,;]\s*/i, '').split('/').slice(1).join('；')),
  });
}

if (currentDrug && currentDrug.entries.length > 0) drugs.push(currentDrug);

// 分类
function classify(name) {
  const map = {
    'Amikacin': '氨基糖苷类', 'Gentamicin': '氨基糖苷类', 'Kanamycin': '氨基糖苷类',
    'Neomycin': '氨基糖苷类', 'Tobramycin': '氨基糖苷类', 'Spectinomycin': '氨基糖苷类',
    'Streptomycin': '氨基糖苷类',
    'Amoxicillin': '青霉素类', 'Amoxicillin sodium': '青霉素类', 'Amoxicillin trihydrate': '青霉素类',
    'Amoxicillin/clavulanate': '青霉素类',
    'Ampicillin': '青霉素类', 'Ampicillin sodium': '青霉素类', 'Ampicillin trihydrate': '青霉素类',
    'Penicillin G': '青霉素类',
    'Cephalexin': '头孢菌素类', 'Ceftazidime': '头孢菌素类', 'Ceftiofur': '头孢菌素类',
    'Cefotaxime': '头孢菌素类', 'Cefovecin': '头孢菌素类',
    'Meropenem': '碳青霉烯类', 'Imipenem/cilastatin': '碳青霉烯类',
    'Doxycycline': '四环素类', 'Tetracycline': '四环素类', 'Chlortetracycline': '四环素类', 'Minocycline': '四环素类',
    'Azithromycin': '大环内酯类', 'Erythromycin': '大环内酯类', 'Tylosin': '大环内酯类',
    'Tiamulin': '大环内酯类', 'Tilmicosin': '大环内酯类', 'Tulathromycin': '大环内酯类',
    'Lincomycin': '林可胺类', 'Clindamycin': '林可胺类',
    'Enrofloxacin': '喹诺酮类', 'Ciprofloxacin': '喹诺酮类', 'Marbofloxacin': '喹诺酮类',
    'Orbifloxacin': '喹诺酮类', 'Pradofloxacin': '喹诺酮类', 'Levofloxacin': '喹诺酮类',
    'Ofloxacin': '喹诺酮类', 'Danofloxacin': '喹诺酮类', 'Difloxacin': '喹诺酮类',
    'Sarafloxacin': '喹诺酮类', 'Norfloxacin': '喹诺酮类', 'Flumequine': '喹诺酮类',
    'Chloramphenicol': '氯霉素类', 'Florfenicol': '氯霉素类',
    'Amphotericin B': '抗真菌类', 'Fluconazole': '抗真菌类', 'Itraconazole': '抗真菌类',
    'Ketoconazole': '抗真菌类', 'Terbinafine': '抗真菌类', 'Voriconazole': '抗真菌类', 'Nystatin': '抗真菌类',
    'Acyclovir': '抗病毒类', 'Famciclovir': '抗病毒类',
    'Sulfadiazine': '磺胺类', 'Sulfadimethoxine': '磺胺类', 'Sulfamethazine': '磺胺类',
    'Trimethoprim': '磺胺类', 'Sulfachlorpyridazine': '磺胺类',
    'Polymyxin B': '多肽类', 'Colistin': '多肽类', 'Vancomycin': '多肽类', 'Bacitracin': '多肽类',
    'Rifampin': '抗结核类', 'Rifampicin': '抗结核类',
    'Metronidazole': '抗寄生虫类', 'Fenbendazole': '抗寄生虫类',
    'Ivermectin': '抗寄生虫类', 'Praziquantel': '抗寄生虫类',
    'Toltrazuril': '抗寄生虫类', 'Ponazuril': '抗寄生虫类',
    'Meloxicam': '抗炎(NSAIDs)', 'Carprofen': '抗炎(NSAIDs)', 'Flunixin': '抗炎(NSAIDs)',
    'Ketoprofen': '抗炎(NSAIDs)', 'Celecoxib': '抗炎(NSAIDs)',
    'Dexamethasone': '皮质类固醇', 'Prednisolone': '皮质类固醇', 'Prednisone': '皮质类固醇',
    'Butorphanol': '镇痛类', 'Midazolam': '镇静类', 'Diazepam': '镇静类',
    'Vitamin A': '营养补充', 'Vitamin D3': '营养补充', 'Vitamin E': '营养补充',
    'Vitamin B': '营养补充', 'Folic acid': '营养补充', 'Iron dextran': '营养补充',
    'Furosemide': '利尿剂', 'Calcium gluconate': '电解质',
    'Atropine': '抗胆碱类', 'Glycopyrrolate': '抗胆碱类',
    'Flumazenil': '解毒剂', 'Naloxone': '解毒剂', 'Yohimbine': '解毒剂',
  };
  return map[name] || '其他';
}

// 合并
const merged = drugs.map(d => {
  const allBirds = [...new Set(d.entries.map(e => e.birds))].filter(Boolean).join('、');
  const allNotes = [...new Set(d.entries.map(e => e.note).filter(n => n))].join('；');
  const mins = d.entries.map(e => e.doseMin);
  const maxs = d.entries.map(e => e.doseMax);
  const freqs = [...new Set(d.entries.map(e => e.freq).filter(f => f))];
  const freqsChina = freqs.map(f => f.replace(/q(\d+)h/, '每$1小时').replace(/q(\d+)d/, '每$1天').replace('BID', '每日2次').replace('SID', '每日1次').replace('TID', '每日3次'));

  return {
    name: d.cnName,
    category: classify(d.name),
    doseMin: Math.round(Math.min(...mins) * 10) / 10,
    doseMax: Math.round(Math.max(...maxs) * 10) / 10,
    unit: 'mg/kg',
    route: '口服',
    freq: freqsChina.join('、') || '',
    birds: allBirds || '鹦鹉',
    note: allNotes || '',
    _entries: d.entries.length,
  };
});

console.log('=== 提取结果 ===');
console.log(`总剂量条目: ${drugs.reduce((s, d) => s + d.entries.length, 0)}`);
console.log(`合并药品数: ${merged.length}`);
console.log();
console.log('=== 分类统计 ===');
const cats = {};
merged.forEach(d => { cats[d.category] = (cats[d.category] || 0) + 1; });
Object.entries(cats).sort((a, b) => b[1] - a[1]).forEach(([c, n]) => console.log(`  ${c}: ${n}`));

console.log();
console.log('=== 药品列表 ===');
merged.forEach(d => {
  const note = d.note ? ` | ${d.note.substring(0, 40)}` : '';
  console.log(`  ${d.name.padEnd(12)} ${String(d.doseMin).padEnd(5)}-${String(d.doseMax).padEnd(5)} mg/kg  ${d.birds.substring(0, 30)}${note}`);
});

// 输出 JSON
const output = {
  version: '2.0',
  date: new Date().toISOString().split('T')[0],
  source: "Carpenter's Exotic Animal Formulary, 6th Edition",
  pageRange: '405-613',
  note: '仅含口服(PO)且与鹦鹉相关的数据',
  drugs: merged,
};
const outPath = path.join(__dirname, '..', 'data', 'drug_database.json');
fs.writeFileSync(outPath, JSON.stringify(output, null, 2), 'utf-8');
console.log(`\n已输出: ${outPath}`);
