import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hira_plus/constants/api_urls.dart';
import 'package:hira_plus/screens/reception_screen/models/reception_user_model.dart';
import 'package:hira_plus/utils/service_utils.dart';

class ReceptionService {
  /// Fetches all users for reception
  Future<List<ReceptionUser>> getAllUsers(BuildContext context) async {
    try {
      log('🏢 Fetching reception users');

      final url = ApiUrls.getAllReceptionUsers();
      log('🔗 API URL: $url');

      final response = await HttpServiceUtils.fetchData(url, true);

      if (response != null) {
        final Map<String, dynamic> responseData = response;
        final List<dynamic> usersList = responseData['users'] ?? [];

        final users = usersList
            .map((userJson) => ReceptionUser.fromJson(userJson))
            .toList();

        log('✅ API success: ${users.length} users');
        return users;
      }

      return [];
    } catch (e) {
      log('❌ Error fetching users: $e');

      if (e is HttpException) {
        log('⚠️ API failed: ${e.message}');
      }

      // Return empty list in case of error
      return [];
    }
  }

  /// Check in a user through API
  Future<bool> checkInUser(BuildContext context, String userId) async {
    try {
      log('📝 Checking in user: $userId');
      final url = ApiUrls.checkInUser(userId);

      final response = await HttpServiceUtils.postData(url, {}, context);

      if (response != null) {
        log('✅ User checked in successfully via API');
        return true;
      }

      return false;
    } catch (e) {
      log('❌ Error checking in user: $e');
      return false;
    }
  }

  /// Check out a user through API
  Future<bool> checkOutUser(BuildContext context, String userId) async {
    try {
      log('📤 Checking out user: $userId');
      final url = ApiUrls.checkOutUser(userId);

      final response = await HttpServiceUtils.postData(url, {}, context);

      if (response != null) {
        log('✅ User checked out successfully via API');
        return true;
      }

      return false;
    } catch (e) {
      log('❌ Error checking out user: $e');
      return false;
    }
  }

  /// Fetch attendance by date
  Future<List<ReceptionAttendance>> getAttendanceByDate(
      BuildContext context, String date) async {
    try {
      final url = ApiUrls.getAttendanceByDate(date);
      log('🔗 Fetching attendance by date: $url');

      final response = await HttpServiceUtils.fetchData(url, true);

      if (response != null) {
        log('📦 Raw attendance response for $date: $response');

        if (response is List) {
          return response
              .map((item) => ReceptionAttendance.fromJson(item))
              .toList();
        } else if (response['data'] is List) {
          return (response['data'] as List)
              .map((item) => ReceptionAttendance.fromJson(item))
              .toList();
        } else if (response['records'] is List) {
          return (response['records'] as List)
              .map((item) => ReceptionAttendance.fromJson(item))
              .toList();
        }
      }

      return [];
    } catch (e) {
      log('❌ Error fetching attendance by date: $e');
      return [];
    }
  }

  /// Fetch today's check-ins
  Future<CheckInsResponse> getTodayCheckIns(BuildContext context) async {
    try {
      final url = ApiUrls.getTodayCheckIns();
      log('🔗 Fetching today\'s check-ins: $url');

      final response = await HttpServiceUtils.fetchData(url, true);

      if (response != null) {
        log('📦 Raw check-ins response: $response');
        return CheckInsResponse.fromJson(response);
      }

      return CheckInsResponse(
        total: 0,
        checkIns: [],
        summary: AttendanceSummary(
          todayCheckIns: 0,
          previousDaysStillCheckedIn: 0,
        ),
      );
    } catch (e) {
      log('❌ Error fetching today\'s check-ins: $e');
      return CheckInsResponse(
        total: 0,
        checkIns: [],
        summary: AttendanceSummary(
          todayCheckIns: 0,
          previousDaysStillCheckedIn: 0,
        ),
      );
    }
  }

  /// Fetch today's check-outs
  Future<List<ReceptionAttendance>> getTodayCheckOuts(
      BuildContext context) async {
    try {
      final url = ApiUrls.getTodayCheckOuts();
      log('🔗 Fetching today\'s check-outs: $url');

      final response = await HttpServiceUtils.fetchData(url, true);

      if (response != null) {
        if (response is List) {
          return response
              .map((item) => ReceptionAttendance.fromJson(item))
              .toList();
        } else if (response['data'] is List) {
          return (response['data'] as List)
              .map((item) => ReceptionAttendance.fromJson(item))
              .toList();
        } else if (response['checkouts'] is List) {
          return (response['checkouts'] as List)
              .map((item) => ReceptionAttendance.fromJson(item))
              .toList();
        }
      }

      return [];
    } catch (e) {
      log('❌ Error fetching today\'s check-outs: $e');
      return [];
    }
  }

  /// Check if a user is already checked in (based on API data)
  bool isUserCheckedIn(List<ReceptionAttendance> checkIns, String userId) {
    return checkIns.any((checkIn) => checkIn.user.id == userId);
  }

  /// Check if a user is already checked out (based on API data)
  bool isUserCheckedOut(List<ReceptionAttendance> checkIns, String userId) {
    final userAttendance =
        checkIns.where((checkIn) => checkIn.user.id == userId);
    if (userAttendance.isNotEmpty) {
      return userAttendance.first.checkoutTime != null;
    }
    return false;
  }
}
