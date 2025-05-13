import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hira_plus/constants/color_class.dart';
import 'package:hira_plus/constants/textstyle_class.dart';
import 'package:hira_plus/screens/user_screens/user_home_screen/provider/canteen_home_page_provider.dart';

class HomeListView extends StatelessWidget {
  final ScrollController scrollController;
  final String Function(int) getMonthName;
  final String Function(int) getDayName;
  const HomeListView(
      {required this.scrollController,
      required this.getMonthName,
      required this.getDayName,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final canteenProvider = Provider.of<CanteenHomeProvider>(context);
    final mealProvider = Provider.of<CanteenHomeProvider>(context);

    if (mealProvider.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Loading your meals..."),
          ],
        ),
      );
    }

    if (mealProvider.errorMessage.isNotEmpty) {
      IconData errorIcon = Icons.error_outline;
      Color errorColor = Colors.red;

      // Different styling for auth errors vs network errors
      if (mealProvider.errorMessage.contains('Authentication')) {
        errorIcon = Icons.lock_outline;
        errorColor = Colors.orange;
      }

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(errorIcon, size: 48, color: errorColor),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                mealProvider.errorMessage,
                textAlign: TextAlign.center,
                style: TextStyleClass.poppinsMedium(
                  fontSize: 16,
                  color: errorColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (mealProvider.meals.isNotEmpty)
              Text(
                "Showing cached data from last sync",
                style: TextStyleClass.poppinsRegular(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorClass.brandDarkGreen,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () => mealProvider.fetchUserMeals(context),
            ),
          ],
        ),
      );
    }

    return Column(
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
                              color: ColorClass.brandDarkGreen,
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
            controller: scrollController,
            itemCount: canteenProvider.allDays.length,
            itemBuilder: (context, index) {
              final date = canteenProvider.allDays[index];
              final isToday = date.day == DateTime.now().day &&
                  date.month == DateTime.now().month &&
                  date.year == DateTime.now().year;
              final bool isFirstDayOfMonth = date.day == 1;

              // Get meal status from meal provider
              final hasBreakfast = mealProvider.isMealMarked(date, 'breakfast');
              final hasLunch = mealProvider.isMealMarked(date, 'lunch');
              final hasDinner = mealProvider.isMealMarked(date, 'dinner');

              return Column(
                children: [
                  if (isFirstDayOfMonth)
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: ColorClass.brandLightGreen,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Text(
                              '${getMonthName(date.month)} ${date.year}',
                              style: TextStyleClass.poppinsMedium(
                                fontSize: 16,
                                color: ColorClass.brandDarkGreen,
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
                                color: ColorClass.brandLightGreen,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Today',
                                style: TextStyleClass.poppinsMedium(
                                  fontSize: 14,
                                  color: ColorClass.brandDarkGreen,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: ColorClass.primaryBase.withOpacity(0.1),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
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
                                    color: ColorClass.brandLightGreen,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    date.day.toString().padLeft(2, '0'),
                                    style: TextStyleClass.poppinsMedium(
                                      fontSize: 26,
                                      color: ColorClass.brandDarkGreen,
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
                                ' ${getDayName(date.weekday)}',
                                style: TextStyleClass.poppinsMedium(
                                  fontSize: 14,
                                  color: ColorClass.neutral400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Breakfast checkbox (read-only indicator)
                              _buildMealCheckbox(
                                isChecked: hasBreakfast,
                                isEnabled: false,
                              ),

                              // Lunch checkbox (read-only indicator)
                              _buildMealCheckbox(
                                isChecked: hasLunch,
                                isEnabled: false,
                              ),

                              // Dinner checkbox (read-only indicator)
                              _buildMealCheckbox(
                                isChecked: hasDinner,
                                isEnabled: false,
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
    );
  }

  // Helper method to build consistent meal checkboxes
  Widget _buildMealCheckbox({
    required bool isChecked,
    required bool isEnabled,
  }) {
    return Checkbox(
      value: isChecked,
      onChanged: isEnabled ? (_) {} : null,
      activeColor: ColorClass.brandLightGreen,
      checkColor: ColorClass.brandDarkGreen,
    );
  }
}
