import 'dart:developer';
import 'dart:io';

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
}
