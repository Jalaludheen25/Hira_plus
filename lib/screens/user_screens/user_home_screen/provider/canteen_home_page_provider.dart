import 'dart:developer';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hira_plus/providers/date_provider.dart';
import 'package:hira_plus/screens/user_screens/user_home_screen/models/banner_model.dart';
import 'package:hira_plus/screens/user_screens/user_home_screen/models/meal_model.dart';
import 'package:hira_plus/screens/user_screens/user_home_screen/services/meal_service.dart';
import 'package:hira_plus/screens/user_screens/user_home_screen/services/contact_service.dart';
import 'package:hira_plus/screens/user_screens/user_home_screen/models/contact_model.dart';
import 'package:hira_plus/utils/shared_utils.dart';

enum HomeViewMode { list, month }

class CanteenHomeProvider extends ChangeNotifier {
  final MealService _mealService = MealService();
  final ContactService _contactService = ContactService();

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

  // Banner state
  BannerModel? _banner;
  BannerModel? get banner => _banner;

  // Contacts state
  List<ContactModel> _contacts = [];
  bool _isLoadingContacts = false;
  String _contactsError = '';

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

  // Contacts getters
  List<ContactModel> get contacts => _contacts;
  bool get isLoadingContacts => _isLoadingContacts;
  String get contactsError => _contactsError;

  // Constructor
  CanteenHomeProvider(BuildContext context) {
    _updateAllDays(context);
    fetchBanner();
  }

  // HomeViewModeProvider methods
  void toggleMode() {
    _mode = _mode == HomeViewMode.list ? HomeViewMode.month : HomeViewMode.list;
    notifyListeners();
  }

  void setMode(HomeViewMode mode) {
    log('setMode called: ' + mode.toString(), name: 'CanteenHomeProvider');
    _mode = mode;
    notifyListeners();
  }

  // CanteenHomePageProvider methods
  void _updateAllDays(BuildContext? context) {
    final now = DateTime.now();
    final prevMonth = DateTime(now.year, now.month - 1, 1);
    final nextMonth =
        DateTime(now.year, now.month + 2, 0); // Last day of next month
    _allDays = [];

    DateTime currentDate = prevMonth;
    while (currentDate.isBefore(nextMonth) ||
        currentDate.isAtSameMomentAs(nextMonth)) {
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
        date.day == now.day &&
        date.month == now.month &&
        date.year == now.year);
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

  /// Updates a meal option for a specific date
  /// Returns the updated meal
  Future<MealModel?> updateMeal(
    BuildContext context, {
    required DateTime date,
    bool? breakfast,
    bool? lunch,
    bool? dinner,
  }) async {
    try {
      // Get current meal values for the date
      final currentMeal = getMealForDate(date);
      log('Current meal state: ${currentMeal?.toJson()}',
          name: 'CanteenHomeProvider');

      // Use provided values or fallback to current values
      final updatedBreakfast = breakfast ?? currentMeal?.breakfast ?? false;
      final updatedLunch = lunch ?? currentMeal?.lunch ?? false;
      final updatedDinner = dinner ?? currentMeal?.dinner ?? false;

      log('Final meal values to send - Breakfast: $updatedBreakfast, Lunch: $updatedLunch, Dinner: $updatedDinner',
          name: 'CanteenHomeProvider');

      // Call meal service to update the meal
      final updatedMeal = await _mealService.addMealForUser(
        context,
        date: date,
        breakfast: updatedBreakfast,
        lunch: updatedLunch,
        dinner: updatedDinner,
      );

      log('✅ Meal updated successfully: ${updatedMeal.id}',
          name: 'CanteenHomeProvider');
      log('Updated meal details: ${updatedMeal.toJson()}',
          name: 'CanteenHomeProvider');

      // Update local meals list without triggering a full rebuild
      if (currentMeal != null && currentMeal.id.isNotEmpty) {
        // Replace existing meal
        final index = _meals.indexWhere((meal) => meal.id == currentMeal.id);
        if (index != -1) {
          log('Replacing existing meal at index $index',
              name: 'CanteenHomeProvider');
          _meals[index] = updatedMeal;
        } else {
          log('Adding new meal (existing meal not found in local list)',
              name: 'CanteenHomeProvider');
          _meals.add(updatedMeal);
        }
      } else {
        // Add new meal
        log('Adding entirely new meal to local list',
            name: 'CanteenHomeProvider');
        _meals.add(updatedMeal);
      }

      // Update cache
      await _saveMealsToCache();
      log('Meal cache updated', name: 'CanteenHomeProvider');

      // Only notify listeners once at the end
      notifyListeners();

      return updatedMeal;
    } catch (e) {
      log('❌ Error updating meal: $e', name: 'CanteenHomeProvider');
      _errorMessage = 'Failed to update meal. Please try again.';
      notifyListeners();
      return null;
    }
  }

  // Method to count meals for the current month
  Map<String, int> getCurrentMonthMealCounts() {
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;
    
    log('🔢 Calculating meal counts for month: $currentMonth/$currentYear', name: 'MealCounts');

    int breakfastCount = 0;
    int lunchCount = 0;
    int dinnerCount = 0;

    // Get first and last day of the current month
    final firstDay = DateTime(currentYear, currentMonth, 1);
    final lastDay = DateTime(currentYear, currentMonth + 1, 0);

    log('📅 Date range: ${firstDay.toString().split(' ')[0]} to ${lastDay.toString().split(' ')[0]}', name: 'MealCounts');

    // Iterate through each day of the month
    for (DateTime date = firstDay; 
         date.isBefore(lastDay.add(const Duration(days: 1))); 
         date = date.add(const Duration(days: 1))) {
      
      if (isMealMarked(date, 'breakfast')) breakfastCount++;
      if (isMealMarked(date, 'lunch')) lunchCount++;
      if (isMealMarked(date, 'dinner')) dinnerCount++;
    }

    log('✅ Meal counts calculated: Breakfast: $breakfastCount, Lunch: $lunchCount, Dinner: $dinnerCount', name: 'MealCounts');

    return {
      'breakfast': breakfastCount,
      'lunch': lunchCount,
      'dinner': dinnerCount,
    };
  }

  Future<void> fetchBanner() async {
    _banner = await _mealService.fetchBanner();
    notifyListeners();
  }

  // Contacts methods
  Future<void> fetchContacts(BuildContext context) async {
    try {
      if (_isLoadingContacts) {
        log('🔄 Already fetching contacts, ignoring new request', name: 'CanteenHomeProvider');
        return;
      }

      _isLoadingContacts = true;
      _contactsError = '';
      notifyListeners();

      log('🔄 Starting to fetch contacts in provider', name: 'CanteenHomeProvider');
      final contactsResponse = await _contactService.getContacts(context);

      if (contactsResponse.success) {
        _contacts = contactsResponse.users;
        log('✅ Successfully updated contacts in provider. Count: ${_contacts.length}', 
            name: 'CanteenHomeProvider');
      } else {
        _contactsError = 'Failed to fetch contacts from server';
        log('❌ Contacts API returned success: false', name: 'CanteenHomeProvider');
      }

      _isLoadingContacts = false;
      notifyListeners();
    } on HttpException catch (e) {
      log('🚨 HTTP error in contacts provider: $e', name: 'CanteenHomeProvider');
      _isLoadingContacts = false;

      if (e.toString().contains('401')) {
        _contactsError = 'Authentication error. Please login again.';
      } else {
        _contactsError = 'Failed to load contacts. Please check your connection and try again.';
      }

      notifyListeners();
    } catch (e) {
      log('❌ Error in contacts provider: $e', name: 'CanteenHomeProvider');
      _isLoadingContacts = false;
      _contactsError = 'Failed to load contacts. Please try again.';
      notifyListeners();
    }
  }

  /// Search contacts by name, department, or designation
  List<ContactModel> searchContacts(String query) {
    if (query.isEmpty) return _contacts;
    
    final lowerQuery = query.toLowerCase();
    return _contacts.where((contact) {
      return contact.name.toLowerCase().contains(lowerQuery) ||
             contact.department.toLowerCase().contains(lowerQuery) ||
             contact.designation.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Reset all provider state
  void reset() {
    _meals = [];
    _isLoading = false;
    _errorMessage = '';
    _mode = HomeViewMode.list;
    _selectedDate = DateTime.now();
    _contacts = [];
    _isLoadingContacts = false;
    _contactsError = '';
    _updateAllDays(null);
    notifyListeners();
  }
}