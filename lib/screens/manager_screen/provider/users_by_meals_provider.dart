import 'package:flutter/material.dart';
import 'package:hira_plus/screens/manager_screen/models/meal_users_model.dart';
import 'package:hira_plus/utils/service_utils.dart';
import 'package:hira_plus/constants/api_urls.dart';
import 'package:intl/intl.dart';

class UsersByMealsProvider extends ChangeNotifier {
  List<UsersByMealModel> _breakfastUsers = [];
  List<UsersByMealModel> _lunchUsers = [];
  List<UsersByMealModel> _dinnerUsers = [];
  bool _isLoading = false;
  String? _error;
  String _currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  // Getters
  List<UsersByMealModel> get breakfastUsers => _breakfastUsers;
  List<UsersByMealModel> get lunchUsers => _lunchUsers;
  List<UsersByMealModel> get dinnerUsers => _dinnerUsers;
  int get breakfastCount => _breakfastUsers.length;
  int get lunchCount => _lunchUsers.length;
  int get dinnerCount => _dinnerUsers.length;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentDate => _currentDate;

  // Set date and fetch all meal data
  Future<void> setDate(String date) async {
    _currentDate = date;
    await fetchAllMeals();
  }

  // Fetch all meal types
  Future<void> fetchAllMeals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Fetch in parallel
      await Future.wait([
        fetchMealUsers('breakfast'),
        fetchMealUsers('lunch'),
        fetchMealUsers('dinner'),
      ]);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching all meals: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch users for a specific meal type
  Future<void> fetchMealUsers(String mealType) async {
    try {
      final response = await HttpServiceUtils.fetchData(
        ApiUrls.usersByMeal(_currentDate, mealType), true);
      
      final users = (response as List)
          .map((e) => UsersByMealModel.fromJson(e))
          .toList();
      
      // Update appropriate meal list
      switch(mealType.toLowerCase()) {
        case 'breakfast':
          _breakfastUsers = users;
          break;
        case 'lunch':
          _lunchUsers = users;
          break;
        case 'dinner':
          _dinnerUsers = users;
          break;
      }
      
      debugPrint('Fetched ${users.length} users for $mealType on $_currentDate');
    } catch (e) {
      debugPrint('Error fetching $mealType users: $e');
      // Don't rethrow, we'll handle the error in fetchAllMeals
    }
  }


  
} 