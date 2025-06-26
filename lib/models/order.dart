class Order {
  final int id;
  final int userId;
  final int workerId;
  final int serviceId;
  final String status;
  final String description;
  final DateTime scheduledDate;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Order({
    required this.id,
    required this.userId,
    required this.workerId,
    required this.serviceId,
    required this.status,
    required this.description,
    required this.scheduledDate,
    required this.totalAmount,
    required this.createdAt,
    this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['user_id'],
      workerId: json['worker_id'],
      serviceId: json['service_id'],
      status: json['status'],
      description: json['description'],
      scheduledDate: DateTime.parse(json['scheduled_date']),
      totalAmount: json['total_amount'].toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'worker_id': workerId,
      'service_id': serviceId,
      'status': status,
      'description': description,
      'scheduled_date': scheduledDate.toIso8601String(),
      'total_amount': totalAmount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
