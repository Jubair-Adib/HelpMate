import 'service.dart';
import 'user.dart';
import 'worker.dart' as worker_models;

class Order {
  final int id;
  final int userId;
  final int workerId;
  final int serviceId;
  final String status;
  final String? description;
  final DateTime? scheduledDate;
  final DateTime? completedDate;
  final double totalAmount;
  final int hours;
  final String? paymentMethod;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Service? service;
  final User? user;
  final worker_models.Worker? worker;

  Order({
    required this.id,
    required this.userId,
    required this.workerId,
    required this.serviceId,
    required this.status,
    this.description,
    this.scheduledDate,
    this.completedDate,
    required this.totalAmount,
    required this.hours,
    this.paymentMethod,
    required this.createdAt,
    this.updatedAt,
    this.service,
    this.user,
    this.worker,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['user_id'],
      workerId: json['worker_id'],
      serviceId: json['service_id'],
      status: json['status'],
      description: json['description'],
      scheduledDate:
          json['scheduled_date'] != null
              ? DateTime.parse(json['scheduled_date'])
              : null,
      completedDate:
          json['completed_date'] != null
              ? DateTime.parse(json['completed_date'])
              : null,
      totalAmount: json['total_amount'].toDouble(),
      hours: json['hours'] ?? 1,
      paymentMethod: json['payment_method'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
      service:
          json['service'] != null ? Service.fromJson(json['service']) : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      worker:
          json['worker'] != null
              ? worker_models.Worker.fromJson(json['worker'])
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
      'scheduled_date': scheduledDate?.toIso8601String(),
      'completed_date': completedDate?.toIso8601String(),
      'total_amount': totalAmount,
      'hours': hours,
      'payment_method': paymentMethod,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'service': service?.toJson(),
      'user': user?.toJson(),
      'worker': worker?.toJson(),
    };
  }
}
