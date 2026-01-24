import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
  );

  static final Logger _fileLogger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 120,
      colors: false,
      printEmojis: false,
    ),
  );

  static void d(String message) {
    _logger.d(message);
  }

  static void i(String message) {
    _logger.i(message);
  }

  static void w(String message) {
    _logger.w(message);
  }

  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void logApiCall(String endpoint, Map<String, dynamic>? params) {
    _logger.i('API Call: $endpoint | Params: $params');
  }

  static void logProviderState(String providerName, String state) {
    _logger.d('$providerName State: $state');
  }

  static void logUserAction(String action, [Map<String, dynamic>? details]) {
    _logger.i('User Action: $action ${details ?? ''}');
  }

  static void logPerformance(String operation, Duration duration) {
    _logger.i('Performance: $operation took ${duration.inMilliseconds}ms');
  }

  static void logError(String context, dynamic error, StackTrace stackTrace) {
    _logger.e('Error in $context', error: error, stackTrace: stackTrace);
  }

  static void logCache(String operation, String key, [dynamic value]) {
    _logger.d('Cache $operation: $key ${value != null ? '= $value' : ''}');
  }

  static void logAnalytics(String event, [Map<String, dynamic>? parameters]) {
    _logger.i('Analytics: $event ${parameters ?? ''}');
  }

  // للتسجيل في الملف (في التطبيق الحقيقي)
  static void logToFile(String level, String message) {
    _fileLogger.log(Level.trace, message);
  }
}

class PerformanceTracker {
  final String _operation;
  final Stopwatch _stopwatch;

  PerformanceTracker(this._operation) : _stopwatch = Stopwatch()..start();

  void stop() {
    _stopwatch.stop();
    AppLogger.logPerformance(_operation, _stopwatch.elapsed);
  }
}
