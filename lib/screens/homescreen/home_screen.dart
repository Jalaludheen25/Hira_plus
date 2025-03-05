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
  late DateTime firstDayOfMonth;
  late List<DateTime> daysInMonth;
  final Map<String, Map<String, bool>> mealPreferences = {};
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    _updateMonthDays();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentWeek();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _updateMonthDays() {
    firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    // Generate days for current month and next month
    daysInMonth = [
      ...List.generate(
        DateTime(selectedDate.year, selectedDate.month + 1, 0).day,
        (index) => DateTime(selectedDate.year, selectedDate.month, index + 1),
      ),
      ...List.generate(
        DateTime(selectedDate.year, selectedDate.month + 2, 0).day,
        (index) => DateTime(selectedDate.year, selectedDate.month + 1, index + 1),
      ),
    ];
    
    // Initialize preferences for all days
    for (var date in daysInMonth) {
      final dateKey = '${date.year}-${date.month}-${date.day}';
      mealPreferences[dateKey] ??= {
        'Breakfast': false,
        'Lunch': false,
        'Dinner': false,
      };
    }
  }

  bool isCurrentWeek(DateTime date) {
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6));
    return date.isAfter(firstDayOfWeek.subtract(const Duration(days: 1))) &&
        date.isBefore(lastDayOfWeek.add(const Duration(days: 1)));
  }

  void _scrollToCurrentWeek() {
    final now = DateTime.now();
    final currentDayIndex = daysInMonth.indexWhere((date) => 
      date.day == now.day && date.month == now.month && date.year == now.year
    );
    
    if (currentDayIndex != -1) {
      final screenHeight = MediaQuery.of(context).size.height;
      final scrollPosition = (currentDayIndex * 110.0) - (screenHeight / 3);
      
      _scrollController.animateTo(
        scrollPosition,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
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
                  _updateMonthDays();
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
                    children: ['B', 'L', 'D'].map((label) => Text(
                      label,
                      style: TextStyleClass.poppinsMedium(
                        fontSize: 14,
                        color: ColorClass.primaryBase,
                      ),
                    )).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: daysInMonth.length,
              itemBuilder: (context, index) {
                final date = daysInMonth[index];
                final dateKey = '${date.year}-${date.month}-${date.day}';
                final isToday = date.day == DateTime.now().day &&
                    date.month == DateTime.now().month &&
                    date.year == DateTime.now().year;

                final bool isFirstDayOfMonth = date.day == 1;
                final Widget monthHeader = isFirstDayOfMonth
                    ? Container(
                        padding: const EdgeInsets.all(8),
                        color: ColorClass.primaryBase.withOpacity(0.05),
                        child: Text(
                          '${_getMonthName(date.month)} ${date.year}',
                          style: TextStyleClass.poppinsMedium(
                            fontSize: 16,
                            color: ColorClass.primaryBase,
                          ),
                        ),
                      )
                    : Container();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    isFirstDayOfMonth ? monthHeader : Container(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                            child: Row(
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
                                      '${date.day.toString().padLeft(2, '0')}',
                                      style: TextStyleClass.poppinsMedium(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                else
                                  Text(
                                    '${date.day.toString().padLeft(2, '0')}',
                                    style: TextStyleClass.poppinsMedium(
                                      fontSize: 16,
                                      color: ColorClass.textMain900,
                                    ),
                                  ),
                                Text(
                                  ' - ${_getDayName(date.weekday)}',
                                  style: TextStyleClass.poppinsMedium(
                                    fontSize: 16,
                                    color: ColorClass.textMain900,
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
        onPressed: _scrollToCurrentWeek,
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

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
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
}