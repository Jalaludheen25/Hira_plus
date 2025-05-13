import 'dart:developer';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hira_plus/screens/user_screens/user_home_screen/models/meal_model.dart';
import 'package:hira_plus/screens/user_screens/user_home_screen/services/meal_service.dart';
import 'package:hira_plus/utils/shared_utils.dart';

class MealProvider extends ChangeNotifier {
  final MealService _mealService = MealService();

  List<MealModel> _meals = [];
  bool _isLoading = false;
  String _errorMessage = '';
  DateTime _lastFetchTime = DateTime(2000); // Long time ago

  // Getters
  List<MealModel> get meals => _meals;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  DateTime get lastFetchTime => _lastFetchTime;

  /// Fetches meals for the current user from the API
  Future<void> fetchUserMeals(BuildContext context) async {
    try {
      // Only start loading if we're not already loading
      if (_isLoading) {
        log('🔄 Already fetching meals, ignoring new request');
        return;
      }

      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      log('🔄 Starting to fetch meals in provider');
      final meals = await _mealService.getUserMeals(context);

      _meals = meals;
      _isLoading = false;
      _lastFetchTime = DateTime.now();

      // Save meal data to shared preferences for offline access
      await _saveMealsToCache();

      log('✅ Successfully updated meals in provider. Count: ${_meals.length}');
      notifyListeners();
    } on HttpException catch (e) {
      log('🚨 HTTP error in meal provider: $e');
      _isLoading = false;

      if (e.toString().contains('401')) {
        _errorMessage = 'Authentication error. Please login again.';
      } else {
        _errorMessage =
            'Failed to load meals. Please check your connection and try again.';
      }

      // Try to load from cache if available
      await _loadMealsFromCache();

      notifyListeners();
    } catch (e) {
      log('❌ Error in meal provider: $e');
      _isLoading = false;
      _errorMessage = 'Failed to load meals. Please try again.';

      // Try to load from cache if available
      await _loadMealsFromCache();

      notifyListeners();
    }
  }

  // Save meals to cache
  Future<void> _saveMealsToCache() async {
    try {
      if (_meals.isNotEmpty) {
        final mealJsonList =
            _meals.map((meal) => jsonEncode(meal.toJson())).toList();
        final mealJsonString = jsonEncode(mealJsonList);
        await SharedUtils.setString('cached_meals', mealJsonString);
        log('💾 Saved ${_meals.length} meals to cache');
      }
    } catch (e) {
      log('❌ Error saving meals to cache: $e');
    }
  }

  // Load meals from cache
  Future<void> _loadMealsFromCache() async {
    try {
      if (_meals.isEmpty) {
        final cachedMealsJson = await SharedUtils.getString('cached_meals');
        if (cachedMealsJson.isNotEmpty) {
          final List<dynamic> mealJsonList = jsonDecode(cachedMealsJson);
          final cachedMeals = mealJsonList
              .map((mealJson) => MealModel.fromJson(jsonDecode(mealJson)))
              .toList();

          if (cachedMeals.isNotEmpty) {
            _meals = cachedMeals;
            log('📂 Loaded ${_meals.length} meals from cache');
          }
        }
      }
    } catch (e) {
      log('❌ Error loading meals from cache: $e');
    }
  }

  /// Gets a meal for a specific date or null if not found
  MealModel? getMealForDate(DateTime date) {
    final formattedDate = DateTime(date.year, date.month, date.day);

    // Find meal for the given date, return null if not found
    final meal = _meals.firstWhere(
      (meal) => DateTime(
        meal.date.year,
        meal.date.month,
        meal.date.day,
      ).isAtSameMomentAs(formattedDate),
      orElse: () => MealModel(
        id: '',
        date: formattedDate,
        userId: '',
        breakfast: false,
        lunch: false,
        dinner: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    // Return null if it's an empty meal (created by orElse)
    // if (meal.id.isEmpty) {
    //   log('📅 No meal found for date: ${formattedDate.toIso8601String()}');
    //   return null;
    // }

    return meal;
  }

  /// Checks if a specific meal type is marked for a given date
  bool isMealMarked(DateTime date, String mealType) {
    final meal = getMealForDate(date);
    if (meal == null) return false;

    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return meal.breakfast;
      case 'lunch':
        return meal.lunch;
      case 'dinner':
        return meal.dinner;
      default:
        return false;
    }
  }

  /// Resets the provider state
  void reset() {
    _meals = [];
    _isLoading = false;
    _errorMessage = '';
    notifyListeners();
  }
}
