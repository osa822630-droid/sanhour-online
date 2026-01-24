
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/shop.dart';
import '../models/product.dart';
import '../models/offer.dart';
import 'dart:async';

class ShopsProvider with ChangeNotifier {
  List<Shop> _shops = [];
  List<Shop> _allShops = [];
  List<Product> _products = [];
  List<Offer> _offers = [];
  bool _isLoading = false;
  String? _selectedCategory;
  String? _searchQuery;
  String? _error;

  List<Shop> get shops => _shops;
  List<Product> get products => _products;
  List<Offer> get offers => _offers;
  bool get isLoading => _isLoading;
  String? get selectedCategory => _selectedCategory;
  String? get searchQuery => _searchQuery;
  String? get error => _error;

  List<Shop> get featuredShops => _shops.where((s) => s.isFeatured).toList();
  List<Shop> get favoriteShops => _shops.where((s) => isFavorite(s.id)).toList();
  List<Product> get favoriteProducts => _products.where((p) => p.isFavorite).toList();
  List<Offer> get favoriteOffers => _offers.where((o) => o.isFavorite).toList();
  
  final Set<String> _favoriteShopIds = {};

  ShopsProvider() {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await fetchShops();
    await fetchProducts();
    await fetchOffers();
    final favoriteIds = await ApiService.getFavorites('shop');
    _favoriteShopIds.clear();
    _favoriteShopIds.addAll(favoriteIds);
    notifyListeners();
  }

  Future<void> fetchShops({String? category, bool refresh = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _selectedCategory = category;
      _allShops = await ApiService.getShops(category: category, query: _searchQuery);
      _applyFilterAndSearch();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchProducts({String? shopId, bool refresh = false}) async {
    _products = await ApiService.getProducts(shopId: shopId);
    notifyListeners();
  }

  Future<void> fetchOffers({String? shopId, bool refresh = false}) async {
    _offers = await ApiService.getOffers(shopId: shopId);
    notifyListeners();
  }

  Future<void> loadShops({bool refresh = false}) async {
    await fetchShops(refresh: refresh);
  }

  Future<void> loadProducts({bool refresh = false}) async {
    await fetchProducts(refresh: refresh);
  }

  Future<void> loadOffers({bool refresh = false}) async {
    await fetchOffers(refresh: refresh);
  }

  void search(String? query) {
    _searchQuery = query;
    _applyFilterAndSearch();
    notifyListeners();
  }

  void _applyFilterAndSearch() {
    _shops = _allShops;
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      _shops = _shops.where((shop) => shop.name.toLowerCase().contains(_searchQuery!.toLowerCase())).toList();
    }
  }
  
  bool isFavorite(String shopId) {
    return _favoriteShopIds.contains(shopId);
  }

  Future<void> toggleFavorite(String type, String id) async {
    if (type == 'shop') {
      _toggleShopFavorite(id);
    } else if (type == 'product') {
      _toggleProductFavorite(id);
    } else if (type == 'offer') {
      _toggleOfferFavorite(id);
    }
    notifyListeners();
    await ApiService.toggleFavorite(type, id); 
  }

  void _toggleShopFavorite(String shopId) {
      final shopIndex = _shops.indexWhere((s) => s.id == shopId);
      if (shopIndex != -1) {
        final shop = _shops[shopIndex];
        _shops[shopIndex] = shop.copyWith(isFavorite: !shop.isFavorite);
      }
  }

  void _toggleProductFavorite(String productId) {
      final productIndex = _products.indexWhere((p) => p.id == productId);
      if (productIndex != -1) {
        final product = _products[productIndex];
        _products[productIndex] = product.copyWith(isFavorite: !product.isFavorite);
      }
  }

  void _toggleOfferFavorite(String offerId) {
      final offerIndex = _offers.indexWhere((o) => o.id == offerId);
      if (offerIndex != -1) {
        final offer = _offers[offerIndex];
        _offers[offerIndex] = offer.copyWith(isFavorite: !offer.isFavorite);
      }
  }

  Future<void> toggleShopFavorite(String shopId) async {
    await toggleFavorite('shop', shopId);
  }

  Future<void> toggleProductFavorite(String productId) async {
    await toggleFavorite('product', productId);
  }

  Future<void> toggleOfferFavorite(String offerId) async {
    await toggleFavorite('offer', offerId);
  }
}
