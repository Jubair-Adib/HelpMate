class Review {
  final int id;
  final String userName;
  final String? userImage;
  final double rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.userName,
    this.userImage,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? 0,
      userName:
          json['user'] != null ? (json['user']['full_name'] ?? 'User') : 'User',
      userImage: json['user'] != null ? json['user']['image'] : null,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      comment: json['comment'] ?? '',
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
    );
  }
}
