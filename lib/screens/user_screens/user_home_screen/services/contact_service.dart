import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hira_plus/constants/api_urls.dart';
import 'package:hira_plus/screens/user_screens/user_home_screen/models/contact_model.dart';
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
}