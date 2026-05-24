class Bird {
  final int id;
  final String name;
  final String? ringNumber;
  final String? gender;
  final int? speciesId;
  final String? species;
  final String? status;
  final String? imagePath;
  final String? reason; // 任务候选人原因

  Bird({
    required this.id,
    required this.name,
    this.ringNumber,
    this.gender,
    this.speciesId,
    this.species,
    this.status,
    this.imagePath,
    this.reason,
  });

  factory Bird.fromJson(Map<String, dynamic> json) {
    return Bird(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      ringNumber: json['ring_number'] as String?,
      gender: json['gender'] as String?,
      speciesId: json['species_id'] as int?,
      species: json['species'] as String? ?? json['bird_species'] as String?,
      status: json['status'] as String?,
      imagePath: json['image_path'] as String?,
      reason: json['reason'] as String?,
    );
  }

  String get displayName {
    if (ringNumber != null && ringNumber!.isNotEmpty) {
      return '$name ($ringNumber)';
    }
    return name;
  }

  String get genderEmoji => gender == '公' ? '♂' : (gender == '母' ? '♀' : '');
}
