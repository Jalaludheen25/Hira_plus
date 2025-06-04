// providers/meeting_food_requirements_provider.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:hira_plus/constants/api_urls.dart';
import 'package:hira_plus/screens/mess_staff_screen/models/meeting_food_model.dart';
import 'package:hira_plus/utils/shared_utils.dart';

class MeetingFoodProvider extends ChangeNotifier {
  MeetingFoodModel? _meetingFoodData;
  bool _isLoading = false;
  String _errorMessage = '';
  DateTime _selectedDate = DateTime.now();

  // Getters
  MeetingFoodModel? get meetingFoodData => _meetingFoodData;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  DateTime get selectedDate => _selectedDate;

  // Get overall totals for display
  OverallTotals? get overallTotals => _meetingFoodData?.overallTotals;

  // Get daily requirement for selected date
  DailyRequirement? get selectedDateRequirement {
    if (_meetingFoodData == null) return null;
    
    final dateKey = _selectedDate.toIso8601String().split('T')[0];
    return _meetingFoodData!.dailyRequirements[dateKey];
  }

  // Get all meetings for selected date
  List<Meeting> get selectedDateMeetings => selectedDateRequirement?.meetings ?? [];

  // Get total food counts for selected date
  OverallTotals? get selectedDateTotals => selectedDateRequirement?.totalCounts;

  // Set selected date
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    developer.log('📅 Selected date changed to: ${date.toIso8601String().split('T')[0]}', 
        name: 'MeetingFoodProvider');
    notifyListeners();
  }

  // Fetch meeting food requirements
  Future<void> fetchMeetingFoodRequirements(BuildContext context) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      developer.log('🔄 Starting to fetch meeting food requirements', 
          name: 'MeetingFoodProvider');

      // Get auth token
      final token = await SharedUtils.getString('auth_token');
      if (token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      // Calculate date range (current implementation uses wide range as in your example)
      final startDate = '2024-03-01';
      final endDate = '2026-03-31';
      
      final url = '${ApiUrls.baseUrl}/mess-staff/meeting-food-requirements?startDate=$startDate&endDate=$endDate';
      
      developer.log('📡 Making request to: $url', name: 'MeetingFoodProvider');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      developer.log('📥 Response status: ${response.statusCode}', 
          name: 'MeetingFoodProvider');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        developer.log('📦 Response data received', name: 'MeetingFoodProvider');

        _meetingFoodData = MeetingFoodModel.fromJson(jsonData);
        _isLoading = false;

        developer.log('✅ Meeting food requirements loaded successfully', 
            name: 'MeetingFoodProvider');
        developer.log('📊 Overall totals: ${_meetingFoodData?.overallTotals.totalCount} total meals', 
            name: 'MeetingFoodProvider');
        developer.log('📅 Daily requirements loaded for ${_meetingFoodData?.dailyRequirements.length} dates', 
            name: 'MeetingFoodProvider');

        notifyListeners();
      } else if (response.statusCode == 401) {
        _isLoading = false;
        _errorMessage = 'Authentication error. Please login again.';
        developer.log('❌ Authentication error (401)', name: 'MeetingFoodProvider');
        notifyListeners();
      } else {
        _isLoading = false;
        _errorMessage = 'Failed to load meeting food requirements. Status: ${response.statusCode}';
        developer.log('❌ HTTP error: ${response.statusCode}', name: 'MeetingFoodProvider');
        notifyListeners();
      }
    } on http.ClientException catch (e) {
      _isLoading = false;
      _errorMessage = 'Network connection failed. Please check your internet connection.';
      developer.log('❌ Network error: $e', name: 'MeetingFoodProvider');
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load meeting food requirements: ${e.toString()}';
      developer.log('❌ Error fetching meeting food requirements: $e', 
          name: 'MeetingFoodProvider');
      notifyListeners();
    }
  }

  // Get meetings for a specific date
  List<Meeting> getMeetingsForDate(DateTime date) {
    if (_meetingFoodData == null) return [];
    
    final dateKey = date.toIso8601String().split('T')[0];
    final dailyReq = _meetingFoodData!.dailyRequirements[dateKey];
    return dailyReq?.meetings ?? [];
  }

  // Get total food counts for a specific date
  OverallTotals? getTotalCountsForDate(DateTime date) {
    if (_meetingFoodData == null) return null;
    
    final dateKey = date.toIso8601String().split('T')[0];
    final dailyReq = _meetingFoodData!.dailyRequirements[dateKey];
    return dailyReq?.totalCounts;
  }

  // Get all dates that have meetings
  List<DateTime> get availableDates {
    if (_meetingFoodData == null) return [];
    
    return _meetingFoodData!.dailyRequirements.keys
        .map((dateString) => DateTime.parse(dateString))
        .toList()
      ..sort();
  }

  // Check if a date has meetings
  bool hasDataForDate(DateTime date) {
    if (_meetingFoodData == null) return false;
    
    final dateKey = date.toIso8601String().split('T')[0];
    return _meetingFoodData!.dailyRequirements.containsKey(dateKey);
  }

  // Get summary string for selected date
  String getSelectedDateSummary() {
    final totals = selectedDateTotals;
    if (totals == null) return 'No data available';
    
    final activeFoods = totals.activeFoodItems;
    if (activeFoods.isEmpty) return 'No food requirements';
    
    return activeFoods.map((food) => '${food.name}: ${food.count}').join(', ');
  }

  // Reset provider state
  void reset() {
    _meetingFoodData = null;
    _isLoading = false;
    _errorMessage = '';
    _selectedDate = DateTime.now();
    developer.log('🔄 Meeting food provider reset', name: 'MeetingFoodProvider');
    notifyListeners();
  }

  // Clear data (for logout)
  Future<void> clearData() async {
    reset();
    developer.log('🧹 Meeting food provider data cleared', name: 'MeetingFoodProvider');
  }

  // Get formatted data for PDF generation
  Map<String, dynamic> getFormattedDataForPdf() {
    if (_meetingFoodData == null || selectedDateRequirement == null) {
      return {};
    }

    final requirement = selectedDateRequirement!;
    final meetings = requirement.meetings;
    final totals = requirement.totalCounts;

    return {
      'date': _selectedDate.toIso8601String().split('T')[0],
      'totalCounts': totals.toJson(),
      'activeFoodItems': totals.activeFoodItems.where((item) => item.count > 0).toList(),
      'meetings': meetings.map((meeting) => {
        'title': meeting.title,
        'department': meeting.department,
        'createdBy': meeting.createdBy,
        'timeRange': meeting.timeRange,
        'hall': meeting.hall,
        'noOfPersons': meeting.noOfPersons,
        'foodCounts': meeting.foodCounts.activeFoodItems,
      }).toList(),
      'totalMeetings': meetings.length,
      'grandTotal': totals.totalCount,
    };
  }
}