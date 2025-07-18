import 'package:flutter/material.dart';
import 'package:hira_plus/constants/api_urls.dart';
import 'package:hira_plus/screens/user_screens/booking_screen/model/guest_meal_model.dart';
import 'package:hira_plus/utils/service_utils.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;
import 'package:logger/logger.dart';

class BulkFoodProvider extends ChangeNotifier {
  final Logger _logger = Logger();
  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Guest meals list
  List<GuestMealModel> _guestMeals = [];
  List<GuestMealModel> get guestMeals => _guestMeals;

  void _setLoading(bool loading) {
    _isLoading = loading;
    _logger.d('🔄 [LOADING] Loading state changed to: $loading');
    developer.log('🔄 Loading state changed to: $loading', name: 'BulkFoodProvider');
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _logger.e('❌ [ERROR] Error set: $error');
    developer.log('❌ Error set: $error', name: 'BulkFoodProvider');
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  /// Submits bulk food booking for guests
  /// Returns true if successful, false otherwise
  Future<bool> submitBulkFoodBooking({
    required BuildContext context,
    required DateTime date,
    required int breakfastCount,
    required int lunchCount,
    required int dinnerCount,
  }) async {
    try {
      _logger.i('🚀 [API] Starting bulk food booking submission');
      developer.log('🚀 Starting bulk food booking submission', name: 'BulkFoodProvider');
      
      _setLoading(true);
      _clearError();

      // Format date
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      
      _logger.d('📅 [DATA] Date: $formattedDate');
      _logger.d('🍽️ [DATA] Breakfast: $breakfastCount, Lunch: $lunchCount, Dinner: $dinnerCount');
      developer.log('📅 Date: $formattedDate', name: 'BulkFoodProvider');
      developer.log('🍽️ Meal counts - Breakfast: $breakfastCount, Lunch: $lunchCount, Dinner: $dinnerCount', 
          name: 'BulkFoodProvider');

      // Prepare request body
      final requestBody = {
        'date': formattedDate,
        'breakfastCount': breakfastCount,
        'lunchCount': lunchCount,
        'dinnerCount': dinnerCount,
      };

      _logger.d('📦 [REQUEST] Request body: $requestBody');
      developer.log('📦 Request body: $requestBody', name: 'BulkFoodProvider');

      // Get API URL
      final url = ApiUrls.getGuestMeals();
      _logger.d('🌐 [API] URL: $url');
      developer.log('🌐 API URL: $url', name: 'BulkFoodProvider');

      // Make API call
      final response = await HttpServiceUtils.postData(url, requestBody, context);
      
      if (response != null) {
        _logger.i('✅ [SUCCESS] Bulk food booking submitted successfully');
        _logger.d('📋 [RESPONSE] Response data: $response');
        developer.log('✅ Bulk food booking submitted successfully', name: 'BulkFoodProvider');
        developer.log('📋 Response data: $response', name: 'BulkFoodProvider');
        
        _setLoading(false);
        return true;
      } else {
        _logger.e('❌ [ERROR] Empty response from server');
        developer.log('❌ Empty response from server', name: 'BulkFoodProvider');
        
        _setError('Failed to submit booking. Please try again.');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _logger.e('💥 [EXCEPTION] Error in bulk food booking: $e');
      developer.log('💥 Error in bulk food booking: $e', name: 'BulkFoodProvider', error: e);
      
      _setError('Failed to submit booking: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// Fetches all guest meal bookings
  /// Returns list of guest meals from API
  Future<void> fetchGuestMeals(BuildContext context) async {
    try {
      _logger.i('📥 [API] Fetching all guest meal bookings');
      developer.log('📥 Fetching all guest meal bookings', name: 'BulkFoodProvider');
      
      _setLoading(true);
      _clearError();

      final url = ApiUrls.getGuestMeals();
      _logger.d('🌐 [API] URL: $url');
      developer.log('🌐 API URL: $url', name: 'BulkFoodProvider');

      final response = await HttpServiceUtils.fetchData(url, true);
      
      if (response != null) {
        _logger.i('✅ [SUCCESS] Guest meals fetched successfully');
        developer.log('✅ Guest meals fetched successfully', name: 'BulkFoodProvider');
        
        // Handle the new API response structure with success and guestMeals
        List<dynamic> mealsData;
        if (response is Map<String, dynamic>) {
          if (response.containsKey('success') && response.containsKey('guestMeals')) {
            // New API response format
            mealsData = response['guestMeals'] as List<dynamic>;
            _logger.d('📋 [API] Using new API response format with success field');
            developer.log('📋 Using new API response format with success field', name: 'BulkFoodProvider');
          } else if (response.containsKey('guestMeals')) {
            // Legacy format with guestMeals array
            mealsData = response['guestMeals'] as List<dynamic>;
            _logger.d('📋 [API] Using legacy API response format');
            developer.log('📋 Using legacy API response format', name: 'BulkFoodProvider');
          } else if (response is List<dynamic>) {
            // Direct array response
            mealsData = response as List<dynamic>;
            _logger.d('📋 [API] Using direct array response format');
            developer.log('📋 Using direct array response format', name: 'BulkFoodProvider');
          } else {
            throw Exception('Unexpected response format');
          }
        } else if (response is List<dynamic>) {
          mealsData = response;
          _logger.d('📋 [API] Using direct array response format');
          developer.log('📋 Using direct array response format', name: 'BulkFoodProvider');
        } else {
          throw Exception('Unexpected response format');
        }

        _guestMeals = mealsData
            .map((mealJson) => GuestMealModel.fromJson(mealJson))
            .toList();

        // Sort by date (most recent first)
        _guestMeals.sort((a, b) => b.date.compareTo(a.date));

        _logger.d('📋 [DATA] Loaded ${_guestMeals.length} guest meals');
        developer.log('📋 Loaded ${_guestMeals.length} guest meals', name: 'BulkFoodProvider');
        
        _setLoading(false);
      } else {
        _logger.w('⚠️ [WARNING] Empty response from server');
        developer.log('⚠️ Empty response from server', name: 'BulkFoodProvider');
        
        _guestMeals = [];
        _setLoading(false);
      }
    } catch (e) {
      _logger.e('💥 [EXCEPTION] Error fetching guest meals: $e');
      developer.log('💥 Error fetching guest meals: $e', name: 'BulkFoodProvider', error: e);
      
      _setError('Failed to load bookings: ${e.toString()}');
      _setLoading(false);
    }
  }

  /// Updates an existing guest meal booking
  /// Returns true if successful, false otherwise
  Future<bool> updateGuestMealBooking({
    required BuildContext context,
    required String id,
    required DateTime date,
    required int breakfastCount,
    required int lunchCount,
    required int dinnerCount,
  }) async {
    try {
      _logger.i('🔄 [API] Updating guest meal booking: $id');
      developer.log('🔄 Updating guest meal booking: $id', name: 'BulkFoodProvider');
      
      _setLoading(true);
      _clearError();

      // Format date
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      
      _logger.d('📅 [DATA] Date: $formattedDate');
      _logger.d('🍽️ [DATA] Breakfast: $breakfastCount, Lunch: $lunchCount, Dinner: $dinnerCount');
      developer.log('📅 Date: $formattedDate', name: 'BulkFoodProvider');
      developer.log('🍽️ Meal counts - Breakfast: $breakfastCount, Lunch: $lunchCount, Dinner: $dinnerCount', 
          name: 'BulkFoodProvider');

      // Prepare request body
      final requestBody = {
        'date': formattedDate,
        'breakfastCount': breakfastCount,
        'lunchCount': lunchCount,
        'dinnerCount': dinnerCount,
      };

      _logger.d('📦 [REQUEST] Request body: $requestBody');
      developer.log('📦 Request body: $requestBody', name: 'BulkFoodProvider');

      // Get API URL for update
      final url = ApiUrls.editGuestMeals(id);
      _logger.d('🌐 [API] URL: $url');
      developer.log('🌐 API URL: $url', name: 'BulkFoodProvider');

      // Make API call
      final response = await HttpServiceUtils.putData(url, requestBody, context);
      
      if (response != null) {
        _logger.i('✅ [SUCCESS] Guest meal booking updated successfully');
        developer.log('✅ Guest meal booking updated successfully', name: 'BulkFoodProvider');
        
        // Refresh the list
        await fetchGuestMeals(context);
        
        _setLoading(false);
        return true;
      } else {
        _logger.e('❌ [ERROR] Empty response from server');
        developer.log('❌ Empty response from server', name: 'BulkFoodProvider');
        
        _setError('Failed to update booking. Please try again.');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _logger.e('💥 [EXCEPTION] Error updating guest meal booking: $e');
      developer.log('💥 Error updating guest meal booking: $e', name: 'BulkFoodProvider', error: e);
      
      _setError('Failed to update booking: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// Deletes a guest meal booking
  /// Returns true if successful, false otherwise
  Future<bool> deleteGuestMeal(BuildContext context, String id) async {
    try {
      _logger.i('🗑️ [API] Deleting guest meal booking: $id');
      developer.log('🗑️ Deleting guest meal booking: $id', name: 'BulkFoodProvider');
      
      _setLoading(true);
      _clearError();

       final url = ApiUrls.deleteGuestMeal(id);
      _logger.d('🌐 [API] URL: $url');
      developer.log('🌐 API URL: $url', name: 'BulkFoodProvider');

      final response = await HttpServiceUtils.deleteData(url, context);
      
      if (response != null) {
        _logger.i('✅ [SUCCESS] Guest meal booking deleted successfully');
        developer.log('✅ Guest meal booking deleted successfully', name: 'BulkFoodProvider');
        
        // Remove from local list
        _guestMeals.removeWhere((meal) => meal.id == id);
        
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _logger.e('❌ [ERROR] Empty response from server');
        developer.log('❌ Empty response from server', name: 'BulkFoodProvider');
        
        _setError('Failed to delete booking. Please try again.');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _logger.e('💥 [EXCEPTION] Error deleting guest meal booking: $e');
      developer.log('💥 Error deleting guest meal booking: $e', name: 'BulkFoodProvider', error: e);
      
      _setError('Failed to delete booking: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// Resets the provider state
  void reset() {
    _logger.i('🔄 [RESET] Resetting bulk food provider state');
    developer.log('🔄 Resetting bulk food provider state', name: 'BulkFoodProvider');
    
    _isLoading = false;
    _errorMessage = '';
    _guestMeals = [];
    notifyListeners();
  }
}