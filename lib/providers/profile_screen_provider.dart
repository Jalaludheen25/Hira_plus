import 'package:flutter/material.dart';

class ProfileScreenProvider extends ChangeNotifier {
  String _userName = 'John Doe';
  String _phone = '+1 234567890';

  String get userName => _userName;
  String get phone => _phone;

  set userName(String value) {
    if (_userName != value) {
      _userName = value;
      notifyListeners();
    }
  }

  set phone(String value) {
    if (_phone != value) {
      _phone = value;
      notifyListeners();
    }
  }
} 