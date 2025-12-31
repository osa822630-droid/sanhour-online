import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> init() async {
    // تهيئة خدمة التحليلات
    await _analytics.logAppOpen();
  }

  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  Future<void> logSearch(String searchTerm) async {
    await _analytics.logSearch(searchTerm: searchTerm);
  }

  Future<void> logViewItem(dynamic item) async {
    if (item is Shop) {
      await _analytics.logViewItem(
        items: [
          AnalyticsEventItem(
            itemId: item.id,
            itemName: item.name,
            itemCategory: item.category,
          ),
        ],
      );
    } else if (item is Product) {
      await _analytics.logViewItem(
        items: [
          AnalyticsEventItem(
            itemId: item.id,
            itemName: item.name,
            itemCategory: item.category,
            price: item.price,
          ),
        ],
      );
    } else if (item is Offer) {
      await _analytics.logViewItem(
        items: [
          AnalyticsEventItem(
            itemId: item.id,
            itemName: item.title,
            itemCategory: 'offer',
          ),
        ],
      );
    }
  }

  Future<void> logAddToFavorites(String itemId, String itemType) async {
    await _analytics.logAddToWishlist(
      items: [
        AnalyticsEventItem(
          itemId: itemId,
          itemCategory: itemType,
        ),
      ],
    );
  }

  Future<void> logRemoveFromFavorites(String itemId, String itemType) async {
    await _analytics.logEvent(
      name: 'remove_from_favorites',
      parameters: {
        'item_id': itemId,
        'item_type': itemType,
      },
    );
  }

  Future<void> logUserRegistration(String userType) async {
    await _analytics.logSignUp(signUpMethod: 'email');
    await _analytics.logEvent(
      name: 'user_registration',
      parameters: {
        'user_type': userType,
      },
    );
  }

  Future<void> logUserLogin(String userType) async {
    await _analytics.logLogin(loginMethod: 'email');
    await _analytics.logEvent(
      name: 'user_login',
      parameters: {
        'user_type': userType,
      },
    );
  }

  Future<void> logMerchantStatsView(String timeFrame) async {
    await _analytics.logEvent(
      name: 'merchant_stats_view',
      parameters: {
        'time_frame': timeFrame,
      },
    );
  }

  Future<void> logAdminStatsView() async {
    await _analytics.logEvent(
      name: 'admin_stats_view',
    );
  }

  Future<void> logReviewSubmission(String itemType, double rating) async {
    await _analytics.logEvent(
      name: 'review_submission',
      parameters: {
        'item_type': itemType,
        'rating': rating,
      },
    );
  }

  Future<void> logExcelUpload(int processedItems, int failedItems) async {
    await _analytics.logEvent(
      name: 'excel_upload',
      parameters: {
        'processed_items': processedItems,
        'failed_items': failedItems,
      },
    );
  }

  Future<void> logPriceDropNotification(String itemType, String itemId) async {
    await _analytics.logEvent(
      name: 'price_drop_notification',
      parameters: {
        'item_type': itemType,
        'item_id': itemId,
      },
    );
  }

  Future<void> logNewOfferNotification(String shopId) async {
    await _analytics.logEvent(
      name: 'new_offer_notification',
      parameters: {
        'shop_id': shopId,
      },
    );
  }

  Future<void> logAdvancedSearch(
    String query,
    Map<String, String> filters,
  ) async {
    await _analytics.logEvent(
      name: 'advanced_search',
      parameters: {
        'query': query,
        ...filters,
      },
    );
  }

  Future<void> setUserProperties({
    String? userType,
    String? userId,
  }) async {
    if (userType != null) {
      await _analytics.setUserProperty(
        name: 'user_type',
        value: userType,
      );
    }
    
    if (userId != null) {
      await _analytics.setUserId(id: userId);
    }
  }

  Future<void> logAppPerformance(String feature, Duration duration) async {
    await _analytics.logEvent(
      name: 'app_performance',
      parameters: {
        'feature': feature,
        'duration_ms': duration.inMilliseconds,
      },
    );
  }

  Future<void> logErrorEvent(String errorType, String errorMessage) async {
    await _analytics.logEvent(
      name: 'app_error',
      parameters: {
        'error_type': errorType,
        'error_message': errorMessage,
      },
    );
  }
}