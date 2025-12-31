import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = false;
  bool _isGuest = false;
  String _error = '';
  Map<String, dynamic>? _userData;
  String? _userToken;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  bool get isGuest => _isGuest;
  String get error => _error;
  Map<String, dynamic>? get userData => _userData;
  String? get userToken => _userToken;
  bool get isMerchant => _userData?['userType'] == 'merchant';
  bool get isAdmin => _userData?['userType'] == 'admin';

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
          _userData = json.decode(userDataString);
          _isLoggedIn = true;
          _isGuest = false;
        } catch (e) {
          print('خطأ في تحميل بيانات المستخدم: $e');
          await prefs.remove('user_token');
          await prefs.remove('user_data');
        }
      } else if (isGuest) {
        _isGuest = true;
        _isLoggedIn = false;
      }
    } catch (e) {
      print('خطأ في تحميل بيانات المصادقة: $e');
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
      _userData = response['user'];
      _isLoggedIn = true;
      _isGuest = false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_token', _userToken!);
      await prefs.setString('user_data', json.encode(_userData));
      await prefs.setBool('is_guest', false);

    } catch (e) {
      _error = _getErrorMessage(e);
      notifyListeners();
      throw e;
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
      _userData = response['user'];
      _isLoggedIn = true;
      _isGuest = false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_token', _userToken!);
      await prefs.setString('user_data', json.encode(_userData));
      await prefs.setBool('is_guest', false);

    } catch (e) {
      _error = _getErrorMessage(e);
      notifyListeners();
      throw e;
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
      _userData = null;
      _userToken = null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_guest', true);
      await prefs.remove('user_token');
      await prefs.remove('user_data');

    } catch (e) {
      _error = 'فشل في الدخول كضيف: $e';
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
      _userData = null;
      _userToken = null;
      _error = '';
    } catch (e) {
      print('خطأ في تسجيل الخروج: $e');
    } finally {
      notifyListeners();
    }
  }

  String _getErrorMessage(dynamic error) {
    final errorString = error.toString();
    if (errorString.contains('network') || errorString.contains('Connection')) {
      return 'حدث خطأ في الاتصال بالإنترنت';
    } else if (errorString.contains('401') || errorString.contains('غير صحيحة')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    } else if (errorString.contains('404')) {
      return 'الحساب غير موجود';
    } else {
      return 'حدث خطأ غير متوقع: $error';
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
    return (isAdmin || (isMerchant && userData?['shopId'] == shopId));
  }
}