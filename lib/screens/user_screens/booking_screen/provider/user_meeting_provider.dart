import 'package:flutter/material.dart';
import 'package:hira_plus/constants/api_urls.dart';
import 'package:hira_plus/screens/manager_screen/models/meating_model.dart';
import 'package:hira_plus/utils/service_utils.dart';
import 'dart:developer' as developer;
import 'dart:convert';
import 'package:logger/logger.dart';

class UserMeetingProvider extends ChangeNotifier {
  final Logger _logger = Logger();
  
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

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
    required int midmorningSnacks,
    required int lunch,
    required int eveningsnacks,
    required int dinner,
  }) async {
    try {
      _logger.i('🆕 [API] Creating new user meeting: $title');
      developer.log('🆕 Creating new user meeting: $title', name: 'UserMeetingProvider');
      
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      final url = ApiUrls.createUserMeeting(); // auth/dept-meetings
      
      final requestBody = {
        'title': title,
        'description': description,
        'startDatetime': startDatetime.toIso8601String(),
        'endDatetime': endDatetime.toIso8601String(),
        'hall': hall,
        'noOfPersons': noOfPersons,
        'foodRequired': foodRequired,
        'breakfast': breakfast,
        'midmorningSnacks': midmorningSnacks,
        'lunch': lunch,
        'eveningsnacks': eveningsnacks,
        'dinner': dinner,
      };

      _logger.d('📤 [API] Request body: $requestBody');
      developer.log('📤 Request body: $requestBody', name: 'UserMeetingProvider');

      final response = await HttpServiceUtils.postData(url, requestBody, context);
      
      if (response != null) {
        _logger.d('📥 [API] Create meeting response: $response');
        developer.log('📥 Create meeting response: $response', name: 'UserMeetingProvider');
        
        Map<String, dynamic> responseData;
        
        if (response is String) {
          responseData = jsonDecode(response);
        } else {
          responseData = response as Map<String, dynamic>;
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
        
        if (newMeeting != null) {
          _logger.i('✅ [API] Successfully created meeting: ${newMeeting.id}');
          developer.log('✅ Successfully created meeting: ${newMeeting.id}', name: 'UserMeetingProvider');
          
          _isLoading = false;
          notifyListeners();
          
          return newMeeting;
        } else {
          throw Exception('Failed to parse created meeting data');
        }
      } else {
        throw Exception('Empty response from server');
      }
    } catch (e) {
      _logger.e('❌ [ERROR] Failed to create meeting: $e');
      developer.log('❌ Failed to create meeting: $e', name: 'UserMeetingProvider');
      
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
    developer.log('🔄 Resetting user meeting provider state', name: 'UserMeetingProvider');
    
    _isLoading = false;
    _errorMessage = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _logger.i('🧹 [DISPOSE] Disposing UserMeetingProvider');
    developer.log('🧹 Disposing UserMeetingProvider', name: 'UserMeetingProvider');
    super.dispose();
  }
}