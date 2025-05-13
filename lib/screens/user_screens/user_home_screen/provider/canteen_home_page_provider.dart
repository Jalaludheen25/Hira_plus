import 'dart:developer';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hira_plus/providers/date_provider.dart';
import 'package:hira_plus/screens/user_screens/user_home_screen/models/meal_model.dart';
import 'package:hira_plus/screens/user_screens/user_home_screen/services/meal_service.dart';
import 'package:hira_plus/utils/shared_utils.dart';


enum HomeViewMode { list, month }

class CanteenHomeProvider extends ChangeNotifier {
  final MealService _mealService = MealService();
  
  // HomeViewModeProvider properties
  HomeViewMode _mode = HomeViewMode.list;
  
  // CanteenHomePageProvider properties
  DateTime _selectedDate = DateTime.now();
  List<DateTime> _allDays = [];
  int _currentYear = DateTime.now().year;
  bool _isLoadingNextYear = false;
  
  // MealProvider properties
  List<MealModel> _meals = [];
  bool _isLoading = false;
  String _errorMessage = '';
  DateTime _lastFetchTime = DateTime(2000); // Initial value
  
  // Getters
  // View mode getters
  HomeViewMode get mode => _mode;
  
  // Date getters
  DateTime get selectedDate => _selectedDate;
  List<DateTime> get allDays => _allDays;
  int get currentYear => _currentYear;
  bool get isLoadingNextYear => _isLoadingNextYear;
  
  // Meal getters
  List<MealModel> get meals => _meals;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  DateTime get lastFetchTime => _lastFetchTime;
  
  // Constructor
  CanteenHomeProvider(BuildContext context) {
    _updateAllDays(context);
  }
  
  // HomeViewModeProvider methods
  void toggleMode() {
    _mode = _mode == HomeViewMode.list ? HomeViewMode.month : HomeViewMode.list;
    notifyListeners();
  }
  
  void setMode(HomeViewMode mode) {
    _mode = mode;
    notifyListeners();
  }
  
  // CanteenHomePageProvider methods
  void _updateAllDays(BuildContext? context) {
    final now = DateTime.now();
    final prevMonth = DateTime(now.year, now.month - 1, 1);
    final nextMonth = DateTime(now.year, now.month + 2, 0); // Last day of next month
    _allDays = [];
    
    DateTime currentDate = prevMonth;
    while (currentDate.isBefore(nextMonth) || currentDate.isAtSameMomentAs(nextMonth)) {
      _allDays.add(currentDate);
      currentDate = currentDate.add(const Duration(days: 1));
    }
    
    if (context != null) {
      final dateProvider = DateProvider();
      for (var date in _allDays) {
        final dateKey = '${date.year}-${date.month}-${date.day}';
        dateProvider.initializeDate(dateKey);
      }
    }
    
    notifyListeners();
  }
  
  void setSelectedDate(DateTime date, BuildContext context) {
    _selectedDate = date;
    notifyListeners();
  }
  
  void goToToday(BuildContext context) {
    _selectedDate = DateTime.now();
    _updateAllDays(context);
    notifyListeners();
  }
  
  int getTodayIndex() {
    final now = DateTime.now();
    return _allDays.indexWhere((date) =>
      date.day == now.day && date.month == now.month && date.year == now.year);
  }
  
  // MealProvider methods
  Future<void> fetchUserMeals(BuildContext context) async {
    try {
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
        _errorMessage = 'Failed to load meals. Please check your connection and try again.';
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
  
  Future<void> _saveMealsToCache() async {
    try {
      if (_meals.isNotEmpty) {
        final mealJsonList = _meals.map((meal) => jsonEncode(meal.toJson())).toList();
        final mealJsonString = jsonEncode(mealJsonList);
        await SharedUtils.setString('cached_meals', mealJsonString);
        log('💾 Saved ${_meals.length} meals to cache');
      }
    } catch (e) {
      log('❌ Error saving meals to cache: $e');
    }
  }
  
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
  
  MealModel? getMealForDate(DateTime date) {
    final formattedDate = DateTime(date.year, date.month, date.day);

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

    return meal;
  }
  
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
  
  // Reset all provider state
  void reset() {
    _meals = [];
    _isLoading = false;
    _errorMessage = '';
    _mode = HomeViewMode.list;
    _selectedDate = DateTime.now();
    _updateAllDays(null);
    notifyListeners();
  }
}