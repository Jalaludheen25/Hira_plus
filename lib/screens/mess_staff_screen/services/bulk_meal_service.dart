import 'dart:developer';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hira_plus/constants/api_urls.dart';
import 'package:hira_plus/screens/mess_staff_screen/models/bulk_meal_model.dart';
import 'package:hira_plus/utils/service_utils.dart';

class BulkMealService {
  /// Fetches guest meals for mess staff
  /// Returns a list of GuestMealModel
  Future<List<BulkMealModel>> getGuestMeals(BuildContext context) async {
    try {
      log('🍽️ Fetching guest meals for mess staff');
      final url = ApiUrls.getBulkMealsForMessStaff();
      log('API URL: $url');

      // Make API request
      final response = await HttpServiceUtils.fetchData(url, true);
      log('Response type: ${response.runtimeType}');

      // Check for empty response
      if (response == null) {
        log('❌ Error: Empty response from guest meals API');
        return [];
      }

      // Parse response
      Map<String, dynamic> responseData;
      if (response is String) {
        responseData = jsonDecode(response);
      } else {
        responseData = response as Map<String, dynamic>;
      }

      // Check if the response has the expected structure
      if (!responseData.containsKey('success') || !responseData.containsKey('guestMeals')) {
        log('❌ Error: Invalid response structure');
        return [];
      }

      // Check if the request was successful
      if (responseData['success'] != true) {
        log('❌ Error: API request was not successful');
        return [];
      }

      // Parse guest meals list
      final List<dynamic> guestMealsList = responseData['guestMeals'] as List<dynamic>;
      log('Number of guest meals received: ${guestMealsList.length}');

      // Convert each JSON object to GuestMealModel
      final guestMeals = guestMealsList
          .map((guestMealJson) => BulkMealModel.fromJson(guestMealJson))
          .toList();
      log('✅ Guest meals parsed successfully: ${guestMeals.length} meals');

      // Sort guest meals by date (most recent first)
      guestMeals.sort((a, b) => b.date.compareTo(a.date));

      return guestMeals;
    } on HttpException catch (e) {
      // Handle HTTP exceptions specifically
      log('❌ HTTP Error fetching guest meals: $e');
      rethrow;
    } catch (e) {
      // Handle all other exceptions
      log('❌ Error fetching guest meals: $e');
      rethrow;
    }
  }
}