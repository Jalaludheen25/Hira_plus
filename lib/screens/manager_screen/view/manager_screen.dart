import 'package:flutter/material.dart';
import 'package:hira_plus/constants/color_class.dart';
import 'package:hira_plus/constants/textstyle_class.dart';
import 'package:hira_plus/screens/manager_screen/models/meal_users_model.dart';
import 'package:hira_plus/screens/manager_screen/provider/users_by_meals_provider.dart';
import 'package:hira_plus/screens/bottom_nav/provider/bottom_nav_provider.dart';
import 'package:hira_plus/screens/manager_screen/view/marking_list_screen.dart';
import 'package:hira_plus/screens/manager_screen/view/settings_screen.dart';
import 'package:hira_plus/screens/manager_screen/view/users_list_screen.dart';
import 'package:hira_plus/screens/mess_staff_screen/widgets/detailed_list.dart';
import 'package:hira_plus/screens/mess_staff_screen/widgets/meal_summary_widget.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:hira_plus/screens/manager_screen/view/messages_screen.dart';
import 'package:hira_plus/screens/manager_screen/view/banner_dialog.dart';
import 'package:toastification/toastification.dart';
import 'dart:async';
import 'package:hira_plus/screens/manager_screen/view/manager_bulk_food_list_screen.dart';

class ManagerScreen extends StatelessWidget {
  const ManagerScreen({Key? key}) : super(key: key);

  // Meal summary list with dynamic icon mapping
  List<Map<String, dynamic>> getMealSummary(UsersByMealsProvider provider) => [
        {
          'label': 'Breakfast',
          'icon': LucideIcons.sunMedium,
          'count': provider.breakfastCount
        },
        {
          'label': 'Lunch',
          'icon': LucideIcons.sun,
          'count': provider.lunchCount
        },
        {
          'label': 'Dinner',
          'icon': LucideIcons.moon,
          'count': provider.dinnerCount
        },
      ];

  // Convert MealUserModel list to detailed list format
  List<Map<String, String>> _convertToDetailedList(
      List<UsersByMealModel> users) {
    return users
        .map((user) => {
              'name': user.name ?? 'No Name',
              'type': user.designation ?? ' ',
              'room': user.department != null ? '${user.department}' : '',
            })
        .toList();
  }

  // Get detailed lists based on selected meal
  List<Map<String, String>> getDetailedList(
      int selectedMeal, UsersByMealsProvider provider) {
    switch (selectedMeal) {
      case 0:
        return _convertToDetailedList(provider.breakfastUsers);
      case 1:
        return _convertToDetailedList(provider.lunchUsers);
      case 2:
        return _convertToDetailedList(provider.dinnerUsers);
      default:
        return [];
    }
  }

  Widget _buildDashboardTab(BuildContext context) {
    final selectedMealNotifier =
        ValueNotifier<int?>(null); // null means no meal selected
    final dateSelectNotifier = DateTimeNotifier(DateTime.now());

    // Fetch meal data for current date
    void selectDate(BuildContext context, DateTimeNotifier notifier) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: notifier.value,
        firstDate: DateTime(2022),
        lastDate: DateTime(2030),
      );
      if (picked != null && picked != notifier.value) {
        notifier.value = picked;
        final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
        Provider.of<UsersByMealsProvider>(context, listen: false)
            .setDate(formattedDate);
      }
    }

    Widget buildMealCard({
      required IconData icon,
      required String label,
      required int count,
      required bool isSelected,
      required VoidCallback onTap,
    }) {
      final hasCount = count > 0;
      return GestureDetector(
        onTap: hasCount ? onTap : null,
        child: Container(
          width: 80,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected ? ColorClass.brandLightGreen : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? ColorClass.brandLightGreen
                  : ColorClass.neutral200,
              width: 1.5,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: ColorClass.brandLightGreen.withOpacity(0.08),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 28,
                color: hasCount
                    ? ColorClass.brandDarkGreen
                    : ColorClass.neutral300,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyleClass.poppinsRegular(
                  fontSize: 12,
                  color: hasCount
                      ? ColorClass.brandDarkGreen
                      : ColorClass.neutral400,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                count.toString(),
                style: TextStyleClass.poppinsBold(
                  fontSize: 16,
                  color: hasCount
                      ? ColorClass.brandDarkGreen
                      : ColorClass.neutral400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => UsersByMealsProvider()..fetchAllMeals(),
      child: Consumer<UsersByMealsProvider>(
        builder: (context, mealProvider, _) {
          final mealSummary = getMealSummary(mealProvider);

          return SafeArea(
            child: mealProvider.isLoading
                ? const Center(child: CupertinoActivityIndicator())
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date selection row
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Meal Summary',
                                  style: TextStyleClass.poppinsSemiBold(
                                      fontSize: 18)),
                              GestureDetector(
                                onTap: () =>
                                    selectDate(context, dateSelectNotifier),
                                child: Row(
                                  children: [
                                    Text(
                                      DateFormat('dd MMM yyyy').format(
                                          DateTime.parse(
                                              mealProvider.currentDate)),
                                      style: TextStyleClass.poppinsMedium(
                                          fontSize: 14),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.calendar_today, size: 16),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Meal summary row
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: ValueListenableBuilder<int?>(
                            valueListenable: selectedMealNotifier,
                            builder: (context, selectedMeal, _) => Wrap(
                              spacing: 12.0,
                              runSpacing: 12.0,
                              children: List.generate(
                                mealSummary.length,
                                (index) => buildMealCard(
                                  icon: mealSummary[index]['icon'] as IconData,
                                  label: mealSummary[index]['label'] as String,
                                  count: mealSummary[index]['count'] as int,
                                  isSelected: selectedMeal == index,
                                  onTap: () {
                                    if (selectedMeal == index) {
                                      selectedMealNotifier.value =
                                          null; // Deselect if tapped again
                                    } else {
                                      selectedMealNotifier.value = index;
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Only show detailed list if a meal is selected and available
                        ValueListenableBuilder<int?>(
                          valueListenable: selectedMealNotifier,
                          builder: (context, selectedMeal, _) {
                            if (selectedMeal == null)
                              return const SizedBox.shrink();
                            final count =
                                mealSummary[selectedMeal]['count'] as int;
                            if (count <= 0) return const SizedBox.shrink();
                            final details =
                                getDetailedList(selectedMeal, mealProvider);
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text('Detailed List',
                                              style: TextStyleClass
                                                  .poppinsSemiBold(
                                                      fontSize: 18)),
                                        ],
                                      ),
                                      Text(
                                        'Total: 	${details.length}',
                                        style: TextStyleClass.poppinsBold(
                                          fontSize: 16,
                                          color: ColorClass.brandDarkGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    height: 220,
                                    child: DetailedList(details: details),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        // Quick Actions Section
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: Text(
                            'Quick Actions',
                            style: TextStyleClass.poppinsSemiBold(fontSize: 18),
                          ),
                        ),
                        // Bulk Food Booking Card
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ManagerBulkFoodListScreen(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: ColorClass.brandWhite,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: ColorClass.brandLightGreen,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: ColorClass.brandLightGreen
                                        .withOpacity(0.1),
                                    spreadRadius: 2,
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: ColorClass.brandLightGreen
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      LucideIcons.utensils,
                                      size: 28,
                                      color: ColorClass.brandDarkGreen,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Bulk Food Booking',
                                          style: TextStyleClass.poppinsSemiBold(
                                            fontSize: 18,
                                            color: ColorClass.brandDarkGreen,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Book meals for guests in bulk',
                                          style: TextStyleClass.poppinsRegular(
                                            fontSize: 14,
                                            color: ColorClass.neutral500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    LucideIcons.chevronRight,
                                    color: ColorClass.brandDarkGreen,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Banner Creation Card
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                          child: GestureDetector(
                            onTap: () async {
                              final result = await showDialog(
                                context: context,
                                builder: (context) => BannerDialog(),
                              );
                              // Optionally handle result
                            },
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: ColorClass.brandWhite,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: ColorClass.brandLightGreen,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: ColorClass.brandLightGreen
                                        .withOpacity(0.1),
                                    spreadRadius: 2,
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: ColorClass.brandLightGreen
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      LucideIcons.image,
                                      size: 28,
                                      color: ColorClass.brandDarkGreen,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Create Banner',
                                          style: TextStyleClass.poppinsSemiBold(
                                            fontSize: 18,
                                            color: ColorClass.brandDarkGreen,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Create promotional banners',
                                          style: TextStyleClass.poppinsRegular(
                                            fontSize: 14,
                                            color: ColorClass.neutral500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    LucideIcons.chevronRight,
                                    color: ColorClass.brandDarkGreen,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Add bottom padding for better spacing
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }

  static List<Widget> _pages(BuildContext context) => [
        // Dashboard tab
        Builder(
            builder: (context) =>
                ((const ManagerScreen()._buildDashboardTab(context)))),
        // Markings tab (changed position)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: MarkingListScreen(showAppBar: false),
        ),
        // Messages tab (center)
        ManagerMessagesScreen(),
        // Users tab (changed position)
        UsersListScreen(),
        // Settings tab
        const SettingsScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<BottomNavProvider>(context);
    final tabTitles = [
      'Dashboard',
      'Markings',
      'Messages',
      'Users',
      'Settings'
    ];
    DateTime? _lastBackPressed;
    return WillPopScope(
      onWillPop: () async {
        if (_lastBackPressed == null ||
            DateTime.now().difference(_lastBackPressed!) >
                Duration(seconds: 2)) {
          _lastBackPressed = DateTime.now();
          toastification.show(
            context: context,
            title: Text('Tap again to exit'),
            type: ToastificationType.info,
            autoCloseDuration: Duration(seconds: 2),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: ColorClass.bgWhite0,
        appBar: AppBar(
          backgroundColor: ColorClass.brandDarkGreen,
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
          title: Text(
            tabTitles[navProvider.selectedIndex],
            style: TextStyleClass.poppinsSemiBold(
              fontSize: 20,
              color: ColorClass.white,
            ),
          ),
        ),
        body: _pages(context)[navProvider.selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: ColorClass.brandWhite,
          selectedItemColor: ColorClass.brandDarkGreen,
          unselectedItemColor: const Color.fromARGB(255, 63, 94, 43),
          unselectedFontSize: 10,
          selectedFontSize: 10,
          selectedLabelStyle: TextStyleClass.poppinsSemiBold(fontSize: 10),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.layoutDashboard,
                  size: 20, color: Color.fromARGB(255, 63, 94, 43)),
              activeIcon: Icon(LucideIcons.layoutDashboard, size: 28),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.clipboardList,
                  size: 20, color: Color.fromARGB(255, 63, 94, 43)),
              activeIcon: Icon(LucideIcons.clipboardList, size: 28),
              label: 'Markings',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.messageCircle,
                  size: 24, color: Color.fromARGB(255, 63, 94, 43)),
              activeIcon: Icon(LucideIcons.messageCircle, size: 28),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.users,
                  size: 20, color: Color.fromARGB(255, 63, 94, 43)),
              activeIcon: Icon(LucideIcons.users, size: 28),
              label: 'Users',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.settings,
                  size: 20, color: Color.fromARGB(255, 63, 94, 43)),
              activeIcon: Icon(LucideIcons.settings, size: 28),
              label: 'Settings',
            ),
          ],
          currentIndex: navProvider.selectedIndex,
          onTap: navProvider.setIndex,
        ),
        // Removed the floating action button
      ),
    );
  }
}

class DateTimeNotifier extends ValueNotifier<DateTime> {
  DateTimeNotifier(DateTime value) : super(value);
}