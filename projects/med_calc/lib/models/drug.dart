class Drug {
  final String name;
  final String category;
  final double doseMin;
  final double doseMax;
  final String unit;
  final String route;
  final String freq;
  final String birds;
  final String note;
  final String mechanism;
  final String sideEffects;

  const Drug({
    required this.name,
    required this.category,
    required this.doseMin,
    required this.doseMax,
    required this.unit,
    required this.route,
    required this.freq,
    required this.birds,
    this.note = '',
    this.mechanism = '',
    this.sideEffects = '',
  });

  double get doseMid => (doseMin + doseMax) / 2;

  factory Drug.fromJson(Map<String, dynamic> json) {
    return Drug(
      name: json['name'] as String,
      category: json['category'] as String,
      doseMin: (json['dose_min'] as num).toDouble(),
      doseMax: (json['dose_max'] as num).toDouble(),
      unit: json['unit'] as String,
      route: json['route'] as String,
      freq: json['freq'] as String,
      birds: json['birds'] as String,
      note: json['note'] as String? ?? '',
      mechanism: json['mechanism'] as String? ?? '',
      sideEffects: json['sideEffects'] as String? ?? '',
    );
  }
}
