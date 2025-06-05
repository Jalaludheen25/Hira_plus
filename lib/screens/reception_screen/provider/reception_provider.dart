import 'package:flutter/material.dart';
import 'package:hira_plus/screens/reception_screen/models/reception_user_model.dart';
import 'package:hira_plus/screens/reception_screen/service/reception_service.dart';
import 'package:hira_plus/utils/shared_utils.dart';
import 'package:toastification/toastification.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:developer';

class ReceptionProvider extends ChangeNotifier {
  final ReceptionService _receptionService = ReceptionService();
  
  List<ReceptionUser> _users = [];
  bool _isLoading = false;
  String _error = '';
  DateTime _selectedDate = DateTime.now();
  
  // Persistent storage for check-in/out status
  final Map<String, bool> _checkInState = {};
  final Map<String, bool> _checkOutState = {};
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
  String get selectedDateString => DateFormat('yyyy-MM-dd').format(_selectedDate);
  
  bool isCheckedIn(String userId) => _checkInState[userId] ?? false;
  bool isCheckedOut(String userId) => _checkOutState[userId] ?? false;

  List<ReceptionAttendance> get attendanceByDate => _attendanceByDate;
  bool get isAttendanceLoading => _isAttendanceLoading;
  String get attendanceError => _attendanceError;
  DateTime get attendanceSelectedDate => _attendanceSelectedDate;
  String get attendanceSelectedDateString => DateFormat('yyyy-MM-dd').format(_attendanceSelectedDate);

  // Initialize provider and load saved states
  Future<void> initialize(BuildContext context) async {
    await _loadSavedStates();
    // Load today's attendance by default
    await fetchAttendanceByDate(context);
  }

  // Load saved check-in/out states from SharedPreferences
  Future<void> _loadSavedStates() async {
    try {
      final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      // Load check-in states
      final checkInJson = await SharedUtils.getString('checkin_$todayKey');
      if (checkInJson.isNotEmpty) {
        final checkInMap = Map<String, dynamic>.from(jsonDecode(checkInJson));
        _checkInState.clear();
        checkInMap.forEach((key, value) {
          _checkInState[key] = value as bool;
        });
        log('📥 Loaded ${_checkInState.length} check-in states');
      }

      // Load check-out states
      final checkOutJson = await SharedUtils.getString('checkout_$todayKey');
      if (checkOutJson.isNotEmpty) {
        final checkOutMap = Map<String, dynamic>.from(jsonDecode(checkOutJson));
        _checkOutState.clear();
        checkOutMap.forEach((key, value) {
          _checkOutState[key] = value as bool;
        });
        log('📥 Loaded ${_checkOutState.length} check-out states');
      }

      notifyListeners();
    } catch (e) {
      log('❌ Error loading saved states: $e');
    }
  }

  // Save check-in/out states to SharedPreferences
  Future<void> _saveStates() async {
    try {
      final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      // Save check-in states
      final checkInJson = jsonEncode(_checkInState);
      await SharedUtils.setString('checkin_$todayKey', checkInJson);
      
      // Save check-out states
      final checkOutJson = jsonEncode(_checkOutState);
      await SharedUtils.setString('checkout_$todayKey', checkOutJson);
      
      log('💾 Saved attendance states for $todayKey');
    } catch (e) {
      log('❌ Error saving states: $e');
    }
  }

  // Back button handling method
  bool shouldExitOnBack(BuildContext context) {
    if (_lastBackPressed == null || DateTime.now().difference(_lastBackPressed!) > Duration(seconds: 2)) {
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
      // Load states for the new selected date
      _loadSavedStatesForDate(date);
      notifyListeners();
    }
  }

  // Load saved states for a specific date
  Future<void> _loadSavedStatesForDate(DateTime date) async {
    try {
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      // Clear current states
      _checkInState.clear();
      _checkOutState.clear();

      // Load check-in states for this date
      final checkInJson = await SharedUtils.getString('checkin_$dateKey');
      if (checkInJson.isNotEmpty) {
        final checkInMap = Map<String, dynamic>.from(jsonDecode(checkInJson));
        checkInMap.forEach((key, value) {
          _checkInState[key] = value as bool;
        });
      }

      // Load check-out states for this date
      final checkOutJson = await SharedUtils.getString('checkout_$dateKey');
      if (checkOutJson.isNotEmpty) {
        final checkOutMap = Map<String, dynamic>.from(jsonDecode(checkOutJson));
        checkOutMap.forEach((key, value) {
          _checkOutState[key] = value as bool;
        });
      }

      // --- Persistent check-in until check-out logic ---
      // For each user, if not checked out on or before this date, check previous days for check-in
      for (final user in _users) {
        final userId = user.id;
        if (!(_checkInState[userId] ?? false) && !(_checkOutState[userId] ?? false)) {
          // Look back for check-in without check-out
          DateTime prevDate = date.subtract(const Duration(days: 1));
          while (prevDate.isAfter(DateTime(2020))) { // reasonable lower bound
            final prevKey = DateFormat('yyyy-MM-dd').format(prevDate);
            final prevCheckInJson = await SharedUtils.getString('checkin_$prevKey');
            final prevCheckOutJson = await SharedUtils.getString('checkout_$prevKey');
            bool prevCheckedIn = false;
            bool prevCheckedOut = false;
            if (prevCheckInJson.isNotEmpty) {
              final prevCheckInMap = Map<String, dynamic>.from(jsonDecode(prevCheckInJson));
              prevCheckedIn = prevCheckInMap[userId] == true;
            }
            if (prevCheckOutJson.isNotEmpty) {
              final prevCheckOutMap = Map<String, dynamic>.from(jsonDecode(prevCheckOutJson));
              prevCheckedOut = prevCheckOutMap[userId] == true;
            }
            if (prevCheckedIn && !prevCheckedOut) {
              _checkInState[userId] = true;
              break;
            } else if (prevCheckedOut) {
              break;
            }
            prevDate = prevDate.subtract(const Duration(days: 1));
          }
        }
      }
      // --- End persistent logic ---

      log('📅 Loaded attendance states for $dateKey (with persistent check-in logic)');
      notifyListeners();
    } catch (e) {
      log('❌ Error loading states for date: $e');
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
        
        // Load saved states after fetching users
        await _loadSavedStates();
      } else {
        log('⚠️ No users found');
        _error = '';
      }
      
      notifyListeners();
    } catch (e) {
      log('❌ Error fetching users: $e');
      
      // Don't show error if we have cached users
      if (_users.isNotEmpty) {
        _error = '';
        log('📂 Using cached users');
      } else {
        _error = 'Unable to load users at the moment';
      }
      
      _isLoading = false;
      notifyListeners();
      
      // Don't show error toast if we have cached data
      if (_users.isEmpty && context.mounted) {
        toastification.show(
          context: context,
          title: Text('Connection issue'),
          description: Text('Using offline data'),
          type: ToastificationType.warning,
          autoCloseDuration: Duration(seconds: 3),
        );
      }
    }
  }

  // Check in user with persistent storage
  Future<void> checkIn(BuildContext context, String userId) async {
    try {
      log('📝 Attempting to check in user: $userId');
      
      // Optimistically update UI first
      _checkInState[userId] = true;
      notifyListeners();
      await _saveStates();
      
      // Show success message immediately
      if (context.mounted) {
        final user = _users.firstWhere(
          (u) => u.id == userId, 
          orElse: () => ReceptionUser(id: '', name: 'User', department: '', designation: '')
        );
        
        toastification.show(
          context: context,
          title: Text('${user.name} checked in'),
          type: ToastificationType.success,
          autoCloseDuration: Duration(seconds: 2),
        );
      }
      
      // Try API call in background
      try {
        final success = await _receptionService.checkInUser(context, userId);
        if (!success) {
          log('⚠️ API check-in failed but keeping local state');
        }
      } catch (e) {
        log('⚠️ Check-in API error (keeping local state): $e');
      }
      
    } catch (e) {
      log('❌ Error checking in user: $e');
      // Revert state on error
      _checkInState[userId] = false;
      notifyListeners();
      await _saveStates();
      
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

  // Check out user with persistent storage
  Future<void> checkOut(BuildContext context, String userId) async {
    try {
      log('📤 Attempting to check out user: $userId');
      
      // Optimistically update UI first
      _checkOutState[userId] = true;
      notifyListeners();
      await _saveStates();
      
      // Show success message immediately
      if (context.mounted) {
        final user = _users.firstWhere(
          (u) => u.id == userId, 
          orElse: () => ReceptionUser(id: '', name: 'User', department: '', designation: '')
        );
        
        toastification.show(
          context: context,
          title: Text('${user.name} checked out'),
          type: ToastificationType.success,
          autoCloseDuration: Duration(seconds: 2),
        );
      }
      
      // Try API call in background
      try {
        final success = await _receptionService.checkOutUser(context, userId);
        if (!success) {
          log('⚠️ API check-out failed but keeping local state');
        }
      } catch (e) {
        log('⚠️ Check-out API error (keeping local state): $e');
      }
      
    } catch (e) {
      log('❌ Error checking out user: $e');
      // Revert state on error
      _checkOutState[userId] = false;
      notifyListeners();
      await _saveStates();
      
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
        // Fetch today's check-ins and check-outs, merge by user
        final checkIns = await _receptionService.getTodayCheckIns(context);
        final checkOuts = await _receptionService.getTodayCheckOuts(context);
        // Merge by user id
        final Map<String, ReceptionAttendance> merged = {};
        for (final checkIn in checkIns) {
          merged[checkIn.user.id] = checkIn;
        }
        for (final checkOut in checkOuts) {
          if (merged.containsKey(checkOut.user.id)) {
            // Update checkoutTime and status if already checked in
            merged[checkOut.user.id] = ReceptionAttendance(
              id: merged[checkOut.user.id]!.id,
              date: merged[checkOut.user.id]!.date,
              user: merged[checkOut.user.id]!.user,
              checkedInTime: merged[checkOut.user.id]!.checkedInTime,
              checkoutTime: checkOut.checkoutTime,
              status: checkOut.status,
              createdAt: merged[checkOut.user.id]!.createdAt,
              updatedAt: checkOut.updatedAt,
              v: merged[checkOut.user.id]!.v,
            );
          } else {
            merged[checkOut.user.id] = checkOut;
          }
        }
        _attendanceByDate = merged.values.toList();
      } else {
        final dateStr = DateFormat('yyyy-MM-dd').format(_attendanceSelectedDate);
        final data = await _receptionService.getAttendanceByDate(context, dateStr);
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
    _checkInState.clear();
    _checkOutState.clear();
    _lastBackPressed = null;
    _attendanceByDate = [];
    _isAttendanceLoading = false;
    _attendanceError = '';
    _attendanceSelectedDate = DateTime.now();
    notifyListeners();
  }
}