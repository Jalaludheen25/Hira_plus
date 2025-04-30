import 'package:flutter/material.dart';

enum HomeViewMode { list, month }

class HomeViewModeProvider extends ChangeNotifier {
  HomeViewMode _mode = HomeViewMode.list;

  HomeViewMode get mode => _mode;

  void toggleMode() {
    _mode = _mode == HomeViewMode.list ? HomeViewMode.month : HomeViewMode.list;
    notifyListeners();
  }

  void setMode(HomeViewMode mode) {
    _mode = mode;
    notifyListeners();
  }
} 