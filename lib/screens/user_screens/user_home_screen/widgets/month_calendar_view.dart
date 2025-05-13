import 'package:flutter/material.dart';
import 'package:hira_plus/constants/color_class.dart';
import 'package:hira_plus/constants/textstyle_class.dart';
import 'package:provider/provider.dart';
import 'package:hira_plus/screens/user_screens/user_home_screen/provider/meal_provider.dart';

class MonthCalendarView extends StatelessWidget {
  final DateTime selectedDate;
  final String Function(int) getMonthName;
  final void Function(int) onMonthChanged;
  const MonthCalendarView(
      {required this.selectedDate,
      required this.getMonthName,
      Key? key,
      required this.onMonthChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final lastDayOfMonth =
        DateTime(selectedDate.year, selectedDate.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final totalDays = lastDayOfMonth.day;
    final totalWeeks = ((firstWeekday + totalDays) / 7).ceil();
    final mealProvider = Provider.of<MealProvider>(context);

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
                onPressed:
                    selectedDate.month == 1 ? null : () => onMonthChanged(-1),
              ),
              Text(
                '${getMonthName(selectedDate.month)} ${selectedDate.year}',
                style: TextStyleClass.poppinsMedium(
                    fontSize: 18, color: ColorClass.brandDarkGreen),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_right, size: 28),
                color: ColorClass.brandDarkGreen,
                onPressed:
                    selectedDate.month == 12 ? null : () => onMonthChanged(1),
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
        if (mealProvider.isLoading)
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Loading your meals..."),
                ],
              ),
            ),
          )
        else if (mealProvider.errorMessage.isNotEmpty &&
            mealProvider.meals.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    mealProvider.errorMessage.contains('Authentication')
                        ? Icons.lock_outline
                        : Icons.error_outline,
                    size: 48,
                    color: mealProvider.errorMessage.contains('Authentication')
                        ? Colors.orange
                        : Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      mealProvider.errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyleClass.poppinsMedium(
                        fontSize: 16,
                        color:
                            mealProvider.errorMessage.contains('Authentication')
                                ? Colors.orange
                                : Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorClass.brandDarkGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    onPressed: () => mealProvider.fetchUserMeals(context),
                  ),
                ],
              ),
            ),
          )
        else
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
                final currentDate =
                    firstDayOfMonth.add(Duration(days: dayOffset));
                final isCurrentMonth = currentDate.month == selectedDate.month;
                final isToday = currentDate.day == DateTime.now().day &&
                    currentDate.month == DateTime.now().month &&
                    currentDate.year == DateTime.now().year;
                if (!isCurrentMonth) {
                  return const SizedBox();
                }

                // Check meal status for this date
                final hasBreakfast =
                    mealProvider.isMealMarked(currentDate, 'breakfast');
                final hasLunch =
                    mealProvider.isMealMarked(currentDate, 'lunch');
                final hasDinner =
                    mealProvider.isMealMarked(currentDate, 'dinner');

                return GestureDetector(
                  onTap: () => _showMealBottomSheet(
                      context, currentDate, hasBreakfast, hasLunch, hasDinner),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isToday
                          ? ColorClass.brandLightGreen
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isToday
                            ? ColorClass.brandLightGreen
                            : ColorClass.neutral200,
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
                          FittedBox(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildMealIndicator('B', hasBreakfast, isToday),
                                _buildMealIndicator('L', hasLunch, isToday),
                                _buildMealIndicator('D', hasDinner, isToday),
                              ],
                            ),
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

  void _showMealBottomSheet(BuildContext context, DateTime date,
      bool hasBreakfast, bool hasLunch, bool hasDinner) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ColorClass.brandWhite,
      builder: (context) {
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
                'Meals for ${date.day}-${date.month}-${date.year}',
                style: TextStyleClass.poppinsMedium(fontSize: 18),
              ),
              const SizedBox(height: 16),
              _buildMealListTile('Breakfast', hasBreakfast, Icons.coffee),
              _buildMealListTile('Lunch', hasLunch, Icons.restaurant),
              _buildMealListTile('Dinner', hasDinner, Icons.dinner_dining),
              const SizedBox(height: 16),
              Text(
                'Meals are read-only. Contact staff to change.',
                style: TextStyleClass.poppinsRegular(
                  fontSize: 14,
                  color: ColorClass.neutral400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMealListTile(String meal, bool isSelected, IconData mealIcon) {
    return ListTile(
      leading: Icon(mealIcon, color: ColorClass.brandDarkGreen),
      title: Text(meal),
      trailing: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isSelected ? ColorClass.brandLightGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: ColorClass.brandDarkGreen,
            width: 1.5,
          ),
        ),
        child: isSelected
            ? const Icon(
                Icons.check,
                color: ColorClass.brandDarkGreen,
                size: 18,
              )
            : null,
      ),
    );
  }
}

Widget _buildMealIndicator(String label, bool isSelected, bool isToday) {
  final bool isTodayAndSelected = isToday && isSelected;
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 2),
    width: 16,
    height: 16,
    decoration: BoxDecoration(
      color: isSelected ? ColorClass.brandDarkGreen : Colors.transparent,
      borderRadius: BorderRadius.circular(4),
      border: Border.all(
        color: isTodayAndSelected ? Colors.white : ColorClass.brandDarkGreen,
        width: 1,
      ),
    ),
    child: Center(
      child: Text(
        label,
        style: TextStyleClass.poppinsRegular(
          fontSize: 10,
          color: isSelected ? Colors.white : ColorClass.brandDarkGreen,
        ),
      ),
    ),
  );
}
