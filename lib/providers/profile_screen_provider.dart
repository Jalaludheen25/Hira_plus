import 'package:flutter/material.dart';

class ProfileScreenProvider extends ChangeNotifier {
  String _userName = 'John Doe';

  String get userName => _userName;

  set userName(String value) {
    if (_userName != value) {
      _userName = value;
      notifyListeners();
    }
  }
} 