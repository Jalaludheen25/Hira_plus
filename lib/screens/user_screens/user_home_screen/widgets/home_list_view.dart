import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hira_plus/constants/color_class.dart';
import 'package:hira_plus/constants/textstyle_class.dart';
import 'package:hira_plus/screens/user_screens/user_home_screen/provider/canteen_home_page_provider.dart';

class HomeListView extends StatelessWidget {
  final ScrollController scrollController;
  final String Function(int) getMonthName;
  final String Function(int) getDayName;
  final double itemHeight;
  const HomeListView(
      {required this.scrollController,
      required this.getMonthName,
      required this.getDayName,
      this.itemHeight = 56.0,
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
            SizedBox(height: 10),
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
            Icon(errorIcon, size: 28, color: errorColor),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0),
              child: Text(
                mealProvider.errorMessage,
                textAlign: TextAlign.center,
                style: TextStyleClass.poppinsMedium(
                  fontSize: 12,
                  color: errorColor,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (mealProvider.meals.isNotEmpty)
              Text(
                "Showing cached data from last sync",
                style: TextStyleClass.poppinsRegular(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            const SizedBox(height: 12),
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

    // Build a list of items: for each date, if first of month, add a banner, then the day row
    final List<_HomeListItem> items = [];
    for (final date in canteenProvider.allDays) {
      if (date.day == 1) {
        items.add(_HomeListItem.banner(date));
      }
      items.add(_HomeListItem.day(date));
    }

    return ListView.builder(
      controller: scrollController,
      itemCount: items.length + 1, // +1 for header
      itemBuilder: (context, index) {
        if (index == 0) {
          // Header row
          return Container(
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
          );
        }
        final item = items[index - 1];
        if (item.isBanner) {
          final date = item.date!;
          final isToday = date.day == DateTime.now().day &&
              date.month == DateTime.now().month &&
              date.year == DateTime.now().year;
          return Container(
            padding: const EdgeInsets.all(4),
            color: ColorClass.brandLightGreen,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    '${getMonthName(date.month)} ${date.year}',
                    style: TextStyleClass.poppinsMedium(
                      fontSize: 12,
                      color: ColorClass.brandDarkGreen,
                    ),
                  ),
                ),
                if (isToday)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: ColorClass.brandLightGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Today',
                      style: TextStyleClass.poppinsMedium(
                        fontSize: 10,
                        color: ColorClass.brandDarkGreen,
                      ),
                    ),
                  ),
              ],
            ),
          );
        } else {
          final date = item.date!;
          final isToday = date.day == DateTime.now().day &&
              date.month == DateTime.now().month &&
              date.year == DateTime.now().year;
          final hasBreakfast = mealProvider.isMealMarked(date, 'breakfast');
          final hasLunch = mealProvider.isMealMarked(date, 'lunch');
          final hasDinner = mealProvider.isMealMarked(date, 'dinner');
          return SizedBox(
            height: itemHeight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: ColorClass.primaryBase.withOpacity(0.08),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isToday)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: ColorClass.brandLightGreen,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              date.day.toString().padLeft(2, '0'),
                              style: TextStyleClass.poppinsMedium(
                                fontSize: 20,
                                color: ColorClass.brandDarkGreen,
                              ),
                            ),
                          )
                        else
                          Text(
                            date.day.toString().padLeft(2, '0'),
                            style: TextStyleClass.poppinsMedium(
                              fontSize: 20,
                              color: ColorClass.textMain900,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          ' ${getDayName(date.weekday)}',
                          style: TextStyleClass.poppinsMedium(
                            fontSize: 12,
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
                        _buildMealCheckbox(
                          context: context,
                          date: date,
                          isChecked: hasBreakfast,
                          mealType: 'breakfast',
                          isEnabled: true,
                          size: 24.0,
                        ),
                        _buildMealCheckbox(
                          context: context,
                          date: date,
                          isChecked: hasLunch,
                          mealType: 'lunch',
                          isEnabled: true,
                          size: 24.0,
                        ),
                        _buildMealCheckbox(
                          context: context,
                          date: date,
                          isChecked: hasDinner,
                          mealType: 'dinner',
                          isEnabled: true,
                          size: 24.0,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  // Updated helper method to build clickable meal checkboxes
  Widget _buildMealCheckbox({
    required BuildContext context,
    required DateTime date,
    required bool isChecked,
    required String mealType,
    required bool isEnabled,
    double size = 24.0,
  }) {
    final mealProvider =
        Provider.of<CanteenHomeProvider>(context, listen: false);
    final now = DateTime.now();

    // Set cutoff time to 6:00 AM today
    final cutoffTime = DateTime(now.year, now.month, now.day, 6, 0);
    final checkDate = DateTime(date.year, date.month, date.day);

    // Check if the date is in the past or if it's today and past 6 AM
    final isPast = checkDate.isBefore(DateTime(now.year, now.month, now.day));
    final isRestrictedToday =
        checkDate.isAtSameMomentAs(DateTime(now.year, now.month, now.day)) &&
            now.isAfter(cutoffTime);
    final isRestricted = isPast || isRestrictedToday;

    return Transform.scale(
      scale: size / 24.0,
      child: Checkbox(
        value: isChecked,
        onChanged: (newValue) {
          if (isRestricted) {
            showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: Text(
                  'Cannot Modify Meals',
                  style: TextStyleClass.poppinsSemiBold(
                    fontSize: 14,
                    color: ColorClass.brandDarkGreen,
                  ),
                ),
                content: Text(
                  isRestrictedToday
                      ? 'Meal preferences for today cannot be modified after 6:00 AM.'
                      : 'Meal preferences for past dates cannot be modified.',
                  style: TextStyleClass.poppinsRegular(
                    fontSize: 12,
                    color: ColorClass.textMain900,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'OK',
                      style: TextStyleClass.poppinsMedium(
                        fontSize: 12,
                        color: ColorClass.brandDarkGreen,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            _updateMeal(
                context, mealProvider, date, mealType, newValue ?? false);
          }
        },
        activeColor: ColorClass.brandLightGreen,
        checkColor: ColorClass.brandDarkGreen,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
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
          color: Colors.transparent,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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

// Helper class for list items
class _HomeListItem {
  final DateTime? date;
  final bool isBanner;
  _HomeListItem.banner(this.date) : isBanner = true;
  _HomeListItem.day(this.date) : isBanner = false;
}
