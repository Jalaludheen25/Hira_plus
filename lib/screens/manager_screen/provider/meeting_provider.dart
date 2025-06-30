import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hira_plus/screens/manager_screen/models/meating_model.dart';
import 'package:hira_plus/screens/manager_screen/service/meeting_service.dart';

class MeetingProvider extends ChangeNotifier {
  final MeetingService _meetingService = MeetingService();

  // State variables
  List<MeetingModel> _meetings = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters - Modified to filter out past meetings
  List<MeetingModel> get meetings {
    final now = DateTime.now();
    return _meetings
        .where((meeting) => meeting.endDatetime.isAfter(now))
        .toList();
  }

  // Helper getter to get all meetings including past ones (for internal use)
  List<MeetingModel> get allMeetings => _meetings;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Filtered lists - updated for only approved and pending (excluding past meetings)
  List<MeetingModel> get pendingMeetings {
    final now = DateTime.now();
    return _meetings
        .where(
            (meeting) => meeting.isPending && meeting.endDatetime.isAfter(now))
        .toList();
  }

  List<MeetingModel> get approvedMeetings {
    final now = DateTime.now();
    return _meetings
        .where(
            (meeting) => meeting.isApproved && meeting.endDatetime.isAfter(now))
        .toList();
  }

  List<MeetingModel> get scheduledMeetings {
    final now = DateTime.now();
    return approvedMeetings
        .where((meeting) => meeting.startDatetime.isAfter(now))
        .toList();
  }

  List<MeetingModel> get pastMeetings {
    final now = DateTime.now();
    return _meetings
        .where((meeting) => meeting.endDatetime.isBefore(now))
        .toList();
  }

  /// Fetches all meetings
  Future<void> fetchMeetings(BuildContext context) async {
    try {
      if (_isLoading) {
        log('🔄 Already fetching meetings, ignoring new request',
            name: 'MeetingProvider');
        return;
      }

      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      log('🔄 Starting to fetch meetings in provider', name: 'MeetingProvider');
      final meetings = await _meetingService.getAllMeetings(context);

      // Sort meetings by meeting date (earliest first)
      meetings.sort((a, b) => a.startDatetime.compareTo(b.startDatetime));

      _meetings = meetings;
      _isLoading = false;

      log('✅ Successfully updated meetings in provider. Total count: ${_meetings.length}, Active (non-past) count: ${meetings.length}',
          name: 'MeetingProvider');
      notifyListeners();
    } on HttpException catch (e) {
      log('🚨 HTTP error in meeting provider: $e', name: 'MeetingProvider');
      _isLoading = false;

      if (e.toString().contains('401')) {
        _errorMessage = 'Authentication error. Please login again.';
      } else {
        _errorMessage =
            'Failed to load meetings. Please check your connection and try again.';
      }

      notifyListeners();
    } catch (e) {
      log('❌ Error in meeting provider: $e', name: 'MeetingProvider');
      _isLoading = false;
      _errorMessage = 'Failed to load meetings. Please try again.';
      notifyListeners();
    }
  }

  /// Creates a new meeting
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
    required int morningTeaCount,
    required int lunch,
    required int eveningsnacks,
    required int eveningTeaCount,
    required int dinner,
    required String department,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      log('🔄 Creating meeting in provider', name: 'MeetingProvider');

      final meeting = await _meetingService.createMeeting(
        context,
        title: title,
        description: description,
        startDatetime: startDatetime,
        endDatetime: endDatetime,
        hall: hall,
        noOfPersons: noOfPersons,
        foodRequired: foodRequired,
        breakfast: breakfast,
        midmorningSnacks: midmorningSnacks,
        morningTeaCount: morningTeaCount,
        lunch: lunch,
        eveningsnacks: eveningsnacks,
        eveningTeaCount: eveningTeaCount,
        dinner: dinner,
        department: department,
      );

      // Add new meeting to local list and sort by meeting date
      _meetings.add(meeting);
      _meetings.sort((a, b) => a.startDatetime.compareTo(b.startDatetime));
      _isLoading = false;

      log('✅ Meeting created successfully: ${meeting.id}',
          name: 'MeetingProvider');
      notifyListeners();

      return meeting;
    } catch (e) {
      log('❌ Error creating meeting: $e', name: 'MeetingProvider');
      _isLoading = false;
      _errorMessage = 'Failed to create meeting. Please try again.';
      notifyListeners();
      return null;
    }
  }

  /// Updates meeting status with improved state management
  Future<bool> updateMeetingStatus(
    BuildContext context,
    String meetingId,
    String status,
  ) async {
    try {
      log('🔄 Updating meeting status in provider: $meetingId -> $status',
          name: 'MeetingProvider');

      // Find the meeting index first
      final meetingIndex =
          _meetings.indexWhere((meeting) => meeting.id == meetingId);
      if (meetingIndex == -1) {
        log('❌ Meeting not found in local list: $meetingId',
            name: 'MeetingProvider');
        return false;
      }

      // Store original meeting for rollback if needed
      final originalMeeting = _meetings[meetingIndex];

      // Optimistically update the UI first for better UX
      final updatedMeeting = MeetingModel(
        id: originalMeeting.id,
        title: originalMeeting.title,
        description: originalMeeting.description,
        startDatetime: originalMeeting.startDatetime,
        endDatetime: originalMeeting.endDatetime,
        hall: originalMeeting.hall,
        noOfPersons: originalMeeting.noOfPersons,
        foodRequired: originalMeeting.foodRequired,
        breakfast: originalMeeting.breakfast,
        midmorningSnacks: originalMeeting.midmorningSnacks,
        morningTeaCount: originalMeeting.morningTeaCount,
        lunch: originalMeeting.lunch,
        eveningsnacks: originalMeeting.eveningsnacks,
        eveningTeaCount: originalMeeting.eveningTeaCount,
        dinner: originalMeeting.dinner,
        department: originalMeeting.department,
        status: status, // Update the status
        createdBy: originalMeeting.createdBy,
        createdAt: originalMeeting.createdAt,
        updatedAt: DateTime.now(),
        rent: originalMeeting.rent,
        morningSnacksCount: originalMeeting.morningSnacksCount,
        eveningSnacksCount: originalMeeting.eveningSnacksCount,
      );

      // Update UI immediately (optimistic update)
      _meetings[meetingIndex] = updatedMeeting;
      notifyListeners();

      try {
        // Make API call
        final serverUpdatedMeeting = await _meetingService.updateMeetingStatus(
          context,
          meetingId,
          status,
        );

        // Update with server response
        _meetings[meetingIndex] = serverUpdatedMeeting;

        // Re-sort the list to maintain meeting date order
        _meetings.sort((a, b) => a.startDatetime.compareTo(b.startDatetime));

        log('✅ Meeting status updated successfully from server',
            name: 'MeetingProvider');
        notifyListeners();

        return true;
      } catch (e) {
        // Rollback optimistic update on API failure
        log('❌ API call failed, rolling back optimistic update: $e',
            name: 'MeetingProvider');
        _meetings[meetingIndex] = originalMeeting;
        notifyListeners();
        rethrow;
      }
    } catch (e) {
      log('❌ Error updating meeting status: $e', name: 'MeetingProvider');
      return false;
    }
  }

  /// Updates a specific meeting in the list
  void updateMeetingInList(MeetingModel updatedMeeting) {
    final index =
        _meetings.indexWhere((meeting) => meeting.id == updatedMeeting.id);
    if (index != -1) {
      _meetings[index] = updatedMeeting;
      // Re-sort to maintain meeting date order
      _meetings.sort((a, b) => a.startDatetime.compareTo(b.startDatetime));
      log('✅ Meeting updated in local list: ${updatedMeeting.id}',
          name: 'MeetingProvider');
      notifyListeners();
    }
  }

  /// Removes a meeting from the list
  void removeMeetingFromList(String meetingId) {
    _meetings.removeWhere((meeting) => meeting.id == meetingId);
    log('✅ Meeting removed from local list: $meetingId',
        name: 'MeetingProvider');
    notifyListeners();
  }

  /// Reset provider state
  void reset() {
    _meetings = [];
    _isLoading = false;
    _errorMessage = '';
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  /// Deletes a meeting by ID
  Future<bool> deleteMeeting(BuildContext context, String meetingId) async {
    try {
      final success = await _meetingService.deleteMeeting(context, meetingId);
      if (success) {
        removeMeetingFromList(meetingId);
      }
      return success;
    } catch (e) {
      log('❌ Error deleting meeting in provider: $e', name: 'MeetingProvider');
      return false;
    }
  }

  /// Updates an existing meeting
  Future<MeetingModel?> updateMeeting(
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
    required int midmorningSnacks,
    required int morningTeaCount,
    required int lunch,
    required int eveningsnacks,
    required int eveningTeaCount,
    required int dinner,
    required String department,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      log('📝 Updating meeting in provider', name: 'MeetingProvider');

      final updatedMeeting = await _meetingService.updateMeeting(
        context,
        meetingId: meetingId,
        title: title,
        description: description,
        startDatetime: startDatetime,
        endDatetime: endDatetime,
        hall: hall,
        noOfPersons: noOfPersons,
        foodRequired: foodRequired,
        breakfast: breakfast,
        midmorningSnacks: midmorningSnacks,
        morningTeaCount: morningTeaCount,
        lunch: lunch,
        eveningsnacks: eveningsnacks,
        eveningTeaCount: eveningTeaCount,
        dinner: dinner,
        department: department,
      );

      // Update the meeting in the local list and re-sort by meeting date
      final index = _meetings.indexWhere((m) => m.id == meetingId);
      if (index != -1) {
        _meetings[index] = updatedMeeting;
        _meetings.sort((a, b) => a.startDatetime.compareTo(b.startDatetime));
      }
      _isLoading = false;
      notifyListeners();
      return updatedMeeting;
    } catch (e) {
      log('❌ Error updating meeting: $e', name: 'MeetingProvider');
      _isLoading = false;
      _errorMessage = 'Failed to update meeting. Please try again.';
      notifyListeners();
      return null;
    }
  }
}
