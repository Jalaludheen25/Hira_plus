import 'package:flutter/material.dart';

class ProfileScreenProvider extends ChangeNotifier {
  String _userName = '';
  String _phone = '';
  String _userType = '';

  String get userName {
    if (_userType == 'manager') {
      return 'Manager';
    } else if (_userType == 'mess_staff') {
      return 'Mess Staff';
    } else {
      return _userName;
    }
  }

  String get phone => _phone;
  String get userType => _userType;

  void setUserInfo({required String userType, String userName = '', String phone = ''}) {
    _userType = userType;
    _userName = userName;
    _phone = phone;
    notifyListeners();
  }

  set phone(String value) {
    if (_phone != value) {
      _phone = value;
      notifyListeners();
    }
  }
} 