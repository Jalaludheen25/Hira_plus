import 'package:flutter/material.dart';
import 'package:hira_plus/constants/api_urls.dart';
import 'package:hira_plus/screens/manager_screen/models/food/manager_guest_meal_model.dart';
import 'package:hira_plus/utils/service_utils.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;
import 'dart:io';

class ManagerBulkFoodProvider extends ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  List<ManagerGuestMealModel> _guestMeals = [];
  List<ManagerGuestMealModel> get guestMeals => _guestMeals;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  /// Parse and handle API error messages
  String _parseErrorMessage(dynamic response, int statusCode) {
    try {
      if (response is Map<String, dynamic>) {
        final message = response['message'] as String?;

        if (message != null) {
          // Handle MongoDB duplicate key error
          if (message.contains('E11000 duplicate key error') &&
              message.contains('date_1_department_1')) {
            return 'A booking already exists for this date and department. Please choose a different date or update the existing booking.';
          }

          // Handle other validation errors
          if (message.contains('validation')) {
            return message;
          }

          // Return the original message for other errors
          return message;
        }
      }

      // Default error messages based on status code
      switch (statusCode) {
        case 400:
          return 'Invalid request. Please check your input and try again.';
        case 401:
          return 'Authentication failed. Please login again.';
        case 403:
          return 'You do not have permission to perform this action.';
        case 404:
          return 'The requested resource was not found.';
        case 409:
          return 'A booking already exists for this date and department.';
        case 500:
          return 'Server error. Please try again later.';
        default:
          return 'An unexpected error occurred. Please try again.';
      }
    } catch (e) {
      developer.log('❌ Error parsing error message: $e',
          name: 'ManagerBulkFoodProvider');
      return 'An error occurred. Please try again.';
    }
  }

  /// Fetch all guest meal bookings (admin)
  /// GET /api/admin/guest-meals
  Future<void> fetchGuestMeals(BuildContext context) async {
    try {
      _setLoading(true);
      _clearError();

      developer.log('🔍 Fetching guest meals from API',
          name: 'ManagerBulkFoodProvider');
      final url = ApiUrls.adminGuestMeals();
      developer.log('📡 API URL: $url', name: 'ManagerBulkFoodProvider');

      final response = await HttpServiceUtils.fetchData(url, true);
      developer.log('📥 Raw response: $response',
          name: 'ManagerBulkFoodProvider');

      if (response != null) {
        if (response is Map<String, dynamic>) {
          // Check if response has success field
          if (response.containsKey('success') && response['success'] == true) {
            // Handle successful response
            if (response.containsKey('guestMeals') &&
                response['guestMeals'] is List) {
              // Multiple guest meals
              final List<dynamic> mealsData = response['guestMeals'];
              _guestMeals = mealsData
                  .map((mealJson) {
                    try {
                      return ManagerGuestMealModel.fromJson(
                          mealJson as Map<String, dynamic>);
                    } catch (e) {
                      developer.log('❌ Error parsing meal: $e, Data: $mealJson',
                          name: 'ManagerBulkFoodProvider');
                      return null;
                    }
                  })
                  .where((meal) => meal != null)
                  .cast<ManagerGuestMealModel>()
                  .toList();
            } else if (response.containsKey('guestMeal')) {
              // Single guest meal
              try {
                final singleMeal = ManagerGuestMealModel.fromJson(
                    response['guestMeal'] as Map<String, dynamic>);
                _guestMeals = [singleMeal];
              } catch (e) {
                developer.log('❌ Error parsing single meal: $e',
                    name: 'ManagerBulkFoodProvider');
                _guestMeals = [];
              }
            } else {
              // No guest meals found
              _guestMeals = [];
            }
          } else {
            // Handle error response
            final errorMessage =
                response['message'] ?? 'Failed to fetch guest meals';
            throw Exception(errorMessage);
          }
        } else if (response is List<dynamic>) {
          // Direct list response (fallback)
          _guestMeals = response
              .map((mealJson) {
                try {
                  return ManagerGuestMealModel.fromJson(
                      mealJson as Map<String, dynamic>);
                } catch (e) {
                  developer.log('❌ Error parsing meal: $e, Data: $mealJson',
                      name: 'ManagerBulkFoodProvider');
                  return null;
                }
              })
              .where((meal) => meal != null)
              .cast<ManagerGuestMealModel>()
              .toList();
        } else {
          throw Exception(
              'Unexpected response format: ${response.runtimeType}');
        }

        // Sort by date (most recent first)
        _guestMeals.sort((a, b) => b.date.compareTo(a.date));

        developer.log('✅ Successfully parsed ${_guestMeals.length} guest meals',
            name: 'ManagerBulkFoodProvider');
        _setLoading(false);
      } else {
        developer.log('📭 No response data received',
            name: 'ManagerBulkFoodProvider');
        _guestMeals = [];
        _setError('No bookings found.');
        _setLoading(false);
      }
    } catch (e, stackTrace) {
      developer.log('❌ Error in fetchGuestMeals: $e',
          name: 'ManagerBulkFoodProvider');
      developer.log('Stack trace: $stackTrace',
          name: 'ManagerBulkFoodProvider');
      _setError('Failed to load bookings: ${e.toString()}');
      _setLoading(false);
    }
  }

  /// Check if a booking already exists for the given date and department
  bool hasExistingBooking(DateTime date, String department) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    return _guestMeals.any((meal) {
      final mealDateFormatted = DateFormat('yyyy-MM-dd').format(meal.date);
      return mealDateFormatted == formattedDate &&
          meal.department.toLowerCase() == department.toLowerCase();
    });
  }

  /// Get existing booking for the given date and department
  ManagerGuestMealModel? getExistingBooking(DateTime date, String department) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    try {
      return _guestMeals.firstWhere((meal) {
        final mealDateFormatted = DateFormat('yyyy-MM-dd').format(meal.date);
        return mealDateFormatted == formattedDate &&
            meal.department.toLowerCase() == department.toLowerCase();
      });
    } catch (e) {
      return null;
    }
  }

  /// Create a new guest meal booking (admin)
  /// POST /api/admin/guest-meals
  Future<bool> submitBulkFoodBooking({
    required BuildContext context,
    required DateTime date,
    required int breakfastCount,
    required int lunchCount,
    required int dinnerCount,
    required String department,
    required String addedBy,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final formattedDate = DateFormat('yyyy-MM-dd').format(date);

      // Check for existing booking locally first
      if (hasExistingBooking(date, department)) {
        getExistingBooking(date, department);
        developer.log('⚠️ Local duplicate booking detected',
            name: 'ManagerBulkFoodProvider');

        _setError(
            'A booking already exists for $department on ${DateFormat('MMM d, yyyy').format(date)}. Please update the existing booking or choose a different date.');
        _setLoading(false);
        return false;
      }

      final requestBody = {
        'date': formattedDate,
        'breakfastCount': breakfastCount,
        'lunchCount': lunchCount,
        'dinnerCount': dinnerCount,
        'department': department,
        'addedBy': addedBy,
      };

      developer.log('🚀 Submitting bulk food booking',
          name: 'ManagerBulkFoodProvider');
      developer.log('📤 Request body: $requestBody',
          name: 'ManagerBulkFoodProvider');

      final url = ApiUrls.adminGuestMeals();
      developer.log('📡 POST URL: $url', name: 'ManagerBulkFoodProvider');

      final response =
          await HttpServiceUtils.postData(url, requestBody, context);
      developer.log('📥 Submit response: $response',
          name: 'ManagerBulkFoodProvider');

      if (response != null && response is Map<String, dynamic>) {
        // Check if response indicates success
        if (response.containsKey('success') && response['success'] == true) {
          developer.log('✅ Booking submitted successfully',
              name: 'ManagerBulkFoodProvider');

          // Add the new guest meal to the local list if provided
          if (response.containsKey('guestMeal')) {
            try {
              final newMeal = ManagerGuestMealModel.fromJson(
                  response['guestMeal'] as Map<String, dynamic>);
              _guestMeals.insert(0, newMeal); // Add to beginning of list
              _guestMeals.sort((a, b) => b.date.compareTo(a.date)); // Re-sort
              notifyListeners();
            } catch (e) {
              developer.log('⚠️ Error parsing new meal, will refresh list: $e',
                  name: 'ManagerBulkFoodProvider');
              // Refresh the list if parsing fails
              await fetchGuestMeals(context);
            }
          } else {
            // Refresh the list if no guest meal data provided
            await fetchGuestMeals(context);
          }

          _setLoading(false);
          return true;
        } else {
          // Handle API error response
          final errorMessage = _parseErrorMessage(response, 400);
          developer.log('❌ API error: $errorMessage',
              name: 'ManagerBulkFoodProvider');
          _setError(errorMessage);
          _setLoading(false);
          return false;
        }
      } else {
        developer.log('❌ Submit response was null or invalid format',
            name: 'ManagerBulkFoodProvider');
        _setError('Failed to submit booking. Please try again.');
        _setLoading(false);
        return false;
      }
    } on HttpException catch (e, stackTrace) {
      developer.log('❌ HTTP Exception in submitBulkFoodBooking: $e',
          name: 'ManagerBulkFoodProvider');
      developer.log('Stack trace: $stackTrace',
          name: 'ManagerBulkFoodProvider');

      // Try to extract the actual error message from HttpException
      String errorMessage = e.message;

      // If the exception message contains the server response, parse it
      if (errorMessage.contains('E11000 duplicate key error')) {
        errorMessage =
            'A booking already exists for this date and department. Please choose a different date or update the existing booking.';
      } else if (errorMessage.contains('Server error')) {
        // Try to get more specific error from the server if available
        errorMessage =
            'Server error occurred. Please try again or contact support if the problem persists.';
      }

      _setError(errorMessage);
      _setLoading(false);
      return false;
    } catch (e, stackTrace) {
      developer.log('❌ General error in submitBulkFoodBooking: $e',
          name: 'ManagerBulkFoodProvider');
      developer.log('Stack trace: $stackTrace',
          name: 'ManagerBulkFoodProvider');
      _setError('Failed to submit booking: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// Update an existing guest meal booking (admin)
  /// PUT /api/admin/guest-meals/:id
  Future<bool> updateGuestMealBooking({
    required BuildContext context,
    required String id,
    required DateTime date,
    required int breakfastCount,
    required int lunchCount,
    required int dinnerCount,
    required String department,
    required String addedBy,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      final requestBody = {
        'date': formattedDate,
        'breakfastCount': breakfastCount,
        'lunchCount': lunchCount,
        'dinnerCount': dinnerCount,
        'department': department,
        'addedBy': addedBy,
      };

      developer.log('🔄 Updating bulk food booking',
          name: 'ManagerBulkFoodProvider');
      developer.log('📤 Update request body: $requestBody',
          name: 'ManagerBulkFoodProvider');

      final url = ApiUrls.adminEditGuestMeals(id);
      developer.log('📡 PUT URL: $url', name: 'ManagerBulkFoodProvider');

      final response =
          await HttpServiceUtils.putData(url, requestBody, context);
      developer.log('📥 Update response: $response',
          name: 'ManagerBulkFoodProvider');

      if (response != null && response is Map<String, dynamic>) {
        // Check if response indicates success
        if (response.containsKey('success') && response['success'] == true) {
          developer.log('✅ Booking updated successfully',
              name: 'ManagerBulkFoodProvider');

          // Update the local list
          if (response.containsKey('guestMeal')) {
            try {
              final updatedMeal = ManagerGuestMealModel.fromJson(
                  response['guestMeal'] as Map<String, dynamic>);
              final index = _guestMeals.indexWhere((meal) => meal.id == id);
              if (index != -1) {
                _guestMeals[index] = updatedMeal;
                _guestMeals.sort((a, b) => b.date.compareTo(a.date)); // Re-sort
                notifyListeners();
              }
            } catch (e) {
              developer.log(
                  '⚠️ Error parsing updated meal, will refresh list: $e',
                  name: 'ManagerBulkFoodProvider');
              await fetchGuestMeals(context);
            }
          } else {
            await fetchGuestMeals(context);
          }

          _setLoading(false);
          return true;
        } else {
          final errorMessage = _parseErrorMessage(response, 400);
          developer.log('❌ API error: $errorMessage',
              name: 'ManagerBulkFoodProvider');
          _setError(errorMessage);
          _setLoading(false);
          return false;
        }
      } else {
        developer.log('❌ Update response was null or invalid format',
            name: 'ManagerBulkFoodProvider');
        _setError('Failed to update booking. Please try again.');
        _setLoading(false);
        return false;
      }
    } on HttpException catch (e, stackTrace) {
      developer.log('❌ HTTP Exception in updateGuestMealBooking: $e',
          name: 'ManagerBulkFoodProvider');
      developer.log('Stack trace: $stackTrace',
          name: 'ManagerBulkFoodProvider');

      String errorMessage = e.message;
      if (errorMessage.contains('E11000 duplicate key error')) {
        errorMessage =
            'A booking already exists for this date and department combination.';
      }

      _setError(errorMessage);
      _setLoading(false);
      return false;
    } catch (e, stackTrace) {
      developer.log('❌ Error in updateGuestMealBooking: $e',
          name: 'ManagerBulkFoodProvider');
      developer.log('Stack trace: $stackTrace',
          name: 'ManagerBulkFoodProvider');
      _setError('Failed to update booking: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// Delete a guest meal booking (admin)
  /// DELETE /api/admin/guest-meals/:id
  Future<bool> deleteGuestMeal(BuildContext context, String id) async {
    try {
      _setLoading(true);
      _clearError();

      developer.log('🗑️ Deleting guest meal booking: $id',
          name: 'ManagerBulkFoodProvider');

      final url = ApiUrls.adminEditGuestMeals(id);
      developer.log('📡 DELETE URL: $url', name: 'ManagerBulkFoodProvider');

      final response = await HttpServiceUtils.deleteData(url, context);
      developer.log('📥 Delete response: $response',
          name: 'ManagerBulkFoodProvider');

      if (response != null) {
        // Check response format
        if (response is Map<String, dynamic>) {
          if (response.containsKey('success') && response['success'] == true) {
            developer.log('✅ Booking deleted successfully',
                name: 'ManagerBulkFoodProvider');
            _guestMeals.removeWhere((meal) => meal.id == id);
            _setLoading(false);
            notifyListeners();
            return true;
          } else {
            final errorMessage = _parseErrorMessage(response, 400);
            developer.log('❌ API error: $errorMessage',
                name: 'ManagerBulkFoodProvider');
            _setError(errorMessage);
            _setLoading(false);
            return false;
          }
        } else {
          // Assume success if response exists but is not a map (some APIs return simple success responses)
          developer.log('✅ Booking deleted successfully (simple response)',
              name: 'ManagerBulkFoodProvider');
          _guestMeals.removeWhere((meal) => meal.id == id);
          _setLoading(false);
          notifyListeners();
          return true;
        }
      } else {
        developer.log('❌ Delete response was null',
            name: 'ManagerBulkFoodProvider');
        _setError('Failed to delete booking. Please try again.');
        _setLoading(false);
        return false;
      }
    } on HttpException catch (e, stackTrace) {
      developer.log('❌ HTTP Exception in deleteGuestMeal: $e',
          name: 'ManagerBulkFoodProvider');
      developer.log('Stack trace: $stackTrace',
          name: 'ManagerBulkFoodProvider');
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e, stackTrace) {
      developer.log('❌ Error in deleteGuestMeal: $e',
          name: 'ManagerBulkFoodProvider');
      developer.log('Stack trace: $stackTrace',
          name: 'ManagerBulkFoodProvider');
      _setError('Failed to delete booking: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  void reset() {
    _isLoading = false;
    _errorMessage = '';
    _guestMeals = [];
    notifyListeners();
  }
}
