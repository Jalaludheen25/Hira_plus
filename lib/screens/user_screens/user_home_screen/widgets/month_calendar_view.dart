import 'package:flutter/material.dart';
import 'package:Hira_Plus/constants/color_class.dart';
import 'package:Hira_Plus/constants/textstyle_class.dart';
import 'package:provider/provider.dart';
import 'package:Hira_Plus/providers/date_provider.dart';

class MonthCalendarView extends StatelessWidget {
  final DateTime selectedDate;
  final String Function(int) getMonthName;
  final void Function(int) onMonthChanged;
  const MonthCalendarView({required this.selectedDate, required this.getMonthName, Key? key, required this.onMonthChanged}) : super(key: key);

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
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_left, size: 28),
                color: ColorClass.brandDarkGreen,
                onPressed: selectedDate.month == 1 ? null : () => onMonthChanged(-1),
              ),
              Text(
                '${getMonthName(selectedDate.month)} ${selectedDate.year}',
                style: TextStyleClass.poppinsMedium(fontSize: 18, color: ColorClass.brandDarkGreen),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_right, size: 28),
                color: ColorClass.brandDarkGreen,
                onPressed: selectedDate.month == 12 ? null : () => onMonthChanged(1),
              ),
            ],
          ),
        ),
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
                    color: isToday ? ColorClass.brandLightGreen : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isToday ? ColorClass.brandLightGreen : ColorClass.neutral200,
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
                                ? ColorClass.brandDarkGreen
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
      backgroundColor: ColorClass.brandWhite,
      builder: (context) {
        return Consumer<DateProvider>(
          builder: (context, dateProvider, child) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: ColorClass.brandDarkGreen,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
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
                      leading: Icon(mealIcon, color: ColorClass.brandDarkGreen),
                      title: Text(meal),
                      trailing: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? ColorClass.brandDarkGreen
                              : Colors.white,
                          border: Border.all(
                            color: ColorClass.brandDarkGreen,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Center(
                                child: Icon(
                                  Icons.check,
                                  size: 16,
                                  color: ColorClass.brandLightGreen,
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
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorClass.brandDarkGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Save',
                        style: TextStyle(
                          color: ColorClass.brandWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
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
                ? ColorClass.brandLightGreen
                : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: isTodayAndSelected
              ? ColorClass.brandDarkGreen
              : isSelected
                  ? ColorClass.brandLightGreen
                  : ColorClass.neutral300,
          width: 1,
        ),
      ),
      child: Center(
        child: isSelected
            ? Icon(
                Icons.check,
                size: 18,
                color: ColorClass.brandLightGreen,
              )
            : Text(
                label,
                style: TextStyleClass.poppinsBold(
                  fontSize: 16,
                  color: isTodayAndSelected
                      ? ColorClass.brandDarkGreen
                      : isSelected
                          ? ColorClass.brandLightGreen
                          : ColorClass.neutral400,
                ),
              ),
      ),
    );
  }
} 