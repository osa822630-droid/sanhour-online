class Offer {
  final String id;
  final String shopId;
  final String title;
  final String description;
  final int discount;
  final DateTime validUntil;
  final String imageUrl;
  final bool isActive;
  final int views;
  final bool isFavorite;

  Offer({
    required this.id,
    required this.shopId,
    required this.title,
    required this.description,
    required this.discount,
    required this.validUntil,
    required this.imageUrl,
    required this.isActive,
    required this.views,
    this.isFavorite = false,
  });

  Offer copyWith({
    String? id,
    String? shopId,
    String? title,
    String? description,
    int? discount,
    DateTime? validUntil,
    String? imageUrl,
    bool? isActive,
    int? views,
    bool? isFavorite,
  }) {
    return Offer(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      title: title ?? this.title,
      description: description ?? this.description,
      discount: discount ?? this.discount,
      validUntil: validUntil ?? this.validUntil,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      views: views ?? this.views,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  bool get isExpired => validUntil.isBefore(DateTime.now());
  bool get isAboutToExpire => validUntil.difference(DateTime.now()).inDays <= 3;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopId': shopId,
      'title': title,
      'description': description,
      'discount': discount,
      'validUntil': validUntil.toIso8601String(),
      'imageUrl': imageUrl,
      'isActive': isActive,
      'views': views,
      'isFavorite': isFavorite,
    };
  }

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'] ?? '',
      shopId: json['shopId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      discount: (json['discount'] as num?)?.toInt() ?? 0,
      validUntil: DateTime.parse(json['validUntil'] ?? DateTime.now().toIso8601String()),
      imageUrl: json['imageUrl'] ?? '',
      isActive: json['isActive'] ?? false,
      views: (json['views'] as num?)?.toInt() ?? 0,
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Offer &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}