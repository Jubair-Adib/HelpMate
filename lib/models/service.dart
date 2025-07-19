class Service {
  final int id;
  final int workerId;
  final int categoryId;
  final String? categoryName;
  final String title;
  final String? description;
  final double hourlyRate;
  final int minimumHours;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Service({
    required this.id,
    required this.workerId,
    required this.categoryId,
    this.categoryName,
    required this.title,
    this.description,
    required this.hourlyRate,
    required this.minimumHours,
    required this.isAvailable,
    required this.createdAt,
    this.updatedAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] is int ? json['id'] : (json['id'] ?? 0),
      workerId:
          json['worker_id'] is int
              ? json['worker_id']
              : (json['worker_id'] ?? 0),
      categoryId:
          json['category_id'] is int
              ? json['category_id']
              : (json['category_id'] ?? 0),
      categoryName: json['category_name'],
      title: json['title'] ?? '',
      description: json['description'],
      hourlyRate:
          (json['hourly_rate'] != null)
              ? (json['hourly_rate'] as num).toDouble()
              : 0.0,
      minimumHours:
          json['minimum_hours'] is int
              ? json['minimum_hours']
              : (json['minimum_hours'] ?? 1),
      isAvailable: json['is_available'] ?? true,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'worker_id': workerId,
      'category_id': categoryId,
      'category_name': categoryName,
      'title': title,
      'description': description,
      'hourly_rate': hourlyRate,
      'minimum_hours': minimumHours,
      'is_available': isAvailable,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
