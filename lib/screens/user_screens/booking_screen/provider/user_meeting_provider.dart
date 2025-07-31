import 'package:flutter/material.dart';
import 'package:hira_plus/constants/api_urls.dart';
import 'package:hira_plus/screens/user_screens/user_home_screen/models/user_meeting_model.dart';
import 'package:hira_plus/utils/service_utils.dart';
import 'dart:developer' as developer;
import 'dart:convert';
import 'dart:io';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:hira_plus/screens/login_screen/provider/auth_provider.dart';
import 'package:hira_plus/utils/shared_utils.dart';
import 'dart:math' as math;

class UserMeetingProvider extends ChangeNotifier {
  final Logger _logger = Logger();

  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  /// Check if there's a conflict with existing meetings for the same date and hall
  Future<bool> hasDateHallConflict(BuildContext context, DateTime startDatetime,
      DateTime endDatetime, String hall,
      {String? excludeMeetingId}) async {
    try {
      _logger.d('🔍 [CONFLICT] Checking for date/hall conflicts');
      developer.log('🔍 Checking for date/hall conflicts',
          name: 'UserMeetingProvider');

      // Fetch all meetings to check for conflicts
      final url = ApiUrls.getUserMeetings(); // auth/meetings
      final response = await HttpServiceUtils.fetchData(url, true);

      if (response == null) {
        _logger.w('⚠️ [CONFLICT] Could not fetch meetings for conflict check');
        return false; // Allow creation if we can't check
      }

      List<dynamic> meetingsData;
      if (response is String) {
        meetingsData = jsonDecode(response);
      } else {
        meetingsData = response as List<dynamic>;
      }

      // Normalize dates to compare only the date part
      final startDate =
          DateTime(startDatetime.year, startDatetime.month, startDatetime.day);
      final endDate =
          DateTime(endDatetime.year, endDatetime.month, endDatetime.day);

      for (final meetingJson in meetingsData) {
        final meeting = MeetingModel.fromJson(meetingJson);

        // Skip the meeting being edited (if any)
        if (excludeMeetingId != null && meeting.id == excludeMeetingId) {
          continue;
        }

        // Check if it's the same hall
        if (meeting.hall != hall) {
          continue;
        }

        // Normalize meeting dates
        final meetingStartDate = DateTime(meeting.startDatetime.year,
            meeting.startDatetime.month, meeting.startDatetime.day);
        final meetingEndDate = DateTime(meeting.endDatetime.year,
            meeting.endDatetime.month, meeting.endDatetime.day);

        // Check for date overlap
        if (startDate.isBefore(meetingEndDate) &&
            endDate.isAfter(meetingStartDate)) {
          _logger.w(
              '❌ [CONFLICT] Date/hall conflict found with meeting: ${meeting.id}');
          developer.log(
              '❌ Date/hall conflict found with meeting: ${meeting.id}',
              name: 'UserMeetingProvider');
          return true; // Conflict found
        }
      }

      _logger.d('✅ [CONFLICT] No conflicts found');
      developer.log('✅ No conflicts found', name: 'UserMeetingProvider');
      return false; // No conflict
    } catch (e) {
      _logger.e('❌ [CONFLICT] Error checking for conflicts: $e');
      developer.log('❌ Error checking for conflicts: $e',
          name: 'UserMeetingProvider');
      return false; // Allow creation if we can't check
    }
  }

  /// Helper method to check if current user can modify a meeting
  bool _canModifyMeeting(BuildContext context, String meetingCreatorId) {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUserId = authProvider.userId;
      final currentUserName = authProvider.userName;

      _logger.d('🔐 [AUTH] Authorization check:');
      _logger.d('   - Current user ID: $currentUserId');
      _logger.d('   - Current user name: $currentUserName');
      _logger.d('   - Meeting creator ID: $meetingCreatorId');

      // Check both user ID and user name (backend inconsistency workaround)
      final canModifyById =
          currentUserId.isNotEmpty && currentUserId == meetingCreatorId;
      final canModifyByName =
          currentUserName.isNotEmpty && currentUserName == meetingCreatorId;
      final canModify = canModifyById || canModifyByName;

      _logger.d('   - Can modify by ID: $canModifyById');
      _logger.d('   - Can modify by name: $canModifyByName');
      _logger.d('   - Can modify: $canModify');

      return canModify;
    } catch (e) {
      _logger.e('❌ [AUTH] Error checking authorization: $e');
      return false;
    }
  }

  /// Create a new meeting (deptHead only) - auth/dept-meetings
  Future<MeetingModel?> createMeeting(
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
  }) async {
    // Declare requestBody at method level for error handling
    Map<String, dynamic> requestBody = {};

    try {
      _logger.i('🆕 [API] Creating new user meeting: $title');
      developer.log('🆕 Creating new user meeting: $title',
          name: 'UserMeetingProvider');

      _logger.d('🔍 [DEBUG] Method parameters:');
      _logger.d('   - Title: $title');
      _logger.d('   - Food Required: $foodRequired');
      _logger.d('   - Start DateTime: $startDatetime');
      _logger.d('   - End DateTime: $endDatetime');
      _logger.d('   - Hall: $hall');

      // Get department from auth provider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Ensure department is loaded
      await authProvider.ensureDepartmentLoaded();

      String department = authProvider.department;

      _logger.d(
          '🔍 [DEPARTMENT] Initial department from auth provider: "$department"');

      // If department is empty, try to get it from SharedUtils
      if (department.isEmpty) {
        _logger.d('🔍 [DEPARTMENT] Department empty, trying SharedUtils...');
        department = await authProvider.getDepartment();
        _logger.d('🔍 [DEPARTMENT] Department from SharedUtils: "$department"');
      }

      // If still empty, try to reload login status to refresh all data
      if (department.isEmpty) {
        _logger.w(
            '⚠️ [DEPARTMENT] Department still empty, reloading login status...');
        await authProvider.checkLoginStatus();
        department = authProvider.department;
        _logger.d(
            '🔍 [DEPARTMENT] Department after reloading login status: "$department"');
      }

      // If still empty, try to refresh user data from server
      if (department.isEmpty) {
        _logger.w(
            '⚠️ [DEPARTMENT] Department still empty, refreshing from server...');
        await authProvider.refreshUserData(context);
        department = authProvider.department;
        _logger.d(
            '🔍 [DEPARTMENT] Department after server refresh: "$department"');
      }

      // Fallback to IT if still empty
      if (department.isEmpty) {
        department = 'IT';
        _logger.w(
            '⚠️ [DEPARTMENT] Department not found, using fallback: $department');
      }

      _logger.d('🔍 [DEPARTMENT] Final department to be sent: "$department"');

      // Check for date and hall conflicts before creating
      // Simplified conflict check - always allow creation for now
      _logger.d('✅ [CONFLICT] Conflict check simplified - allowing creation');

      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      final url = ApiUrls.createUserMeeting(); // auth/dept-meetings

      // Build request body with all fields
      requestBody = {
        'title': title.trim(),
        'description': description.trim(),
        'startDatetime': startDatetime.toIso8601String(),
        'endDatetime': endDatetime.toIso8601String(),
        'hall': hall.trim(),
        'department': department,
        'noOfPersons': noOfPersons,
        'foodRequired': foodRequired,
        'breakfast': foodRequired ? breakfast : 0,
        'morningSnacksCount': foodRequired ? morningSnacksCount : 0,
        'morningTeaCount': foodRequired ? morningTeaCount : 0,
        'lunch': foodRequired ? lunch : 0,
        'eveningSnacksCount': foodRequired ? eveningSnacksCount : 0,
        'eveningTeaCount': foodRequired ? eveningTeaCount : 0,
        'dinner': foodRequired ? dinner : 0,
        'rent': 0, // Department heads cannot change rent amount
      };

      // Validate request data before sending
      _logger.d('🔍 [VALIDATION] Validating request data:');
      _logger.d(
          '   - Title: ${title.isNotEmpty ? "✓" : "✗"} (${title.length} chars)');
      _logger.d(
          '   - Description: ${description.isNotEmpty ? "✓" : "✗"} (${description.length} chars)');
      _logger.d(
          '   - Start DateTime: ${startDatetime.isAfter(DateTime.now()) ? "✓" : "✗"} ($startDatetime)');
      _logger.d(
          '   - End DateTime: ${endDatetime.isAfter(startDatetime) ? "✓" : "✗"} ($endDatetime)');
      _logger.d('   - Hall: ${hall.isNotEmpty ? "✓" : "✗"} ($hall)');
      _logger.d(
          '   - No of Persons: ${noOfPersons > 0 ? "✓" : "✗"} ($noOfPersons)');
      _logger.d('   - Food Required: $foodRequired');
      _logger.d(
          '   - Department: ${department.isNotEmpty ? "✓" : "✗"} ($department)');
      _logger.d('   - Rent: 0 (fixed for dept heads)');

      // Log food details specifically
      if (foodRequired) {
        _logger.d('🍽️ [FOOD_DETAILS] Food is required:');
        _logger.d('   - Breakfast: $breakfast');
        _logger.d('   - Morning Snacks: $morningSnacksCount');
        _logger.d('   - Morning Tea: $morningTeaCount');
        _logger.d('   - Lunch: $lunch');
        _logger.d('   - Evening Snacks: $eveningSnacksCount');
        _logger.d('   - Evening Tea: $eveningTeaCount');
        _logger.d('   - Dinner: $dinner');
      } else {
        _logger.d(
            '🍽️ [FOOD_DETAILS] Food is not required - all food counts should be 0');
      }

      // Additional debugging for auth token
      final token = await SharedUtils.getString('auth_token');
      _logger.d(
          '🔑 [AUTH] Current auth token: ${token.isNotEmpty ? "✓ Present" : "✗ Missing"}');
      if (token.isNotEmpty) {
        _logger.d('🔑 [AUTH] Token length: ${token.length}');
        _logger.d(
            '🔑 [AUTH] Token starts with: ${token.substring(0, math.min<int>(20, token.length))}...');
      }

      // Additional debugging for user type and department head status
      final userType = await SharedUtils.getString('user_type');
      final isDeptHead = await SharedUtils.getBoolean('is_dept_head');
      _logger.d('👤 [USER] User type: $userType');
      _logger.d('👤 [USER] Is department head: $isDeptHead');
      _logger.d('👤 [USER] Department: $department');

      // Validate that user is actually a department head
      if (!isDeptHead) {
        _logger.e(
            '❌ [AUTH] User is not a department head but trying to create meeting');
        throw Exception('Only department heads can create meetings');
      }

      // Validate all required fields are present
      if (title.trim().isEmpty) {
        throw Exception('Meeting title is required');
      }
      if (description.trim().isEmpty) {
        throw Exception('Meeting description is required');
      }
      if (hall.trim().isEmpty) {
        throw Exception('Meeting hall is required');
      }
      if (noOfPersons <= 0) {
        throw Exception('Number of persons must be greater than 0');
      }
      if (startDatetime.isBefore(DateTime.now())) {
        throw Exception('Start date must be in the future');
      }
      if (endDatetime.isBefore(startDatetime)) {
        throw Exception('End date must be after start date');
      }
      if (department.trim().isEmpty) {
        throw Exception('Department is required');
      }

      _logger.d('✅ [VALIDATION] All required fields are present and valid');

      _logger.d('📤 [API] Request body: $requestBody');
      developer.log('📤 Request body: $requestBody',
          name: 'UserMeetingProvider');

      _logger.d('🚀 [API] About to make POST request to: $url');
      final response =
          await HttpServiceUtils.postData(url, requestBody, context);

      if (response != null) {
        _logger.d('📥 [API] Create meeting response: $response');
        developer.log('📥 Create meeting response: $response',
            name: 'UserMeetingProvider');

        Map<String, dynamic> responseData;

        if (response is String) {
          responseData = jsonDecode(response);
        } else {
          responseData = response as Map<String, dynamic>;
        }

        // Check for success like manager implementation
        if (responseData['success'] == false) {
          final errorMsg =
              responseData['message'] ?? 'Failed to create meeting';
          _logger.e('❌ [API_ERROR] Server returned success: false - $errorMsg');
          developer.log('❌ Server returned success: false - $errorMsg',
              name: 'UserMeetingProvider');
          throw HttpException(errorMsg);
        }

        MeetingModel? newMeeting;

        // Handle response format - extract meeting data
        if (responseData.containsKey('meeting')) {
          newMeeting = MeetingModel.fromJson(responseData['meeting']);
        } else if (responseData.containsKey('data')) {
          newMeeting = MeetingModel.fromJson(responseData['data']);
        } else {
          // Assume the response itself is the meeting data
          newMeeting = MeetingModel.fromJson(responseData);
        }

        _logger.i('✅ [API] Successfully created meeting: ${newMeeting.id}');
        developer.log('✅ Successfully created meeting: ${newMeeting.id}',
            name: 'UserMeetingProvider');

        _isLoading = false;
        notifyListeners();

        return newMeeting;
      } else {
        throw Exception('Empty response from server');
      }
    } on HttpException catch (e) {
      _logger.e('❌ [HTTP_ERROR] Failed to create meeting: $e');
      developer.log('❌ HTTP Error creating meeting: $e',
          name: 'UserMeetingProvider');

      _isLoading = false;

      // Handle specific HTTP errors
      if (e.toString().contains('409')) {
        _errorMessage =
            'This hall is already booked for the selected date and time. Please select another date or hall.';
      } else if (e.toString().contains('401')) {
        _errorMessage = 'Authentication error. Please login again.';
      } else if (e.toString().contains('500')) {
        _errorMessage = 'Server error. Please check your input and try again.';
        _logger.e(
            '❌ [SERVER_ERROR] 500 error - this might be due to invalid data format');
        developer.log(
            '❌ Server error 500 - this might be due to invalid data format',
            name: 'UserMeetingProvider');

        // Log the request body for debugging
        _logger.e('❌ [DEBUG] Request body that caused 500 error: $requestBody');
        developer.log('❌ Request body that caused 500 error: $requestBody',
            name: 'UserMeetingProvider');
      } else if (e.toString().contains('400')) {
        _errorMessage =
            'Invalid request data. Please check your input and try again.';
        _logger.e('❌ [BAD_REQUEST] 400 error - invalid request data');
        developer.log('❌ Bad request 400 - invalid request data',
            name: 'UserMeetingProvider');
      } else {
        _errorMessage = 'Failed to create meeting. Please try again.';
      }

      notifyListeners();

      // Show error to user
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }

      return null;
    } catch (e) {
      _logger.e('❌ [ERROR] Failed to create meeting: $e');
      developer.log('❌ Failed to create meeting: $e',
          name: 'UserMeetingProvider');

      _isLoading = false;
      _errorMessage = 'Failed to create meeting. Please try again.';
      notifyListeners();

      // Show error to user
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create meeting: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }

      return null;
    }
  }

  /// Update an existing meeting (creator only)
  Future<MeetingModel?> updateMeeting(
    BuildContext context,
    String meetingId,
    Map<String, dynamic> meetingData, {
    String? meetingCreatorId,
  }) async {
    try {
      _logger.i('🔄 [API] Updating user meeting: $meetingId');
      developer.log('🔄 Updating user meeting: $meetingId',
          name: 'UserMeetingProvider');

      // Check authorization if creatorId is provided
      if (meetingCreatorId != null &&
          !_canModifyMeeting(context, meetingCreatorId)) {
        _logger.w(
            '🚫 [AUTH] Unauthorized update attempt blocked for meeting: $meetingId');
        developer.log('🚫 Unauthorized update attempt blocked',
            name: 'UserMeetingProvider');

        _errorMessage = 'You can only update meetings that you created';
        notifyListeners();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You can only update meetings that you created'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return null;
      }

      // Check for date and hall conflicts before updating (excluding current meeting)
      final startDatetime = DateTime.parse(meetingData['startDatetime']);
      final endDatetime = DateTime.parse(meetingData['endDatetime']);
      final hall = meetingData['hall'];

      final hasConflict = await hasDateHallConflict(
          context, startDatetime, endDatetime, hall,
          excludeMeetingId: meetingId);
      if (hasConflict) {
        _logger.w(
            '❌ [CONFLICT] Date and hall conflict detected for meeting update');
        developer.log('❌ Date and hall conflict detected for meeting update',
            name: 'UserMeetingProvider');

        _errorMessage =
            'This hall is already booked for the selected date and time. Please select another date or hall.';
        notifyListeners();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'This hall is already booked for the selected date and time. Please select another date or hall.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return null;
      }

      // Ensure rent is set to 0 for department heads
      meetingData['rent'] = 0;

      _isLoading = true;
      _errorMessage = '';
      notifyListeners();
      final url = ApiUrls.editMeeting(meetingId); // PUT endpoint
      final response =
          await HttpServiceUtils.putData(url, meetingData, context);
      if (response != null) {
        Map<String, dynamic> responseData;
        if (response is String) {
          responseData = jsonDecode(response);
        } else {
          responseData = response as Map<String, dynamic>;
        }
        MeetingModel? updatedMeeting;
        if (responseData.containsKey('meeting')) {
          updatedMeeting = MeetingModel.fromJson(responseData['meeting']);
        } else if (responseData.containsKey('data')) {
          updatedMeeting = MeetingModel.fromJson(responseData['data']);
        } else {
          updatedMeeting = MeetingModel.fromJson(responseData);
        }
        _isLoading = false;
        notifyListeners();
        return updatedMeeting;
      } else {
        throw Exception('Empty response from server');
      }
    } on HttpException catch (e) {
      _logger.e('❌ [HTTP_ERROR] Failed to update meeting: $e');
      developer.log('❌ HTTP Error updating meeting: $e',
          name: 'UserMeetingProvider');
      _isLoading = false;

      // Handle 409 Conflict error specifically
      if (e.toString().contains('409')) {
        _errorMessage =
            'This hall is already booked for the selected date and time. Please select another date or hall.';
      } else if (e.toString().contains('401')) {
        _errorMessage = 'Authentication error. Please login again.';
      } else {
        _errorMessage = 'Failed to update meeting. Please try again.';
      }

      notifyListeners();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    } catch (e) {
      _logger.e('❌ [ERROR] Failed to update meeting: $e');
      developer.log('❌ Failed to update meeting: $e',
          name: 'UserMeetingProvider');
      _isLoading = false;
      _errorMessage = 'Failed to update meeting. Please try again.';
      notifyListeners();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update meeting: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  /// Delete an existing meeting (creator only)
  Future<bool> deleteMeeting(
    BuildContext context,
    String meetingId,
    String meetingCreatorId,
  ) async {
    try {
      _logger.i('🗑️ [API] Deleting user meeting: $meetingId');
      developer.log('🗑️ Deleting user meeting: $meetingId',
          name: 'UserMeetingProvider');

      // Check authorization
      if (!_canModifyMeeting(context, meetingCreatorId)) {
        _logger.w(
            '🚫 [AUTH] Unauthorized delete attempt blocked for meeting: $meetingId');
        developer.log('🚫 Unauthorized delete attempt blocked',
            name: 'UserMeetingProvider');

        _errorMessage = 'You can only delete meetings that you created';
        notifyListeners();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You can only delete meetings that you created'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return false;
      }

      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      final url = ApiUrls.deleteMeeting(meetingId); // DELETE endpoint
      final response = await HttpServiceUtils.deleteData(url, context);

      if (response != null) {
        _logger.i('✅ [API] Successfully deleted meeting: $meetingId');
        developer.log('✅ Successfully deleted meeting: $meetingId',
            name: 'UserMeetingProvider');

        _isLoading = false;
        notifyListeners();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Meeting deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }

        return true;
      } else {
        throw Exception('Empty response from server');
      }
    } catch (e) {
      _logger.e('❌ [ERROR] Failed to delete meeting: $e');
      developer.log('❌ Failed to delete meeting: $e',
          name: 'UserMeetingProvider');

      _isLoading = false;
      _errorMessage = 'Failed to delete meeting. Please try again.';
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete meeting: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }

      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _logger.d('🔄 [STATE] Clearing error message');
    developer.log('🔄 Clearing error message', name: 'UserMeetingProvider');

    _errorMessage = '';
    notifyListeners();
  }

  /// Reset state
  void reset() {
    _logger.i('🔄 [STATE] Resetting user meeting provider state');
    developer.log('🔄 Resetting user meeting provider state',
        name: 'UserMeetingProvider');

    _isLoading = false;
    _errorMessage = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _logger.i('🧹 [DISPOSE] Disposing UserMeetingProvider');
    developer.log('🧹 Disposing UserMeetingProvider',
        name: 'UserMeetingProvider');
    super.dispose();
  }
}
