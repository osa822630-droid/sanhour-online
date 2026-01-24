 // lib/services/merchant_notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
// 👇 تم تغيير الاسم هنا من tzData إلى tz_data
import 'package:timezone/data/latest.dart' as tz_data;

class MerchantNotificationService {
  static final MerchantNotificationService _instance = MerchantNotificationService._internal();
  factory MerchantNotificationService() => _instance;
  MerchantNotificationService._internal();

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

  // إشعار يومي للتاجر
  Future<void> scheduleDailyStatsNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'merchant_daily_channel',
      'الإحصائيات اليومية',
      channelDescription: 'إشعارات الإحصائيات اليومية للتجار',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      1,
      'تقرير الأداء اليومي',
      'اطلع على إحصائيات متجرك اليومية',
      _nextInstanceOfTime(0, 0, 0), // 12 منتصف الليل
      details,
      // 👇 تم استبدال androidAllowWhileIdle بالكود الجديد
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // إشعار أسبوعي للتاجر
  Future<void> scheduleWeeklyStatsNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'merchant_weekly_channel',
      'الإحصائيات الأسبوعية',
      channelDescription: 'إشعارات الإحصائيات الأسبوعية للتجار',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      2,
      'تقرير الأداء الأسبوعي',
      'اطلع على إحصائيات متجرك هذا الأسبوع',
      _nextInstanceOfDayAndTime(DateTime.saturday, 0, 0, 0), // السبت 12 منتصف الليل
      details,
      // 👇 تم التحديث هنا أيضاً
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // إشعار شهري للتاجر
  Future<void> scheduleMonthlyStatsNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'merchant_monthly_channel',
      'الإحصائيات الشهرية',
      channelDescription: 'إشعارات الإحصائيات الشهرية للتجار',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      3,
      'تقرير الأداء الشهري',
      'اطلع على إحصائيات متجرك هذا الشهر',
      _nextInstanceOfMonthDayAndTime(1, 0, 0, 0), // يوم 1 من الشهر 12 منتصف الليل
      details,
      // 👇 تم التحديث هنا أيضاً
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
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

  tz.TZDateTime _nextInstanceOfDayAndTime(int day, int hour, int minute, int second) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute, second);
    
    while (scheduledDate.weekday != day || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }

  tz.TZDateTime _nextInstanceOfMonthDayAndTime(int day, int hour, int minute, int second) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, day, hour, minute, second);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = tz.TZDateTime(tz.local, now.year, now.month + 1, day, hour, minute, second);
    }
    
    return scheduledDate;
  }
}
