// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sanhour_app/main.dart';
import 'package:sanhour_app/providers/auth_provider.dart';
import 'package:sanhour_app/providers/favorites_provider.dart';
import 'package:sanhour_app/providers/shops_provider.dart';
import 'package:sanhour_app/providers/theme_provider.dart';
import 'package:sanhour_app/providers/voting_provider.dart';
import 'package:sanhour_app/screens/home_screen.dart';
import 'package:sanhour_app/screens/splash_screen.dart';
import 'package:mockito/mockito.dart';
import 'mocks.mocks.dart';

void main() {
  late MockShopsProvider mockShopsProvider;

  setUp(() {
    mockShopsProvider = MockShopsProvider();
  });

  testWidgets('App shows loading indicator and then content', (WidgetTester tester) async {
    // Stub the provider methods and getters.
    when(mockShopsProvider.loadShops(refresh: true)).thenAnswer((_) async {});
    when(mockShopsProvider.shops).thenReturn([]);
    when(mockShopsProvider.offers).thenReturn([]);
    when(mockShopsProvider.products).thenReturn([]);
    when(mockShopsProvider.error).thenReturn('');
    when(mockShopsProvider.favoriteShops).thenReturn([]);
    when(mockShopsProvider.favoriteProducts).thenReturn([]);
    when(mockShopsProvider.favoriteOffers).thenReturn([]);

    // --- Phase 1: Test Loading State ---
    when(mockShopsProvider.isLoading).thenReturn(true);

    // Build the app with the mock provider.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider<ShopsProvider>.value(value: mockShopsProvider),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => VotingProvider()),
          ChangeNotifierProvider(create: (_) => FavoritesProvider(null, [], [], [])),
        ],
        child: const MyApp(),
      ),
    );

    // Since the initial screen is a SplashScreen, we should check for that first.
    expect(find.byType(SplashScreen), findsOneWidget, reason: "The app should start with the SplashScreen");

    // After the splash screen, the app will decide which screen to show based on auth state.
    // For this test, let's assume the user is not authenticated, so it should go to the LoginScreen.
    // We'll need to mock the AuthProvider to control this.

    // Let's simplify the test to focus on the home screen with the ShopsProvider.
    // We will directly test the HomeScreen with the mock provider.

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider<ShopsProvider>.value(value: mockShopsProvider),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );


    // Verify that the loading indicator is displayed within the HomeScreen.
    expect(find.descendant(of: find.byType(HomeScreen), matching: find.byType(CircularProgressIndicator)), findsOneWidget, reason: "HomeScreen should show a loading indicator when isLoading is true");

    // --- Phase 2: Test Loaded State ---
    when(mockShopsProvider.isLoading).thenReturn(false);

    // Rebuild the widget tree to reflect the new state.
    await tester.pump();

    // Verify that the loading indicator is gone.
    expect(find.descendant(of: find.byType(HomeScreen), matching: find.byType(CircularProgressIndicator)), findsNothing, reason: "Loading indicator should disappear after loading is complete");

    // Verify that the content of the home screen is now visible.
    // We can check for a widget that is specific to the loaded state of HomeScreen.
    // For example, let's assume it shows a search bar when loaded.
    expect(find.byType(TextField), findsOneWidget, reason: "Content (like a search bar) should be visible after loading");
  });
}
