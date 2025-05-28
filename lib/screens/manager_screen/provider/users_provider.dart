import 'package:flutter/material.dart';
import 'package:hira_plus/constants/api_urls.dart';
import 'package:hira_plus/screens/manager_screen/models/users_list_model.dart';
import 'package:hira_plus/utils/service_utils.dart';


class UsersProvider extends ChangeNotifier {
  List<UsersListModel> _users = [];
  bool _isLoading = false;
  String? _error;
  bool tempIsVerified = false;

  List<UsersListModel> get users => List.unmodifiable(_users);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchUsers() async {
    debugPrint('[UsersProvider] fetchUsers called');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await HttpServiceUtils.fetchData(ApiUrls.getUsers(), true);
      debugPrint('[UsersProvider] fetchUsers response: $response');
      _users = (response as List).map((e) => UsersListModel.fromJson(e)).toList();
      _error = null;
      _isLoading = false;
      notifyListeners();
      debugPrint('[UsersProvider] fetchUsers success, users count: ${_users.length}');
    } catch (e) {
      debugPrint('[UsersProvider] fetchUsers error: $e');
      // Do not set error, just keep loading
      notifyListeners();
    }
  }

  List<UsersListModel> searchUsers(String query) {
    debugPrint('[UsersProvider] searchUsers called with query: $query');
    final search = query.toLowerCase();
    return _users.where((user) =>
      (user.name?.toLowerCase().contains(search) ?? false) ||
      (user.phoneNumber?.toLowerCase().contains(search) ?? false) ||
      (user.department?.toLowerCase().contains(search) ?? false) ||
      (user.designation?.toLowerCase().contains(search) ?? false)
    ).toList();
  }

  Future<void> updateUser(String id, String name, String phoneNumber, String department, String designation, bool isVerified, bool isDeptHead) async {
    debugPrint('[UsersProvider] updateUser called for id: $id');
    try {
      final data = {
        "name": name,
        "phoneNumber": phoneNumber,
        "department": department,
        "designation": designation,
        "isVerified": isVerified,
        "isDeptHead": isDeptHead
      };
      debugPrint('[UsersProvider] updateUser data: $data');
      debugPrint('Sending isVerified: $isVerified (${isVerified.runtimeType}), isDeptHead: $isDeptHead');
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

  Future<void> addUser(String name, String phoneNumber, String department, String designation, bool isVerified, bool isDeptHead) async {
    debugPrint('[UsersProvider] addUser called');
    try {
      final data = {
        "name": name,
        "phoneNumber": phoneNumber,
        "department": department,
        "designation": designation,
        "isVerified": isVerified,
        "isDeptHead": isDeptHead
      };
      debugPrint('[UsersProvider] addUser data: $data');
      debugPrint('Sending isVerified: $isVerified (${isVerified.runtimeType}), isDeptHead: $isDeptHead');
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