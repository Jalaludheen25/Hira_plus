import 'package:canteen_app/constants/color_class.dart';
import 'package:canteen_app/constants/textstyle_class.dart';
import 'package:flutter/material.dart';

class CanteenHomePage extends StatefulWidget {
  const CanteenHomePage({super.key});

  @override
  State<CanteenHomePage> createState() => _CanteenHomePageState();
}

class _CanteenHomePageState extends State<CanteenHomePage> {
  late DateTime selectedDate;
  List<DateTime> allDays = [];
  final Map<String, Map<String, bool>> mealPreferences = {};
  final ScrollController _scrollController = ScrollController();
  int currentYear = DateTime.now().year;
  bool isLoadingNextYear = false;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    _updateAllDays();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentDay();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8 && 
        !isLoadingNextYear) {
      _loadNextYear();
    }
  }

  void _loadNextYear() {
    if (isLoadingNextYear) return;
    
    setState(() {
      isLoadingNextYear = true;
    });

    final nextYear = currentYear + 1;
    final startDate = DateTime(nextYear, 1, 1);
    final endDate = DateTime(nextYear + 1, 1, 0); // Last day of December next year
    
    final newDays = <DateTime>[];
    DateTime currentDate = startDate;
    
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      newDays.add(currentDate);
      currentDate = currentDate.add(const Duration(days: 1));
    }

    // Initialize preferences for new days
    for (var date in newDays) {
      final dateKey = '${date.year}-${date.month}-${date.day}';
      mealPreferences[dateKey] ??= {
        'Breakfast': false,
        'Lunch': false,
        'Dinner': false,
      };
    }

    setState(() {
      allDays.addAll(newDays);
      currentYear = nextYear;
      isLoadingNextYear = false;
    });
  }

  void _updateAllDays() {
    // Generate days for the current year and next year
    final now = DateTime.now();
    final startDate = DateTime(now.year, 1, 1); // Start from January 1st
    final endDate = DateTime(now.year + 2, 1, 0); // Last day of next year
    
    allDays = [];
    DateTime currentDate = startDate;
    
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      allDays.add(currentDate);
      currentDate = currentDate.add(const Duration(days: 1));
    }

    // Initialize preferences for all days
    for (var date in allDays) {
      final dateKey = '${date.year}-${date.month}-${date.day}';
      mealPreferences[dateKey] ??= {
        'Breakfast': false,
        'Lunch': false,
        'Dinner': false,
      };
    }
  }

  void _scrollToCurrentDay() {
    final now = DateTime.now();
    final currentDayIndex = allDays.indexWhere((date) =>
        date.day == now.day &&
        date.month == now.month &&
        date.year == now.year);

    if (currentDayIndex != -1) {
      // Scroll to the top of the current day
      final itemHeight = 80.0; // Approximate height of each date item
      final scrollPosition = currentDayIndex * itemHeight;

      _scrollController.animateTo(
        scrollPosition,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      // If today's date is not in the list, update the list to include it
      _updateAllDays();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCurrentDay();
      });
    }
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

  @override
  Widget build(BuildContext context) {
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
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2024),
                lastDate: DateTime(2025),
                initialDatePickerMode: DatePickerMode.day,
              );
              if (picked != null) {
                setState(() {
                  selectedDate = picked;
                  _scrollToCurrentDay();
                });
              }
            },
            icon: const Icon(Icons.calendar_month, color: Colors.white),
            label: Text(
              '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}',
              style: TextStyleClass.poppinsRegular(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: ColorClass.primaryBase.withOpacity(0.1),
                ),
              ),
            ),
            child: Row(
              children: [
                const Expanded(flex: 2, child: SizedBox()),
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['B', 'L', 'D']
                        .map((label) => Text(
                              label,
                              style: TextStyleClass.poppinsMedium(
                                fontSize: 14,
                                color: ColorClass.primaryBase,
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: allDays.length,
              itemBuilder: (context, index) {
                final date = allDays[index];
                final dateKey = '${date.year}-${date.month}-${date.day}';
                final isToday = date.day == DateTime.now().day &&
                    date.month == DateTime.now().month &&
                    date.year == DateTime.now().year;

                // Check if this is the first day of the month
                final bool isFirstDayOfMonth = date.day == 1;

                return Column(
                  children: [
                    if (isFirstDayOfMonth)
                      Container(
                        padding: const EdgeInsets.all(8),
                        color: ColorClass.primaryBase.withOpacity(0.05),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Text(
                                '${_getMonthName(date.month)} ${date.year}',
                                style: TextStyleClass.poppinsMedium(
                                  fontSize: 16,
                                  color: ColorClass.primaryBase,
                                ),
                              ),
                            ),
                            if (isToday)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: ColorClass.primaryBase,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Today',
                                  style: TextStyleClass.poppinsMedium(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: ColorClass.primaryBase.withOpacity(0.1),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Date and day section
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                if (isToday)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: ColorClass.primaryBase,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      date.day.toString().padLeft(2, '0'),
                                      style: TextStyleClass.poppinsMedium(
                                        fontSize: 26,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                else
                                  Text(
                                    date.day.toString().padLeft(2, '0'),
                                    style: TextStyleClass.poppinsMedium(
                                      fontSize: 26,
                                      color: ColorClass.textMain900,
                                    ),
                                  ),
                                Text(
                                  ' ${_getDayName(date.weekday)}',
                                  style: TextStyleClass.poppinsMedium(
                                    fontSize: 14,
                                    color: ColorClass.neutral400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Checkboxes section
                          Expanded(
                            flex: 3,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Checkbox(
                                  value: mealPreferences[dateKey]!['Breakfast'],
                                  onChanged: (value) {
                                    setState(() {
                                      mealPreferences[dateKey]!['Breakfast'] = value!;
                                    });
                                  },
                                  activeColor: ColorClass.primaryBase,
                                ),
                                Checkbox(
                                  value: mealPreferences[dateKey]!['Lunch'],
                                  onChanged: (value) {
                                    setState(() {
                                      mealPreferences[dateKey]!['Lunch'] = value!;
                                    });
                                  },
                                  activeColor: ColorClass.primaryBase,
                                ),
                                Checkbox(
                                  value: mealPreferences[dateKey]!['Dinner'],
                                  onChanged: (value) {
                                    setState(() {
                                      mealPreferences[dateKey]!['Dinner'] = value!;
                                    });
                                  },
                                  activeColor: ColorClass.primaryBase,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            selectedDate = DateTime.now();
            _updateAllDays();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToCurrentDay();
            });
          });
        },
        label: Text(
          'Today',
          style: TextStyleClass.poppinsRegular(
            fontSize: 14,
            color: ColorClass.white,
          ),
        ),
        backgroundColor: ColorClass.primaryBase,
      ),
    );
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
}
