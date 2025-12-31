import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'offers_screen.dart';
import 'favorites_screen.dart';
import 'options_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const OffersScreen(),
    const FavoritesScreen(),
    const OptionsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'الرئيسية',
            tooltip: 'الصفحة الرئيسية'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer),
            label: 'العروض',
            tooltip: 'العروض والتخفيضات'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'المفضلة',
            tooltip: 'المفضلة'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'خيارات',
            tooltip: 'الإعدادات والخيارات'
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 8.0,
      ),
    );
  }
}