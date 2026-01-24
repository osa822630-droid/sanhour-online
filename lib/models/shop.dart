
class Shop {
  final String id;
  final String name;
  final String category;
  final String location;
  final String imageUrl;
  final double rating;
  final int views;
  final String description;
  final String phone;
  final String? facebookUrl;
  final String? instagramUrl;
  final String? whatsapp;
  final String? tiktokUrl;
  
  // --- Fields restored to fix analysis errors ---
  final int reviews;
  final int uniqueVisitors;
  final bool isFeatured;
  final List<String> workingDays;
  final String workingHours;
  final Map<String, String> socialMedia;
  final int favoriteCount;
  final DateTime createdAt;
  final int rank;
  final bool isFavorite; // Added for provider logic


  Shop({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.imageUrl,
    this.rating = 0.0,
    this.views = 0,
    this.description = 'A great shop.',
    this.phone = 'No phone number available.',
    this.facebookUrl,
    this.instagramUrl,
    this.whatsapp,
    this.tiktokUrl,
    // --- Initialize restored fields ---
    this.reviews = 0,
    this.uniqueVisitors = 0,
    this.isFeatured = false,
    this.workingDays = const [],
    this.workingHours = 'N/A',
    this.socialMedia = const {},
    this.favoriteCount = 0,
    DateTime? createdAt,
    this.rank = 0,
    this.isFavorite = false,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Shop.fromMap(Map<String, dynamic> map, String id) {
    return Shop(
      id: id,
      name: map['name'] ?? 'No Name',
      category: map['category'] ?? 'Uncategorized',
      location: map['location'] ?? 'Unknown Location',
      imageUrl: map['imageUrl'] ?? 'https://via.placeholder.com/150',
      rating: (map['rating'] ?? 0.0).toDouble(),
      views: map['views'] ?? 0,
      description: map['description'] ?? 'A great shop.',
      phone: map['phone'] ?? 'No phone number available.',
      facebookUrl: map['facebookUrl'],
      instagramUrl: map['instagramUrl'],
      whatsapp: map['whatsapp'],
      tiktokUrl: map['tiktokUrl'],
      reviews: map['reviews'] ?? 0,
      uniqueVisitors: map['uniqueVisitors'] ?? 0,
      isFeatured: map['isFeatured'] ?? false,
      workingDays: List<String>.from(map['workingDays'] ?? []),
      workingHours: map['workingHours'] ?? 'N/A',
      socialMedia: Map<String, String>.from(map['socialMedia'] ?? {}),
      favoriteCount: map['favoriteCount'] ?? 0,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      rank: map['rank'] ?? 0,
      isFavorite: map['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'location': location,
      'imageUrl': imageUrl,
      'rating': rating,
      'views': views,
      'description': description,
      'phone': phone,
      'facebookUrl': facebookUrl,
      'instagramUrl': instagramUrl,
      'whatsapp': whatsapp,
      'tiktokUrl': tiktokUrl,
      'reviews': reviews,
      'uniqueVisitors': uniqueVisitors,
      'isFeatured': isFeatured,
      'workingDays': workingDays,
      'workingHours': workingHours,
      'socialMedia': socialMedia,
      'favoriteCount': favoriteCount,
      'createdAt': createdAt.toIso8601String(),
      'rank': rank,
      'isFavorite': isFavorite,
    };
  }

  // --- copyWith method restored to fix analysis errors ---
  Shop copyWith({
    String? id,
    String? name,
    String? category,
    String? location,
    String? imageUrl,
    double? rating,
    int? views,
    String? description,
    String? phone,
    String? facebookUrl,
    String? instagramUrl,
    String? whatsapp,
    String? tiktokUrl,
    int? reviews,
    int? uniqueVisitors,
    bool? isFeatured,
    List<String>? workingDays,
    String? workingHours,
    Map<String, String>? socialMedia,
    int? favoriteCount,
    DateTime? createdAt,
    int? rank,
    bool? isFavorite,
  }) {
    return Shop(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      views: views ?? this.views,
      description: description ?? this.description,
      phone: phone ?? this.phone,
      facebookUrl: facebookUrl ?? this.facebookUrl,
      instagramUrl: instagramUrl ?? this.instagramUrl,
      whatsapp: whatsapp ?? this.whatsapp,
      tiktokUrl: tiktokUrl ?? this.tiktokUrl,
      reviews: reviews ?? this.reviews,
      uniqueVisitors: uniqueVisitors ?? this.uniqueVisitors,
      isFeatured: isFeatured ?? this.isFeatured,
      workingDays: workingDays ?? this.workingDays,
      workingHours: workingHours ?? this.workingHours,
      socialMedia: socialMedia ?? this.socialMedia,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      createdAt: createdAt ?? this.createdAt,
      rank: rank ?? this.rank,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
