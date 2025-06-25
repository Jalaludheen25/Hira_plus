import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hira_plus/constants/api_urls.dart';
import 'package:hira_plus/screens/user_screens/user_home_screen/models/contact_model.dart';
import 'package:hira_plus/screens/user_screens/user_home_screen/models/today_checkin_model.dart';
import 'package:hira_plus/utils/service_utils.dart';

class ContactService {
  /// Fetches all contacts from the auth/users endpoint
  /// Returns a ContactsResponse containing the list of users
  Future<ContactsResponse> getContacts(BuildContext context) async {
    try {
      log('🔗 Fetching contacts from auth/users', name: 'ContactService');
      final url = ApiUrls.getContacts();
      log('API URL: $url', name: 'ContactService');

      // Make API request using HttpServiceUtils
      final response = await HttpServiceUtils.fetchData(url, true);
      log('Response type: ${response.runtimeType}', name: 'ContactService');

      // Check for empty response
      if (response == null) {
        log('❌ Error: Empty response from contacts API', name: 'ContactService');
        return ContactsResponse(success: false, users: []);
      }

      // Parse response into ContactsResponse
      final contactsResponse = ContactsResponse.fromJson(response);
      log('✅ Contacts parsed successfully: ${contactsResponse.users.length} contacts', 
          name: 'ContactService');

      return contactsResponse;
    } on HttpException catch (e) {
      // Handle HTTP exceptions specifically
      log('❌ HTTP Error fetching contacts: $e', name: 'ContactService');
      // We'll pass the error to the provider to handle UI feedback
      rethrow;
    } catch (e) {
      // Handle all other exceptions
      log('❌ Error fetching contacts: $e', name: 'ContactService');
      rethrow;
    }
  }

  /// Fetches today's check-ins from the API
  Future<TodayCheckInModel?> getTodayCheckIns(BuildContext context) async {
    try {
      log('🔗 Fetching today\'s check-ins', name: 'ContactService');
      final url = ApiUrls.getTodayCheckIns();
      log('API URL: $url', name: 'ContactService');

      final response = await HttpServiceUtils.fetchData(url, true);
      log('Response type: \\${response.runtimeType}', name: 'ContactService');

      if (response == null) {
        log('❌ Error: Empty response from today\'s check-ins API', name: 'ContactService');
        return null;
      }

      final checkInModel = TodayCheckInModel.fromJson(response);
      log('✅ Today\'s check-ins parsed successfully: totalCheckedIn = \\${checkInModel.totalCheckedIn}', name: 'ContactService');
      return checkInModel;
    } on HttpException catch (e) {
      log('❌ HTTP Error fetching today\'s check-ins: $e', name: 'ContactService');
      rethrow;
    } catch (e) {
      log('❌ Error fetching today\'s check-ins: $e', name: 'ContactService');
      rethrow;
    }
  }
}