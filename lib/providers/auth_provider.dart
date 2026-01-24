import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = false;
  bool _isGuest = false;
  String _error = '';
  User? _user;
  String? _userToken;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  bool get isGuest => _isGuest;
  String get error => _error;
  User? get user => _user;
  String? get userToken => _userToken;
  bool get isMerchant => _user?.userType == 'merchant';
  bool get isAdmin => _user?.userType == 'admin';
  bool get isAuthenticated => _isLoggedIn;


  AuthProvider() {
    _loadAuthData();
  }

  Future<void> _loadAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('user_token');
      final userDataString = prefs.getString('user_data');
      final isGuest = prefs.getBool('is_guest') ?? false;

      if (token != null && userDataString != null) {
        try {
          _userToken = token;
          _user = User.fromMap(json.decode(userDataString));
          _isLoggedIn = true;
          _isGuest = false;
        } catch (e) {
          debugPrint('Error loading user data: $e');
          await prefs.remove('user_token');
          await prefs.remove('user_data');
        }
      } else if (isGuest) {
        _isGuest = true;
        _isLoggedIn = false;
      }
    } catch (e) {
      debugPrint('Error loading auth data: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await ApiService.login(email, password);
      _userToken = response['token'];
      _user = User.fromMap(response['user']);
      _isLoggedIn = true;
      _isGuest = false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_token', _userToken!);
      await prefs.setString('user_data', json.encode(response['user']));
      await prefs.setBool('is_guest', false);

    } catch (e) {
      _error = _getErrorMessage(e);
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> registerUser(Map<String, dynamic> userData) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await ApiService.registerUser(userData);
      _userToken = response['token'];
      _user = User.fromMap(response['user']);
      _isLoggedIn = true;
      _isGuest = false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_token', _userToken!);
      await prefs.setString('user_data', json.encode(response['user']));
      await prefs.setBool('is_guest', false);

    } catch (e) {
      _error = _getErrorMessage(e);
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loginAsGuest() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _isGuest = true;
      _isLoggedIn = false;
      _user = null;
      _userToken = null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_guest', true);
      await prefs.remove('user_token');
      await prefs.remove('user_data');

    } catch (e) {
      _error = 'Failed to login as guest: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_token');
      await prefs.remove('user_data');
      await prefs.setBool('is_guest', false);

      _isLoggedIn = false;
      _isGuest = false;
      _user = null;
      _userToken = null;
      _error = '';
    } catch (e) {
      debugPrint('Error logging out: $e');
    } finally {
      notifyListeners();
    }
  }

  String _getErrorMessage(dynamic error) {
    final errorString = error.toString();
    if (errorString.contains('network') || errorString.contains('Connection')) {
      return 'Network error';
    } else if (errorString.contains('401') || errorString.contains('incorrect')) {
      return 'Invalid email or password';
    } else if (errorString.contains('404')) {
      return 'Account not found';
    } else {
      return 'An unexpected error occurred: $error';
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }

  bool canAccessAdminPanel() {
    return isAdmin && isLoggedIn;
  }

  bool canManageShop(String shopId) {
    return (isAdmin || (isMerchant && user?.id == shopId));
  }
}
