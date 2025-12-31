import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class VotingProvider with ChangeNotifier {
  Map<String, dynamic> _winners = {};
  bool _isVotingOpen = false;
  DateTime? _lastVotingCheck;

  Map<String, dynamic> get winners => _winners;
  bool get isVotingOpen => _isVotingOpen;

  void checkVotingStatus() {
    final now = DateTime.now();
    
    if (_lastVotingCheck != null && 
        DateTime.now().difference(_lastVotingCheck!).inHours < 1) {
      return;
    }
    
    _lastVotingCheck = now;
    
    // حساب تواريخ أكثر دقة
    final firstDayOfNextMonth = DateTime(now.year, now.month + 1, 1);
    final lastDayOfMonth = firstDayOfNextMonth.subtract(const Duration(days: 1));
    
    final isLastWeek = now.day >= lastDayOfMonth.day - 7;
    
    if (isLastWeek) {
      _isVotingOpen = true;
      _winners = {};
    } else if (now.day == 1) {
      _isVotingOpen = false;
      _announceWinners();
    }
    
    notifyListeners();
  }

  void _announceWinners() {
    _winners = {
      'shop': 'مطعم النخبة',
      'product': 'شاورما دجاج',
      'offer': 'خصم 20% على جميع المشويات',
      'month': DateTime.now().month,
      'year': DateTime.now().year
    };
  }

  Future<void> voteForShop(String shopId) async {
    if (!_isVotingOpen) {
      throw Exception('التصويت غير متاح حالياً');
    }
    
    try {
      // محاكاة طلب التصويت
      await Future.delayed(const Duration(seconds: 1));
      print('تم التصويت للمحل: $shopId');
    } catch (e) {
      throw Exception('فشل في التصويت: $e');
    }
  }

  Future<void> voteForProduct(String productId) async {
    if (!_isVotingOpen) {
      throw Exception('التصويت غير متاح حالياً');
    }
    
    try {
      await Future.delayed(const Duration(seconds: 1));
      print('تم التصويت للمنتج: $productId');
    } catch (e) {
      throw Exception('فشل في التصويت: $e');
    }
  }

  Future<void> voteForOffer(String offerId) async {
    if (!_isVotingOpen) {
      throw Exception('التصويت غير متاح حالياً');
    }
    
    try {
      await Future.delayed(const Duration(seconds: 1));
      print('تم التصويت للعرض: $offerId');
    } catch (e) {
      throw Exception('فشل في التصويت: $e');
    }
  }
}