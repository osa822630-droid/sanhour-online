import 'package:flutter/foundation.dart';
import '../models/shop.dart';
import '../models/product.dart';
import '../models/offer.dart';
import '../services/api_service.dart';
import '../services/user_notification_service.dart';
import '../utils/logger.dart';

class FavoritesProvider with ChangeNotifier {
  final List<Shop> _favoriteShops = [];
  final List<Product> _favoriteProducts = [];
  final List<Offer> _favoriteOffers = [];
  bool _isLoading = false;

  List<Shop> get favoriteShops => _favoriteShops;
  List<Product> get favoriteProducts => _favoriteProducts;
  List<Offer> get favoriteOffers => _favoriteOffers;
  bool get isLoading => _isLoading;

  int get totalFavorites => _favoriteShops.length + _favoriteProducts.length + _favoriteOffers.length;

  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      final [shops, products, offers] = await Future.wait([
        ApiService.getFavorites('shop'),
        ApiService.getFavorites('product'),
        ApiService.getFavorites('offer'),
      ]);

      // تحميل بيانات المحلات المفضلة
      _favoriteShops.clear();
      for (final shopId in shops) {
        final shop = await _getShopById(shopId);
        if (shop != null) {
          _favoriteShops.add(shop.copyWith(isFavorite: true));
        }
      }

      // تحميل بيانات المنتجات المفضلة
      _favoriteProducts.clear();
      for (final productId in products) {
        final product = await _getProductById(productId);
        if (product != null) {
          _favoriteProducts.add(product.copyWith(isFavorite: true));
        }
      }

      // تحميل بيانات العروض المفضلة
      _favoriteOffers.clear();
      for (final offerId in offers) {
        final offer = await _getOfferById(offerId);
        if (offer != null) {
          _favoriteOffers.add(offer.copyWith(isFavorite: true));
        }
      }

      AppLogger.i('تم تحميل ${totalFavorites} عنصر في المفضلة');
    } catch (e) {
      AppLogger.e('خطأ في تحميل المفضلة', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isShopFavorite(String shopId) {
    return _favoriteShops.any((shop) => shop.id == shopId);
  }

  bool isProductFavorite(String productId) {
    return _favoriteProducts.any((product) => product.id == productId);
  }

  bool isOfferFavorite(String offerId) {
    return _favoriteOffers.any((offer) => offer.id == offerId);
  }

  Future<void> addShopToFavorites(Shop shop) async {
    if (!isShopFavorite(shop.id)) {
      try {
        await ApiService.toggleFavorite('shop', shop.id);
        _favoriteShops.add(shop.copyWith(isFavorite: true));
        notifyListeners();
        
        AppLogger.i('تم إضافة المحل ${shop.name} للمفضلة');
        
        // مراقبة العروض الجديدة في هذا المحل
        _monitorShopForNewOffers(shop);
      } catch (e) {
        AppLogger.e('خطأ في إضافة المحل للمفضلة', e);
        rethrow;
      }
    }
  }

  Future<void> removeShopFromFavorites(String shopId) async {
    try {
      await ApiService.toggleFavorite('shop', shopId);
      _favoriteShops.removeWhere((shop) => shop.id == shopId);
      notifyListeners();
      
      AppLogger.i('تم إزالة المحل $shopId من المفضلة');
    } catch (e) {
      AppLogger.e('خطأ في إزالة المحل من المفضلة', e);
      rethrow;
    }
  }

  Future<void> addProductToFavorites(Product product) async {
    if (!isProductFavorite(product.id)) {
      try {
        await ApiService.toggleFavorite('product', product.id);
        _favoriteProducts.add(product.copyWith(
          isFavorite: true,
          oldPrice: product.price, // حفظ السعر الحالي للمراقبة
        ));
        notifyListeners();
        
        AppLogger.i('تم إضافة المنتج ${product.name} للمفضلة');
        
        // مراقبة تغيرات السعر
        _monitorProductPrice(product);
      } catch (e) {
        AppLogger.e('خطأ في إضافة المنتج للمفضلة', e);
        rethrow;
      }
    }
  }

  Future<void> removeProductFromFavorites(String productId) async {
    try {
      await ApiService.toggleFavorite('product', productId);
      _favoriteProducts.removeWhere((product) => product.id == productId);
      notifyListeners();
      
      AppLogger.i('تم إزالة المنتج $productId من المفضلة');
    } catch (e) {
      AppLogger.e('خطأ في إزالة المنتج من المفضلة', e);
      rethrow;
    }
  }

  Future<void> addOfferToFavorites(Offer offer) async {
    if (!isOfferFavorite(offer.id)) {
      try {
        await ApiService.toggleFavorite('offer', offer.id);
        _favoriteOffers.add(offer.copyWith(isFavorite: true));
        notifyListeners();
        
        AppLogger.i('تم إضافة العرض ${offer.title} للمفضلة');
        
        // مراقبة تغيرات السعر في العرض
        _monitorOfferPrice(offer);
      } catch (e) {
        AppLogger.e('خطأ في إضافة العرض للمفضلة', e);
        rethrow;
      }
    }
  }

  Future<void> removeOfferFromFavorites(String offerId) async {
    try {
      await ApiService.toggleFavorite('offer', offerId);
      _favoriteOffers.removeWhere((offer) => offer.id == offerId);
      notifyListeners();
      
      AppLogger.i('تم إزالة العرض $offerId من المفضلة');
    } catch (e) {
      AppLogger.e('خطأ في إزالة العرض من المفضلة', e);
      rethrow;
    }
  }

  Future<void> toggleShopFavorite(Shop shop) async {
    if (isShopFavorite(shop.id)) {
      await removeShopFromFavorites(shop.id);
    } else {
      await addShopToFavorites(shop);
    }
  }

  Future<void> toggleProductFavorite(Product product) async {
    if (isProductFavorite(product.id)) {
      await removeProductFromFavorites(product.id);
    } else {
      await addProductToFavorites(product);
    }
  }

  Future<void> toggleOfferFavorite(Offer offer) async {
    if (isOfferFavorite(offer.id)) {
      await removeOfferFromFavorites(offer.id);
    } else {
      await addOfferToFavorites(offer);
    }
  }

  List<Shop> getShopsByCategory(String category) {
    return _favoriteShops.where((shop) => shop.category == category).toList();
  }

  List<Product> getProductsByCategory(String category) {
    return _favoriteProducts.where((product) => product.category == category).toList();
  }

  List<Offer> getExpiringOffers() {
    final now = DateTime.now();
    return _favoriteOffers.where((offer) => 
      offer.validUntil.difference(now).inDays <= 3 && offer.isActive
    ).toList();
  }

  List<Product> getProductsWithPriceDrop() {
    return _favoriteProducts.where((product) => product.hasPriceDrop).toList();
  }

  void clearAllFavorites() {
    _favoriteShops.clear();
    _favoriteProducts.clear();
    _favoriteOffers.clear();
    notifyListeners();
    
    AppLogger.i('تم مسح كل المفضلة');
  }

  // مراقبة العروض الجديدة في المحلات المفضلة
  void _monitorShopForNewOffers(Shop shop) {
    // في التطبيق الحقيقي، هنا سيتم الاتصال بالخادم للاشتراك في إشعارات المحل
    AppLogger.i('بدء مراقبة العروض الجديدة في ${shop.name}');
  }

  // مراقبة تغيرات أسعار المنتجات المفضلة
  void _monitorProductPrice(Product product) {
    // في التطبيق الحقيقي، هنا سيتم مراقبة تغيرات السعر
    AppLogger.i('بدء مراقبة سعر المنتج ${product.name}');
  }

  // مراقبة تغيرات أسعار العروض المفضلة
  void _monitorOfferPrice(Offer offer) {
    // في التطبيق الحقيقي، هنا سيتم مراقبة تغيرات السعر
    AppLogger.i('بدء مراقبة سعر العرض ${offer.title}');
  }

  // محاكاة اكتشاف انخفاض سعر منتج
  void simulatePriceDrop(String productId, double newPrice) {
    final productIndex = _favoriteProducts.indexWhere((p) => p.id == productId);
    if (productIndex != -1) {
      final product = _favoriteProducts[productIndex];
      if (newPrice < product.price) {
        _favoriteProducts[productIndex] = product.copyWith(
          oldPrice: product.price,
          price: newPrice,
        );
        
        // إرسال إشعار بانخفاض السعر
        UserNotificationService().notifyFavoriteProductPriceDrop(
          product.name,
          product.price,
          newPrice,
        );
        
        notifyListeners();
        AppLogger.i('انخفاض سعر المنتج ${product.name} إلى $newPrice');
      }
    }
  }

  Future<Shop?> _getShopById(String shopId) async {
    try {
      final shops = await ApiService.getShops();
      return shops.firstWhere((shop) => shop.id == shopId);
    } catch (e) {
      return null;
    }
  }

  Future<Product?> _getProductById(String productId) async {
    try {
      final products = await ApiService.getProducts();
      return products.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }

  Future<Offer?> _getOfferById(String offerId) async {
    try {
      final offers = await ApiService.getOffers();
      return offers.firstWhere((offer) => offer.id == offerId);
    } catch (e) {
      return null;
    }
  }
}