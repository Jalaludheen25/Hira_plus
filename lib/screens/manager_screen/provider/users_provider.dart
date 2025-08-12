import 'package:flutter/material.dart';
import 'package:hira_plus/constants/api_urls.dart';
import 'package:hira_plus/constants/user_role_enum.dart';
import 'package:hira_plus/screens/manager_screen/models/users_list_model.dart';
import 'package:hira_plus/utils/service_utils.dart';

class UsersProvider extends ChangeNotifier {
  List<UsersListModel> _users = [];
  bool _isLoading = false;
  String? _error;
  bool tempIsVerified = false;
  String? _selectedDepartment;

  List<UsersListModel> get users => List.unmodifiable(_users);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedDepartment => _selectedDepartment;

  // Get total count of users
  int get totalUsersCount => _users.length;

  // Get unique departments from users
  List<String> get availableDepartments {
    final departments = _users
        .where((user) => user.department != null && user.department!.isNotEmpty)
        .map((user) => user.department!)
        .toSet()
        .toList();
    departments.sort(); // Sort departments alphabetically
    return departments;
  }

  // Get filtered and sorted users
  List<UsersListModel> get filteredUsers {
    var filtered = _selectedDepartment == null || _selectedDepartment == 'All'
        ? _users
        : _users
            .where((user) => user.department == _selectedDepartment)
            .toList();

    // Sort alphabetically by name
    filtered.sort((a, b) {
      final nameA = a.name ?? '';
      final nameB = b.name ?? '';
      return nameA.toLowerCase().compareTo(nameB.toLowerCase());
    });

    return filtered;
  }

  // Set selected department filter
  void setSelectedDepartment(String? department) {
    _selectedDepartment = department;
    notifyListeners();
  }

  Future<void> fetchUsers() async {
    debugPrint('[UsersProvider] fetchUsers called');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response =
          await HttpServiceUtils.fetchData(ApiUrls.getUsers(), true);
      debugPrint('[UsersProvider] fetchUsers response: $response');
      _users =
          (response as List).map((e) => UsersListModel.fromJson(e)).toList();
      _error = null;
      _isLoading = false;
      notifyListeners();
      debugPrint(
          '[UsersProvider] fetchUsers success, users count: ${_users.length}');

      debugPrint(
          '[UsersProvider] fetchUsers success, users count: ${_users.length}');
    } catch (e) {
      debugPrint('[UsersProvider] fetchUsers error: $e');
      // Do not set error, just keep loading
      notifyListeners();
    }
  }

  List<UsersListModel> searchUsers(String query) {
    debugPrint('[UsersProvider] searchUsers called with query: $query');
    final search = query.toLowerCase();
    var searchResults = filteredUsers
        .where((user) =>
            (user.name?.toLowerCase().contains(search) ?? false) ||
            (user.phoneNumber?.toLowerCase().contains(search) ?? false) ||
            (user.department?.toLowerCase().contains(search) ?? false) ||
            (user.designation?.toLowerCase().contains(search) ?? false) ||
            (user.role?.displayName.toLowerCase().contains(search) ?? false))
        .toList();

    // Keep alphabetical sorting for search results
    searchResults.sort((a, b) {
      final nameA = a.name ?? '';
      final nameB = b.name ?? '';
      return nameA.toLowerCase().compareTo(nameB.toLowerCase());
    });

    return searchResults;
  }

  Future<void> updateUser(
      String id,
      String name,
      String phoneNumber,
      String department,
      String designation,
      bool isVerified,
      bool isDeptHead,
      UserRole? role) async {
    debugPrint('[UsersProvider] updateUser called for id: $id');
    try {
      // Create data matching the backend API format exactly
      final data = {
        "phoneNumber": phoneNumber,
        "name": name,
        "department": department,
        "designation": designation,
        "role": role?.toApiString() ?? 'member',
        "isDeptHead": isDeptHead,
        "status": "active", // Required field
        "isFreeFood": false, // Required field
        "isIntern": false, // Required field
      };

      await HttpServiceUtils.putData('${ApiUrls.getUsers()}/$id', data, null);
      await fetchUsers(); // Refresh the list
      debugPrint('[UsersProvider] updateUser success');
    } catch (e) {
      debugPrint('[UsersProvider] updateUser error: $e');
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteUser(String id) async {
    debugPrint('[UsersProvider] deleteUser called for id: $id');
    try {
      await HttpServiceUtils.deleteData('${ApiUrls.getUsers()}/$id', null);
      await fetchUsers(); // Refresh the list
      debugPrint('[UsersProvider] deleteUser success');
    } catch (e) {
      debugPrint('[UsersProvider] deleteUser error: $e');
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addUser(
      String name,
      String phoneNumber,
      String department,
      String designation,
      bool isVerified,
      bool isDeptHead,
      UserRole? role) async {
    try {
      // Create data matching the backend API format exactly
      final data = {
        "phoneNumber": phoneNumber,
        "name": name,
        "department": department,
        "designation": designation,
        "role": role?.toApiString() ?? 'member',
        "isDeptHead": isDeptHead,
        "status": "active", // Required field
        "isFreeFood": false, // Required field
        "isIntern": false, // Required field
      };

      await HttpServiceUtils.postData(ApiUrls.getUsers(), data, null);
      await fetchUsers(); // Refresh the list
      debugPrint('[UsersProvider] addUser success');
    } catch (e) {
      debugPrint('[UsersProvider] addUser error: $e');
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void setTempIsVerified(bool value) {
    tempIsVerified = value;
    notifyListeners();
  }
}
