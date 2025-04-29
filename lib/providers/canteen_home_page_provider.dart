import 'package:flutter/material.dart';
import 'package:canteen_app/providers/date_provider.dart';

class CanteenHomePageProvider extends ChangeNotifier {
  DateTime selectedDate = DateTime.now();
  List<DateTime> allDays = [];
  int currentYear = DateTime.now().year;
  bool isLoadingNextYear = false;

  CanteenHomePageProvider(BuildContext context) {
    _updateAllDays(context);
  }


  void _updateAllDays(BuildContext? context) {
    final now = DateTime.now();
    final startDate = DateTime(now.year, 1, 1);
    final endDate = DateTime(now.year + 2, 1, 0);
    allDays = [];
    DateTime currentDate = startDate;
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      allDays.add(currentDate);
      currentDate = currentDate.add(const Duration(days: 1));
    }
    final dateProvider = DateProvider();
    for (var date in allDays) {
      final dateKey = '${date.year}-${date.month}-${date.day}';
      dateProvider.initializeDate(dateKey);
    }
    notifyListeners();
  }

  void setSelectedDate(DateTime date, BuildContext context) {
    selectedDate = date;
    notifyListeners();
  }

  void goToToday(BuildContext context) {
    selectedDate = DateTime.now();
    _updateAllDays(context);
    notifyListeners();
  }
} 