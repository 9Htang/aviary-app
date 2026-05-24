import '../models/drug.dart';

class DoseResult {
  final Drug drug;
  final double selectedDose;      // mg/kg or IU/kg
  final double birdWeightKg;
  final double drugStrength;      // mg or 万IU per tablet
  final String strengthUnit;      // "mg" or "万IU"
  final double dosePerTimeMl;
  final double maxOralMl;

  String get doseUnit => drug.unit; // "mg/kg" or "IU/kg"
  bool get isIu => doseUnit.contains('IU');

  /// 需药量（统一单位：mg 或 万IU）
  double get requiredAmount {
    double raw = birdWeightKg * selectedDose;
    if (isIu) return raw / 10000; // IU → 万IU，与用户输入的 drugStrength 单位一致
    return raw;
  }

  /// 整片数量
  int get tabletsNeeded => (requiredAmount / drugStrength).ceil();

  /// 实际总药量
  double get actualAmount => tabletsNeeded * drugStrength;

  /// 推荐加水量
  double get waterVolumeMl {
    if (requiredAmount <= 0) return 0;
    double vol = dosePerTimeMl * actualAmount / requiredAmount;
    return (vol * 20).roundToDouble() / 20.0;
  }

  /// 药液浓度
  double get concentration => actualAmount / waterVolumeMl;

  /// 每次实际喂入药量
  double get actualDoseAmount => dosePerTimeMl * concentration;

  /// 安全上限检查
  bool get isOverLimit => dosePerTimeMl > maxOralMl;

  bool get isAccurate {
    if (requiredAmount <= 0) return false;
    double ratio = actualDoseAmount / requiredAmount;
    return ratio >= 0.8 && ratio <= 1.2;
  }

  String get note {
    if (isOverLimit) return '⚠️ 超过安全上限 ${maxOralMl}mL！';
    double ratio = actualDoseAmount / requiredAmount;
    if (ratio > 1.2) return '💡 每次 ${dosePerTimeMl}mL 含药 ${actualDoseAmount.toStringAsFixed(1)}${_unit}（略超）';
    if (ratio < 0.8) return '💡 每次 ${dosePerTimeMl}mL 含药 ${actualDoseAmount.toStringAsFixed(1)}${_unit}（略不足）';
    return '';
  }

  String get _unit => isIu ? '万IU' : 'mg';
  /// 显示用的剂量单位标签
  String get doseLabel => isIu ? '万IU' : 'mg';

  DoseResult({
    required this.drug,
    required this.selectedDose,
    required this.birdWeightKg,
    required this.drugStrength,
    required this.strengthUnit,
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
    required String strengthUnit,
    required double dosePerTimeMl,
    required double maxOralMl,
  }) {
    return DoseResult(
      drug: drug,
      selectedDose: selectedDose,
      birdWeightKg: birdWeightG / 1000,
      drugStrength: drugStrength,
      strengthUnit: strengthUnit,
      dosePerTimeMl: dosePerTimeMl,
      maxOralMl: maxOralMl,
    );
  }
}
