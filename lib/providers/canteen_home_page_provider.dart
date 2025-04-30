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
    final prevMonth = DateTime(now.year, now.month - 1, 1);
    final nextMonth = DateTime(now.year, now.month + 2, 0); // Last day of next month
    allDays = [];
    DateTime currentDate = prevMonth;
    while (currentDate.isBefore(nextMonth) || currentDate.isAtSameMomentAs(nextMonth)) {
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

  int getTodayIndex() {
    final now = DateTime.now();
    return allDays.indexWhere((date) =>
      date.day == now.day && date.month == now.month && date.year == now.year);
  }
} 