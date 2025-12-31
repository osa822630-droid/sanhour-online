import 'package:hive/hive.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  static const String _shopsBox = 'shops_cache';
  static const String _productsBox = 'products_cache';
  static const String _offersBox = 'offers_cache';
  static const String _userBox = 'user_cache';
  static const Duration cacheDuration = Duration(hours: 1);

  late Box _shopsCache;
  late Box _productsCache;
  late Box _offersCache;
  late Box _userCache;

  Future<void> init() async {
    await Hive.initFlutter();
    
    _shopsCache = await Hive.openBox(_shopsBox);
    _productsCache = await Hive.openBox(_productsBox);
    _offersCache = await Hive.openBox(_offersBox);
    _userCache = await Hive.openBox(_userBox);
  }

  // محلات
  Future<void> cacheShops(List<dynamic> shops, String category) async {
    final cacheKey = '${category}_${DateTime.now().millisecondsSinceEpoch}';
    await _shopsCache.put(cacheKey, {
      'data': shops,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'category': category,
    });
    
    // تنظيف البيانات القديمة
    _cleanOldData(_shopsCache);
  }

  Future<List<dynamic>?> getCachedShops(String category) async {
    final keys = _shopsCache.keys.where((key) {
      final cached = _shopsCache.get(key);
      return cached != null && 
             cached['category'] == category &&
             _isCacheValid(cached['timestamp']);
    }).toList();

    if (keys.isEmpty) return null;

    final latestKey = keys.reduce((a, b) {
      final aTime = _shopsCache.get(a)['timestamp'];
      final bTime = _shopsCache.get(b)['timestamp'];
      return aTime > bTime ? a : b;
    });

    return _shopsCache.get(latestKey)['data'];
  }

  // منتجات
  Future<void> cacheProducts(List<dynamic> products, {String? shopId, String? category}) async {
    final cacheKey = '${shopId ?? category}_${DateTime.now().millisecondsSinceEpoch}';
    await _productsCache.put(cacheKey, {
      'data': products,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'shopId': shopId,
      'category': category,
    });
    
    _cleanOldData(_productsCache);
  }

  Future<List<dynamic>?> getCachedProducts({String? shopId, String? category}) async {
    final keys = _productsCache.keys.where((key) {
      final cached = _productsCache.get(key);
      if (cached == null || !_isCacheValid(cached['timestamp'])) return false;
      
      if (shopId != null) return cached['shopId'] == shopId;
      if (category != null) return cached['category'] == category;
      return false;
    }).toList();

    if (keys.isEmpty) return null;

    final latestKey = keys.reduce((a, b) {
      final aTime = _productsCache.get(a)['timestamp'];
      final bTime = _productsCache.get(b)['timestamp'];
      return aTime > bTime ? a : b;
    });

    return _productsCache.get(latestKey)['data'];
  }

  // عروض
  Future<void> cacheOffers(List<dynamic> offers, {String? shopId}) async {
    final cacheKey = '${shopId ?? 'all'}_${DateTime.now().millisecondsSinceEpoch}';
    await _offersCache.put(cacheKey, {
      'data': offers,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'shopId': shopId,
    });
    
    _cleanOldData(_offersCache);
  }

  Future<List<dynamic>?> getCachedOffers({String? shopId}) async {
    final keys = _offersCache.keys.where((key) {
      final cached = _offersCache.get(key);
      return cached != null && 
             _isCacheValid(cached['timestamp']) &&
             (shopId == null || cached['shopId'] == shopId);
    }).toList();

    if (keys.isEmpty) return null;

    final latestKey = keys.reduce((a, b) {
      final aTime = _offersCache.get(a)['timestamp'];
      final bTime = _offersCache.get(b)['timestamp'];
      return aTime > bTime ? a : b;
    });

    return _offersCache.get(latestKey)['data'];
  }

  // بيانات المستخدم
  Future<void> cacheUserData(Map<String, dynamic> userData) async {
    await _userCache.put('user_data', {
      'data': userData,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<Map<String, dynamic>?> getCachedUserData() async {
    final cached = _userCache.get('user_data');
    if (cached == null || !_isCacheValid(cached['timestamp'])) {
      return null;
    }
    return cached['data'];
  }

  // إعدادات التطبيق
  Future<void> cacheAppSettings(Map<String, dynamic> settings) async {
    await _userCache.put('app_settings', settings);
  }

  Future<Map<String, dynamic>?> getCachedAppSettings() async {
    return _userCache.get('app_settings');
  }

  // البحث
  Future<void> cacheSearchResults(String query, List<dynamic> results) async {
    await _userCache.put('search_$query', {
      'data': results,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    
    // حفظ آخر 10 عمليات بحث
    final recentSearches = await getRecentSearches();
    recentSearches.remove(query);
    recentSearches.insert(0, query);
    
    if (recentSearches.length > 10) {
      recentSearches.removeLast();
    }
    
    await _userCache.put('recent_searches', recentSearches);
  }

  Future<List<dynamic>?> getCachedSearchResults(String query) async {
    final cached = _userCache.get('search_$query');
    if (cached == null || !_isCacheValid(cached['timestamp'])) {
      return null;
    }
    return cached['data'];
  }

  Future<List<String>> getRecentSearches() async {
    return List<String>.from(_userCache.get('recent_searches') ?? []);
  }

  // تنظيف الذاكرة المؤقتة
  Future<void> clearCache() async {
    await _shopsCache.clear();
    await _productsCache.clear();
    await _offersCache.clear();
    
    // الاحتفاظ ببيانات المستخدم والإعدادات
    final userData = await getCachedUserData();
    final appSettings = await getCachedAppSettings();
    final recentSearches = await getRecentSearches();
    
    await _userCache.clear();
    
    if (userData != null) await cacheUserData(userData);
    if (appSettings != null) await cacheAppSettings(appSettings);
    if (recentSearches.isNotEmpty) {
      await _userCache.put('recent_searches', recentSearches);
    }
  }

  Future<void> clearCategoryCache(String category) async {
    final shopKeys = _shopsCache.keys.where((key) {
      final cached = _shopsCache.get(key);
      return cached != null && cached['category'] == category;
    }).toList();
    
    final productKeys = _productsCache.keys.where((key) {
      final cached = _productsCache.get(key);
      return cached != null && cached['category'] == category;
    }).toList();
    
    for (final key in shopKeys) await _shopsCache.delete(key);
    for (final key in productKeys) await _productsCache.delete(key);
  }

  // إحصائيات الذاكرة المؤقتة
  Future<Map<String, int>> getCacheStats() async {
    return {
      'shops': _shopsCache.length,
      'products': _productsCache.length,
      'offers': _offersCache.length,
      'user_data': _userCache.length,
    };
  }

  // مساعدة
  bool _isCacheValid(int timestamp) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return now - timestamp < cacheDuration.inMilliseconds;
  }

  void _cleanOldData(Box box) {
    final keysToRemove = <dynamic>[];
    
    for (final key in box.keys) {
      final cached = box.get(key);
      if (cached != null && !_isCacheValid(cached['timestamp'])) {
        keysToRemove.add(key);
      }
    }
    
    for (final key in keysToRemove) {
      box.delete(key);
    }
  }

  // إغلاق الصناديق
  Future<void> close() async {
    await _shopsCache.close();
    await _productsCache.close();
    await _offersCache.close();
    await _userCache.close();
  }
}