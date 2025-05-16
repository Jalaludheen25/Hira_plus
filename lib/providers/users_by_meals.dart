import 'package:flutter/material.dart';
import 'package:hira_plus/models/meal_users_model.dart';
import 'package:hira_plus/utils/service_utils.dart';
import 'package:hira_plus/constants/api_urls.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hira_plus/utils/shared_utils.dart';
import 'package:hira_plus/screens/login_screen/provider/auth_provider.dart';
import 'package:hira_plus/utils/navigation_helper.dart';
import 'package:hira_plus/routes/app_routes.dart';
import 'package:provider/provider.dart';

class UsersByMealsProvider extends ChangeNotifier {
  List<UsersByMealModel> _breakfastUsers = [];
  List<UsersByMealModel> _lunchUsers = [];
  List<UsersByMealModel> _dinnerUsers = [];
  bool _isLoading = false;
  String? _error;
  String _currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  bool _authErrorHandled = false;
  int _authErrorCount = 0;
  DateTime? _firstAuthErrorTime;
  
  // Constants for error handling
  static const int maxAuthErrors = 3; // Number of errors before logout
  static const Duration authErrorTimeWindow = Duration(minutes: 5); // Time window to count errors

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
      
      // Reset auth error count on successful fetch
      _authErrorCount = 0;
      _firstAuthErrorTime = null;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching all meals: $e');
      _error = e.toString();
      _isLoading = false;
      
      // Handle authentication error with a more sophisticated approach
      if (e.toString().contains('Authentication failed') && !_authErrorHandled) {
        _trackAuthError();
      }
      
      notifyListeners();
    }
  }

  // Track authentication errors to prevent immediate logout on transient issues
  void _trackAuthError() {
    // Set the first error time if this is the first error
    _firstAuthErrorTime ??= DateTime.now();
    
    // Increment the error count
    _authErrorCount++;
    
    // Check if we've exceeded the time window - if so, reset the counter
    final now = DateTime.now();
    if (_firstAuthErrorTime != null && 
        now.difference(_firstAuthErrorTime!) > authErrorTimeWindow) {
      _firstAuthErrorTime = now;
      _authErrorCount = 1;
      debugPrint('[log] 🕒 Auth error time window reset, starting new count');
    }
    
    debugPrint('[log] 🔢 Auth error count: $_authErrorCount');
    
    // Only handle the auth error if we've reached the threshold
    if (_authErrorCount >= maxAuthErrors) {
      debugPrint('[log] ⚠️ Auth error threshold reached, handling logout');
      _handleAuthError();
    } else {
      debugPrint('[log] ⏳ Auth error detected but below threshold, continuing');
    }
  }

  // Handle authentication error - logout and redirect to login
  void _handleAuthError() async {
    _authErrorHandled = true; // Prevent multiple redirects
    debugPrint('[log] 🔐 Handling authentication error, logging out...');
    
    try {
      // Clear auth data
      await SharedUtils.setString('auth_token', '');
      await SharedUtils.setString('user_type', '');
      
      // Navigate to login screen
      if (navigatorKey.currentContext != null) {
        // Get auth provider and update state
        final authProvider = Provider.of<AuthProvider>(
          navigatorKey.currentContext!,
          listen: false
        );
        await authProvider.logout();
        
        // Show message and navigate to login
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          const SnackBar(
            content: Text('Session expired. Please login again.'),
            duration: Duration(seconds: 2),
          ),
        );
        
        // Navigate to login screen with a delay
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.of(navigatorKey.currentContext!)
            .pushNamedAndRemoveUntil(Routes.login, (route) => false);
        });
      }
    } catch (e) {
      debugPrint('[log] Error handling auth error: $e');
    }
  }

  // Fetch users for a specific meal type
  Future<void> fetchMealUsers(String mealType) async {
    try {
      // Direct API call for better error handling
      final url = ApiUrls.usersByMeal(_currentDate, mealType);
      debugPrint('[log] URL: $url');
      
      final authToken = await SharedUtils.getString('auth_token');
      if (authToken.isEmpty) {
        debugPrint('[log] 🔒 No auth token available');
        throw Exception('Authentication required');
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken'
        },
      );
      
      debugPrint('[log] Response Status Code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData == null) {
          // Handle null response
          debugPrint('[log] Empty response data for $mealType');
          // Update appropriate meal list with empty array
          _updateMealList(mealType, []);
          return;
        }
        
        // Safe type casting with null check
        if (responseData is List) {
          final users = responseData
              .map((e) => UsersByMealModel.fromJson(e))
              .toList();
          
          _updateMealList(mealType, users);
          debugPrint('[log] Fetched ${users.length} users for $mealType on $_currentDate');
        } else {
          debugPrint('[log] Invalid response format for $mealType: $responseData');
          _updateMealList(mealType, []);
        }
      } else if (response.statusCode == 401) {
        debugPrint('[log] 🔒 Authentication error: Token may be expired or invalid');
        _updateMealList(mealType, []);
        throw Exception('Authentication failed. Please login again.');
      } else {
        debugPrint('[log] Error response for $mealType: ${response.body}');
        _updateMealList(mealType, []);
      }
    } catch (e) {
      debugPrint('Error fetching $mealType users: $e');
      // Set appropriate meal list to empty to avoid null issues
      _updateMealList(mealType, []);
      rethrow;
    }
  }
  
  // Helper method to update the right meal list
  void _updateMealList(String mealType, List<UsersByMealModel> users) {
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
  }
} 