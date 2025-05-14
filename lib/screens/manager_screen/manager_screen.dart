import 'package:Hira_Plus/screens/mess_staff_screen/widgets/detailed_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Hira_Plus/providers/bottom_nav_provider.dart';
import 'package:Hira_Plus/constants/color_class.dart';
import 'package:Hira_Plus/constants/textstyle_class.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:Hira_Plus/screens/mess_staff_screen/widgets/meal_summary_widget.dart';
import 'package:Hira_Plus/screens/manager_screen/marking_list_screen.dart';
import 'package:Hira_Plus/screens/manager_screen/users_list_screen.dart';
import 'package:Hira_Plus/providers/profile_screen_provider.dart';
import 'package:Hira_Plus/screens/user_screens/user_home_screen/widgets/custom_drawer.dart';
import 'package:Hira_Plus/screens/user_screens/profile_screen/widgets/profile_card.dart';
import 'package:Hira_Plus/screens/user_screens/profile_screen/widgets/powered_by_section.dart';
import 'package:Hira_Plus/screens/user_screens/profile_screen/widgets/logout_confirmation_bottom_sheet.dart';
import 'package:Hira_Plus/utils/navigation_helper.dart';
import 'package:Hira_Plus/routes/app_routes.dart';
import 'package:shake_flutter/shake_flutter.dart';
import 'package:shake_flutter/enums/shake_screen.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Hira_Plus/providers/users_by_meals.dart';
import 'package:Hira_Plus/models/meal_users_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

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
    final selectedMealNotifier = ValueNotifier<int>(0);
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

    return ChangeNotifierProvider(
      create: (_) => UsersByMealsProvider()..fetchAllMeals(),
      child: Consumer<UsersByMealsProvider>(
        builder: (context, mealProvider, _) {
          final mealSummary = getMealSummary(mealProvider);

          return SafeArea(
            child: mealProvider.isLoading
                ? const Center(child: CupertinoActivityIndicator())
                : Column(
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
                      // Meal summary widgets
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: ValueListenableBuilder<int>(
                          valueListenable: selectedMealNotifier,
                          builder: (context, selectedMeal, _) => Wrap(
                            spacing: 12.0,
                            runSpacing: 12.0,
                            children: List.generate(
                                mealSummary.length,
                                (index) => GestureDetector(
                                      onTap: () {
                                        selectedMealNotifier.value = index;
                                      },
                                      child: MealSummaryWidget(
                                        icon: mealSummary[index]['icon']
                                            as IconData,
                                        label: mealSummary[index]['label']
                                            as String,
                                        count:
                                            mealSummary[index]['count'] as int,
                                        isSelected: selectedMeal == index,
                                      ),
                                    )),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Detailed list section
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: ValueListenableBuilder<int>(
                            valueListenable: selectedMealNotifier,
                            builder: (context, selectedMeal, _) {
                              final details =
                                  getDetailedList(selectedMeal, mealProvider);
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Detailed List',
                                          style: TextStyleClass.poppinsSemiBold(
                                              fontSize: 18)),
                                      
                                      Text(
                                        'Total: ${details.length}',
                                        style: TextStyleClass.poppinsBold(
                                            fontSize: 18,
                                            color: ColorClass.brandDarkGreen),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  Expanded(
                                    child: details.isEmpty
                                        ? const Center(
                                            child: Text(
                                                'No users found for this meal'),
                                          )
                                        : DetailedList(details: details),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  static List<Widget> _pages(BuildContext context) => [
        // Dashboard tab with selectable meals
        Builder(
            builder: (context) =>
                ((const ManagerScreen()._buildDashboardTab(context)))),
        // Markings tab
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: MarkingListScreen(showAppBar: false),
        ),
        // Users tab
        UsersListScreen(),
        // Settings tab
        const SettingsScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<BottomNavProvider>(context);
    final tabTitles = ['Dashboard', 'Markings', 'Users', 'Notifications', 'Settings'];
    return Scaffold(
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
      body: navProvider.selectedIndex == 1
          ? Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: MarkingListScreen(showAppBar: false),
            )
          : _pages(context)[navProvider.selectedIndex],
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
            icon: Icon(LucideIcons.users,
                size: 20, color: Color.fromARGB(255, 63, 94, 43)),
            activeIcon: Icon(LucideIcons.users, size: 28),
            label: 'Users',
            
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.bell,
                size: 20, color: Color.fromARGB(255, 63, 94, 43)),
            activeIcon: Icon(LucideIcons.bell, size: 28),
            label: 'Notifications',
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
    );
  }
}

class DateTimeNotifier extends ValueNotifier<DateTime> {
  DateTimeNotifier(DateTime value) : super(value);
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileScreenProvider>(context);
    return Column(
      children: [
        const SizedBox(height: 24),
        ProfileCard(
          userName: profileProvider.userName,
          phone: profileProvider.phone,
        ),
        const SizedBox(height: 32),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              CustomDrawerItem(
                title: 'Feedback',
                icon: LucideIcons.messageCircle,
                onTap: () async {
                  final Uri emailLaunchUri = Uri(
                    scheme: 'mailto',
                    path: 'mail@d4dx.co',
                  );
                  await launchUrl(emailLaunchUri);
                },
              ),
              CustomDrawerItem(
                title: 'Privacy Policy',
                icon: LucideIcons.shieldCheck,
                onTap: () async {
                  final Uri url = Uri.parse(
                      'https://www.termsfeed.com/live/b1d9ea79-6dfb-4c0e-83fa-0fc2841ec2b4');
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                },
              ),
              CustomDrawerItem(
                title: 'Contact Us',
                icon: LucideIcons.phone,
                onTap: () {
                  navigateTo(
                    context: context,
                    route: Routes.contactUs,
                  );
                },
              ),
              CustomDrawerItem(
                title: 'About Us',
                icon: LucideIcons.info,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('About Us'),
                      content:
                          const Text('This is dummy content for About Us.'),
                      actions: [
                        TextButton(
                          onPressed: () => navigateBack(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              CustomDrawerItem(
                title: 'Raise a bug',
                icon: LucideIcons.bug,
                onTap: () {
                  Shake.show(ShakeScreen.home);
                },
              ),
              const Divider(),
              CustomDrawerItem(
                title: 'Logout',
                icon: LucideIcons.logOut,
                isDestructive: true,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    builder: (BuildContext context) {
                      return LogoutConfirmationBottomSheet(
                        onLogout: () {
                          Provider.of<BottomNavProvider>(
                                  navigatorKey.currentContext!,
                                  listen: false)
                              .setIndex(0);
                          toastification.show(
                            context: context,
                            title: Text('Logged out successfully'),
                            type: ToastificationType.success,
                            autoCloseDuration: const Duration(seconds: 2),
                          );
                          Future.delayed(const Duration(milliseconds: 500), () {
                            navigatePRTo(
                              context: navigatorKey.currentContext!,
                              route: Routes.login,
                            );
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        PoweredBySection(),
        const SizedBox(height: 16),
      ],
    );
  }
}
