import 'package:flutter/material.dart';
import 'package:hira_plus/constants/api_urls.dart';
import 'package:hira_plus/screens/manager_screen/models/department_model.dart';
import 'package:hira_plus/utils/service_utils.dart';

class DepartmentProvider extends ChangeNotifier {
  List<String> _departments = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedDepartment;

  List<String> get departments => _departments;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedDepartment => _selectedDepartment;

  Future<void> fetchDepartments(BuildContext context) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await HttpServiceUtils.fetchData(ApiUrls.getDepartments(), true);
      final model = DepartmentModel.fromJson(response);
      _departments = model.departments;
      if (_departments.isNotEmpty && _selectedDepartment == null) {
        _selectedDepartment = _departments[0];
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load departments.';
      notifyListeners();
    }
  }

  void selectDepartment(String department) {
    _selectedDepartment = department;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 