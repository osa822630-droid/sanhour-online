import 'package:flutter/foundation.dart';
import '../models/shop.dart';
import '../models/product.dart';
import '../models/offer.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class FavoritesProvider with ChangeNotifier {
  final User? _user;
  final List<Shop> _favoriteShops = [];
  final List<Product> _favoriteProducts = [];
  final List<Offer> _favoriteOffers = [];
  bool _isLoading = false;

  FavoritesProvider(this._user, List<Shop> initialShops, List<Product> initialProducts, List<Offer> initialOffers) {
    _favoriteShops.addAll(initialShops);
    _favoriteProducts.addAll(initialProducts);
    _favoriteOffers.addAll(initialOffers);
    if (_user != null) {
      loadFavorites();
    }
  }

  List<Shop> get favoriteShops => _favoriteShops;
  List<Product> get favoriteProducts => _favoriteProducts;
  List<Offer> get favoriteOffers => _favoriteOffers;
  bool get isLoading => _isLoading;

  int get totalFavorites =>
      _favoriteShops.length + _favoriteProducts.length + _favoriteOffers.length;

  Future<void> loadFavorites() async {
    if (_user == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.getFavorites('shop');
      _favoriteShops.clear();
      // for (var shopId in favoriteIds) {
      //   // You might need a way to fetch full shop details from just an ID
      //   // This is a placeholder, assuming you have a way to get a Shop from an id.
      //   // _favoriteShops.add(await ApiService.getShopById(shopId));
      // }
    } catch (e) {
      debugPrint('Error loading favorite shops: $e');
    }

    try {
      await ApiService.getFavorites('product');
      _favoriteProducts.clear();
      // for (var productId in favoriteIds) {
      //   // Similarly, for products
      //   // _favoriteProducts.add(await ApiService.getProductById(productId));
      // }
    } catch (e) {
      debugPrint('Error loading favorite products: $e');
    }

    try {
      await ApiService.getFavorites('offer');
      _favoriteOffers.clear();
      // for (var offerId in favoriteIds) {
      //   // Similarly, for offers
      //   // _favoriteOffers.add(await ApiService.getOfferById(offerId));
      // }
    } catch (e) {
      debugPrint('Error loading favorite offers: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ... rest of the provider ...
}
