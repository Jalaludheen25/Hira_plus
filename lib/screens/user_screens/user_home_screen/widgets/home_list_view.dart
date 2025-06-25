import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hira_plus/constants/color_class.dart';
import 'package:hira_plus/constants/textstyle_class.dart';
import 'package:hira_plus/screens/user_screens/user_home_screen/provider/canteen_home_page_provider.dart';
import 'package:hira_plus/screens/user_screens/user_home_screen/models/meal_model.dart';

class HomeListView extends StatefulWidget {
  final ScrollController scrollController;
  final String Function(int) getMonthName;
  final String Function(int) getDayName;
  final double itemHeight;
  const HomeListView({
    required this.scrollController,
    required this.getMonthName,
    required this.getDayName,
    this.itemHeight = 56.0,
    Key? key,
  }) : super(key: key);

  @override
  State<HomeListView> createState() => _HomeListViewState();
}

class _HomeListViewState extends State<HomeListView> {
  late Map<DateTime, MealModel> _localMeals;
  late List<DateTime> _allDays;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    final canteenProvider =
        Provider.of<CanteenHomeProvider>(context, listen: false);
    _allDays = List<DateTime>.from(canteenProvider.allDays);
    _localMeals = {
      for (var meal in canteenProvider.meals)
        DateTime(meal.date.year, meal.date.month, meal.date.day): meal
    };
    _isLoading = canteenProvider.isLoading;
    _errorMessage = canteenProvider.errorMessage;
  }

  void updateMeal(DateTime date, MealModel meal) {
    setState(() {
      _localMeals[DateTime(date.year, date.month, date.day)] = meal;
    });
  }

  bool isMealMarked(DateTime date, String mealType) {
    final meal = _localMeals[DateTime(date.year, date.month, date.day)];
    if (meal == null) return false;
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return meal.breakfast;
      case 'lunch':
        return meal.lunch;
      case 'dinner':
        return meal.dinner;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
    if (_errorMessage.isNotEmpty) {
      IconData errorIcon = Icons.error_outline;
      Color errorColor = Colors.red;
      String retryButtonText = 'Retry';

      // Customize UI based on error type
      if (_errorMessage.contains('Authentication') ||
          _errorMessage.contains('Unauthorized')) {
        errorIcon = Icons.lock_outline;
        errorColor = Colors.orange;
        retryButtonText = 'Login Again';
      } else if (_errorMessage.contains('timeout') ||
          _errorMessage.contains('Connection timeout')) {
        errorIcon = Icons.wifi_off;
        errorColor = Colors.blue;
        retryButtonText = 'Retry Connection';
      } else if (_errorMessage.contains('No internet') ||
          _errorMessage.contains('network')) {
        errorIcon = Icons.signal_wifi_off;
        errorColor = Colors.blue;
        retryButtonText = 'Check Network';
      }

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(errorIcon, size: 48, color: errorColor),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0),
              child: Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: TextStyleClass.poppinsMedium(
                  fontSize: 14,
                  color: errorColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(_isLoading ? Icons.hourglass_empty : Icons.refresh),
              label: Text(_isLoading ? 'Retrying...' : retryButtonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorClass.brandDarkGreen,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: _isLoading
                  ? null
                  : () async {
                      setState(() {
                        _isLoading = true;
                        _errorMessage = '';
                      });

                      try {
                        final canteenProvider =
                            Provider.of<CanteenHomeProvider>(context,
                                listen: false);
                        await canteenProvider.fetchUserMeals(context);

                        setState(() {
                          _localMeals = {
                            for (var meal in canteenProvider.meals)
                              DateTime(meal.date.year, meal.date.month,
                                  meal.date.day): meal
                          };
                          _isLoading = canteenProvider.isLoading;
                          _errorMessage = canteenProvider.errorMessage;
                        });

                        if (canteenProvider.errorMessage.isEmpty &&
                            context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text('Meals loaded successfully!'),
                                ],
                              ),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      } catch (e) {
                        setState(() {
                          _isLoading = false;
                          _errorMessage = 'Failed to retry: ${e.toString()}';
                        });
                      }
                    },
            ),
          ],
        ),
      );
    }
    final List<_HomeListItem> items = [];
    for (final date in _allDays) {
      if (date.day == 1) {
        items.add(_HomeListItem.banner(date));
      }
      items.add(_HomeListItem.day(date));
    }
    return ListView.builder(
      controller: widget.scrollController,
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
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
                    '${widget.getMonthName(date.month)} ${date.year}',
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
          final hasBreakfast = isMealMarked(date, 'breakfast');
          final hasLunch = isMealMarked(date, 'lunch');
          final hasDinner = isMealMarked(date, 'dinner');
          return SizedBox(
            height: widget.itemHeight,
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
                          ' ${widget.getDayName(date.weekday)}',
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
                          size: 24.0,
                        ),
                        _buildMealCheckbox(
                          context: context,
                          date: date,
                          isChecked: hasLunch,
                          mealType: 'lunch',
                          size: 24.0,
                        ),
                        _buildMealCheckbox(
                          context: context,
                          date: date,
                          isChecked: hasDinner,
                          mealType: 'dinner',
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

  Widget _buildMealCheckbox({
    required BuildContext context,
    required DateTime date,
    required bool isChecked,
    required String mealType,
    double size = 24.0,
  }) {
    final now = DateTime.now();
    final isDinner = mealType.toLowerCase() == 'dinner';
    final cutoffTime = isDinner
        ? DateTime(now.year, now.month, now.day, 14, 0) // 2:00 PM for dinner
        : DateTime(now.year, now.month, now.day, 6, 0); // 6:00 AM for others
    final checkDate = DateTime(date.year, date.month, date.day);
    final isPast = checkDate.isBefore(DateTime(now.year, now.month, now.day));
    final isRestrictedToday =
        checkDate.isAtSameMomentAs(DateTime(now.year, now.month, now.day)) &&
            now.isAfter(cutoffTime);
    final isRestricted = isPast || isRestrictedToday;
    if (isRestricted) {
      return GestureDetector(
        onTap: () {
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
                    ? 'Can\'t modify meal for today after 6:00 AM.'
                    : 'Can\'t modify meal for past dates.',
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
        },
        child: Transform.scale(
          scale: size / 24.0,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isChecked ? ColorClass.neutral300 : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: ColorClass.neutral300,
                width: 1.5,
              ),
            ),
            child: isChecked
                ? const Icon(
                    Icons.check,
                    color: ColorClass.neutral400,
                    size: 18,
                  )
                : Icon(
                    Icons.lock,
                    color: ColorClass.neutral400,
                    size: 12,
                  ),
          ),
        ),
      );
    }
    return Transform.scale(
      scale: size / 24.0,
      child: Checkbox(
        value: isChecked,
        onChanged: (newValue) async {
          // Prepare meal parameters
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
          final canteenProvider =
              Provider.of<CanteenHomeProvider>(context, listen: false);
          final result = await canteenProvider.updateMeal(
            context,
            date: date,
            breakfast: breakfast,
            lunch: lunch,
            dinner: dinner,
          );
          if (result != null) {
            updateMeal(date, result);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$mealType updated successfully'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 1),
                ),
              );
            }
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to update $mealType'),
                  backgroundColor: ColorClass.redBase,
                ),
              );
            }
          }
        },
        activeColor: ColorClass.brandLightGreen,
        checkColor: ColorClass.brandDarkGreen,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

// Helper class for list items
class _HomeListItem {
  final DateTime? date;
  final bool isBanner;
  _HomeListItem.banner(this.date) : isBanner = true;
  _HomeListItem.day(this.date) : isBanner = false;
}
