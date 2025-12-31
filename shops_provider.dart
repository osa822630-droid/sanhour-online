import 'package:flutter/foundation.dart';
import '../models/shop.dart';
import '../models/product.dart';
import '../models/offer.dart';
import '../services/api_service.dart';

class ShopsProvider with ChangeNotifier {
  List<Shop> _shops = [];
  List<Product> _products = [];
  List<Offer> _offers = [];
  bool _isLoading = false;
  String _error = '';
  int _currentPage = 1;
  bool _hasMore = true;
  
  List<Shop> get shops => _shops;
  List<Product> get products => _products;
  List<Offer> get offers => _offers;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get hasMore => _hasMore;

  List<Shop> get featuredShops => _shops.where((shop) => shop.isFeatured).toList();
  List<Product> get topProducts => _products.where((product) => product.views > 30).toList();
  List<Offer> get featuredOffers => _offers.where((offer) => offer.isActive).toList();

  List<Shop> get topVisitedShops {
    final sorted = List<Shop>.from(_shops)..sort((a, b) => b.views.compareTo(a.views));
    return sorted.take(10).toList();
  }

  List<Product> get topVisitedProducts {
    final sorted = List<Product>.from(_products)..sort((a, b) => b.views.compareTo(a.views));
    return sorted.take(10).toList();
  }

  List<Offer> get topVisitedOffers {
    final sorted = List<Offer>.from(_offers)..sort((a, b) => b.views.compareTo(a.views));
    return sorted.take(10).toList();
  }

  Future<void> loadShops({String category = 'all', int page = 1, bool refresh = false}) async {
    if (refresh) {
      _shops.clear();
      _currentPage = 1;
      _hasMore = true;
    }

    if (!_hasMore && !refresh) return;

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final loadedShops = await ApiService.getShops(category: category, page: page);
      
      if (loadedShops.isEmpty) {
        _hasMore = false;
      } else {
        _shops.addAll(loadedShops);
        _currentPage = page;
      }
      
      await _loadFavoritesForShops();
    } catch (e) {
      _error = 'فشل في تحميل المحلات: ${_getErrorMessage(e)}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProducts({String? shopId, String? category, bool refresh = false}) async {
    if (refresh) {
      _products.clear();
    }

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final loadedProducts = await ApiService.getProducts(shopId: shopId, category: category);
      if (refresh) {
        _products = loadedProducts;
      } else {
        _products.addAll(loadedProducts);
      }
      
      await _loadFavoritesForProducts();
    } catch (e) {
      _error = 'فشل في تحميل المنتجات: ${_getErrorMessage(e)}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadOffers({String? shopId, bool refresh = false}) async {
    if (refresh) {
      _offers.clear();
    }

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final loadedOffers = await ApiService.getOffers(shopId: shopId);
      if (refresh) {
        _offers = loadedOffers;
      } else {
        _offers.addAll(loadedOffers);
      }
      
      await _loadFavoritesForOffers();
    } catch (e) {
      _error = 'فشل في تحميل العروض: ${_getErrorMessage(e)}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTopVisited() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final [topShops, topProducts, topOffers] = await Future.wait([
        ApiService.getTopVisitedShops(),
        ApiService.getTopVisitedProducts(),
        ApiService.getTopVisitedOffers(),
      ]);

      _shops = topShops;
      _products = topProducts;
      _offers = topOffers;
      
      await Future.wait([
        _loadFavoritesForShops(),
        _loadFavoritesForProducts(),
        _loadFavoritesForOffers(),
      ]);
    } catch (e) {
      _error = 'فشل في تحميل البيانات: ${_getErrorMessage(e)}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadFavoritesForShops() async {
    try {
      final favoriteShopIds = await ApiService.getFavorites('shop');
      for (var i = 0; i < _shops.length; i++) {
        _shops[i] = _shops[i].copyWith(isFavorite: favoriteShopIds.contains(_shops[i].id));
      }
    } catch (e) {
      print('خطأ في تحميل مفضلة المحلات: $e');
    }
  }

  Future<void> _loadFavoritesForProducts() async {
    try {
      final favoriteProductIds = await ApiService.getFavorites('product');
      for (var i = 0; i < _products.length; i++) {
        _products[i] = _products[i].copyWith(isFavorite: favoriteProductIds.contains(_products[i].id));
      }
    } catch (e) {
      print('خطأ في تحميل مفضلة المنتجات: $e');
    }
  }

  Future<void> _loadFavoritesForOffers() async {
    try {
      final favoriteOfferIds = await ApiService.getFavorites('offer');
      for (var i = 0; i < _offers.length; i++) {
        _offers[i] = _offers[i].copyWith(isFavorite: favoriteOfferIds.contains(_offers[i].id));
      }
    } catch (e) {
      print('خطأ في تحميل مفضلة العروض: $e');
    }
  }

  Future<void> toggleShopFavorite(String shopId) async {
    try {
      final shopIndex = _shops.indexWhere((shop) => shop.id == shopId);
      if (shopIndex != -1) {
        final newFavoriteState = !_shops[shopIndex].isFavorite;
        _shops[shopIndex] = _shops[shopIndex].copyWith(isFavorite: newFavoriteState);
        notifyListeners();
        
        await ApiService.toggleFavorite('shop', shopId);
      }
    } catch (e) {
      // التراجع عن التغيير إذا فشل الطلب
      final shopIndex = _shops.indexWhere((shop) => shop.id == shopId);
      if (shopIndex != -1) {
        _shops[shopIndex] = _shops[shopIndex].copyWith(isFavorite: !_shops[shopIndex].isFavorite);
        notifyListeners();
      }
      print('فشل في تحديث المفضلة: $e');
    }
  }

  Future<void> toggleProductFavorite(String productId) async {
    try {
      final productIndex = _products.indexWhere((product) => product.id == productId);
      if (productIndex != -1) {
        final newFavoriteState = !_products[productIndex].isFavorite;
        _products[productIndex] = _products[productIndex].copyWith(isFavorite: newFavoriteState);
        notifyListeners();
        
        await ApiService.toggleFavorite('product', productId);
      }
    } catch (e) {
      final productIndex = _products.indexWhere((product) => product.id == productId);
      if (productIndex != -1) {
        _products[productIndex] = _products[productIndex].copyWith(isFavorite: !_products[productIndex].isFavorite);
        notifyListeners();
      }
      print('فشل في تحديث المفضلة: $e');
    }
  }

  Future<void> toggleOfferFavorite(String offerId) async {
    try {
      final offerIndex = _offers.indexWhere((offer) => offer.id == offerId);
      if (offerIndex != -1) {
        final newFavoriteState = !_offers[offerIndex].isFavorite;
        _offers[offerIndex] = _offers[offerIndex].copyWith(isFavorite: newFavoriteState);
        notifyListeners();
        
        await ApiService.toggleFavorite('offer', offerId);
      }
    } catch (e) {
      final offerIndex = _offers.indexWhere((offer) => offer.id == offerId);
      if (offerIndex != -1) {
        _offers[offerIndex] = _offers[offerIndex].copyWith(isFavorite: !_offers[offerIndex].isFavorite);
        notifyListeners();
      }
      print('فشل في تحديث المفضلة: $e');
    }
  }

  List<Shop> get favoriteShops => _shops.where((shop) => shop.isFavorite).toList();
  List<Product> get favoriteProducts => _products.where((product) => product.isFavorite).toList();
  List<Offer> get favoriteOffers => _offers.where((offer) => offer.isFavorite).toList();

  List<Shop> getDiscoveryShops({String? userPreferredCategory, int limit = 6}) {
    try {
      var discoveryShops = _shops.where((shop) {
        if (shop.rating < 4.0) return false;
        if (shop.views > 300) return false;
        if (userPreferredCategory != null && 
            userPreferredCategory != 'all' &&
            shop.category != userPreferredCategory) {
          return false;
        }
        return true;
      }).toList();
      
      discoveryShops = discoveryShops.map((shop) {
        return shop.copyWith(discoveryScore: shop.calculateDiscoveryScore());
      }).toList();
      
      discoveryShops.sort((a, b) => b.discoveryScore.compareTo(a.discoveryScore));
      return discoveryShops.take(limit).toList();
    } catch (e) {
      print('خطأ في حساب المحلات الاستكشافية: $e');
      return [];
    }
  }

  String _getErrorMessage(dynamic error) {
    final errorString = error.toString();
    if (errorString.contains('network') || errorString.contains('Connection')) {
      return 'حدث خطأ في الاتصال بالإنترنت';
    } else {
      return 'حدث خطأ في تحميل البيانات';
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }

  void refreshData() {
    _shops.clear();
    _products.clear();
    _offers.clear();
    _currentPage = 1;
    _hasMore = true;
    notifyListeners();
  }
}