import 'package:flutter/material.dart';

class MessStaffMealProvider extends ChangeNotifier {
  int _selectedMeal = 0; // 0: Breakfast, 1: Lunch, 2: Dinner

  int get selectedMeal => _selectedMeal;

  void selectMeal(int index) {
    if (_selectedMeal != index) {
      _selectedMeal = index;
      notifyListeners();
    }
  }
} 