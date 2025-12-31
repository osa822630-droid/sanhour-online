// lib/services/api_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shop.dart';
import '../models/product.dart';
import '../models/offer.dart';

class ApiService {
  static const String baseUrl = 'https://mock-api.sanhour.com/api';
  
  static final List<Shop> _mockShops = [];
  static final List<Product> _mockProducts = [];
  static final List<Offer> _mockOffers = [];

  static bool _isDataGenerated = false;

  static void _generateMockData() {
    if (_isDataGenerated) return;

    final Map<String, List<String>> categories = {
      'مأكولات ومشروبات': ['مطاعم', 'كافيهات', 'حلويات', 'عصائر'],
      'مواد غذائية': ['سوبرماركت', 'موزع جملة', 'فواكه وخضروات', 'مخبوزات', 'عطارة', 'جزارة', 'طيور'],
      'خدمات طبية': ['عيادات', 'معامل', 'صيدليات', 'مراكز طبية'],
      'خدمات تعليمية': ['مدرسين', 'مكتبات', 'مطبعات', 'سناتر دروس', 'حضانات', 'كُتَّاب'],
      'ملابس': ['رجالي', 'حريمي', 'أولادي', 'شنط وأحذية', 'مصانع', 'أقمشة', 'تفصيل'],
      'أثاث وأجهزة': ['أجهزة كهربائية', 'موبيليا', 'مفروشات', 'أدوات منزلية', 'أدوات كهربائية', 'أدوات سباكة'],
      'خدمات المحمول': ['سنترال', 'محلات', 'صيانة'],
      'وِرَش': ['نجارة', 'حدادة'],
      'حِرَف': ['كهربائي', 'سباك', 'نجار', 'حداد', 'دِش', 'ترزي'],
    };

    int shopId = 1;
    int productId = 1;
    int offerId = 1;

    for (var mainCat in categories.keys) {
      for (var subCat in categories[mainCat]!) {
        for (int s = 1; s <= 5; s++) {
          final shop = Shop(
            id: (shopId++).toString(),
            name: 'محل $s في $subCat',
            category: mainCat,
            description: 'وصف للمحل $s في فئة $subCat. هذا المحل يقدم أفضل الخدمات والمنتجات.',
            imageUrl: 'https://via.placeholder.com/300x200/4CAF50/FFFFFF?text=محل+$s',
            rating: 4.0 + (s % 5) * 0.2,
            reviews: 10 * s,
            views: 100 * s,
            uniqueVisitors: (50 * s) + (s % 3) * 10,
            phone: '01234567${s.toString().padLeft(2, '0')}',
            location: 'سنهور، المنطقة ${s}',
            isFeatured: s % 3 == 0,
            workingDays: ['السبت', 'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس'],
            workingHours: '${8 + s % 4}:00 ص - ${8 + s % 4 + 8}:00 م',
            socialMedia: {
              if (s % 2 == 0) 'فيسبوك': 'https://facebook.com/shop$s',
              if (s % 3 == 0) 'انستجرام': 'https://instagram.com/shop$s',
            },
            favoriteCount: s * 5,
            createdAt: DateTime.now().subtract(Duration(days: s * 10)),
            rank: s,
          );
          _mockShops.add(shop);

          for (int p = 1; p <= 3; p++) {
            final hasPriceDrop = p % 2 == 0;
            _mockProducts.add(
              Product(
                id: (productId++).toString(),
                shopId: shop.id,
                name: 'منتج $p من ${shop.name}',
                description: 'وصف مفصل للمنتج $p. هذا المنتج يتميز بجودته العالية وسعره المناسب.',
                price: 10.0 * p + (s * 5),
                oldPrice: hasPriceDrop ? 15.0 * p + (s * 5) : null,
                imageUrls: [
                  'https://via.placeholder.com/200/2196F3/FFFFFF?text=منتج+$p',
                  'https://via.placeholder.com/200/FF9800/FFFFFF?text=صورة+2',
                ],
                category: subCat,
                views: p * 25 + s * 10,
                uniqueVisitors: (p * 15 + s * 5) + (p % 2) * 5,
                rating: 4.0 + (p % 5) * 0.3,
                reviews: p * 5,
                sizes: p % 2 == 0 ? ['صغير', 'كبير'] : ['وحدة'],
                colors: ['أحمر', 'أزرق', 'أخضر'].sublist(0, (p % 3) + 1),
                material: p % 2 == 0 ? 'قطن' : 'بوليستر',
                favoriteCount: p * 3 + s,
                createdAt: DateTime.now().subtract(Duration(days: p * 7)),
                isApproved: true,
              ),
            );
          }

          for (int o = 1; o <= 2; o++) {
            _mockOffers.add(
              Offer(
                id: (offerId++).toString(),
                shopId: shop.id,
                title: 'عرض $o من ${shop.name}',
                description: 'وصف مفصل للعرض $o. استفد من هذا العرض المميز لفترة محدودة.',
                discount: o * 10,
                validUntil: DateTime.now().add(Duration(days: 7 * o)),
                imageUrl: 'https://via.placeholder.com/200/FF5722/FFFFFF?text=عرض+$o',
                isActive: true,
                views: o * 35 + s * 15,
              ),
            );
          }
        }
      }
    }

    _isDataGenerated = true;
  }

  static Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_token');
    } catch (e) {
      print('خطأ في الحصول على التوكن: $e');
      return null;
    }
  }

  // 🔥 الحسابات الوهمية المحسنة:
  static Future<Map<String, dynamic>> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    
    // محاكاة أخطاء الشبكة بنسبة 10%
    if (DateTime.now().millisecond % 10 == 0) {
      throw Exception('فشل في الاتصال بالخادم. يرجى التحقق من اتصال الإنترنت.');
    }

    // 1. حساب مدير النظام
    if (email == 'admin@example.com' && password == 'password123') {
      final userData = {
        'id': 'admin_123',
        'name': 'أحمد المدير',
        'email': 'admin@example.com',
        'phone': '01012345678',
        'userType': 'admin',
        'joinDate': '2024-01-01',
        'isActive': true
      };
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_token', 'mock_admin_token_${DateTime.now().millisecondsSinceEpoch}');
      await prefs.setString('user_data', json.encode(userData));
      
      return {
        'token': 'mock_admin_token_${DateTime.now().millisecondsSinceEpoch}',
        'user': userData
      };
    }
    
    // 2. حساب تاجر
    else if (email == 'merchant@example.com' && password == 'password123') {
      final userData = {
        'id': 'merchant_123',
        'name': 'محمد التاجر',
        'email': 'merchant@example.com',
        'phone': '01112345678',
        'userType': 'merchant',
        'shopId': 'shop_merchant_123',
        'shopName': 'متجر محمد للأجهزة',
        'joinDate': '2024-02-01',
        'isActive': true
      };
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_token', 'mock_merchant_token_${DateTime.now().millisecondsSinceEpoch}');
      await prefs.setString('user_data', json.encode(userData));
      
      return {
        'token': 'mock_merchant_token_${DateTime.now().millisecondsSinceEpoch}',
        'user': userData
      };
    }
    
    // 3. حساب عميل عادي
    else if (email == 'customer@example.com' && password == 'password123') {
      final userData = {
        'id': 'customer_123',
        'name': 'علي العميل',
        'email': 'customer@example.com',
        'phone': '01212345678',
        'userType': 'customer',
        'joinDate': '2024-03-01',
        'isActive': true
      };
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_token', 'mock_customer_token_${DateTime.now().millisecondsSinceEpoch}');
      await prefs.setString('user_data', json.encode(userData));
      
      return {
        'token': 'mock_customer_token_${DateTime.now().millisecondsSinceEpoch}',
        'user': userData
      };
    }
    
    // الحساب القديم (للتوافق)
    else if (email == 'test@example.com' && password == 'password123') {
      final userData = {
        'id': 'user_123',
        'name': 'مستخدم تجريبي',
        'email': 'test@example.com',
        'phone': '01512345678',
        'userType': 'customer',
        'joinDate': '2024-01-15',
        'isActive': true
      };
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_token', 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}');
      await prefs.setString('user_data', json.encode(userData));
      
      return {
        'token': 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
        'user': userData
      };
    } else {
      throw Exception('البريد الإلكتروني أو كلمة المرور غير صحيحة');
    }
  }

  static Future<Map<String, dynamic>> registerUser(Map<String, dynamic> userData) async {
    await Future.delayed(const Duration(seconds: 2));
    
    // محاكاة أخطاء الشبكة بنسبة 10%
    if (DateTime.now().millisecond % 10 == 0) {
      throw Exception('فشل في الاتصال بالخادم. يرجى التحقق من اتصال الإنترنت.');
    }

    final newUserData = {
      'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
      'name': userData['name'] ?? '',
      'email': userData['email'] ?? '',
      'phone': userData['phone'] ?? '',
      'userType': userData['userType'] ?? 'customer',
      'joinDate': DateTime.now().toIso8601String(),
      'isActive': true
    };
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_token', 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}');
    await prefs.setString('user_data', json.encode(newUserData));
    
    return {
      'token': 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
      'user': newUserData
    };
  }

  // 🔥 إحصائيات التاجر المحسنة (بدون مبيعات وإيرادات)
  static Future<Map<String, dynamic>> getMerchantStats(String merchantId) async {
    await Future.delayed(const Duration(seconds: 1));
    
    return {
      'totalViews': 1245,
      'uniqueVisitors': 856,
      'totalFavorites': 234,
      'rating': 4.7,
      'viewsChange': 12.5,
      'visitorsChange': 8.3,
      'favoritesChange': 15.2,
      'ratingChange': 2.1,
      
      // بيانات الرسوم البيانية
      'viewsData': [120, 135, 110, 145, 130, 125, 140],
      'favoritesData': [15, 20, 18, 25, 22, 19, 24],
      
      // مقارنة الأداء
      'currentViews': 1245,
      'previousViews': 1107,
      'currentFavorites': 234,
      'previousFavorites': 203,
      'currentReviews': 45,
      'previousReviews': 38,
      
      // ترتيب المتجر
      'shopRank': 3,
      'totalShopsInCategory': 28,
      
      // المنتجات والعروض الأكثر أداءً
      'topProducts': [
        {'name': 'شاورما دجاج', 'views': 245, 'favorites': 45},
        {'name': 'برجر لحم', 'views': 189, 'favorites': 38},
        {'name': 'بيتزا كبيرة', 'views': 167, 'favorites': 29},
      ],
      'topOffers': [
        {'title': 'خصم 20% على المشويات', 'views': 156, 'favorites': 32},
        {'title': 'عروض نهاية الأسبوع', 'views': 134, 'favorites': 28},
        {'title': 'عرض العائلة', 'views': 98, 'favorites': 19},
      ]
    };
  }

  // 🔥 إحصائيات المدير المحسنة (بدون مبيعات وإيرادات)
  static Future<Map<String, dynamic>> getAdminStats() async {
    await Future.delayed(const Duration(seconds: 1));
    
    return {
      'totalShops': 145,
      'totalUsers': 2345,
      'activeUsers': 1890,
      'totalOffers': 23,
      'pendingApprovals': 12,
      'topCategories': [
        {'name': 'مطاعم', 'shops': 45, 'views': 45800},
        {'name': 'ملابس', 'shops': 38, 'views': 39200},
        {'name': 'أجهزة', 'shops': 29, 'views': 28700},
      ],
      'recentActivities': [
        {'action': 'تسجيل محل جديد', 'shop': 'مطعم النخبة', 'time': 'منذ 5 دقائق'},
        {'action': 'طلب انضمام', 'user': 'محمد التاجر', 'time': 'منذ 15 دقيقة'},
        {'action': 'بلاغ مستخدم', 'user': 'أحمد العميل', 'time': 'منذ ساعة'},
        {'action': 'تقييم جديد', 'user': 'فاطمة العميل', 'time': 'منذ ساعتين'},
      ],
      'performanceStats': {
        'dailyGrowth': 5.2,
        'weeklyGrowth': 18.7,
        'monthlyGrowth': 42.3,
        'activeShops': 132,
        'inactiveShops': 13,
      }
    };
  }

  static Future<List<Shop>> getShops({String? category, int page = 1, int limit = 20}) async {
    _generateMockData();
    await Future.delayed(const Duration(seconds: 1));
    
    List<Shop> filteredShops;
    
    if (category == null || category == 'all') {
      filteredShops = _mockShops;
    } else {
      filteredShops = _mockShops.where((shop) => shop.category == category).toList();
    }
    
    // تطبيق pagination
    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit;
    
    if (startIndex >= filteredShops.length) {
      return [];
    }
    
    return filteredShops.sublist(
      startIndex,
      endIndex < filteredShops.length ? endIndex : filteredShops.length
    );
  }

  static Future<List<Shop>> getFeaturedShops() async {
    _generateMockData();
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockShops.where((shop) => shop.isFeatured).take(10).toList();
  }

  static Future<List<Shop>> getTopVisitedShops() async {
    _generateMockData();
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_mockShops)..sort((a, b) => b.views.compareTo(a.views));
  }

  static Future<List<Shop>> getFavoriteShops() async {
    _generateMockData();
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_mockShops)..sort((a, b) => b.favoriteCount.compareTo(a.favoriteCount));
  }

  static Future<List<Product>> getProducts({String? shopId, String? category, int limit = 20}) async {
    _generateMockData();
    await Future.delayed(const Duration(milliseconds: 500));
    
    List<Product> filteredProducts;
    
    if (shopId != null) {
      filteredProducts = _mockProducts.where((product) => product.shopId == shopId).toList();
    } else if (category != null) {
      filteredProducts = _mockProducts.where((product) => product.category == category).toList();
    } else {
      filteredProducts = _mockProducts;
    }
    
    return filteredProducts.take(limit).toList();
  }

  static Future<List<Product>> getTopVisitedProducts() async {
    _generateMockData();
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_mockProducts)..sort((a, b) => b.views.compareTo(a.views));
  }

  static Future<List<Product>> getFavoriteProducts() async {
    _generateMockData();
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_mockProducts)..sort((a, b) => b.favoriteCount.compareTo(a.favoriteCount));
  }

  static Future<List<Product>> getProductsWithPriceDrop() async {
    _generateMockData();
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockProducts.where((product) => product.hasPriceDrop).toList();
  }

  static Future<List<Offer>> getOffers({String? shopId, int limit = 20}) async {
    _generateMockData();
    await Future.delayed(const Duration(milliseconds: 500));
    
    List<Offer> filteredOffers;
    
    if (shopId != null) {
      filteredOffers = _mockOffers.where((offer) => offer.shopId == shopId).toList();
    } else {
      filteredOffers = _mockOffers;
    }
    
    return filteredOffers.take(limit).toList();
  }

  static Future<List<Offer>> getTopVisitedOffers() async {
    _generateMockData();
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_mockOffers)..sort((a, b) => b.views.compareTo(a.views));
  }

  static Future<List<Offer>> getFavoriteOffers() async {
    _generateMockData();
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockOffers.where((offer) => offer.isFavorite).toList();
  }

  static Future<List<Offer>> getExpiringOffers() async {
    _generateMockData();
    await Future.delayed(const Duration(milliseconds: 500));
    final now = DateTime.now();
    return _mockOffers.where((offer) => 
      offer.validUntil.difference(now).inDays <= 3 && offer.isActive
    ).toList();
  }

  static Future<void> addRating(String shopId, double rating, String comment, List<String> images, String userId) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // في التطبيق الحقيقي، هنا سيتم إرسال التقييم للمدير للموافقة
    print('تم إضافة التقييم: $rating للمحل $shopId بواسطة $userId');
    print('الصور المرفقة: ${images.length}');
    print('التعليق: $comment');
    
    // محاكاة إضافة التقييم للمنتج/المحل
    final productIndex = _mockProducts.indexWhere((p) => p.shopId == shopId);
    if (productIndex != -1) {
      final product = _mockProducts[productIndex];
      final newReviews = product.reviews + 1;
      final newRating = ((product.rating * product.reviews) + rating) / newReviews;
      
      _mockProducts[productIndex] = product.copyWith(
        rating: double.parse(newRating.toStringAsFixed(1)),
        reviews: newReviews,
      );
    }
  }

  static Future<void> toggleFavorite(String type, String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = prefs.getStringList('favorites_$type') ?? [];
      
      if (favorites.contains(id)) {
        favorites.remove(id);
        // تحديث العدد في البيانات الوهمية
        _updateFavoriteCount(type, id, -1);
      } else {
        favorites.add(id);
        // تحديث العدد في البيانات الوهمية
        _updateFavoriteCount(type, id, 1);
      }
      
      await prefs.setStringList('favorites_$type', favorites);
    } catch (e) {
      throw Exception('فشل في تحديث المفضلة: $e');
    }
  }

  static void _updateFavoriteCount(String type, String id, int change) {
    if (type == 'shop') {
      final index = _mockShops.indexWhere((shop) => shop.id == id);
      if (index != -1) {
        final shop = _mockShops[index];
        _mockShops[index] = shop.copyWith(
          favoriteCount: shop.favoriteCount + change
        );
      }
    } else if (type == 'product') {
      final index = _mockProducts.indexWhere((product) => product.id == id);
      if (index != -1) {
        final product = _mockProducts[index];
        _mockProducts[index] = product.copyWith(
          favoriteCount: product.favoriteCount + change
        );
      }
    }
  }

  static Future<List<String>> getFavorites(String type) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList('favorites_$type') ?? [];
    } catch (e) {
      print('خطأ في الحصول على المفضلة: $e');
      return [];
    }
  }

  static Future<bool> validateActivationCode(String code) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final validCodes = ['SANHOUR2024BASIC', 'SANHOUR2024PREMIUM', 'TESTCODE123'];
    return validCodes.contains(code.toUpperCase());
  }

  static Future<void> useActivationCode(String code, String shopId) async {
    await Future.delayed(const Duration(seconds: 1));
    print('تم استخدام الكود $code للمحل $shopId');
  }

  static Future<String> uploadImage(String imagePath) async {
    await Future.delayed(const Duration(seconds: 2));
    return 'https://via.placeholder.com/300x200/4CAF50/FFFFFF?text=صورة+محمولة';
  }

  static Future<List<String>> uploadMultipleImages(List<String> imagePaths) async {
    await Future.delayed(const Duration(seconds: 2));
    return imagePaths.map((path) => 
      'https://via.placeholder.com/300x200/2196F3/FFFFFF?text=صورة+${imagePaths.indexOf(path) + 1}'
    ).toList();
  }

  static Future<Map<String, dynamic>> getShopAnalytics(String shopId) async {
    await Future.delayed(const Duration(seconds: 1));
    
    return {
      'views': 1500,
      'uniqueVisitors': 856,
      'clicks': 450,
      'favorites': 120,
      'topProducts': [
        {'name': 'شاورما دجاج', 'views': 250, 'favorites': 85},
        {'name': 'برجر لحم', 'views': 180, 'favorites': 60},
      ],
      'performanceTrends': {
        'daily': [120, 135, 110, 145, 130, 125, 140],
        'weekly': [800, 850, 790, 920, 880, 860, 900],
        'monthly': [3200, 3500, 3100, 3800, 3600, 3400, 3700],
      }
    };
  }

  static Future<Map<String, dynamic>> getVotingResults() async {
    await Future.delayed(const Duration(seconds: 1));
    
    return {
      'shop': 'مطعم النخبة',
      'product': 'شاورما دجاج',
      'offer': 'خصم 20% على جميع المشويات',
      'month': DateTime.now().month,
      'year': DateTime.now().year,
      'winners': [
        {'type': 'shop', 'name': 'مطعم النخبة', 'votes': 245},
        {'type': 'product', 'name': 'شاورما دجاج', 'votes': 189},
        {'type': 'offer', 'name': 'خصم 20% على جميع المشويات', 'votes': 167},
      ]
    };
  }

  static Future<List<Map<String, dynamic>>> searchAll(String query) async {
    _generateMockData();
    await Future.delayed(const Duration(milliseconds: 500));
    
    final results = <Map<String, dynamic>>[];
    final searchQuery = query.toLowerCase();
    
    // البحث في المحلات
    final shops = _mockShops.where((shop) =>
      shop.name.toLowerCase().contains(searchQuery) ||
      shop.category.toLowerCase().contains(searchQuery) ||
      shop.description.toLowerCase().contains(searchQuery)
    ).toList();
    
    // البحث في المنتجات
    final products = _mockProducts.where((product) =>
      product.name.toLowerCase().contains(searchQuery) ||
      product.category.toLowerCase().contains(searchQuery) ||
      product.description.toLowerCase().contains(searchQuery)
    ).toList();
    
    // البحث في العروض
    final offers = _mockOffers.where((offer) =>
      offer.title.toLowerCase().contains(searchQuery) ||
      offer.description.toLowerCase().contains(searchQuery)
    ).toList();
    
    results.addAll(shops.map((shop) => {'type': 'shop', 'data': shop}));
    results.addAll(products.map((product) => {'type': 'product', 'data': product}));
    results.addAll(offers.map((offer) => {'type': 'offer', 'data': offer}));
    
    return results;
  }

  static Future<List<Map<String, dynamic>>> getPendingReviews() async {
    await Future.delayed(const Duration(seconds: 1));
    
    return [
      {
        'id': 'review_1',
        'userName': 'أحمد محمد',
        'productName': 'شاورما دجاج',
        'rating': 4.5,
        'comment': 'تجربة رائعة والمنتج ممتاز',
        'images': ['https://via.placeholder.com/100'],
        'date': '2024-01-15',
        'isVerified': true,
      },
      {
        'id': 'review_2',
        'userName': 'فاطمة علي',
        'productName': 'برجر لحم',
        'rating': 5.0,
        'comment': 'أفضل برجر جربته في حياتي',
        'images': ['https://via.placeholder.com/100'],
        'date': '2024-01-14',
        'isVerified': true,
      },
    ];
  }

  static Future<void> approveReview(String reviewId) async {
    await Future.delayed(const Duration(seconds: 1));
    print('تمت الموافقة على التقييم: $reviewId');
  }

  static Future<void> rejectReview(String reviewId, String reason) async {
    await Future.delayed(const Duration(seconds: 1));
    print('تم رفض التقييم: $reviewId - السبب: $reason');
  }

  static Future<Map<String, dynamic>> processExcelFile(String filePath) async {
    await Future.delayed(const Duration(seconds: 3));
    
    // محاكاة معالجة ملف Excel
    return {
      'success': true,
      'message': 'تم معالجة الملف بنجاح',
      'processedItems': 15,
      'failedItems': 2,
      'results': [
        {'name': 'منتج 1', 'price': 50.0, 'status': 'success'},
        {'name': 'منتج 2', 'price': 75.0, 'status': 'success'},
        {'name': 'منتج 3', 'price': 0.0, 'status': 'failed', 'error': 'سعر غير صحيح'},
      ]
    };
  }

  static Future<void> updateProductPrices(List<Map<String, dynamic>> products) async {
    await Future.delayed(const Duration(seconds: 2));
    
    for (final productData in products) {
      final productId = productData['id'];
      final newPrice = productData['price'];
      final oldPrice = productData['oldPrice'];
      
      final index = _mockProducts.indexWhere((p) => p.id == productId);
      if (index != -1) {
        final product = _mockProducts[index];
        _mockProducts[index] = product.copyWith(
          price: newPrice,
          oldPrice: oldPrice,
        );
        
        // إرسال إشعارات انخفاض السعر إذا لزم
        if (oldPrice != null && newPrice < oldPrice) {
          print('إشعار: انخفاض سعر المنتج ${product.name} من $oldPrice إلى $newPrice');
        }
      }
    }
  }

  static Future<List<Map<String, dynamic>>> getPriceChangeHistory(String productId) async {
    await Future.delayed(const Duration(seconds: 1));
    
    return [
      {'date': '2024-01-15', 'oldPrice': 100.0, 'newPrice': 90.0, 'change': -10.0},
      {'date': '2024-01-10', 'oldPrice': 110.0, 'newPrice': 100.0, 'change': -10.0},
      {'date': '2024-01-01', 'oldPrice': 120.0, 'newPrice': 110.0, 'change': -10.0},
    ];
  }

  // دالة للمساعدة في إنشاء بيانات وهمية للرسم البياني
  static List<Map<String, dynamic>> generateChartData(String type, int count) {
    final data = <Map<String, dynamic>>[];
    final now = DateTime.now();
    
    for (int i = count - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final value = 100 + (i * 10) + (DateTime.now().millisecond % 50);
      
      data.add({
        'date': date.toIso8601String(),
        'value': value,
        'label': '${date.day}/${date.month}',
      });
    }
    
    return data;
  }
}