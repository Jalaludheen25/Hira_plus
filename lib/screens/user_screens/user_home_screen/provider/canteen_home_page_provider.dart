import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hira_plus/providers/date_provider.dart';
import 'package:hira_plus/screens/user_screens/user_home_screen/models/banner_model.dart';
import 'package:hira_plus/screens/user_screens/user_home_screen/models/meal_model.dart';
import 'package:hira_plus/screens/user_screens/user_home_screen/services/meal_service.dart';
import 'package:hira_plus/screens/user_screens/user_home_screen/services/contact_service.dart';
import 'package:hira_plus/screens/user_screens/user_home_screen/models/contact_model.dart';
import 'package:hira_plus/screens/user_screens/user_home_screen/models/today_checkin_model.dart';

enum HomeViewMode { list, month }

class CanteenHomeProvider extends ChangeNotifier {
  final MealService _mealService = MealService();
  final ContactService _contactService = ContactService();

  // HomeViewModeProvider properties
  HomeViewMode _mode = HomeViewMode.list;

  // CanteenHomePageProvider properties
  DateTime _selectedDate = DateTime.now();
  List<DateTime> _allDays = [];
  final int _currentYear = DateTime.now().year;
  final bool _isLoadingNextYear = false;

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
  String _searchQuery = '';

  // Check-in state
  TodayCheckInModel? _todayCheckIns;
  bool _isLoadingCheckIns = false;
  String _checkInsError = '';

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
  String get searchQuery => _searchQuery;

  // Check-in getters
  TodayCheckInModel? get todayCheckIns => _todayCheckIns;
  bool get isLoadingCheckIns => _isLoadingCheckIns;
  String get checkInsError => _checkInsError;

  // Computed filtered contacts based on search query
  List<ContactModel> get filteredContacts {
    if (_searchQuery.isEmpty) return _contacts;
    final lowerQuery = _searchQuery.toLowerCase();
    return _contacts.where((contact) {
      return contact.name.toLowerCase().contains(lowerQuery) ||
          contact.phoneNumber.toLowerCase().contains(lowerQuery) ||
          contact.department.toLowerCase().contains(lowerQuery) ||
          contact.designation.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Returns a set of checked-in user names for quick lookup
  Set<String> get checkedInUserNames {
    if (_todayCheckIns == null) return {};
    return _todayCheckIns!.checkIns.map((c) => c.user.name).toSet();
  }

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
    log('setMode called: $mode', name: 'CanteenHomeProvider');
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

      log('✅ Successfully updated meals in provider. Count: ${_meals.length}');
      notifyListeners();
    } on HttpException catch (e) {
      log('🚨 HTTP error in meal provider: $e');
      _isLoading = false;

      // Provide more specific error messages
      if (e.toString().contains('401') ||
          e.toString().contains('Unauthorized')) {
        _errorMessage = 'Authentication error. Please login again.';
      } else if (e.toString().contains('timeout') ||
          e.toString().contains('Connection timeout')) {
        _errorMessage =
            'Connection timeout. Please check your network and try again.';
      } else if (e.toString().contains('No internet') ||
          e.toString().contains('network')) {
        _errorMessage =
            'No internet connection. Please check your network and try again.';
      } else if (e.toString().contains('500') ||
          e.toString().contains('Server error')) {
        _errorMessage = 'Server error. Please try again later.';
      } else if (e.toString().contains('503') ||
          e.toString().contains('unavailable')) {
        _errorMessage =
            'Service temporarily unavailable. Please try again later.';
      } else {
        _errorMessage =
            'Failed to load meals. Please check your connection and try again.';
      }

      notifyListeners();
    } catch (e) {
      log('❌ Error in meal provider: $e');
      _isLoading = false;

      // Handle different types of errors
      if (e.toString().contains('timeout')) {
        _errorMessage =
            'Connection timeout. Please check your network and try again.';
      } else if (e.toString().contains('SocketException') ||
          e.toString().contains('network')) {
        _errorMessage =
            'Network error. Please check your internet connection and try again.';
      } else if (e.toString().contains('FormatException')) {
        _errorMessage = 'Invalid data format received. Please try again.';
      } else {
        _errorMessage = 'Failed to load meals. Please try again.';
      }

      notifyListeners();
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

    log('🔢 Calculating meal counts for month: $currentMonth/$currentYear',
        name: 'MealCounts');

    int breakfastCount = 0;
    int lunchCount = 0;
    int dinnerCount = 0;

    // Get first and last day of the current month
    final firstDay = DateTime(currentYear, currentMonth, 1);
    final lastDay = DateTime(currentYear, currentMonth + 1, 0);

    log('📅 Date range: ${firstDay.toString().split(' ')[0]} to ${lastDay.toString().split(' ')[0]}',
        name: 'MealCounts');

    // Iterate through each day of the month
    for (DateTime date = firstDay;
        date.isBefore(lastDay.add(const Duration(days: 1)));
        date = date.add(const Duration(days: 1))) {
      if (isMealMarked(date, 'breakfast')) breakfastCount++;
      if (isMealMarked(date, 'lunch')) lunchCount++;
      if (isMealMarked(date, 'dinner')) dinnerCount++;
    }

    log('✅ Meal counts calculated: Breakfast: $breakfastCount, Lunch: $lunchCount, Dinner: $dinnerCount',
        name: 'MealCounts');

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
        log('🔄 Already fetching contacts, ignoring new request',
            name: 'CanteenHomeProvider');
        return;
      }

      _isLoadingContacts = true;
      _contactsError = '';
      notifyListeners();

      log('🔄 Starting to fetch contacts in provider',
          name: 'CanteenHomeProvider');
      final contactsResponse = await _contactService.getContacts(context);

      if (contactsResponse.success) {
        _contacts = contactsResponse.users;
        log('✅ Successfully updated contacts in provider. Count: ${_contacts.length}',
            name: 'CanteenHomeProvider');
      } else {
        _contactsError = 'Failed to fetch contacts from server';
        log('❌ Contacts API returned success: false',
            name: 'CanteenHomeProvider');
      }

      _isLoadingContacts = false;
      notifyListeners();
    } on HttpException catch (e) {
      log('🚨 HTTP error in contacts provider: $e',
          name: 'CanteenHomeProvider');
      _isLoadingContacts = false;

      if (e.toString().contains('401')) {
        _contactsError = 'Authentication error. Please login again.';
      } else {
        _contactsError =
            'Failed to load contacts. Please check your connection and try again.';
      }

      notifyListeners();
    } catch (e) {
      log('❌ Error in contacts provider: $e', name: 'CanteenHomeProvider');
      _isLoadingContacts = false;
      _contactsError = 'Failed to load contacts. Please try again.';
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Search contacts by name, department, or designation
  List<ContactModel> searchContacts(String query) {
    if (query.isEmpty) return _contacts;
    final lowerQuery = query.toLowerCase();
    return _contacts.where((contact) {
      return contact.name.toLowerCase().contains(lowerQuery) ||
          contact.phoneNumber.toLowerCase().contains(lowerQuery) ||
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
    _searchQuery = '';
    _updateAllDays(null);
    notifyListeners();
  }

  // Check-in methods
  Future<void> fetchTodayCheckIns(BuildContext context) async {
    try {
      _isLoadingCheckIns = true;
      _checkInsError = '';
      notifyListeners();
      final result = await _contactService.getTodayCheckIns(context);
      if (result != null) {
        _todayCheckIns = result;
      } else {
        _checkInsError = 'Failed to fetch today\'s check-ins.';
      }
      _isLoadingCheckIns = false;
      notifyListeners();
    } catch (e) {
      _isLoadingCheckIns = false;
      _checkInsError = 'Error fetching today\'s check-ins: \\${e.toString()}';
      notifyListeners();
    }
  }
}
