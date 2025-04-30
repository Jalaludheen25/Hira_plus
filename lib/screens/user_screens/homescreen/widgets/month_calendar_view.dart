import 'package:flutter/material.dart';
import 'package:canteen_app/constants/color_class.dart';
import 'package:canteen_app/constants/textstyle_class.dart';
import 'package:provider/provider.dart';
import 'package:canteen_app/providers/date_provider.dart';

class MonthCalendarView extends StatelessWidget {
  final DateTime selectedDate;
  final String Function(int) getMonthName;
  const MonthCalendarView({required this.selectedDate, required this.getMonthName, Key? key}) : super(key: key);

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
              return GestureDetector(
                onTap: () => _showMealBottomSheet(context, dateKey, currentDate),
                child: Container(
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showMealBottomSheet(BuildContext context, String dateKey, DateTime date) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Consumer<DateProvider>(
          builder: (context, dateProvider, child) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Mark Meals for ${date.day}-${date.month}-${date.year}',
                    style: TextStyleClass.poppinsMedium(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ...['Breakfast', 'Lunch', 'Dinner'].map((meal) {
                    final isSelected = dateProvider.isMealSelected(dateKey, meal);
                    IconData mealIcon;
                    switch (meal) {
                      case 'Breakfast':
                        mealIcon = Icons.coffee;
                        break;
                      case 'Lunch':
                        mealIcon = Icons.restaurant;
                        break;
                      case 'Dinner':
                        mealIcon = Icons.dinner_dining;
                        break;
                      default:
                        mealIcon = Icons.fastfood;
                    }
                    return ListTile(
                      leading: Icon(mealIcon, color: ColorClass.primaryBase),
                      title: Text(meal),
                      trailing: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? ColorClass.primaryBase
                              : Colors.white,
                          border: Border.all(
                            color: ColorClass.primaryBase,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Center(
                                child: Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                      onTap: () {
                        dateProvider.toggleMeal(dateKey, meal);
                      },
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
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