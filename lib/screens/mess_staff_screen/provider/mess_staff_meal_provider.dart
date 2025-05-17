import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hira_plus/screens/mess_staff_screen/models/mess_staff_screen_model.dart';
import 'package:hira_plus/screens/mess_staff_screen/services/mess_staff_meal_service.dart';
import 'package:hira_plus/utils/shared_utils.dart';
import 'package:logger/logger.dart';

class MessStaffMealProvider extends ChangeNotifier {
  final MessStaffMealService _mealService = MessStaffMealService();
  final Logger _logger = Logger();
  
  // Existing property for selected meal
  int _selectedMeal = 0; // 0: Breakfast, 1: Lunch, 2: Dinner

  // New properties for API data
  MessStaffScreenModel? _messStaffMealData;
  bool _isLoading = false;
  String _errorMessage = '';
  DateTime _lastFetchTime = DateTime(2000); // Initial value
  
  // Getters
  int get selectedMeal => _selectedMeal;
  MessStaffScreenModel? get messStaffMealData => _messStaffMealData;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  DateTime get lastFetchTime => _lastFetchTime;

  // Existing method to select a meal type
  void selectMeal(int index) {
    if (_selectedMeal != index) {
      _selectedMeal = index;
      notifyListeners();
    }
  }

  // New method to fetch mess staff meals - always fetch fresh data first
  Future<void> fetchMessStaffMeals(BuildContext context) async {
    try {
      if (_isLoading) {
        log('🔄 Already fetching meals, ignoring new request', name: 'MessStaffMealProvider');
        return;
      }

      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      // Try to load cached data first for immediate display
      await _loadMealsFromCache();
      
      // Then fetch fresh data from API
      _logger.i('🔄 [API] Fetching fresh mess staff meals');
      log('🔄 Fetching fresh mess staff meals data', name: 'MessStaffMealProvider');
      
      final meals = await _mealService.getMessStaffMeals();

      _messStaffMealData = meals;
      _isLoading = false;
      _lastFetchTime = DateTime.now();

      // Save meal data to shared preferences for offline access
      await _saveMealsToCache();

      _logger.i('✅ [API] Successfully updated mess staff meals with fresh data');
      log('✅ Successfully updated mess staff meals with fresh data', name: 'MessStaffMealProvider');
      notifyListeners();
    } on HttpException catch (e) {
      _logger.e('🚨 [API] HTTP error fetching mess staff meals: $e');
      log('🚨 HTTP error in meal provider: $e', name: 'MessStaffMealProvider');
      _isLoading = false;

      if (e.toString().contains('401')) {
        _errorMessage = 'Authentication error. Please login again.';
      } else {
        _errorMessage = 'Failed to load meals. Please check your connection and try again.';
      }

      notifyListeners();
    } catch (e) {
      _logger.e('❌ [API] Error fetching mess staff meals: $e');
      log('❌ Error in meal provider: $e', name: 'MessStaffMealProvider');
      _isLoading = false;
      _errorMessage = 'Failed to load meals. Please try again.';

      notifyListeners();
    }
  }

  Future<void> _saveMealsToCache() async {
    try {
      if (_messStaffMealData != null) {
        final mealJsonString = jsonEncode(_messStaffMealData!.toJson());
        await SharedUtils.setString('cached_mess_staff_meals', mealJsonString);
        log('💾 Saved mess staff meals to cache', name: 'MessStaffMealProvider');
      }
    } catch (e) {
      log('❌ Error saving mess staff meals to cache: $e', name: 'MessStaffMealProvider');
    }
  }

  Future<void> _loadMealsFromCache() async {
    try {
      final cachedMealsJson = await SharedUtils.getString('cached_mess_staff_meals');
      if (cachedMealsJson.isNotEmpty) {
        final cachedMeals = MessStaffScreenModel.fromJson(jsonDecode(cachedMealsJson));
        _messStaffMealData = cachedMeals;
        log('📂 Loaded mess staff meals from cache', name: 'MessStaffMealProvider');
      }
    } catch (e) {
      log('❌ Error loading meals from cache: $e', name: 'MessStaffMealProvider');
    }
  }

  // Helper methods to access meal data

  /// Get meal counts for today
  Map<String, int> getTodayMealCounts() {
    if (_messStaffMealData == null || _messStaffMealData!.meals == null) {
      log('⚠️ No meal data available yet', name: 'MessStaffMealProvider');
      return {'breakfast': 0, 'lunch': 0, 'dinner': 0};
    }

    // Get today's date
    final today = DateTime.now();
    final dateStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    log('🔍 Looking for meal counts for today: $dateStr', name: 'MessStaffMealProvider');
    
    try {
      // Find today's meals
      final mealsMap = _messStaffMealData!.meals!;
      if (mealsMap.containsKey(dateStr)) {
        final dayMeals = mealsMap[dateStr]!;
        log('✅ Found meal data for today!', name: 'MessStaffMealProvider');
        // Get the counts for today
        final breakfastCount = dayMeals.breakfast?.length ?? 0;
        final lunchCount = dayMeals.lunch?.length ?? 0;
        final dinnerCount = dayMeals.dinner?.length ?? 0;
        log('🍳 Today\'s breakfast count: $breakfastCount', name: 'MessStaffMealProvider');
        log('🍲 Today\'s lunch count: $lunchCount', name: 'MessStaffMealProvider');
        log('🍽️ Today\'s dinner count: $dinnerCount', name: 'MessStaffMealProvider');
        return {
          'breakfast': breakfastCount,
          'lunch': lunchCount,
          'dinner': dinnerCount
        };
      }
      // If today's data not found, return zeros
      log('⚠️ No meal data found for today, returning zeros', name: 'MessStaffMealProvider');
      return {'breakfast': 0, 'lunch': 0, 'dinner': 0};
    } catch (e) {
      log('❌ Error getting today meal counts: $e', name: 'MessStaffMealProvider');
      return {'breakfast': 0, 'lunch': 0, 'dinner': 0};
    }
  }

  /// Get detailed list of users for a specific meal type on current day
  List<Map<String, String>> getMealDetailsList(int mealType) {
    if (_messStaffMealData == null || _messStaffMealData!.meals == null) {
      log('⚠️ No meal data available yet', name: 'MessStaffMealProvider');
      return [];
    }

    // Get today's date
    final today = DateTime.now();
    final dateStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    log('🔍 Looking for meal details for today: $dateStr', name: 'MessStaffMealProvider');
    
    try {
      final mealsMap = _messStaffMealData!.meals!;
      log('📊 Available meal dates: \\${mealsMap.keys.join(", ")}', name: 'MessStaffMealProvider');
      if (mealsMap.containsKey(dateStr)) {
        final dayMeals = mealsMap[dateStr]!;
        log('✅ Found meal data for today!', name: 'MessStaffMealProvider');
        List<Breakfast> mealList = [];
        switch (mealType) {
          case 0:
            mealList = dayMeals.breakfast ?? [];
            break;
          case 1:
            mealList = dayMeals.lunch ?? [];
            break;
          case 2:
            mealList = dayMeals.dinner ?? [];
            break;
        }
        log('🍽️ Found \\${mealList.length} users for mealType $mealType today', name: 'MessStaffMealProvider');
        final detailsList = mealList.map((meal) {
          final userName = meal.userId?.name ?? 'User';
          final mobile = meal.userId?.phoneNumber ?? '';
          final department = meal.userId?.department ?? '';
          return {
            'name': userName, // Show user name as name
            'type': mobile,   // Show mobile number as type (second line)
            'room': department, // Show department as third line
          };
        }).toList();
        return detailsList;
      }
      log('⚠️ No meal data found for today, returning empty list', name: 'MessStaffMealProvider');
      return [];
    } catch (e) {
      log('❌ Error getting meal details: $e', name: 'MessStaffMealProvider');
      return [];
    }
  }

  String _getMealTypeLabel(int mealType) {
    switch (mealType) {
      case 0:
        return 'Breakfast';
      case 1:
        return 'Lunch';
      case 2:
        return 'Dinner';
      default:
        return 'Unknown';
    }
  }

  // Clear all data
  Future<void> clearData() async {
    try {
      _logger.i('🧹 [LOGOUT] Clearing mess staff meal data');
      log('🧹 Clearing all mess staff meal data', name: 'MessStaffMealProvider');
      
      // Clear the data in memory
      _messStaffMealData = null;
      _selectedMeal = 0;
      _isLoading = false;
      _errorMessage = '';
      
      // Clear the cached data
      await SharedUtils.setString('cached_mess_staff_meals', '');
      
      log('✅ Successfully cleared all mess staff meal data', name: 'MessStaffMealProvider');
      notifyListeners();
    } catch (e) {
      log('❌ Error clearing mess staff meal data: $e', name: 'MessStaffMealProvider');
    }
  }

  // Reset provider state - less drastic than clear
  void reset() {
    _isLoading = false;
    _errorMessage = '';
    _selectedMeal = 0;
    notifyListeners();
  }
}