import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hira_plus/screens/mess_staff_screen/models/bulk_meal_model.dart';
import 'package:hira_plus/screens/mess_staff_screen/services/bulk_meal_service.dart';

class MessBulkMealProvider extends ChangeNotifier {
  final BulkMealService _guestMealService = BulkMealService();

  // State variables
  List<BulkMealModel> _guestMeals = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  List<BulkMealModel> get guestMeals => _guestMeals;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  /// Fetches guest meals from the API
  Future<void> fetchGuestMeals(BuildContext context) async {
    try {
      if (_isLoading) {
        log('🔄 Already fetching guest meals, ignoring new request');
        return;
      }

      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      log('🔄 Starting to fetch guest meals in provider');
      final guestMeals = await _guestMealService.getGuestMeals(context);

      _guestMeals = guestMeals;
      _isLoading = false;

      log('✅ Successfully updated guest meals in provider. Count: ${_guestMeals.length}');
      notifyListeners();
    } on HttpException catch (e) {
      log('🚨 HTTP error in guest meal provider: $e');
      _isLoading = false;

      if (e.toString().contains('401')) {
        _errorMessage = 'Authentication error. Please login again.';
      } else {
        _errorMessage =
            'Failed to load guest meals. Please check your connection and try again.';
      }

      notifyListeners();
    } catch (e) {
      log('❌ Error in guest meal provider: $e');
      _isLoading = false;
      _errorMessage = 'Failed to load guest meals. Please try again.';
      notifyListeners();
    }
  }

  /// Gets guest meals for today
  List<BulkMealModel> getTodayGuestMeals() {
    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);
    
    return _guestMeals.where((meal) {
      final mealDateOnly = DateTime(meal.date.year, meal.date.month, meal.date.day);
      return mealDateOnly.isAtSameMomentAs(todayDateOnly);
    }).toList();
  }

  /// Gets total meal counts for today across all departments
  Map<String, int> getTodayTotalCounts() {
    final todayMeals = getTodayGuestMeals();
    
    int totalBreakfast = 0;
    int totalLunch = 0;
    int totalDinner = 0;
    
    for (final meal in todayMeals) {
      totalBreakfast += meal.totalCounts.breakfast;
      totalLunch += meal.totalCounts.lunch;
      totalDinner += meal.totalCounts.dinner;
    }
    
    return {
      'breakfast': totalBreakfast,
      'lunch': totalLunch,
      'dinner': totalDinner,
    };
  }

  /// Checks if there are any guest meals for today
  bool get hasTodayGuestMeals {
    return getTodayGuestMeals().isNotEmpty;
  }

  /// Gets guest meals for a specific date
  List<BulkMealModel> getGuestMealsForDate(DateTime date) {
    final targetDateOnly = DateTime(date.year, date.month, date.day);
    
    return _guestMeals.where((meal) {
      final mealDateOnly = DateTime(meal.date.year, meal.date.month, meal.date.day);
      return mealDateOnly.isAtSameMomentAs(targetDateOnly);
    }).toList();
  }

  /// Reset all provider state
  void reset() {
    _guestMeals = [];
    _isLoading = false;
    _errorMessage = '';
    notifyListeners();
  }

  /// Clear all data
  Future<void> clearData() async {
    log('🧹 Clearing guest meal provider data');
    reset();
  }
}