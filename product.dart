class Product {
  final String id;
  final String shopId;
  final String name;
  final String description;
  final double price;
  final double? oldPrice; // للسعر القديم للإشعارات
  final List<String> imageUrls;
  final String category;
  final int views;
  final int uniqueVisitors;
  final double rating;
  final int reviews;
  final bool isFavorite;
  final List<String> sizes;
  final List<String> colors;
  final String material;
  final int favoriteCount;
  final DateTime createdAt;
  final bool isApproved; // للموافقة على التقييمات
  final List<Review> reviewsList;

  Product({
    required this.id,
    required this.shopId,
    required this.name,
    required this.description,
    required this.price,
    this.oldPrice,
    required this.imageUrls,
    required this.category,
    required this.views,
    required this.uniqueVisitors,
    required this.rating,
    required this.reviews,
    this.isFavorite = false,
    this.sizes = const [],
    this.colors = const [],
    this.material = '',
    this.favoriteCount = 0,
    required this.createdAt,
    this.isApproved = false,
    this.reviewsList = const [],
  });

  Product copyWith({
    String? id,
    String? shopId,
    String? name,
    String? description,
    double? price,
    double? oldPrice,
    List<String>? imageUrls,
    String? category,
    int? views,
    int? uniqueVisitors,
    double? rating,
    int? reviews,
    bool? isFavorite,
    List<String>? sizes,
    List<String>? colors,
    String? material,
    int? favoriteCount,
    DateTime? createdAt,
    bool? isApproved,
    List<Review>? reviewsList,
  }) {
    return Product(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      oldPrice: oldPrice ?? this.oldPrice,
      imageUrls: imageUrls ?? this.imageUrls,
      category: category ?? this.category,
      views: views ?? this.views,
      uniqueVisitors: uniqueVisitors ?? this.uniqueVisitors,
      rating: rating ?? this.rating,
      reviews: reviews ?? this.reviews,
      isFavorite: isFavorite ?? this.isFavorite,
      sizes: sizes ?? this.sizes,
      colors: colors ?? this.colors,
      material: material ?? this.material,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      createdAt: createdAt ?? this.createdAt,
      isApproved: isApproved ?? this.isApproved,
      reviewsList: reviewsList ?? this.reviewsList,
    );
  }

  bool get hasPriceDrop => oldPrice != null && oldPrice! > price;
  double get discountPercentage => hasPriceDrop ? ((oldPrice! - price) / oldPrice! * 100) : 0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopId': shopId,
      'name': name,
      'description': description,
      'price': price,
      'oldPrice': oldPrice,
      'imageUrls': imageUrls,
      'category': category,
      'views': views,
      'uniqueVisitors': uniqueVisitors,
      'rating': rating,
      'reviews': reviews,
      'isFavorite': isFavorite,
      'sizes': sizes,
      'colors': colors,
      'material': material,
      'favoriteCount': favoriteCount,
      'createdAt': createdAt.toIso8601String(),
      'isApproved': isApproved,
      'reviewsList': reviewsList.map((review) => review.toJson()).toList(),
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      shopId: json['shopId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      oldPrice: (json['oldPrice'] as num?)?.toDouble(),
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      category: json['category'] ?? '',
      views: (json['views'] as num?)?.toInt() ?? 0,
      uniqueVisitors: (json['uniqueVisitors'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviews: (json['reviews'] as num?)?.toInt() ?? 0,
      isFavorite: json['isFavorite'] ?? false,
      sizes: List<String>.from(json['sizes'] ?? []),
      colors: List<String>.from(json['colors'] ?? []),
      material: json['material'] ?? '',
      favoriteCount: (json['favoriteCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      isApproved: json['isApproved'] ?? false,
      reviewsList: List<Review>.from((json['reviewsList'] ?? []).map((x) => Review.fromJson(x))),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Review {
  final String id;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final List<String> images;
  final DateTime date;
  final bool isVerified; // تم التحقق من الشراء
  final bool isApproved; // موافقة المدير

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    this.images = const [],
    required this.date,
    this.isVerified = false,
    this.isApproved = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'images': images,
      'date': date.toIso8601String(),
      'isVerified': isVerified,
      'isApproved': isApproved,
    };
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      comment: json['comment'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      isVerified: json['isVerified'] ?? false,
      isApproved: json['isApproved'] ?? false,
    );
  }
}