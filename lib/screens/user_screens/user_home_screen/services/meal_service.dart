import 'dart:developer';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hira_plus/constants/api_urls.dart';
import 'package:hira_plus/screens/user_screens/user_home_screen/models/banner_model.dart';
import 'package:hira_plus/screens/user_screens/user_home_screen/models/meal_model.dart';
import 'package:hira_plus/utils/service_utils.dart';
import 'package:hira_plus/utils/shared_utils.dart';

class MealService {
  /// Fetches meals based on user role
  /// Returns a list of MealModel
  Future<List<MealModel>> getUserMeals(BuildContext context) async {
    try {
      log('🔍 Checking user role for meal fetch');
      final userType = await SharedUtils.getString('user_type');
      log('👤 User type: $userType');

      String url;
      if (userType == 'Manager') {
        url = '${ApiUrls.baseUrl}/admin/users/meals';
        log('🎯 Using manager');
      } else if (userType == 'Mess Staff') {
        url = '${ApiUrls.baseUrl}/mess-staff/meals';
        log('🎯 Using mess staff');
      } else {
        url = ApiUrls.getMealsForUser();
        log('🎯 Using regular user endpoint: $url');
      }

      log('🍽️ Fetching meals for $userType');
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

  /// Adds or updates a meal based on user role
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
      log('🔍 Checking user role for meal update');
      final userType = await SharedUtils.getString('user_type');
      log('👤 User type: $userType');

      String url;
      if (userType == 'Manager') {
        url = '${ApiUrls.baseUrl}/admin/meals/mark';
        log('🎯 Using manager endpoint for marking: $url');
      } else if (userType == 'Mess Staff') {
        url = '${ApiUrls.baseUrl}/mess-staff/meals/mark';
        log('🎯 Using mess staff endpoint for marking: $url');
      } else {
        url = ApiUrls.addMealForUser();
        log('🎯 Using regular user endpoint for marking: $url');
      }

      log('🍽️ Starting meal update process', name: 'MealService');
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
      final response =
          await HttpServiceUtils.postData(url, requestBody, context);
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

  /// Fetches the banner from the API
  Future<BannerModel?> fetchBanner() async {
    try {
      final url = ApiUrls.getBanner();
      log('Fetching banner from: $url');
      final response = await HttpServiceUtils.fetchData(url, true);
      if (response == null || response is! List || response.isEmpty) {
        log('No banner data received');
        return null;
      }

      // Convert all banners to BannerModel objects
      final banners =
          (response).map((json) => BannerModel.fromJson(json)).toList();

      // Sort banners by updatedAt date in descending order (most recent first)
      banners.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      // Get the most recent banner
      final latestBanner = banners.first;
      log('Latest banner fetched: ${latestBanner.title} (Updated: ${latestBanner.updatedAt})');
      return latestBanner;
    } catch (e) {
      log('Error fetching banner: $e');
      return null;
    }
  }
}
