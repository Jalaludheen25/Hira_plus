import 'package:flutter/material.dart';
import 'package:hira_plus/screens/reception_screen/models/reception_user_model.dart';
import 'package:hira_plus/screens/reception_screen/service/reception_service.dart';
import 'package:toastification/toastification.dart';
import 'package:intl/intl.dart';
import 'dart:developer';

class ReceptionProvider extends ChangeNotifier {
  final ReceptionService _receptionService = ReceptionService();

  List<ReceptionUser> _users = [];
  bool _isLoading = false;
  String _error = '';
  DateTime _selectedDate = DateTime.now();

  // API data storage
  CheckInsResponse _todayCheckInsResponse = CheckInsResponse(
      total: 0,
      checkIns: [],
      summary:
          AttendanceSummary(todayCheckIns: 0, previousDaysStillCheckedIn: 0));

  DateTime? _lastBackPressed;

  // Attendance by date state
  List<ReceptionAttendance> _attendanceByDate = [];
  bool _isAttendanceLoading = false;
  String _attendanceError = '';
  DateTime _attendanceSelectedDate = DateTime.now();

  // Tab index state for ReceptionScreen
  int _tabIndex = 0;
  int get tabIndex => _tabIndex;
  void setTabIndex(int index) {
    if (_tabIndex != index) {
      _tabIndex = index;
      notifyListeners();
    }
  }

  List<ReceptionUser> get users => _users;
  bool get isLoading => _isLoading;
  String get error => _error;
  DateTime get selectedDate => _selectedDate;
  String get selectedDateString =>
      DateFormat('yyyy-MM-dd').format(_selectedDate);

  CheckInsResponse get todayCheckInsResponse => _todayCheckInsResponse;
  List<ReceptionAttendance> get todayCheckIns =>
      _todayCheckInsResponse.checkIns;

  // Check if a user is checked in based on API data
  bool isCheckedIn(String userId) {
    return _todayCheckInsResponse.checkIns
        .any((checkIn) => checkIn.user.id == userId);
  }

  // Check if a user is checked out based on API data
  bool isCheckedOut(String userId) {
    final userAttendance = _todayCheckInsResponse.checkIns
        .where((checkIn) => checkIn.user.id == userId);

    if (userAttendance.isNotEmpty) {
      return userAttendance.first.checkoutTime != null;
    }
    return false;
  }

  List<ReceptionAttendance> get attendanceByDate => _attendanceByDate;
  bool get isAttendanceLoading => _isAttendanceLoading;
  String get attendanceError => _attendanceError;
  DateTime get attendanceSelectedDate => _attendanceSelectedDate;
  String get attendanceSelectedDateString =>
      DateFormat('yyyy-MM-dd').format(_attendanceSelectedDate);

  // Initialize provider and load data from API
  Future<void> initialize(BuildContext context) async {
    // Load today's check-ins by default
    await fetchTodayCheckIns(context);
    // Load attendance by date
    await fetchAttendanceByDate(context);
  }

  // Back button handling method
  bool shouldExitOnBack(BuildContext context) {
    if (_lastBackPressed == null ||
        DateTime.now().difference(_lastBackPressed!) > Duration(seconds: 2)) {
      _lastBackPressed = DateTime.now();
      toastification.show(
        context: context,
        title: Text('Press back again to exit'),
        type: ToastificationType.info,
        autoCloseDuration: Duration(seconds: 2),
      );
      return false;
    }
    return true;
  }

  // Method to set selected date
  void setSelectedDate(DateTime date) {
    if (_selectedDate != date) {
      _selectedDate = date;
      notifyListeners();
    }
  }

  // Fetch all users with better error handling
  Future<void> fetchUsers(BuildContext context) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      log('🔄 Starting to fetch reception users');
      final users = await _receptionService.getAllUsers(context);

      _users = users;
      _isLoading = false;

      if (users.isNotEmpty) {
        log('✅ Successfully fetched ${_users.length} users');
        _error = '';
      } else {
        log('⚠️ No users found');
        _error = 'No users found';
      }

      notifyListeners();
    } catch (e) {
      log('❌ Error fetching users: $e');
      _error = 'Unable to load users at the moment';
      _isLoading = false;
      notifyListeners();

      if (context.mounted) {
        toastification.show(
          context: context,
          title: Text('Connection issue'),
          description: Text('Failed to load users'),
          type: ToastificationType.warning,
          autoCloseDuration: Duration(seconds: 3),
        );
      }
    }
  }

  // Fetch today's check-ins from API
  Future<void> fetchTodayCheckIns(BuildContext context) async {
    try {
      log('🔄 Fetching today\'s check-ins');

      final checkInsResponse =
          await _receptionService.getTodayCheckIns(context);
      _todayCheckInsResponse = checkInsResponse;

      log('✅ Fetched ${checkInsResponse.checkIns.length} check-ins');
      log('📊 Summary: ${checkInsResponse.summary.todayCheckIns} today, ${checkInsResponse.summary.previousDaysStillCheckedIn} from previous days');

      notifyListeners();
    } catch (e) {
      log('❌ Error fetching today\'s check-ins: $e');
      // Keep the current data if available
      if (_todayCheckInsResponse.checkIns.isEmpty) {
        _todayCheckInsResponse = CheckInsResponse(
          total: 0,
          checkIns: [],
          summary: AttendanceSummary(
            todayCheckIns: 0,
            previousDaysStillCheckedIn: 0,
          ),
        );
      }
      notifyListeners();
    }
  }

  // Check in user using API
  Future<void> checkIn(BuildContext context, String userId) async {
    try {
      log('📝 Attempting to check in user: $userId');

      // Call API first, only update UI if successful
      final success = await _receptionService.checkInUser(context, userId);

      if (success) {
        // Refresh check-ins data after successful check-in
        await fetchTodayCheckIns(context);

        // Show success message
        if (context.mounted) {
          final user = _users.firstWhere((u) => u.id == userId,
              orElse: () => ReceptionUser(
                  id: '', name: 'User', department: '', designation: ''));

          toastification.show(
            context: context,
            title: Text('${user.name} checked in'),
            type: ToastificationType.success,
            autoCloseDuration: Duration(seconds: 2),
          );
        }
      } else {
        throw Exception('Check-in failed');
      }
    } catch (e) {
      log('❌ Error checking in user: $e');

      if (context.mounted) {
        toastification.show(
          context: context,
          title: Text('Check-in failed'),
          description: Text('Please try again'),
          type: ToastificationType.error,
          autoCloseDuration: Duration(seconds: 3),
        );
      }
    }
  }

  // Check out user using API
  Future<void> checkOut(BuildContext context, String userId) async {
    try {
      log('📤 Attempting to check out user: $userId');

      // Call API first, only update UI if successful
      final success = await _receptionService.checkOutUser(context, userId);

      if (success) {
        // Refresh check-ins data after successful check-out
        await fetchTodayCheckIns(context);

        // Show success message
        if (context.mounted) {
          final user = _users.firstWhere((u) => u.id == userId,
              orElse: () => ReceptionUser(
                  id: '', name: 'User', department: '', designation: ''));

          toastification.show(
            context: context,
            title: Text('${user.name} checked out'),
            type: ToastificationType.success,
            autoCloseDuration: Duration(seconds: 2),
          );
        }
      } else {
        throw Exception('Check-out failed');
      }
    } catch (e) {
      log('❌ Error checking out user: $e');

      if (context.mounted) {
        toastification.show(
          context: context,
          title: Text('Check-out failed'),
          description: Text('Please try again'),
          type: ToastificationType.error,
          autoCloseDuration: Duration(seconds: 3),
        );
      }
    }
  }

  // Set selected date for attendance
  void setAttendanceSelectedDate(DateTime date, BuildContext context) {
    if (_attendanceSelectedDate != date) {
      _attendanceSelectedDate = date;
      fetchAttendanceByDate(context);
      notifyListeners();
    }
  }

  // Fetch attendance by date
  Future<void> fetchAttendanceByDate(BuildContext context) async {
    _isAttendanceLoading = true;
    _attendanceError = '';
    notifyListeners();
    try {
      final now = DateTime.now();
      final isToday = _attendanceSelectedDate.year == now.year &&
          _attendanceSelectedDate.month == now.month &&
          _attendanceSelectedDate.day == now.day;

      if (isToday) {
        // If today, use the check-ins data we already have
        _attendanceByDate = _todayCheckInsResponse.checkIns;
      } else {
        // For other dates, fetch from API
        final dateStr =
            DateFormat('yyyy-MM-dd').format(_attendanceSelectedDate);
        final data =
            await _receptionService.getAttendanceByDate(context, dateStr);
        _attendanceByDate = data;
      }

      log('Fetched attendance for date ${DateFormat('yyyy-MM-dd').format(_attendanceSelectedDate)}: count = ${_attendanceByDate.length}');
      _isAttendanceLoading = false;
      _attendanceError = '';
      notifyListeners();
    } catch (e) {
      _attendanceByDate = [];
      _isAttendanceLoading = false;
      _attendanceError = 'Unable to load attendance for selected date.';
      notifyListeners();
    }
  }

  void reset() {
    _users = [];
    _isLoading = false;
    _error = '';
    _selectedDate = DateTime.now();
    _lastBackPressed = null;
    _todayCheckInsResponse = CheckInsResponse(
      total: 0,
      checkIns: [],
      summary: AttendanceSummary(
        todayCheckIns: 0,
        previousDaysStillCheckedIn: 0,
      ),
    );
    _attendanceByDate = [];
    _isAttendanceLoading = false;
    _attendanceError = '';
    _attendanceSelectedDate = DateTime.now();
    notifyListeners();
  }
}
