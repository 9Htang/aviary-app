import sys, re, json
sys.stdout.reconfigure(encoding='utf-8')

with open('异宠药典_全文.txt', 'r', encoding='utf-8') as f:
    text = f.read()

# 章节结构
sections = re.findall(r'第[\u4e00-\u9fff\d]+章[\u4e00-\u9fff]+', text)
print('=== 章节结构 ===')
for s in sorted(set(sections)):
    print(f'  {s}')

# 关键数据统计
print()
print('=== 关键数据统计 ===')
print(f'总字符数: {len(text)}')
print(f'mg/kg 剂量: {len(re.findall(r"mg/kg", text))}')
print(f'混饮剂量: {len(re.findall(r"混饮", text))}')
print(f'饲料剂量: {len(re.findall(r"饲料", text))}')
print(f'PO(口服): {len(re.findall(r"\bPO\b", text))}')
print(f'IM(肌注): {len(re.findall(r"\bIM\b", text))}')
print(f'IV(静脉): {len(re.findall(r"\bIV\b", text))}')
print(f'SC(皮下): {len(re.findall(r"\bSC\b", text))}')

# 提取药名章节标题（更准确）
print()
print('=== 检测到的药品名 ===')
drug_patterns = [
    '阿莫西林', '氨苄西林', '头孢', '庆大霉素', '恩诺沙星', 
    '多西环素', '阿奇霉素', '克拉霉素', '甲硝唑', '氟康唑',
    '伊曲康唑', '两性霉素', '酮康唑', '泰妙菌素', '林可霉素',
    '克林霉素', '磺胺', '甲氧苄啶', '呋喃', '利福平',
    '强力霉素', '四环素', '氯霉素', '卡那霉素', '新霉素',
    '妥布霉素', '大观霉素', '链霉素', '杆菌肽', '万古霉素',
    '青霉素', '苯唑西林', '哌拉西林', '美罗培南', '亚胺培南',
    '多黏菌素', '黏菌素', '硝唑尼特', '托拉菌素', '泰拉霉素',
    '马波沙星', '奥比沙星', '麻保沙星', '帕珠沙星', '左氧氟沙星',
    '环丙沙星', '氧氟沙星', '培氟沙星', '达氟沙星', '二氟沙星',
    '沙拉沙星', '诺氟沙星', '氟甲喹', '红霉素', '螺旋霉素',
    '替米考星', '沃尼妙林', '氟苯尼考', '甲砜霉素', '地塞米松',
    '泼尼松', '布洛芬', '美洛昔康', '卡洛芬', '氟尼辛'
]
found = {}
for d in drug_patterns:
    count = len(re.findall(d, text))
    if count > 0:
        found[d] = count
for d, c in sorted(found.items(), key=lambda x: -x[1]):
    print(f'  {d}: {c}处')

# 找出常见的鸟种名
print()
print('=== 检测到的鸟种 ===')
birds = ['玄凤鹦鹉', '亚马逊鹦鹉', '金刚鹦鹉', '蓝黄金刚鹦鹉', '蓝顶亚马逊',
         '红尾', '雀形目', '鹦鹉', '鸽子', '金丝雀', '驼鸟', '平胸鸟类',
         '猛禽', '软食鸟', '雀', '鹅', '鸭', '鸡', '火鸡']
for b in birds:
    c = len(re.findall(b, text))
    if c > 0:
        print(f'  {b}: {c}处')

# 剂量模式统计
print()
print('=== 剂量模式分布 ===')
dose_patterns = [
    (r'\d+~\d+mg/kg', '范围剂量'),
    (r'\d+mg/kg', '固定剂量'),
    (r'\d+mg/L', '混饮浓度'),
    (r'\d+mg/kg 饲料', '饲料添加'),
    (r'\d+mg/kg, (PO|IM|IV|SC)', '剂量+途径'),
]
for pat, label in dose_patterns:
    c = len(re.findall(pat, text))
    print(f'  {label}: {c}处')
