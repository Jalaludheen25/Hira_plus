import 'dart:developer';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hira_plus/screens/user_screens/user_home_screen/models/user_meeting_model.dart'; 
import 'package:hira_plus/screens/user_screens/user_home_screen/services/user_meeting_service.dart';
import 'package:hira_plus/utils/shared_utils.dart';

class MeetingListProvider extends ChangeNotifier {
  final MeetingService _meetingService = MeetingService();

  // Meeting state
  List<MeetingModel> _meetings = [];
  bool _isLoading = false;
  String _errorMessage = '';
  DateTime _lastFetchTime = DateTime(2000);

  // Getters
  List<MeetingModel> get meetings => _meetings;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  DateTime get lastFetchTime => _lastFetchTime;

  // Computed getters
  List<MeetingModel> get pendingMeetings => _meetings.where((m) => m.isPending).toList();
  List<MeetingModel> get approvedMeetings => _meetings.where((m) => m.isApproved).toList();
  List<MeetingModel> get rejectedMeetings => _meetings.where((m) => m.isRejected).toList();
  List<MeetingModel> get todaysMeetings {
    final today = DateTime.now();
    return _meetings.where((meeting) {
      final meetingDate = meeting.startDatetime;
      return meetingDate.year == today.year &&
             meetingDate.month == today.month &&
             meetingDate.day == today.day;
    }).toList();
  }

  int get totalMeetingsCount => _meetings.length;
  int get pendingCount => pendingMeetings.length;
  int get approvedCount => approvedMeetings.length;
  int get rejectedCount => rejectedMeetings.length;
  int get todaysCount => todaysMeetings.length;

  /// Fetches all meetings from the API
  Future<void> fetchMeetings(BuildContext context) async {
    try {
      if (_isLoading) {
        log('🔄 Already fetching meetings, ignoring new request', name: 'MeetingListProvider');
        return;
      }

      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      log('🔄 Starting to fetch meetings in provider', name: 'MeetingListProvider');
      final meetings = await _meetingService.getUserMeetings(context);

      _meetings = meetings;
      _isLoading = false;
      _lastFetchTime = DateTime.now();

      // Save meeting data to shared preferences for offline access
      await _saveMeetingsToCache();

      log('✅ Successfully updated meetings in provider. Count: ${_meetings.length}', name: 'MeetingListProvider');
      
      // Sort meetings by latest first
      _meetings.sort((a, b) => b.startDatetime.compareTo(a.startDatetime));
      
      notifyListeners();
    } on HttpException catch (e) {
      log('🚨 HTTP error in meeting provider: $e', name: 'MeetingListProvider');
      _isLoading = false;

      if (e.toString().contains('401')) {
        _errorMessage = 'Authentication error. Please login again.';
      } else {
        _errorMessage = 'Failed to load meetings. Please check your connection and try again.';
      }

      // Try to load from cache if available
      await _loadMeetingsFromCache();
      notifyListeners();
    } catch (e) {
      log('❌ Error in meeting provider: $e', name: 'MeetingListProvider');
      _isLoading = false;
      _errorMessage = 'Failed to load meetings. Please try again.';

      // Try to load from cache if available
      await _loadMeetingsFromCache();
      notifyListeners();
    }
  }

  /// Saves meetings to cache
  Future<void> _saveMeetingsToCache() async {
    try {
      if (_meetings.isNotEmpty) {
        final meetingJsonList = _meetings.map((meeting) => jsonEncode(meeting.toJson())).toList();
        final meetingJsonString = jsonEncode(meetingJsonList);
        await SharedUtils.setString('cached_meetings', meetingJsonString);
        log('💾 Saved ${_meetings.length} meetings to cache', name: 'MeetingListProvider');
      }
    } catch (e) {
      log('❌ Error saving meetings to cache: $e', name: 'MeetingListProvider');
    }
  }

  /// Loads meetings from cache
  Future<void> _loadMeetingsFromCache() async {
    try {
      if (_meetings.isEmpty) {
        final cachedMeetingsJson = await SharedUtils.getString('cached_meetings');
        if (cachedMeetingsJson.isNotEmpty) {
          final List<dynamic> meetingJsonList = jsonDecode(cachedMeetingsJson);
          final cachedMeetings = meetingJsonList
              .map((meetingJson) => MeetingModel.fromJson(jsonDecode(meetingJson)))
              .toList();

          if (cachedMeetings.isNotEmpty) {
            _meetings = cachedMeetings;
            // Sort meetings by latest first
            _meetings.sort((a, b) => b.startDatetime.compareTo(a.startDatetime));
            log('📂 Loaded ${_meetings.length} meetings from cache', name: 'MeetingListProvider');
          }
        }
      }
    } catch (e) {
      log('❌ Error loading meetings from cache: $e', name: 'MeetingListProvider');
    }
  }

  /// Gets meetings for a specific date
  List<MeetingModel> getMeetingsForDate(DateTime date) {
    return _meetings.where((meeting) {
      final meetingDate = meeting.startDatetime;
      return meetingDate.year == date.year &&
             meetingDate.month == date.month &&
             meetingDate.day == date.day;
    }).toList();
  }

  /// Gets meetings for current week
  List<MeetingModel> getWeekMeetings() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return _meetings.where((meeting) {
      final meetingDate = meeting.startDatetime;
      return meetingDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
             meetingDate.isBefore(endOfWeek.add(const Duration(days: 1)));
    }).toList();
  }

  /// Gets meetings for current month
  List<MeetingModel> getMonthMeetings() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    return _meetings.where((meeting) {
      final meetingDate = meeting.startDatetime;
      return meetingDate.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
             meetingDate.isBefore(endOfMonth.add(const Duration(days: 1)));
    }).toList();
  }

  /// Refreshes meetings (clears cache and fetches fresh data)
  Future<void> refreshMeetings(BuildContext context) async {
    await SharedUtils.setString('cached_meetings', '');
    _meetings.clear();
    await fetchMeetings(context);
  }

  /// Deletes a meeting by ID (DeptHead only)
  Future<void> deleteMeeting(BuildContext context, String meetingId) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();
      
      log('🗑️ Attempting to delete meeting: $meetingId', name: 'MeetingListProvider');
      
      final success = await _meetingService.deleteMeeting(context, meetingId);
      if (success) {
        log('✅ Meeting deleted successfully, refreshing list', name: 'MeetingListProvider');
        // Remove the meeting from local list immediately for better UX
        _meetings.removeWhere((meeting) => meeting.id == meetingId);
        await _saveMeetingsToCache(); // Update cache
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Meeting deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
        // Only fetch meetings if delete was successful
        await fetchMeetings(context);
      }
    } catch (e) {
      log('❌ Error deleting meeting: $e', name: 'MeetingListProvider');
      _errorMessage = 'Failed to delete meeting. Please try again.';
      final errorStr = e.toString().toLowerCase();
      if (context.mounted) {
        if (errorStr.contains('not found') || errorStr.contains('cannot be deleted')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("You can't delete this meeting."),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete meeting: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates a meeting by ID (DeptHead only)
  Future<void> updateMeeting(BuildContext context, String meetingId, Map<String, dynamic> meetingData) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();
      
      log('📝 Attempting to update meeting: $meetingId', name: 'MeetingListProvider');
      log('📦 Update data: $meetingData', name: 'MeetingListProvider');
      
      // Check if meeting exists in local list before making API call
      final existingMeeting = _meetings.firstWhere(
        (meeting) => meeting.id == meetingId,
        orElse: () => throw Exception('Meeting not found in local list'),
      );
      
      // Check if meeting can be edited (only pending meetings)
      if (!existingMeeting.isPending) {
        throw Exception('Only pending meetings can be edited. This meeting is ${existingMeeting.status}.');
      }
      
      final updatedMeeting = await _meetingService.updateMeeting(context, meetingId, meetingData);
      
      if (updatedMeeting != null) {
        log('✅ Meeting updated successfully', name: 'MeetingListProvider');
        
        // Update the meeting in local list immediately for better UX
        final index = _meetings.indexWhere((meeting) => meeting.id == meetingId);
        if (index != -1) {
          _meetings[index] = updatedMeeting;
          // Maintain sorting
          _meetings.sort((a, b) => b.startDatetime.compareTo(a.startDatetime));
          await _saveMeetingsToCache(); // Update cache
        }
        
        // Also fetch latest data from server to ensure consistency
        await fetchMeetings(context);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Meeting updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } on HttpException catch (e) {
      log('❌ HTTP error updating meeting: $e', name: 'MeetingListProvider');
      _errorMessage = _getDetailedErrorMessage(e.toString());
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      log('❌ Error updating meeting: $e', name: 'MeetingListProvider');
      _errorMessage = 'Failed to update meeting. Please try again.';
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Helper method to provide user-friendly error messages
  String _getDetailedErrorMessage(String error) {
    if (error.contains('404') || error.contains('not found')) {
      return 'Meeting not found. It may have been deleted or you don\'t have permission to edit it.';
    } else if (error.contains('403') || error.contains('forbidden')) {
      return 'You don\'t have permission to edit this meeting.';
    } else if (error.contains('401') || error.contains('unauthorized')) {
      return 'Your session has expired. Please login again.';
    } else if (error.contains('cannot be edited')) {
      return 'This meeting cannot be edited. Only pending meetings can be modified.';
    } else if (error.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    }
    return 'Failed to update meeting. Please try again later.';
  }

  /// Refresh a specific meeting from server
  Future<void> refreshMeeting(BuildContext context, String meetingId) async {
    try {
      // Fetch latest meetings to get updated data
      await fetchMeetings(context);
    } catch (e) {
      log('❌ Error refreshing meeting: $e', name: 'MeetingListProvider');
    }
  }

  /// Resets all provider state
  void reset() {
    _meetings = [];
    _isLoading = false;
    _errorMessage = '';
    _lastFetchTime = DateTime(2000);
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}