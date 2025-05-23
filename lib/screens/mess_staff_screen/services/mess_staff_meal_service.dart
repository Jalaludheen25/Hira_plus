import 'dart:developer';
import 'dart:io';
import 'dart:convert';

import 'package:hira_plus/constants/api_urls.dart';
import 'package:hira_plus/screens/mess_staff_screen/models/mess_staff_screen_model.dart';
import 'package:hira_plus/utils/service_utils.dart';

class MessStaffMealService {
  /// Fetches meals for mess staff
  /// Returns MessStaffScreenModel
  Future<MessStaffScreenModel> getMessStaffMeals() async {
    try {
      log('🍽️ Fetching meals for mess staff', name: 'MessStaffMealService');

      final url = ApiUrls.getMessStaffMeals();
      log('API URL: $url', name: 'MessStaffMealService');

      // Make API request
      final response = await HttpServiceUtils.fetchData(url, true);
      log('Response type: ${response.runtimeType}',
          name: 'MessStaffMealService');

      // Check for empty response
      if (response == null) {
        log('❌ Error: Empty response from meals API',
            name: 'MessStaffMealService');
        throw Exception('Empty response from server');
      }

      // Log the response data for debugging
      log('📊 Response data: ${jsonEncode(response)}',
          name: 'MessStaffMealService');

      // Parse response into model
      log('Parsing response data', name: 'MessStaffMealService');
      final meals = MessStaffScreenModel.fromJson(response);

      // Log the parsed model
      log('✅ Meals parsed successfully', name: 'MessStaffMealService');
      log('Total meals counts: ${meals.totalCounts?.toJson()}',
          name: 'MessStaffMealService');

      // Log daily counts
      if (meals.dailyCounts != null) {
        final dailyCountsMap = meals.dailyCounts!;
        log('Daily counts available for dates: ${dailyCountsMap.keys.join(", ")}',
            name: 'MessStaffMealService');
      }

      // Log meals details
      if (meals.meals != null) {
        final mealsMap = meals.meals!;
        log('Meal details available for dates: ${mealsMap.keys.join(", ")}',
            name: 'MessStaffMealService');

        // Log counts for today
        final today = DateTime.now();
        final dateStr =
            "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
        if (mealsMap.containsKey(dateStr)) {
          final dayMeals = mealsMap[dateStr]!;
          log('Today\'s breakfast count: \\${dayMeals.breakfast?.length ?? 0}',
              name: 'MessStaffMealService');
          log('Today\'s lunch count: \\${dayMeals.lunch?.length ?? 0}',
              name: 'MessStaffMealService');
          log('Today\'s dinner count: \\${dayMeals.dinner?.length ?? 0}',
              name: 'MessStaffMealService');
        }
      }

      return meals;
    } on HttpException catch (e) {
      // Handle HTTP exceptions specifically
      log('❌ HTTP Error fetching mess staff meals: $e',
          name: 'MessStaffMealService');
      rethrow;
    } catch (e) {
      // Handle all other exceptions
      log('❌ Error fetching mess staff meals: $e',
          name: 'MessStaffMealService');
      rethrow;
    }
  }
}
