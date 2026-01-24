
class Product {
  final String id;
  final String shopId;
  final String name;
  final String description;
  final double price;
  final double originalPrice;
  final List<String> imageUrls;
  final String category;
  final bool isFavorite;
  final double rating;
  final bool hasPriceDrop;
  final double oldPrice;
  final bool hasDiscount;
  final double discountPercentage;
  final List<String> colors;
  final List<String> sizes;
  final String material;
  final List<String> reviews;

  Product({
    required this.id,
    required this.shopId,
    required this.name,
    this.description = '',
    required this.price,
    this.originalPrice = 0.0,
    this.imageUrls = const [],
    this.category = '',
    this.isFavorite = false,
    this.rating = 0.0,
    this.hasPriceDrop = false,
    this.oldPrice = 0.0,
    this.hasDiscount = false,
    this.discountPercentage = 0.0,
    this.colors = const [],
    this.sizes = const [],
    this.material = '',
    this.reviews = const [],
  });

  Product copyWith({
    String? id,
    String? shopId,
    String? name,
    String? description,
    double? price,
    double? originalPrice,
    List<String>? imageUrls,
    String? category,
    bool? isFavorite,
    double? rating,
    bool? hasPriceDrop,
    double? oldPrice,
    bool? hasDiscount,
    double? discountPercentage,
    List<String>? colors,
    List<String>? sizes,
    String? material,
    List<String>? reviews,
  }) {
    return Product(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      imageUrls: imageUrls ?? this.imageUrls,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      rating: rating ?? this.rating,
      hasPriceDrop: hasPriceDrop ?? this.hasPriceDrop,
      oldPrice: oldPrice ?? this.oldPrice,
      hasDiscount: hasDiscount ?? this.hasDiscount,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      colors: colors ?? this.colors,
      sizes: sizes ?? this.sizes,
      material: material ?? this.material,
      reviews: reviews ?? this.reviews,
    );
  }
}
