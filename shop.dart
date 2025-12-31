class Shop {
  final String id;
  final String name;
  final String category;
  final String description;
  final String imageUrl;
  final double rating;
  final int reviews;
  final int views;
  final int uniqueVisitors; // زوار فريدون لمنع التكرار
  final String phone;
  final String location;
  final bool isFeatured;
  final List<String> workingDays;
  final String workingHours;
  final Map<String, String> socialMedia;
  final bool isFavorite;
  final double discoveryScore;
  final int favoriteCount; // عدد الإضافات للمفضلة
  final DateTime createdAt;
  final int rank; // ترتيب المحل في قسمه

  Shop({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.rating,
    required this.reviews,
    required this.views,
    required this.uniqueVisitors,
    required this.phone,
    required this.location,
    required this.isFeatured,
    required this.workingDays,
    required this.workingHours,
    this.socialMedia = const {},
    this.isFavorite = false,
    this.discoveryScore = 0.0,
    this.favoriteCount = 0,
    required this.createdAt,
    this.rank = 0,
  });

  Shop copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    String? imageUrl,
    double? rating,
    int? reviews,
    int? views,
    int? uniqueVisitors,
    String? phone,
    String? location,
    bool? isFeatured,
    List<String>? workingDays,
    String? workingHours,
    Map<String, String>? socialMedia,
    bool? isFavorite,
    double? discoveryScore,
    int? favoriteCount,
    DateTime? createdAt,
    int? rank,
  }) {
    return Shop(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      reviews: reviews ?? this.reviews,
      views: views ?? this.views,
      uniqueVisitors: uniqueVisitors ?? this.uniqueVisitors,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      isFeatured: isFeatured ?? this.isFeatured,
      workingDays: workingDays ?? this.workingDays,
      workingHours: workingHours ?? this.workingHours,
      socialMedia: socialMedia ?? this.socialMedia,
      isFavorite: isFavorite ?? this.isFavorite,
      discoveryScore: discoveryScore ?? this.discoveryScore,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      createdAt: createdAt ?? this.createdAt,
      rank: rank ?? this.rank,
    );
  }

  double calculateDiscoveryScore() {
    try {
      final ratingWeight = 0.5;
      final viewsWeight = 0.3;
      final favoritesWeight = 0.2;
      
      final normalizedRating = rating / 5.0;
      final normalizedViews = 1.0 - (views / 5000.0).clamp(0.0, 1.0);
      final normalizedFavorites = (favoriteCount / 100.0).clamp(0.0, 1.0);
      
      return (normalizedRating * ratingWeight) + 
             (normalizedViews * viewsWeight) + 
             (normalizedFavorites * favoritesWeight);
    } catch (e) {
      return 0.0;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviews': reviews,
      'views': views,
      'uniqueVisitors': uniqueVisitors,
      'phone': phone,
      'location': location,
      'isFeatured': isFeatured,
      'workingDays': workingDays,
      'workingHours': workingHours,
      'socialMedia': socialMedia,
      'isFavorite': isFavorite,
      'discoveryScore': discoveryScore,
      'favoriteCount': favoriteCount,
      'createdAt': createdAt.toIso8601String(),
      'rank': rank,
    };
  }

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviews: (json['reviews'] as num?)?.toInt() ?? 0,
      views: (json['views'] as num?)?.toInt() ?? 0,
      uniqueVisitors: (json['uniqueVisitors'] as num?)?.toInt() ?? 0,
      phone: json['phone'] ?? '',
      location: json['location'] ?? '',
      isFeatured: json['isFeatured'] ?? false,
      workingDays: List<String>.from(json['workingDays'] ?? []),
      workingHours: json['workingHours'] ?? '',
      socialMedia: Map<String, String>.from(json['socialMedia'] ?? {}),
      isFavorite: json['isFavorite'] ?? false,
      discoveryScore: (json['discoveryScore'] as num?)?.toDouble() ?? 0.0,
      favoriteCount: (json['favoriteCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      rank: (json['rank'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Shop &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}