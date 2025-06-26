class Service {
  final int id;
  final int workerId;
  final int categoryId;
  final String title;
  final String description;
  final double price;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;

  Service({
    required this.id,
    required this.workerId,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.isActive,
    required this.createdAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      workerId: json['worker_id'],
      categoryId: json['category_id'],
      title: json['title'],
      description: json['description'],
      price: json['price'].toDouble(),
      imageUrl: json['image_url'],
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'worker_id': workerId,
      'category_id': categoryId,
      'title': title,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
