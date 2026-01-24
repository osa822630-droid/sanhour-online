
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/shop.dart';
import '../models/product.dart';
import '../models/offer.dart';

class ApiService {
  static final List<Shop> _mockShops = [];
  static final List<Product> _mockProducts = [];
  static final List<Offer> _mockOffers = [];
  static bool _isDataGenerated = false;

  static void _generateMockData() {
    if (_isDataGenerated) return;
    _mockShops.clear();
    _mockProducts.clear();
    _mockOffers.clear();

    final categories = {
      'مأكولات ومشروبات': ['مطاعم', 'كافيهات', 'حلويات', 'عصائر'],
      'مواد غذائية': ['سوبرماركت', 'موزع جملة', 'فواكه وخضروات', 'مخبوزات', 'عطارة', 'جزارة', 'طيور'],
      'خدمات طبية': ['عيادات', 'معامل', 'صيدليات', 'مراكز طبية'],
    };

    int shopIdCounter = 1;
    final random = Random();

    categories.forEach((mainCategory, subCategories) {
      for (var subCategory in subCategories) {
        for (int i = 1; i <= 25; i++) {
          final shopId = 'shop_${shopIdCounter++}';
          _mockShops.add(Shop(
            id: shopId,
            name: 'محل $i في $subCategory',
            category: mainCategory,
            location: 'سنهور، الفيوم',
            imageUrl: 'https://picsum.photos/seed/$shopId/400/200',
            rating: 3.5 + random.nextDouble() * 1.5,
            views: random.nextInt(5000) + 200,
            reviews: random.nextInt(500),
            description: 'وصف تفصيلي لمحل $i.',
            phone: '010${random.nextInt(90000000) + 10000000}',
            facebookUrl: 'https://facebook.com/example',
            instagramUrl: 'https://instagram.com/example',
            whatsapp: 'https://wa.me/201012345678',
            tiktokUrl: 'https://tiktok.com/@example',
            isFeatured: random.nextBool(),
            favoriteCount: random.nextInt(1000),
            workingHours: '9 ص - 10 م',
            socialMedia: {'facebook': 'https://facebook.com/example'}
          ));
        }
      }
    });

    _isDataGenerated = true;
  }

  // --- Mock methods restored to fix analysis errors ---

  static Future<Map<String, dynamic>> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email == 'admin@example.com' && password == 'password') {
      return {'token': 'admin-token', 'user': {'name': 'Admin User', 'userType': 'admin'}};
    }
    return {'token': 'user-token', 'user': {'name': 'Test User', 'userType': 'customer'}};
  }

  static Future<Map<String, dynamic>> registerUser(Map<String, dynamic> userData) async {
      await Future.delayed(const Duration(seconds: 1));
      return {
        'token': 'new-user-token',
        'user': {'name': userData['name'], 'userType': 'customer'}
      };
  }

  static Future<Map<String, dynamic>> getAdminStats() async {
      await Future.delayed(const Duration(milliseconds: 500));
      return {
          'totalShops': _mockShops.length,
          'totalUsers': 1500, // Dummy data
          'pendingApprovals': 5, // Dummy data
      };
  }

    static Future<Map<String, dynamic>> getMerchantStats(String merchantId) async {
    await Future.delayed(const Duration(seconds: 1));

    return {
      'totalViews': 1245,
      'uniqueVisitors': 856,
      'totalFavorites': 234,
    };
  }

  static Future<void> toggleFavorite(String type, String id) async {
      await Future.delayed(const Duration(milliseconds: 200));
      debugPrint('Toggled favorite for $type with id $id');
      // This is a mock, so we don't need to change state here. The provider handles it.
  }

  static Future<List<String>> getFavorites(String type) async {
      await Future.delayed(const Duration(milliseconds: 200));
      // Return a dummy list of favorite IDs
      return _mockShops.where((s) => s.isFavorite).map((s) => s.id).toList()..add('shop_1');
  }

  static Future<String> uploadImage(String imagePath) async {
    await Future.delayed(const Duration(seconds: 2));
    return 'https://via.placeholder.com/300';
  }

  static Future<void> addRating(String shopId, double rating, String comment, List<String> images, String userId) async {
    await Future.delayed(const Duration(seconds: 1));
    debugPrint('Rating added for shop $shopId');
  }

  static Future<Map<String, dynamic>> processExcelFile(String filePath) async {
    await Future.delayed(const Duration(seconds: 3));
    return {
      'success': true,
      'message': 'File processed successfully',
      'processedItems': 20,
      'failedItems': 0,
    };
  }

  // --- Core API methods from previous step ---

  static Future<List<Shop>> getShops({String? category, String? query, int? page}) async {
    _generateMockData();
    await Future.delayed(const Duration(milliseconds: 300));
    var shops = _mockShops;
    if (category != null && category != 'all') {
      shops = shops.where((s) => s.category == category).toList();
    }
    if (query != null && query.isNotEmpty) {
      shops = shops.where((s) => s.name.toLowerCase().contains(query.toLowerCase())).toList();
    }
    return shops;
  }

  static Future<List<Product>> getProducts({String? shopId}) async {
    _generateMockData();
    await Future.delayed(const Duration(milliseconds: 300));
    return [];
  }

  static Future<List<Offer>> getOffers({String? shopId}) async {
    _generateMockData();
    await Future.delayed(const Duration(milliseconds: 300));
    return [];
  }

  static Future<Map<String, String>> addShop(Shop shop) async {
    _generateMockData();
    await Future.delayed(const Duration(seconds: 1));
    final newShop = shop.copyWith(id: 'shop_${_mockShops.length + 1}', views: 0, rating: 0.0);
    _mockShops.add(newShop);
    return {'status': 'success', 'message': 'Shop added successfully'};
  }

  static Future<Map<String, String>> deleteShop(String shopId) async {
    _generateMockData();
    await Future.delayed(const Duration(seconds: 1));
    _mockShops.removeWhere((shop) => shop.id == shopId);
    return {'status': 'success', 'message': 'Shop deleted successfully'};
  }

  static Future<Map<String, String>> updateShop(Shop shop) async {
    _generateMockData();
    await Future.delayed(const Duration(seconds: 1));
    int index = _mockShops.indexWhere((s) => s.id == shop.id);
    if (index != -1) {
      _mockShops[index] = shop;
      return {'status': 'success', 'message': 'Shop updated successfully'};
    } else {
      return {'status': 'error', 'message': 'Shop not found'};
    }
  }

  static Future<Map<String, dynamic>> importShopsFromExcel(String filePath) async {
    await Future.delayed(const Duration(seconds: 3));
    return {
      'success': true,
      'message': 'تم استيراد 25 محلاً بنجاح.',
      'importedCount': 25,
      'failedCount': 0,
    };
  }

  static Future<Map<String, int>> getAppStatistics() async {
    _generateMockData();
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'totalShops': _mockShops.length,
      'totalViews': _mockShops.fold(0, (sum, shop) => sum + shop.views),
      'totalFavorites': _mockShops.fold(0, (sum, shop) => sum + shop.favoriteCount),
    };
  }

  static Future<Map<String, double>> getCategoryChartData() async {
    _generateMockData();
    await Future.delayed(const Duration(milliseconds: 500));
    final Map<String, int> categoryCounts = {};
    for (var shop in _mockShops) {
      categoryCounts[shop.category] = (categoryCounts[shop.category] ?? 0) + 1;
    }
    return categoryCounts.map((key, value) => MapEntry(key, value.toDouble()));
  }
}
