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
  List<MeetingModel> _filteredMeetings = [];
  bool _isLoading = false;
  String _errorMessage = '';
  DateTime _lastFetchTime = DateTime(2000);

  // Filter state
  String _selectedStatus = 'all'; // all, pending, approved, rejected
  String _searchQuery = '';
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;

  // Getters
  List<MeetingModel> get meetings => _filteredMeetings.isNotEmpty ? _filteredMeetings : _meetings;
  List<MeetingModel> get allMeetings => _meetings;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  DateTime get lastFetchTime => _lastFetchTime;
  String get selectedStatus => _selectedStatus;
  String get searchQuery => _searchQuery;
  DateTime? get filterStartDate => _filterStartDate;
  DateTime? get filterEndDate => _filterEndDate;

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

      // Apply current filters
      _applyFilters();

      // Save meeting data to shared preferences for offline access
      await _saveMeetingsToCache();

      log('✅ Successfully updated meetings in provider. Count: ${_meetings.length}', name: 'MeetingListProvider');
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

  /// Fetches today's meetings
  Future<void> fetchTodaysMeetings(BuildContext context) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      final todaysMeetings = await _meetingService.getTodaysMeetings(context);
      _meetings = todaysMeetings;
      _isLoading = false;
      _lastFetchTime = DateTime.now();

      _applyFilters();
      notifyListeners();
    } catch (e) {
      log('❌ Error fetching today\'s meetings: $e', name: 'MeetingListProvider');
      _isLoading = false;
      _errorMessage = 'Failed to load today\'s meetings. Please try again.';
      notifyListeners();
    }
  }

  /// Fetches meetings by status
  Future<void> fetchMeetingsByStatus(BuildContext context, String status) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      final meetingsByStatus = await _meetingService.getMeetingsByStatus(context, status);
      _meetings = meetingsByStatus;
      _isLoading = false;
      _lastFetchTime = DateTime.now();

      _applyFilters();
      notifyListeners();
    } catch (e) {
      log('❌ Error fetching meetings by status: $e', name: 'MeetingListProvider');
      _isLoading = false;
      _errorMessage = 'Failed to load meetings by status. Please try again.';
      notifyListeners();
    }
  }

  /// Sets the status filter
  void setStatusFilter(String status) {
    _selectedStatus = status;
    _applyFilters();
    notifyListeners();
  }

  /// Sets the search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  /// Sets the date range filter
  void setDateRangeFilter(DateTime? startDate, DateTime? endDate) {
    _filterStartDate = startDate;
    _filterEndDate = endDate;
    _applyFilters();
    notifyListeners();
  }

  /// Clears all filters
  void clearFilters() {
    _selectedStatus = 'all';
    _searchQuery = '';
    _filterStartDate = null;
    _filterEndDate = null;
    _applyFilters();
    notifyListeners();
  }

  /// Applies current filters to the meetings list
  void _applyFilters() {
    List<MeetingModel> filtered = List.from(_meetings);

    // Apply status filter
    if (_selectedStatus != 'all') {
      filtered = filtered.where((meeting) {
        switch (_selectedStatus) {
          case 'pending':
            return meeting.isPending;
          case 'approved':
            return meeting.isApproved;
          case 'rejected':
            return meeting.isRejected;
          default:
            return true;
        }
      }).toList();
    }

    // Apply search query filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((meeting) {
        return meeting.title.toLowerCase().contains(query) ||
               meeting.description.toLowerCase().contains(query) ||
               meeting.department.toLowerCase().contains(query) ||
               meeting.hall.toLowerCase().contains(query);
      }).toList();
    }

    // Apply date range filter
    if (_filterStartDate != null || _filterEndDate != null) {
      filtered = filtered.where((meeting) {
        final meetingDate = meeting.startDatetime;
        
        if (_filterStartDate != null && _filterEndDate != null) {
          return meetingDate.isAfter(_filterStartDate!.subtract(const Duration(days: 1))) &&
                 meetingDate.isBefore(_filterEndDate!.add(const Duration(days: 1)));
        } else if (_filterStartDate != null) {
          return meetingDate.isAfter(_filterStartDate!.subtract(const Duration(days: 1)));
        } else if (_filterEndDate != null) {
          return meetingDate.isBefore(_filterEndDate!.add(const Duration(days: 1)));
        }
        
        return true;
      }).toList();
    }

    _filteredMeetings = filtered;
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
            _applyFilters();
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
    _filteredMeetings.clear();
    await fetchMeetings(context);
  }

  /// Resets all provider state
  void reset() {
    _meetings = [];
    _filteredMeetings = [];
    _isLoading = false;
    _errorMessage = '';
    _selectedStatus = 'all';
    _searchQuery = '';
    _filterStartDate = null;
    _filterEndDate = null;
    _lastFetchTime = DateTime(2000);
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}