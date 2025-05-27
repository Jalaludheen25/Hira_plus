import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class BottomNavProvider extends ChangeNotifier {
  int _selectedIndex = 0;
  DateTime? _lastBackPressed;

  int get selectedIndex => _selectedIndex;

  void setIndex(int index) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners();
    }
  }

  bool shouldExitOnBack(BuildContext context) {
    if (_lastBackPressed == null || DateTime.now().difference(_lastBackPressed!) > Duration(seconds: 2)) {
      _lastBackPressed = DateTime.now();
      toastification.show(
        context: context,
        title: Text('Back again to exit'),
        type: ToastificationType.info,
        autoCloseDuration: Duration(seconds: 2),
      );
      return false;
    }
    return true;
  }
} 