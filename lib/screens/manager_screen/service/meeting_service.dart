import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hira_plus/constants/api_urls.dart';
import 'package:hira_plus/screens/manager_screen/models/meating_model.dart';
import 'package:hira_plus/utils/service_utils.dart';

class MeetingService {
  /// Fetches all meetings
  Future<List<MeetingModel>> getAllMeetings(BuildContext context) async {
    try {
      log('🏢 Fetching all meetings', name: 'MeetingService');
      final url = '${ApiUrls.baseUrl}/admin/meetings';
      log('API URL: $url', name: 'MeetingService');

      // Make API request
      final response = await HttpServiceUtils.fetchData(url, true);
      log('Response type: ${response.runtimeType}', name: 'MeetingService');
      debugPrint('Response: $response');

      // Check for empty response
      if (response == null) {
        log('❌ Error: Empty response from meetings API',
            name: 'MeetingService');
        return [];
      }

      // Parse response
      final Map<String, dynamic> responseData = response;
      final List<dynamic> meetingsList = responseData['meetings'] ?? [];
      log('Number of meetings received: ${meetingsList.length}',
          name: 'MeetingService');

      // Log the first meeting structure for debugging
      if (meetingsList.isNotEmpty) {
        log('📋 First meeting structure: ${meetingsList.first}',
            name: 'MeetingService');
        log('📋 First meeting keys: ${meetingsList.first.keys.toList()}',
            name: 'MeetingService');
      }

      // Convert each JSON object to MeetingModel
      final meetings = meetingsList
          .map((meetingJson) => MeetingModel.fromJson(meetingJson))
          .toList();
      log('✅ Meetings parsed successfully: ${meetings.length} meetings',
          name: 'MeetingService');

      // Sort meetings by date (most recent first)
      meetings.sort((a, b) => b.startDatetime.compareTo(a.startDatetime));

      return meetings;
    } on HttpException catch (e) {
      log('❌ HTTP Error fetching meetings: $e', name: 'MeetingService');
      rethrow;
    } catch (e) {
      log('❌ Error fetching meetings: $e', name: 'MeetingService');
      rethrow;
    }
  }

  /// Creates a new meeting
  Future<MeetingModel> createMeeting(
    BuildContext context, {
    required String title,
    required String description,
    required DateTime startDatetime,
    required DateTime endDatetime,
    required String hall,
    required int noOfPersons,
    required bool foodRequired,
    required int breakfast,
    required int morningSnacksCount,
    required int morningTeaCount,
    required int lunch,
    required int eveningSnacksCount,
    required int eveningTeaCount,
    required int dinner,
    required String department,
    required int rent,
  }) async {
    try {
      log('🏢 Creating new meeting', name: 'MeetingService');
      final url = '${ApiUrls.baseUrl}/admin/meetings';
      log('API URL: $url', name: 'MeetingService');

      // Prepare request body - ensure all values are properly formatted
      final requestBody = {
        'title': title.trim(),
        'description': description.trim(),
        'startDatetime': startDatetime.toIso8601String(),
        'endDatetime': endDatetime.toIso8601String(),
        'hall': hall.trim(),
        'department': department, // <-- ADDED BACK
        'noOfPersons': noOfPersons,
        'foodRequired': foodRequired,
        'breakfast': breakfast,
        'morningSnacksCount': morningSnacksCount,
        'morningTeaCount': morningTeaCount,
        'lunch': lunch,
        'eveningSnacksCount': eveningSnacksCount,
        'eveningTeaCount': eveningTeaCount,
        'dinner': dinner,
        'rent': rent,
      };

      log('Request body: $requestBody', name: 'MeetingService');
      print('📤 Sending request to: $url');
      print('📤 Request body: $requestBody');

      // Make API request
      log('Sending POST request to server...', name: 'MeetingService');
      final response =
          await HttpServiceUtils.postData(url, requestBody, context);
      log('Response received from server', name: 'MeetingService');
      print('📥 Response received: ${response.runtimeType}');

      if (response == null) {
        log('❌ Error: Empty response from meetings API',
            name: 'MeetingService');
        print('❌ Empty response from server');
        throw HttpException('Failed to create meeting: Empty response');
      }

      print('📥 Response data: $response');

      // Parse response
      log('Parsing response data', name: 'MeetingService');
      final responseData = response is String ? jsonDecode(response) : response;
      print('📥 Parsed response: $responseData');

      if (responseData['success'] != true) {
        final errorMsg = responseData['message'] ?? 'Failed to create meeting';
        print('❌ API Error: $errorMsg');
        print('❌ Full error response: $responseData');
        throw HttpException(errorMsg);
      }

      final meeting = MeetingModel.fromJson(responseData['meeting']);
      log('✅ Meeting created successfully: ${meeting.id}',
          name: 'MeetingService');

      return meeting;
    } on HttpException catch (e) {
      log('❌ HTTP Error creating meeting: $e', name: 'MeetingService');
      rethrow;
    } catch (e) {
      log('❌ Error creating meeting: $e', name: 'MeetingService');
      rethrow;
    }
  }

  /// Updates meeting status (approve/reject)
  Future<MeetingModel> updateMeetingStatus(
    BuildContext context,
    String meetingId,
    String status,
  ) async {
    try {
      log('🏢 Updating meeting status', name: 'MeetingService');
      final url = '${ApiUrls.baseUrl}/admin/meetings/$meetingId';
      log('API URL: $url', name: 'MeetingService');

      final requestBody = {'status': status};
      log('Request body: $requestBody', name: 'MeetingService');

      final response =
          await HttpServiceUtils.putData(url, requestBody, context);

      if (response == null) {
        log('❌ Error: Empty response from meetings API',
            name: 'MeetingService');
        throw HttpException('Failed to update meeting: Empty response');
      }

      final responseData = response is String ? jsonDecode(response) : response;

      if (responseData['success'] != true) {
        throw HttpException(
            responseData['message'] ?? 'Failed to update meeting');
      }

      final meeting = MeetingModel.fromJson(responseData['meeting']);
      log('✅ Meeting status updated successfully: ${meeting.id}',
          name: 'MeetingService');

      return meeting;
    } on HttpException catch (e) {
      log('❌ HTTP Error updating meeting: $e', name: 'MeetingService');
      rethrow;
    } catch (e) {
      log('❌ Error updating meeting: $e', name: 'MeetingService');
      rethrow;
    }
  }

  /// Deletes a meeting by ID
  Future<bool> deleteMeeting(BuildContext context, String meetingId) async {
    try {
      final url = ApiUrls.adminDeleteMeeting(meetingId);
      final response = await HttpServiceUtils.deleteData(url, context);
      if (response == null) {
        throw HttpException('Failed to delete meeting: Empty response');
      }
      final responseData = response is String ? jsonDecode(response) : response;
      if (responseData['success'] != true) {
        throw HttpException(
            responseData['message'] ?? 'Failed to delete meeting');
      }
      return true;
    } catch (e) {
      log('❌ Error deleting meeting: $e', name: 'MeetingService');
      rethrow;
    }
  }

  /// Updates an existing meeting (admin)
  Future<MeetingModel> updateMeeting(
    BuildContext context, {
    required String meetingId,
    required String title,
    required String description,
    required DateTime startDatetime,
    required DateTime endDatetime,
    required String hall,
    required int noOfPersons,
    required bool foodRequired,
    required int breakfast,
    required int morningSnacksCount,
    required int morningTeaCount,
    required int lunch,
    required int eveningSnacksCount,
    required int eveningTeaCount,
    required int dinner,
    required String department,
    required int rent,
  }) async {
    try {
      log('📝 Updating meeting', name: 'MeetingService');
      final url = ApiUrls.adminEditMeeting(meetingId);
      log('API URL: $url', name: 'MeetingService');

      final requestBody = {
        'title': title,
        'description': description,
        'startDatetime': startDatetime.toIso8601String(),
        'endDatetime': endDatetime.toIso8601String(),
        'hall': hall,
        'department': department, // <-- ADDED BACK
        'noOfPersons': noOfPersons,
        'foodRequired': foodRequired,
        'breakfast': breakfast,
        'morningSnacksCount': morningSnacksCount,
        'morningTeaCount': morningTeaCount,
        'lunch': lunch,
        'eveningSnacksCount': eveningSnacksCount,
        'eveningTeaCount': eveningTeaCount,
        'dinner': dinner,
        'rent': rent,
      };

      log('Request body: $requestBody', name: 'MeetingService');

      final response =
          await HttpServiceUtils.putData(url, requestBody, context);
      log('Response received from server', name: 'MeetingService');

      if (response == null) {
        log('❌ Error: Empty response from meetings API',
            name: 'MeetingService');
        throw HttpException('Failed to update meeting: Empty response');
      }

      final responseData = response is String ? jsonDecode(response) : response;
      if (responseData['success'] != true) {
        throw HttpException(
            responseData['message'] ?? 'Failed to update meeting');
      }

      final meeting = MeetingModel.fromJson(responseData['meeting']);
      log('✅ Meeting updated successfully: ${meeting.id}',
          name: 'MeetingService');
      return meeting;
    } on HttpException catch (e) {
      log('❌ HTTP Error updating meeting: $e', name: 'MeetingService');
      rethrow;
    } catch (e) {
      log('❌ Error updating meeting: $e', name: 'MeetingService');
      rethrow;
    }
  }
}
