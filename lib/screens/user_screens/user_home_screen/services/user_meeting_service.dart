import 'dart:developer';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hira_plus/constants/api_urls.dart';
import 'package:hira_plus/screens/user_screens/user_home_screen/models/user_meeting_model.dart';
import 'package:hira_plus/utils/service_utils.dart';
import 'package:hira_plus/utils/shared_utils.dart';

class MeetingService {
  /// Fetches all meetings for the current user
  /// Returns a list of MeetingModel
  Future<List<MeetingModel>> getUserMeetings(BuildContext context) async {
    try {
      log('📅 Fetching meetings for user');
      
      // First, let's check if we have a valid auth token
      final authToken = await SharedUtils.getString('auth_token');
      log('🔑 Auth token available: ${authToken.isNotEmpty ? "Yes (${authToken.length} chars)" : "No"}');
      
      if (authToken.isEmpty) {
        log('❌ No auth token found - user needs to login');
        throw HttpException('Authentication required. Please login again.');
      }
      
      final url = ApiUrls.getUserMeetings();
      log('🌐 API URL: $url');
      log('🔍 Making authenticated request...');

      // Make API request with authentication
      final response = await HttpServiceUtils.fetchData(url, true);
      log('📡 Response received, type: ${response.runtimeType}');

      // Check for empty response
      if (response == null) {
        log('❌ Error: Empty response from meetings API');
        return [];
      }

      // Log the raw response for debugging
      log('📄 Raw response: ${response.toString().substring(0, response.toString().length > 500 ? 500 : response.toString().length)}...');

      // Parse response - expecting format: {"success": true, "meetings": [...]}
      Map<String, dynamic> responseData;
      if (response is String) {
        responseData = jsonDecode(response);
      } else {
        responseData = response;
      }

      log('✅ Response parsed successfully');
      log('🔍 Response keys: ${responseData.keys.toList()}');

      // Check if response has success field and meetings array
      if (responseData['success'] != true) {
        log('❌ Error: API returned success: false');
        log('📄 Full response: $responseData');
        throw HttpException('Failed to fetch meetings: API returned error');
      }

      final List<dynamic> meetingsList = responseData['meetings'] ?? [];
      log('📊 Number of meetings received: ${meetingsList.length}');

      if (meetingsList.isNotEmpty) {
        log('📝 Sample meeting keys: ${meetingsList.first.keys.toList()}');
      }

      // Convert each JSON object to MeetingModel
      final meetings = meetingsList
          .map((meetingJson) {
            try {
              return MeetingModel.fromJson(meetingJson);
            } catch (e) {
              log('❌ Error parsing meeting: $e');
              log('📄 Problematic meeting data: $meetingJson');
              rethrow;
            }
          })
          .toList();
      
      log('✅ Meetings parsed successfully: ${meetings.length} meetings');

      // Sort meetings by start date (most recent first)
      meetings.sort((a, b) => b.startDatetime.compareTo(a.startDatetime));

      return meetings;
    } on HttpException catch (e) {
      // Handle HTTP exceptions specifically
      log('❌ HTTP Error fetching meetings: $e');
      
      // Check if it's an auth error
      if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        log('🔑 Authentication error detected - token may be expired');
        // You might want to trigger a re-login here
      }
      
      // We'll pass the error to the provider to handle UI feedback
      rethrow;
    } catch (e) {
      // Handle all other exceptions
      log('❌ Unexpected error fetching meetings: $e');
      log('📍 Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  /// Deletes a meeting by ID (DeptHead only)
  /// Returns true if successful, throws exception if failed
  Future<bool> deleteMeeting(BuildContext context, String meetingId) async {
    try {
      log('🗑️ Starting delete process for meeting: $meetingId', name: 'MeetingService');
      
      final authToken = await SharedUtils.getString('auth_token');
      if (authToken.isEmpty) {
        log('❌ No auth token found', name: 'MeetingService');
        throw HttpException('Authentication required. Please login again.');
      }
      
      final url = ApiUrls.deleteMeeting(meetingId); // DELETE auth/dept-meetings/{meetingId}
      log('🌐 DELETE URL: $url', name: 'MeetingService');
      
      // Make DELETE request
      final response = await HttpServiceUtils.deleteData(url, context);
      log('📡 Delete response received', name: 'MeetingService');
      
      if (response == null) {
        log('❌ Empty response from delete API', name: 'MeetingService');
        throw HttpException('Empty response from server');
      }
      
      // Parse response
      Map<String, dynamic> responseData;
      if (response is String) {
        responseData = jsonDecode(response);
      } else {
        responseData = response;
      }
      
      log('📄 Delete response data: $responseData', name: 'MeetingService');
      
      if (responseData['success'] == true) {
        log('✅ Meeting deleted successfully', name: 'MeetingService');
        return true;
      } else {
        final errorMessage = responseData['message'] ?? 'Failed to delete meeting';
        log('❌ Delete failed: $errorMessage', name: 'MeetingService');
        throw HttpException(errorMessage);
      }
    } on HttpException catch (e) {
      log('❌ HTTP error deleting meeting: $e', name: 'MeetingService');
      rethrow;
    } catch (e) {
      log('❌ Unexpected error deleting meeting: $e', name: 'MeetingService');
      rethrow;
    }
  }

  /// Updates a meeting by ID (DeptHead only)
  /// Returns updated MeetingModel if successful, throws exception if failed
  Future<MeetingModel?> updateMeeting(BuildContext context, String meetingId, Map<String, dynamic> meetingData) async {
    try {
      log('📝 Starting update process for meeting: $meetingId', name: 'MeetingService');
      log('📦 Update data: $meetingData', name: 'MeetingService');
      
      final authToken = await SharedUtils.getString('auth_token');
      if (authToken.isEmpty) {
        log('❌ No auth token found', name: 'MeetingService');
        throw HttpException('Authentication required. Please login again.');
      }
      
      final url = ApiUrls.editMeeting(meetingId); // PUT auth/dept-meetings/{meetingId}
      log('🌐 PUT URL: $url', name: 'MeetingService');
      
      // Make PUT request
      final response = await HttpServiceUtils.putData(url, meetingData, context);
      log('📡 Update response received', name: 'MeetingService');
      
      if (response == null) {
        log('❌ Empty response from update API', name: 'MeetingService');
        throw HttpException('Empty response from server');
      }
      
      // Parse response
      Map<String, dynamic> responseData;
      if (response is String) {
        responseData = jsonDecode(response);
      } else {
        responseData = response;
      }
      
      log('📄 Update response data keys: ${responseData.keys.toList()}', name: 'MeetingService');
      
      if (responseData['success'] == true) {
        // Try to find the updated meeting data in different possible response formats
        Map<String, dynamic>? updatedMeetingData;
        
        if (responseData['meeting'] != null) {
          updatedMeetingData = responseData['meeting'];
        } else if (responseData['data'] != null) {
          updatedMeetingData = responseData['data'];
        } else if (responseData.containsKey('_id')) {
          // Sometimes the meeting data is directly in the response
          updatedMeetingData = responseData;
        }
        
        if (updatedMeetingData != null) {
          log('✅ Meeting updated successfully', name: 'MeetingService');
          log('📝 Updated meeting data: $updatedMeetingData', name: 'MeetingService');
          return MeetingModel.fromJson(updatedMeetingData);
        } else {
          log('⚠️ Update successful but no meeting data returned', name: 'MeetingService');
          return null;
        }
      } else {
        final errorMessage = responseData['message'] ?? 'Failed to update meeting';
        log('❌ Update failed: $errorMessage', name: 'MeetingService');
        throw HttpException(errorMessage);
      }
    } on HttpException catch (e) {
      log('❌ HTTP error updating meeting: $e', name: 'MeetingService');
      rethrow;
    } catch (e) {
      log('❌ Unexpected error updating meeting: $e', name: 'MeetingService');
      log('📍 Error type: ${e.runtimeType}', name: 'MeetingService');
      rethrow;
    }
  }

  /// Helper method to verify auth token validity
  Future<bool> _verifyAuthToken() async {
    try {
      final token = await SharedUtils.getString('auth_token');
      if (token.isEmpty) {
        return false;
      }
      
      // You could add a simple API call here to verify the token
      // For now, just check if it exists and looks valid
      return token.length > 10; // Basic check
    } catch (e) {
      log('❌ Error verifying auth token: $e');
      return false;
    }
  }

  /// Fetches meetings for a specific date range
  /// Returns a list of MeetingModel filtered by date
  Future<List<MeetingModel>> getMeetingsForDateRange(
    BuildContext context, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final allMeetings = await getUserMeetings(context);
      
      if (startDate == null && endDate == null) {
        return allMeetings;
      }

      return allMeetings.where((meeting) {
        final meetingDate = meeting.startDatetime;
        
        if (startDate != null && endDate != null) {
          return meetingDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
                 meetingDate.isBefore(endDate.add(const Duration(days: 1)));
        } else if (startDate != null) {
          return meetingDate.isAfter(startDate.subtract(const Duration(days: 1)));
        } else if (endDate != null) {
          return meetingDate.isBefore(endDate.add(const Duration(days: 1)));
        }
        
        return true;
      }).toList();
    } catch (e) {
      log('❌ Error fetching meetings for date range: $e');
      rethrow;
    }
  }

  /// Fetches meetings for today
  /// Returns a list of MeetingModel for today's date
  Future<List<MeetingModel>> getTodaysMeetings(BuildContext context) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
      
      return await getMeetingsForDateRange(
        context,
        startDate: startOfDay,
        endDate: endOfDay,
      );
    } catch (e) {
      log('❌ Error fetching today\'s meetings: $e');
      rethrow;
    }
  }

  /// Fetches meetings by status
  /// Returns a list of MeetingModel filtered by status
  Future<List<MeetingModel>> getMeetingsByStatus(
    BuildContext context,
    String status,
  ) async {
    try {
      final allMeetings = await getUserMeetings(context);
      return allMeetings
          .where((meeting) => meeting.status.toLowerCase() == status.toLowerCase())
          .toList();
    } catch (e) {
      log('❌ Error fetching meetings by status: $e');
      rethrow;
    }
  }
}