import 'dart:developer';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hira_plus/constants/api_urls.dart';
import 'package:hira_plus/screens/user_screens/user_home_screen/models/meal_model.dart';
import 'package:hira_plus/utils/service_utils.dart';

class MealService {
  /// Fetches meals for the current user
  /// Returns a list of MealModel
  Future<List<MealModel>> getUserMeals(BuildContext context) async {
    try {
      log('🍽️ Fetching meals for user');
      final url = ApiUrls.getMealsForUser();
      log('API URL: $url');

      // Make API request
      final response = await HttpServiceUtils.fetchData(url, true);
      log('Response type: ${response.runtimeType}');

      // Check for empty response
      if (response == null) {
        log('❌ Error: Empty response from meals API');
        return [];
      }

      // Parse response into list
      final List<dynamic> mealsList = response;
      log('Number of meals received: ${mealsList.length}');

      // Convert each JSON object to MealModel
      final meals =
          mealsList.map((mealJson) => MealModel.fromJson(mealJson)).toList();
      log('✅ Meals parsed successfully: ${meals.length} meals');

      // Sort meals by date (most recent first)
      meals.sort((a, b) => a.date.compareTo(b.date));

      return meals;
    } on HttpException catch (e) {
      // Handle HTTP exceptions specifically
      log('❌ HTTP Error fetching meals: $e');
      // We'll pass the error to the provider to handle UI feedback
      rethrow;
    } catch (e) {
      // Handle all other exceptions
      log('❌ Error fetching meals: $e');
      rethrow;
    }
  }

  /// Adds or updates a meal for the current user
  /// Returns the updated MealModel
  ///
  /// Example usage:
  /// ```dart
  /// final mealService = MealService();
  /// try {
  ///   final updatedMeal = await mealService.addMealForUser(
  ///     context,
  ///     date: DateTime(2025, 4, 26),
  ///     breakfast: false,
  ///     lunch: true,
  ///     dinner: false,
  ///   );
  ///   print('Meal updated with ID: ${updatedMeal.id}');
  /// } catch (e) {
  ///   print('Error updating meal: $e');
  /// }
  /// ```
  Future<MealModel> addMealForUser(
  BuildContext context, {
  required DateTime date,
  required bool breakfast,
  required bool lunch,
  required bool dinner,
}) async {
  try {
    log('🍽️ Starting meal update process', name: 'MealService');
    final url = ApiUrls.addMealForUser();
    log('API URL: $url', name: 'MealService');

    // Prepare request body
    final requestBody = {
      'date': date.toIso8601String().split('T')[0], // Format as YYYY-MM-DD
      'breakfast': breakfast,
      'lunch': lunch,
      'dinner': dinner,
    };

    log('Request body: $requestBody', name: 'MealService');

    // Make API request
    log('Sending POST request to server...', name: 'MealService');
    final response = await HttpServiceUtils.postData(url, requestBody, context);
    log('Response received from server', name: 'MealService');
    
    if (response == null) {
      log('❌ Error: Empty response from meals API', name: 'MealService');
      throw HttpException('Failed to add meal: Empty response');
    }

    // Parse response into MealModel
    log('Parsing response data', name: 'MealService');
    final mealData = response is String ? jsonDecode(response) : response;
    final meal = MealModel.fromJson(mealData);
    log('✅ Meal added/updated successfully: ${meal.id}', name: 'MealService');
    log('Response meal data: ${meal.toJson()}', name: 'MealService');

    return meal;
  } on HttpException catch (e) {
    // Handle HTTP exceptions specifically
    log('❌ HTTP Error adding meal: $e', name: 'MealService');
    rethrow;
  } catch (e) {
    // Handle all other exceptions
    log('❌ Error adding meal: $e', name: 'MealService');
    rethrow;
  }
}
}