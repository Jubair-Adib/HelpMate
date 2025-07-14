import 'service.dart';

class Worker {
  final int id;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final String? address;
  final String? bio;
  final List<String>? skills;
  final double? hourlyRate;
  final int? experienceYears;
  final bool isAvailable;
  final double rating;
  final int totalReviews;
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? image;

  Worker({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    this.address,
    this.bio,
    this.skills,
    this.hourlyRate,
    this.experienceYears,
    required this.isAvailable,
    required this.rating,
    required this.totalReviews,
    required this.isVerified,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
    this.image,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['id'] is int ? json['id'] : (json['id'] ?? 0),
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      phoneNumber: json['phone_number']?.toString(),
      address: json['address']?.toString(),
      bio: json['bio']?.toString(),
      skills:
          json['skills'] != null
              ? List<String>.from(json['skills'])
              : <String>[],
      hourlyRate:
          json['hourly_rate'] != null
              ? (json['hourly_rate'] as num).toDouble()
              : 0.0,
      experienceYears:
          json['experience_years'] != null
              ? (json['experience_years'] as num).toInt()
              : 0,
      isAvailable: json['is_available'] ?? true,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : 0.0,
      totalReviews:
          json['total_reviews'] != null
              ? (json['total_reviews'] as num).toInt()
              : 0,
      isVerified: json['is_verified'] ?? false,
      isActive: json['is_active'] ?? true,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
      image: json['image']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'address': address,
      'bio': bio,
      'skills': skills,
      'hourly_rate': hourlyRate,
      'experience_years': experienceYears,
      'is_available': isAvailable,
      'rating': rating,
      'total_reviews': totalReviews,
      'is_verified': isVerified,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'image': image,
    };
  }
}
