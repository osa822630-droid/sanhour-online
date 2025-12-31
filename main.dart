import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/shops_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/voting_provider.dart';
import 'providers/favorites_provider.dart';
import 'screens/main_screen.dart';
import 'services/user_notification_service.dart';
import 'services/merchant_notification_service.dart';
import 'services/analytics_service.dart';
import 'services/cache_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تهيئة خدمات الإشعارات
  await UserNotificationService().init();
  await MerchantNotificationService().init();
  await CacheService().init();
  await AnalyticsService().init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ShopsProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => VotingProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: const SanhourApp(),
    ),
  );
}

class SanhourApp extends StatelessWidget {
  const SanhourApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'Sanhour Online',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        primaryColor: const Color(0xFF2E7D32),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFF1976D2),
          background: Colors.grey[50],
        ),
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        tabBarTheme: const TabBarTheme(
          labelColor: Color(0xFF2E7D32),
          unselectedLabelColor: Colors.grey,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF4CAF50),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFF2196F3),
          background: const Color(0xFF121212),
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
          elevation: 1,
        ),
        tabBarTheme: const TabBarTheme(
          labelColor: Color(0xFF4CAF50),
          unselectedLabelColor: Colors.grey,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      themeMode: themeProvider.themeMode,
      home: const MainScreen(),
    );
  }
}