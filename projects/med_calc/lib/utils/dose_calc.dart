import '../models/drug.dart';

class DoseResult {
  final Drug drug;
  final double selectedDose;    // mg/kg
  final double birdWeightKg;
  final double drugStrength;    // mg per tablet
  final double waterVolumeMl;   // user-set water volume
  final double maxOralMl;       // bird safety limit

  /// 需药量 (mg)
  double get requiredMg => birdWeightKg * selectedDose;

  /// 整片数量（向上取整）
  int get tabletsNeeded => (requiredMg / drugStrength).ceil();

  /// 实际总药量 (mg)
  double get actualMg => tabletsNeeded * drugStrength;

  /// 药液浓度 (mg/mL)
  double get concentration => actualMg / waterVolumeMl;

  /// 每次喂服量 (mL)
  double get dosePerTimeMl => requiredMg / concentration;

  /// 是否超过安全上限
  bool get isOverLimit => dosePerTimeMl > maxOralMl;

  /// 剩余药量 (mg) - 已配但没用到的
  double get wastedMg => actualMg - requiredMg;

  DoseResult({
    required this.drug,
    required this.selectedDose,
    required this.birdWeightKg,
    required this.drugStrength,
    required this.waterVolumeMl,
    required this.maxOralMl,
  });
}

class DoseCalculator {
  static DoseResult calculate({
    required Drug drug,
    required double selectedDose,
    required double birdWeightG,
    required double drugStrength,    // mg/tablet
    required double waterVolumeMl,
    required double maxOralMl,
  }) {
    return DoseResult(
      drug: drug,
      selectedDose: selectedDose,
      birdWeightKg: birdWeightG / 1000,
      drugStrength: drugStrength,
      waterVolumeMl: waterVolumeMl,
      maxOralMl: maxOralMl,
    );
  }
}
