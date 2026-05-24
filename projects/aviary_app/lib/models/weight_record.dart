class WeightRecord {
  final int id;
  final double weight;
  final String recordedAt;
  final String? notes;
  final bool isFasting;

  WeightRecord({
    required this.id,
    required this.weight,
    required this.recordedAt,
    this.notes,
    this.isFasting = true,
  });

  factory WeightRecord.fromJson(Map<String, dynamic> json) {
    return WeightRecord(
      id: json['id'] as int,
      weight: (json['weight'] as num).toDouble(),
      recordedAt: json['recorded_at'] as String? ?? '',
      notes: json['notes'] as String?,
      isFasting: (json['is_fasting'] as int?) == 1,
    );
  }

  String get formattedDate {
    try {
      final dt = DateTime.parse(recordedAt);
      return '${dt.month}/${dt.day} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return recordedAt;
    }
  }
}
