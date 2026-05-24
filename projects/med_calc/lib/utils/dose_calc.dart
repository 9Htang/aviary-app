import '../models/drug.dart';

class DoseResult {
  final Drug drug;
  final double selectedDose;    // mg/kg
  final double birdWeightKg;
  final double drugStrength;    // mg per tablet
  final double dosePerTimeMl;   // 用户选的每次喂服量 (0.1/0.2/0.5/1.0)
  final double maxOralMl;       // 安全上限

  /// 需药量 (mg)
  double get requiredMg => birdWeightKg * selectedDose;

  /// 整片数量（向上取整）
  int get tabletsNeeded => (requiredMg / drugStrength).ceil();

  /// 实际总药量 (mg)
  double get actualMg => tabletsNeeded * drugStrength;

  /// 推荐加水量 (mL) — 使每次喂服量正好等于用户选的剂量
  double get waterVolumeMl {
    if (requiredMg <= 0) return 0;
    double vol = dosePerTimeMl * actualMg / requiredMg;
    // 取整到 0.05mL（用户称重可以精确到0.05g）
    return (vol * 20).roundToDouble() / 20.0;
  }

  /// 药液浓度 (mg/mL)
  double get concentration => actualMg / waterVolumeMl;

  /// 实际喂入药量 (mg)
  double get actualDoseMg => dosePerTimeMl * concentration;

  /// 是否超过安全上限
  bool get isOverLimit => dosePerTimeMl > maxOralMl;

  /// 是否在合理范围（80-120%）
  bool get isAccurate {
    if (requiredMg <= 0) return false;
    double ratio = actualDoseMg / requiredMg;
    return ratio >= 0.8 && ratio <= 1.2;
  }

  String get note {
    if (isOverLimit) return '⚠️ 超过安全上限 ${maxOralMl}mL！';
    double ratio = actualDoseMg / requiredMg;
    if (ratio > 1.2) return '💡 每次 ${dosePerTimeMl}mL 含药 ${actualDoseMg.toStringAsFixed(1)}mg（略超需药量），可以';
    if (ratio < 0.8) return '💡 每次 ${dosePerTimeMl}mL 含药 ${actualDoseMg.toStringAsFixed(1)}mg（略不足），可以';
    return '';
  }

  DoseResult({
    required this.drug,
    required this.selectedDose,
    required this.birdWeightKg,
    required this.drugStrength,
    required this.dosePerTimeMl,
    required this.maxOralMl,
  });
}

class DoseCalculator {
  static DoseResult calculate({
    required Drug drug,
    required double selectedDose,
    required double birdWeightG,
    required double drugStrength,
    required double dosePerTimeMl,
    required double maxOralMl,
  }) {
    return DoseResult(
      drug: drug,
      selectedDose: selectedDose,
      birdWeightKg: birdWeightG / 1000,
      drugStrength: drugStrength,
      dosePerTimeMl: dosePerTimeMl,
      maxOralMl: maxOralMl,
    );
  }
}
