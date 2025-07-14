class User {
  final int id;
  final String email;
  final String fullName;
  final String phone;
  final String address;
  final String userType;
  final DateTime createdAt;
  final bool isAdmin;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.address,
    required this.userType,
    required this.createdAt,
    this.isAdmin = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      phone: json['phone_number'] ?? '',
      address: json['address'] ?? '',
      userType: json['user_type'] ?? 'user',
      createdAt: DateTime.parse(json['created_at']),
      isAdmin: json['is_admin'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone_number': phone,
      'address': address,
      'user_type': userType,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Worker extends User {
  final String skills;
  final double hourlyRate;
  final bool lookingForWork;
  final double? rating;
  final int? totalReviews;

  Worker({
    required super.id,
    required super.email,
    required super.fullName,
    required super.phone,
    required super.address,
    required super.userType,
    required super.createdAt,
    super.isAdmin = false,
    required this.skills,
    required this.hourlyRate,
    required this.lookingForWork,
    this.rating,
    this.totalReviews,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      phone: json['phone'],
      address: json['address'],
      userType: json['user_type'],
      createdAt: DateTime.parse(json['created_at']),
      isAdmin: json['is_admin'] ?? false,
      skills: json['skills'],
      hourlyRate: json['hourly_rate'].toDouble(),
      lookingForWork: json['looking_for_work'],
      rating: json['rating']?.toDouble(),
      totalReviews: json['total_reviews'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'skills': skills,
      'hourly_rate': hourlyRate,
      'looking_for_work': lookingForWork,
      'rating': rating,
      'total_reviews': totalReviews,
    };
  }
}
