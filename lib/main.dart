
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'providers/shops_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/favorites_provider.dart';
import 'screens/login_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/merchant_dashboard.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:developer' as developer;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  developer.log("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await NotificationService().init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ShopsProvider()),
        ChangeNotifierProxyProvider<AuthProvider, FavoritesProvider>(
          create: (_) => FavoritesProvider(null, [], [], []),
          update: (context, auth, previous) => FavoritesProvider(
            auth.user, 
            previous?.favoriteShops ?? [], 
            previous?.favoriteProducts ?? [], 
            previous?.favoriteOffers ?? [],
          ),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'دليلك في سنهور',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              fontFamily: 'Tajawal',
            ),
            debugShowCheckedModeBanner: false,
            home: _getHomeScreen(auth),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/admin': (context) => const AdminDashboard(),
              '/merchant': (context) => const MerchantDashboard(),
            },
          );
        },
      ),
    );
  }

  Widget _getHomeScreen(AuthProvider auth) {
    if (auth.isAuthenticated) {
      if (auth.user?.userType == 'admin') {
        return const AdminDashboard();
      } else if (auth.user?.userType == 'merchant') {
        return const MerchantDashboard();
      } else {
        return const HomeScreen();
      }
    } else {
      return const SplashScreen();
    }
  }
}
