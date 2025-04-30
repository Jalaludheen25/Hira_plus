import 'package:canteen_app/constants/color_class.dart';
import 'package:canteen_app/constants/textstyle_class.dart';
import 'package:canteen_app/providers/date_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:canteen_app/providers/home_view_mode_provider.dart';
import 'package:canteen_app/providers/canteen_home_page_provider.dart';
import 'widgets/month_calendar_view.dart';
import 'widgets/home_list_view.dart';
import 'widgets/today_fab.dart';

class CanteenHomePage extends StatefulWidget {
  const CanteenHomePage({super.key});

  @override
  State<CanteenHomePage> createState() => _CanteenHomePageState();
}

class _CanteenHomePageState extends State<CanteenHomePage> {
  final ScrollController _scrollController = ScrollController();
  HomeViewModeProvider? _viewModeProvider;
  VoidCallback? _viewModeListener;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final canteenProvider = Provider.of<CanteenHomePageProvider>(context, listen: false);
      _scrollToToday(canteenProvider);
      _setupViewModeListener();
    });
  }

  void _setupViewModeListener() {
    _viewModeProvider = Provider.of<HomeViewModeProvider>(context, listen: false);
    _viewModeListener = () {
      if (_viewModeProvider!.mode == HomeViewMode.list) {
        final canteenProvider = Provider.of<CanteenHomePageProvider>(context, listen: false);
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
      final canteenProvider = Provider.of<CanteenHomePageProvider>(context, listen: false);
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

  void _scrollToToday(CanteenHomePageProvider canteenProvider) {
    final todayIndex = canteenProvider.getTodayIndex();
    if (todayIndex != -1) {
      _scrollController.animateTo(
        todayIndex * 80.0, // Approximate item height
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canteenProvider = Provider.of<CanteenHomePageProvider>(context);
    final viewModeProvider = Provider.of<HomeViewModeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorClass.primaryBase,
        title: Text(
          'Canteen App',
          style: TextStyleClass.poppinsSemiBold(
            fontSize: 20,
            color: ColorClass.white,
          ),
        ),
        actions: [
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
            ),
      floatingActionButton: viewModeProvider.mode == HomeViewMode.list
          ? TodayFAB(
              onPressed: () {
                canteenProvider.goToToday(context);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToToday(canteenProvider);
                });
              },
            )
          : null,
    );
  }
}

// Month view widget (inline, adapted from MonthScreen)
class _MonthViewWidget extends StatelessWidget {
  final DateTime selectedDate;
  final String Function(int) getMonthName;
  const _MonthViewWidget({required this.selectedDate, required this.getMonthName});

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final lastDayOfMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final totalDays = lastDayOfMonth.day;
    final totalWeeks = ((firstWeekday + totalDays) / 7).ceil();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: ColorClass.primaryBase.withOpacity(0.1),
              ),
            ),
          ),
          child: Row(
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                .map((day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyleClass.poppinsMedium(
                            fontSize: 16,
                            color: ColorClass.neutral400,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: totalWeeks * 7,
            itemBuilder: (context, index) {
              final dayOffset = index - firstWeekday;
              final currentDate = firstDayOfMonth.add(Duration(days: dayOffset));
              final isCurrentMonth = currentDate.month == selectedDate.month;
              final isToday = currentDate.day == DateTime.now().day &&
                  currentDate.month == DateTime.now().month &&
                  currentDate.year == DateTime.now().year;
              if (!isCurrentMonth) {
                return const SizedBox();
              }
              final dateKey = _getDateKey(currentDate);
              Provider.of<DateProvider>(context, listen: false).initializeDate(dateKey);
              return Container(
                margin: const EdgeInsets.all(2),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isToday ? ColorClass.primaryBase : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isToday ? ColorClass.primaryBase : ColorClass.neutral200,
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        currentDate.day.toString(),
                        style: TextStyleClass.poppinsMedium(
                          fontSize: 16,
                          color: isToday
                              ? Colors.white
                              : currentDate.weekday == DateTime.sunday
                                  ? Colors.red
                                  : ColorClass.textMain900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Consumer<DateProvider>(
                        builder: (context, dateProvider, child) {
                          return FittedBox(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildMealIndicator('B', dateProvider.isMealSelected(dateKey, 'Breakfast'), isToday),
                                _buildMealIndicator('L', dateProvider.isMealSelected(dateKey, 'Lunch'), isToday),
                                _buildMealIndicator('D', dateProvider.isMealSelected(dateKey, 'Dinner'), isToday),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMealIndicator(String label, bool isSelected, bool isToday) {
    final bool isTodayAndSelected = isToday && isSelected;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: isTodayAndSelected
            ? Colors.white
            : isSelected
                ? ColorClass.primaryBase
                : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: isTodayAndSelected
              ? ColorClass.primaryBase
              : isSelected
                  ? ColorClass.primaryBase
                  : ColorClass.neutral300,
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyleClass.poppinsBold(
            fontSize: 16,
            color: isTodayAndSelected
                ? ColorClass.primaryBase
                : isSelected
                    ? Colors.white
                    : ColorClass.neutral400,
          ),
        ),
      ),
    );
  }
}
