import 'package:hira_plus/constants/color_class.dart';
import 'package:hira_plus/constants/textstyle_class.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hira_plus/screens/user_screens/user_home_screen/provider/canteen_home_page_provider.dart';
import '../widgets/month_calendar_view.dart';
import '../widgets/home_list_view.dart';
import '../widgets/today_fab.dart';
import 'dart:developer';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final ScrollController _scrollController = ScrollController();
  CanteenHomeProvider? _viewModeProvider;
  VoidCallback? _viewModeListener;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final canteenProvider =
          Provider.of<CanteenHomeProvider>(context, listen: false);
      _scrollToToday(canteenProvider);
      _setupViewModeListener();

      // Fetch meals when the screen loads
      log('🔄 Initializing meal data on home screen');
      final mealProvider = Provider.of<CanteenHomeProvider>(context, listen: false);
      mealProvider.fetchUserMeals(context);
    });
  }

  void _setupViewModeListener() {
    _viewModeProvider =
        Provider.of<CanteenHomeProvider>(context, listen: false);
    _viewModeListener = () {
      if (_viewModeProvider!.mode == HomeViewMode.list) {
        final canteenProvider =
            Provider.of<CanteenHomeProvider>(context, listen: false);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToToday(canteenProvider);
        });
      }
    };
    _viewModeProvider?.addListener(_viewModeListener!);
  }

  @override
  void dispose() {
    _viewModeProvider?.removeListener(_viewModeListener!);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final canteenProvider =
          Provider.of<CanteenHomeProvider>(context, listen: false);
      _scrollToToday(canteenProvider);
    });
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  void _scrollToToday(CanteenHomeProvider canteenProvider) {
    final todayIndex = canteenProvider.getTodayIndex();
    if (todayIndex != -1) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          todayIndex * 80.0, // Approximate item height
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        // Try again after a short delay if not attached yet
        Future.delayed(const Duration(milliseconds: 100), () {
          _scrollToToday(canteenProvider);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canteenProvider = Provider.of<CanteenHomeProvider>(context);
    final viewModeProvider = Provider.of<CanteenHomeProvider>(context);
    // Adding meal provider consumer here just for reactivity
    final mealProvider = Provider.of<CanteenHomeProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorClass.brandDarkGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Canteen App',
          style: TextStyleClass.poppinsSemiBold(
            fontSize: 20,
            color: ColorClass.white,
          ),
        ),
        actions: [
          if (mealProvider.isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
          TextButton.icon(
            onPressed: () {
              viewModeProvider.toggleMode();
            },
            icon: const Icon(Icons.calendar_month, color: Colors.white),
            label: Text(
              '${_getMonthName(canteenProvider.selectedDate.month)} ${canteenProvider.selectedDate.year}',
              style: TextStyleClass.poppinsRegular(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: viewModeProvider.mode == HomeViewMode.list
          ? HomeListView(
              scrollController: _scrollController,
              getMonthName: _getMonthName,
              getDayName: _getDayName,
            )
          : MonthCalendarView(
              selectedDate: canteenProvider.selectedDate,
              getMonthName: _getMonthName,
              onMonthChanged: (int delta) {
                final currentYear = DateTime.now().year;
                final currentMonth = canteenProvider.selectedDate.month;
                final newMonth = currentMonth + delta;
                final newYear =
                    canteenProvider.selectedDate.year + ((newMonth - 1) ~/ 12);
                final normalizedMonth = ((newMonth - 1) % 12) + 1;
                // Only allow months within the current year
                if (newYear == currentYear &&
                    normalizedMonth >= 1 &&
                    normalizedMonth <= 12) {
                  final newDate = DateTime(newYear, normalizedMonth, 1);
                  canteenProvider.setSelectedDate(newDate, context);
                }
              },
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (mealProvider.errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: FloatingActionButton(
                heroTag: 'refreshBtn',
                backgroundColor: Colors.orange,
                onPressed: () {
                  mealProvider.fetchUserMeals(context);
                },
                child: const Icon(Icons.refresh),
              ),
            ),
          if (viewModeProvider.mode == HomeViewMode.list)
            TodayFAB(
              onPressed: () {
                canteenProvider.goToToday(context);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToToday(canteenProvider);
                });
              },
            ),
        ],
      ),
    );
  }
}
