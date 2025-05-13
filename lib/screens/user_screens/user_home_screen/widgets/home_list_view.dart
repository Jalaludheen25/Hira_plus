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
                              // Updated: Clickable breakfast checkbox
                              _buildMealCheckbox(
                                context: context,
                                date: date,
                                isChecked: hasBreakfast,
                                mealType: 'breakfast',
                                isEnabled: true,
                              ),

                              // Updated: Clickable lunch checkbox
                              _buildMealCheckbox(
                                context: context,
                                date: date,
                                isChecked: hasLunch,
                                mealType: 'lunch',
                                isEnabled: true,
                              ),

                              // Updated: Clickable dinner checkbox
                              _buildMealCheckbox(
                                context: context,
                                date: date,
                                isChecked: hasDinner,
                                mealType: 'dinner',
                                isEnabled: true,
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

  // Updated helper method to build clickable meal checkboxes
  Widget _buildMealCheckbox({
    required BuildContext context,
    required DateTime date,
    required bool isChecked,
    required String mealType,
    required bool isEnabled,
  }) {
    final mealProvider =
        Provider.of<CanteenHomeProvider>(context, listen: false);

    return Checkbox(
      value: isChecked,
      onChanged: isEnabled
          ? (newValue) {
              _updateMeal(
                  context, mealProvider, date, mealType, newValue ?? false);
            }
          : null,
      activeColor: ColorClass.brandLightGreen,
      checkColor: ColorClass.brandDarkGreen,
    );
  }

  // New helper method to handle meal updates
  Future<void> _updateMeal(
    BuildContext context,
    CanteenHomeProvider mealProvider,
    DateTime date,
    String mealType,
    bool newValue,
  ) async {
    try {
      debugPrint(
          'Updating $mealType for ${date.toIso8601String().split('T')[0]} to: $newValue');

      // Prepare meal parameters based on mealType
      bool? breakfast;
      bool? lunch;
      bool? dinner;

      switch (mealType.toLowerCase()) {
        case 'breakfast':
          breakfast = newValue;
          break;
        case 'lunch':
          lunch = newValue;
          break;
        case 'dinner':
          dinner = newValue;
          break;
      }

      // Show a loading indicator
      final loadingOverlay = _showLoadingOverlay(context);

      // Make the API call to update the meal
      final result = await mealProvider.updateMeal(
        context,
        date: date,
        breakfast: breakfast,
        lunch: lunch,
        dinner: dinner,
      );

      // Hide loading indicator
      loadingOverlay.remove();

      // Check if the widget is still mounted before showing feedback
      if (context.mounted) {
        // Show appropriate feedback
        if (result != null) {
          debugPrint(
              '✅ Successfully updated $mealType for ${date.day}-${date.month}-${date.year}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$mealType updated successfully'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 1),
            ),
          );
        } else {
          debugPrint('❌ Failed to update $mealType');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update $mealType'),
              backgroundColor: ColorClass.redBase,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error updating meal: $e');
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

  // Helper method to show a loading overlay
  OverlayEntry _showLoadingOverlay(BuildContext context) {
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          color: Colors.black.withOpacity(0.3),
          child: const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Updating meal...'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
    return overlayEntry;
  }
}
