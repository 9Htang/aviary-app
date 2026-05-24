class Bird {
  final String name;
  final String category;  // 小型/中型/大型
  final double weightMinG;
  final double weightMaxG;
  final double maxOralMl;  // 单次安全口服液量上限

  const Bird({
    required this.name,
    required this.category,
    required this.weightMinG,
    required this.weightMaxG,
    required this.maxOralMl,
  });
}

final List<Bird> birdSpecies = [
  Bird(name: '虎皮鹦鹉', category: '小型', weightMinG: 30, weightMaxG: 40, maxOralMl: 0.2),
  Bird(name: '牡丹鹦鹉', category: '小型', weightMinG: 40, weightMaxG: 60, maxOralMl: 0.2),
  Bird(name: '玄凤鹦鹉', category: '中型', weightMinG: 80, weightMaxG: 120, maxOralMl: 0.2),
  Bird(name: '小太阳鹦鹉', category: '中型', weightMinG: 60, weightMaxG: 100, maxOralMl: 0.2),
  Bird(name: '和尚鹦鹉', category: '中型', weightMinG: 100, weightMaxG: 150, maxOralMl: 0.2),
  Bird(name: '塞内加尔鹦鹉', category: '中型', weightMinG: 150, weightMaxG: 200, maxOralMl: 0.2),
  Bird(name: '亚马逊鹦鹉', category: '大型', weightMinG: 300, weightMaxG: 550, maxOralMl: 1.0),
  Bird(name: '非洲灰鹦鹉', category: '大型', weightMinG: 400, weightMaxG: 600, maxOralMl: 1.0),
  Bird(name: '蓝黄金刚鹦鹉', category: '大型', weightMinG: 900, weightMaxG: 1300, maxOralMl: 1.0),
  Bird(name: '金丝雀', category: '小型', weightMinG: 15, weightMaxG: 30, maxOralMl: 0.2),
  Bird(name: '鸽子', category: '大型', weightMinG: 250, weightMaxG: 500, maxOralMl: 1.0),
];
