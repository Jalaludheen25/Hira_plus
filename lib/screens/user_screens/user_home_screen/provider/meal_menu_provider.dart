import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:hira_plus/constants/api_urls.dart';
import 'package:hira_plus/screens/user_screens/user_home_screen/models/meal_menu_model.dart';
import 'package:hira_plus/utils/shared_utils.dart';

class MealMenuProvider extends ChangeNotifier {
  MealMenuResponse? _mealMenuData;
  bool _isLoading = false;
  String _errorMessage = '';
  DateTime _selectedDate = DateTime.now();

  // Getters
  MealMenuResponse? get mealMenuData => _mealMenuData;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  DateTime get selectedDate => _selectedDate;

  // Get menus for selected date
  List<Menu> get selectedDateMenus => _mealMenuData?.menus ?? [];

  // Set selected date
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    developer.log(
        '📅 Selected date changed to: ${date.toIso8601String().split('T')[0]}',
        name: 'MealMenuProvider');
    notifyListeners();
  }

  // Fetch meal menu data
  Future<void> fetchMealMenu(BuildContext context) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      developer.log('🔄 Starting to fetch meal menu data',
          name: 'MealMenuProvider');

      // Get auth token
      final token = await SharedUtils.getString('auth_token');
      if (token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      // Format date for API
      final dateString = _selectedDate.toIso8601String().split('T')[0];
      final url = ApiUrls.mealsMenu(dateString);

      developer.log('📡 Making request to: $url', name: 'MealMenuProvider');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      developer.log('📥 Response status: ${response.statusCode}',
          name: 'MealMenuProvider');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        developer.log('📦 Response data received', name: 'MealMenuProvider');

        _mealMenuData = MealMenuResponse.fromJson(jsonData);
        _isLoading = false;
        notifyListeners();

        developer.log('✅ Meal menu data loaded successfully',
            name: 'MealMenuProvider');
        developer.log('📊 Total menus: ${_mealMenuData?.totalMenus}',
            name: 'MealMenuProvider');
        developer.log('📅 Menus loaded: ${_mealMenuData?.menus.length}',
            name: 'MealMenuProvider');

        notifyListeners();
      } else if (response.statusCode == 401) {
        _isLoading = false;
        _errorMessage = 'Authentication error. Please login again.';
        developer.log('❌ Authentication error (401)', name: 'MealMenuProvider');
        notifyListeners();
      } else {
        _isLoading = false;
        _errorMessage =
            'Failed to load meal menu data. Status: ${response.statusCode}';
        developer.log('❌ HTTP error: ${response.statusCode}',
            name: 'MealMenuProvider');
        notifyListeners();
      }
    } on http.ClientException catch (e) {
      _isLoading = false;
      _errorMessage =
          'Network connection failed. Please check your internet connection.';
      developer.log('❌ Network error: $e', name: 'MealMenuProvider');
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load meal menu data: ${e.toString()}';
      developer.log('❌ Error fetching meal menu data: $e',
          name: 'MealMenuProvider');
      notifyListeners();
    }
  }

  // Get menus for a specific date
  List<Menu> getMenusForDate(DateTime date) {
    if (_mealMenuData == null) return [];

    return _mealMenuData!.menus
        .where((menu) =>
            menu.date.year == date.year &&
            menu.date.month == date.month &&
            menu.date.day == date.day)
        .toList();
  }

  // Get all available dates
  List<DateTime> get availableDates {
    if (_mealMenuData == null) return [];

    return _mealMenuData!.menus.map((menu) => menu.date).toList()..sort();
  }

  // Check if a date has menu data
  bool hasDataForDate(DateTime date) {
    if (_mealMenuData == null) return false;

    return _mealMenuData!.menus.any((menu) =>
        menu.date.year == date.year &&
        menu.date.month == date.month &&
        menu.date.day == date.day);
  }

  // Reset provider state
  void reset() {
    _mealMenuData = null;
    _isLoading = false;
    _errorMessage = '';
    _selectedDate = DateTime.now();
    developer.log('🔄 Meal menu provider reset', name: 'MealMenuProvider');
    notifyListeners();
  }

  // Clear data (for logout)
  Future<void> clearData() async {
    reset();
    developer.log('🧹 Meal menu provider data cleared',
        name: 'MealMenuProvider');
  }
}
