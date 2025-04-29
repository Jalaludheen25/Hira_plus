import 'package:flutter/material.dart';

class DateProvider extends ChangeNotifier {
  final Map<String, Map<String, bool>> _mealPreferences = {};

  Map<String, Map<String, bool>> get mealPreferences => _mealPreferences;

  void toggleMeal(String dateKey, String mealType) {
    _mealPreferences[dateKey] ??= {
      'Breakfast': false,
      'Lunch': false,
      'Dinner': false,
    };
    
    _mealPreferences[dateKey]![mealType] = !(_mealPreferences[dateKey]![mealType] ?? false);
    notifyListeners();
  }

  bool isMealSelected(String dateKey, String mealType) {
    return _mealPreferences[dateKey]?[mealType] ?? false;
  }

  void initializeDate(String dateKey) {
    _mealPreferences[dateKey] ??= {
      'Breakfast': false,
      'Lunch': false,
      'Dinner': false,
    };
  }
}