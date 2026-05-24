class TaskItem {
  final int id;
  final int taskId;
  final int birdId;
  final String taskType;
  final String? medication;
  final String? dosage;
  final String? notes;
  final int? isFasting;
  final int priority;
  final String status;
  final int sortOrder;
  final String? completedAt;
  final String? birdName;
  final String? birdRing;
  final String? birdSpecies;
  final String? gender;

  TaskItem({
    required this.id,
    required this.taskId,
    required this.birdId,
    required this.taskType,
    this.medication,
    this.dosage,
    this.notes,
    this.isFasting,
    this.priority = 0,
    this.status = 'pending',
    this.sortOrder = 0,
    this.completedAt,
    this.birdName,
    this.birdRing,
    this.birdSpecies,
    this.gender,
  });

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'] as int,
      taskId: json['task_id'] as int? ?? 0,
      birdId: json['bird_id'] as int,
      taskType: json['task_type'] as String? ?? 'weigh',
      medication: json['medication'] as String?,
      dosage: json['dosage'] as String?,
      notes: json['notes'] as String?,
      isFasting: json['is_fasting'] as int?,
      priority: json['priority'] as int? ?? 0,
      status: json['status'] as String? ?? 'pending',
      sortOrder: json['sort_order'] as int? ?? 0,
      completedAt: json['completed_at'] as String?,
      birdName: json['bird_name'] as String?,
      birdRing: json['bird_ring'] as String?,
      birdSpecies: json['bird_species'] as String?,
      gender: json['gender'] as String?,
    );
  }

  String get displayName => birdName ?? '鸟#$birdId';
  String get displayRing => birdRing != null ? '($birdRing)' : '';

  String get taskTypeLabel {
    switch (taskType) {
      case 'weigh': return '称重';
      case 'feed': return '喂食';
      case 'medicate': return '喂药';
      case 'check': return '检查';
      default: return taskType;
    }
  }

  String get fastingLabel => isFasting == 1 ? '空腹' : '未空腹';

  String get statusEmoji => status == 'done' ? '✅' : (status == 'skipped' ? '⏭️' : '⬜');
}
