import 'package:flutter/material.dart';
import 'package:hira_plus/constants/color_class.dart';
import 'package:hira_plus/constants/textstyle_class.dart';
import 'package:hira_plus/screens/user_screens/user_home_screen/provider/canteen_home_page_provider.dart';
import 'package:provider/provider.dart';

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
    final mealProvider = Provider.of<CanteenHomeProvider>(context);

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
    // Track original and current meal states
    Map<String, bool> originalMealStates = {
      'breakfast': hasBreakfast,
      'lunch': hasLunch,
      'dinner': hasDinner,
    };

    Map<String, bool> currentMealStates = {
      'breakfast': hasBreakfast,
      'lunch': hasLunch,
      'dinner': hasDinner,
    };

    showModalBottomSheet(
      context: context,
      backgroundColor: ColorClass.brandWhite,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
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
                _buildToggleableMealTile(
                  'Breakfast',
                  currentMealStates['breakfast']!,
                  Icons.coffee,
                  () {
                    setState(() {
                      currentMealStates['breakfast'] =
                          !currentMealStates['breakfast']!;
                    });
                    debugPrint(
                        'Breakfast toggled to: ${currentMealStates['breakfast']}');
                  },
                ),
                _buildToggleableMealTile(
                  'Lunch',
                  currentMealStates['lunch']!,
                  Icons.restaurant,
                  () {
                    setState(() {
                      currentMealStates['lunch'] = !currentMealStates['lunch']!;
                    });
                    debugPrint(
                        'Lunch toggled to: ${currentMealStates['lunch']}');
                  },
                ),
                _buildToggleableMealTile(
                  'Dinner',
                  currentMealStates['dinner']!,
                  Icons.dinner_dining,
                  () {
                    setState(() {
                      currentMealStates['dinner'] =
                          !currentMealStates['dinner']!;
                    });
                    debugPrint(
                        'Dinner toggled to: ${currentMealStates['dinner']}');
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Tap on a meal to select/deselect it',
                  style: TextStyleClass.poppinsRegular(
                    fontSize: 14,
                    color: ColorClass.neutral400,
                  ),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: ColorClass.brandDarkGreen,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          debugPrint('Meal selection canceled');
                        },
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorClass.brandDarkGreen,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          // Check if any changes were made
                          if (originalMealStates['breakfast'] !=
                                  currentMealStates['breakfast'] ||
                              originalMealStates['lunch'] !=
                                  currentMealStates['lunch'] ||
                              originalMealStates['dinner'] !=
                                  currentMealStates['dinner']) {
                            debugPrint(
                                'Saving meal changes: $currentMealStates');

                            // Get the meal provider and update all meals at once
                            final mealProvider =
                                Provider.of<CanteenHomeProvider>(context,
                                    listen: false);

                            _saveMealChanges(
                                context,
                                mealProvider,
                                date,
                                currentMealStates['breakfast']!,
                                currentMealStates['lunch']!,
                                currentMealStates['dinner']!);
                          } else {
                            debugPrint('No meal changes to save');
                          }
                          Navigator.pop(context);
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  // Helper method to build toggleable meal tiles without API calls
  Widget _buildToggleableMealTile(
    String meal,
    bool isSelected,
    IconData mealIcon,
    VoidCallback onTap,
  ) {
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
      onTap: onTap,
    );
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

  Future<void> _saveMealChanges(
    BuildContext context,
    CanteenHomeProvider mealProvider,
    DateTime date,
    bool breakfast,
    bool lunch,
    bool dinner,
  ) async {
    try {
      // Log detailed information about the update
      debugPrint(
          'Updating meals for date: ${date.toIso8601String().split('T')[0]}');
      debugPrint('Breakfast: $breakfast, Lunch: $lunch, Dinner: $dinner');

      // Make the API call to update all meals at once
      final result = await mealProvider.updateMeal(
        context,
        date: date,
        breakfast: breakfast,
        lunch: lunch,
        dinner: dinner,
      );

      if (result != null) {
        debugPrint('✅ Successfully updated meals: ${result.id}');

        // Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Meal preferences updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        debugPrint('❌ Failed to update meals');

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update meal preferences'),
              backgroundColor: ColorClass.redBase,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error updating meals: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: ColorClass.redBase,
          ),
        );
      }
    }
  }
}
