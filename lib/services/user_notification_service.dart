 // lib/services/user_notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
// 👇 تم تغيير الاسم هنا من tzData إلى tz_data
import 'package:timezone/data/latest.dart' as tz_data;

class UserNotificationService {
  static final UserNotificationService _instance = UserNotificationService._internal();
  factory UserNotificationService() => _instance;
  UserNotificationService._internal();

  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 👇 استخدام الاسم الجديد هنا
    tz_data.initializeTimeZones();
    
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
  }

  // إشعار عند نزول عرض في محل مفضل
  Future<void> notifyFavoriteShopNewOffer(String shopName, String offerTitle) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'favorite_shops_channel',
      'عروض المحلات المفضلة',
      channelDescription: 'إشعارات العروض الجديدة في المحلات المفضلة',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      shopName.hashCode,
      'عرض جديد في $shopName',
      offerTitle,
      details,
    );
  }

  // إشعار عند انخفاض سعر منتج مفضل
  Future<void> notifyFavoriteProductPriceDrop(String productName, double oldPrice, double newPrice) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'price_drop_channel',
      'انخفاض الأسعار',
      channelDescription: 'إشعارات انخفاض أسعار المنتجات المفضلة',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      productName.hashCode,
      'انخفاض سعر $productName',
      'انخفض السعر من $oldPrice إلى $newPrice جنيه',
      details,
    );
  }

  // إشعار عند انخفاض سعر عرض مفضل
  Future<void> notifyFavoriteOfferPriceDrop(String offerTitle, double oldPrice, double newPrice) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'price_drop_channel',
      'انخفاض الأسعار',
      channelDescription: 'إشعارات انخفاض أسعار العروض المفضلة',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      offerTitle.hashCode,
      'انخفاض سعر العرض $offerTitle',
      'انخفض السعر من $oldPrice إلى $newPrice جنيه',
      details,
    );
  }

  // جدولة فحص يومي للعروض والأسعار
  Future<void> scheduleDailyPriceCheck() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'daily_check_channel',
      'الفحص اليومي',
      channelDescription: 'فحص يومي للعروض والأسعار',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      0,
      'فحص العروض اليومي',
      'يتم فحص العروض والأسعار الجديدة',
      _nextInstanceOfTime(9, 0, 0), // 9 صباحاً
      details,
      // 👇 تم التحديث هنا لاستخدام الكود الجديد
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute, int second) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute, second);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }
}
