import 'package:flutter/material.dart';
import 'package:hira_plus/constants/color_class.dart';
import 'package:hira_plus/constants/textstyle_class.dart';
import 'package:hira_plus/screens/manager_screen/models/meal_users_model.dart';
import 'package:hira_plus/screens/manager_screen/provider/users_by_meals_provider.dart';
import 'package:hira_plus/screens/bottom_nav/provider/bottom_nav_provider.dart';
import 'package:hira_plus/screens/manager_screen/view/banner_dialog.dart';
import 'package:hira_plus/screens/manager_screen/view/marking_list_screen.dart';
import 'package:hira_plus/screens/manager_screen/view/users_list_screen.dart';
import 'package:hira_plus/screens/profile_screen/provider/profile_screen_provider.dart';
import 'package:hira_plus/screens/profile_screen/widgets/logout_confirmation_bottom_sheet.dart';
import 'package:hira_plus/screens/profile_screen/widgets/powered_by_section.dart';
import 'package:hira_plus/screens/profile_screen/widgets/profile_card.dart';
import 'package:hira_plus/screens/user_screens/user_home_screen/widgets/custom_drawer.dart';
import 'package:hira_plus/utils/navigation_helper.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shake_flutter/enums/shake_screen.dart';
import 'package:shake_flutter/shake_flutter.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:hira_plus/screens/login_screen/provider/auth_provider.dart';
import 'package:hira_plus/screens/manager_screen/view/messages_screen.dart';
import 'package:hira_plus/screens/manager_screen/view/manager_bulk_food_list_screen.dart';
import 'package:hira_plus/screens/manager_screen/view/meeting_management_screen.dart';
import 'package:hira_plus/routes/app_routes.dart';
import 'dart:developer' as developer;

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

  // Show detailed list bottom sheet
  void _showDetailedListBottomSheet(
    BuildContext context,
    String mealLabel,
    List<Map<String, String>> details,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: ColorClass.brandWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: ColorClass.neutral300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$mealLabel - Detailed List',
                    style: TextStyleClass.poppinsSemiBold(fontSize: 18),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      LucideIcons.x,
                      color: ColorClass.neutral500,
                    ),
                  ),
                ],
              ),
            ),

            // Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Total: ${details.length}',
                    style: TextStyleClass.poppinsBold(
                      fontSize: 16,
                      color: ColorClass.brandDarkGreen,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // List content
            Expanded(
              child: details.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.users,
                            size: 48,
                            color: ColorClass.neutral300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No users found for this meal',
                            style: TextStyleClass.poppinsRegular(
                              fontSize: 16,
                              color: ColorClass.neutral400,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: details.length,
                      itemBuilder: (context, index) {
                        final item = details[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: ColorClass.neutral200,
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'] ?? '',
                                style:
                                    TextStyleClass.poppinsMedium(fontSize: 16),
                              ),
                              if (item['type']?.isNotEmpty == true) ...[
                                const SizedBox(height: 2),
                                Text(
                                  item['type']!,
                                  style: TextStyleClass.poppinsRegular(
                                    fontSize: 13,
                                    color: ColorClass.neutral400,
                                  ),
                                ),
                              ],
                              if (item['room']?.isNotEmpty == true) ...[
                                const SizedBox(height: 1),
                                Text(
                                  item['room']!,
                                  style: TextStyleClass.poppinsRegular(
                                    fontSize: 13,
                                    color: ColorClass.neutral400,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCard({
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
            color:
                isSelected ? ColorClass.brandLightGreen : ColorClass.neutral200,
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
              color:
                  hasCount ? ColorClass.brandDarkGreen : ColorClass.neutral300,
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

  Widget _buildDashboardTab(BuildContext context) {
    final selectedMealNotifier = ValueNotifier<int?>(null);
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
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Date selection row
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 16, 20, 0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Meal Summary',
                                        style: TextStyleClass.poppinsSemiBold(
                                            fontSize: 18)),
                                    GestureDetector(
                                      onTap: () => selectDate(
                                          context, dateSelectNotifier),
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
                                          const Icon(Icons.calendar_today,
                                              size: 16),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Meal Cards Row - Fixed layout like mess staff
                              SizedBox(
                                height: 110,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0),
                                  child: ValueListenableBuilder<int?>(
                                    valueListenable: selectedMealNotifier,
                                    builder: (context, selectedMeal, _) => Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: List.generate(
                                        mealSummary.length,
                                        (index) => _buildMealCard(
                                          icon: mealSummary[index]['icon']
                                              as IconData,
                                          label: mealSummary[index]['label']
                                              as String,
                                          count: mealSummary[index]['count']
                                              as int,
                                          isSelected: selectedMeal == index,
                                          onTap: () {
                                            // Update selection state and show bottom sheet
                                            selectedMealNotifier.value = index;
                                            final details = getDetailedList(
                                                index, mealProvider);
                                            final mealLabel = mealSummary[index]
                                                ['label'] as String;
                                            _showDetailedListBottomSheet(
                                                context, mealLabel, details);
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Quick Actions Section
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 32, 20, 0),
                                child: Text(
                                  'Quick Actions',
                                  style: TextStyleClass.poppinsSemiBold(
                                      fontSize: 18),
                                ),
                              ),

                              // Bulk Food Booking Card
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 12, 20, 0),
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
                                            borderRadius:
                                                BorderRadius.circular(12),
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
                                                style: TextStyleClass
                                                    .poppinsSemiBold(
                                                  fontSize: 18,
                                                  color:
                                                      ColorClass.brandDarkGreen,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Book meals for guests in bulk',
                                                style: TextStyleClass
                                                    .poppinsRegular(
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
                                padding:
                                    const EdgeInsets.fromLTRB(20, 12, 20, 0),
                                child: GestureDetector(
                                  onTap: () async {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            BannerDialog(),
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
                                            borderRadius:
                                                BorderRadius.circular(12),
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
                                                style: TextStyleClass
                                                    .poppinsSemiBold(
                                                  fontSize: 18,
                                                  color:
                                                      ColorClass.brandDarkGreen,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Create promotional banners',
                                                style: TextStyleClass
                                                    .poppinsRegular(
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

                              // NEW: Meeting Management Card
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 12, 20, 0),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const MeetingManagementScreen(),
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
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            LucideIcons.calendar,
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
                                                'Meeting Management',
                                                style: TextStyleClass
                                                    .poppinsSemiBold(
                                                  fontSize: 18,
                                                  color:
                                                      ColorClass.brandDarkGreen,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Schedule & manage meetings',
                                                style: TextStyleClass
                                                    .poppinsRegular(
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
                      ),
                    ],
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
    DateTime? lastBackPressed;
    return WillPopScope(
      onWillPop: () async {
        if (lastBackPressed == null ||
            DateTime.now().difference(lastBackPressed!) >
                Duration(seconds: 2)) {
          lastBackPressed = DateTime.now();
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
          unselectedItemColor: ColorClass.neutral400,
          unselectedFontSize: 10,
          selectedFontSize: 10,
          selectedLabelStyle: TextStyleClass.poppinsSemiBold(fontSize: 10),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.layoutDashboard,
                  size: 20, color: ColorClass.neutral400),
              activeIcon: Icon(LucideIcons.layoutDashboard, size: 28),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.clipboardList,
                  size: 20, color: ColorClass.neutral400),
              activeIcon: Icon(LucideIcons.clipboardList, size: 28),
              label: 'Markings',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.messageCircle,
                  size: 24, color: ColorClass.neutral400),
              activeIcon: Icon(LucideIcons.messageCircle, size: 28),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.users,
                  size: 20, color: ColorClass.neutral400),
              activeIcon: Icon(LucideIcons.users, size: 28),
              label: 'Users',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.settings,
                  size: 20, color: ColorClass.neutral400),
              activeIcon: Icon(LucideIcons.settings, size: 28),
              label: 'Settings',
            ),
          ],
          currentIndex: navProvider.selectedIndex,
          onTap: navProvider.setIndex,
        ),
      ),
    );
  }
}

class DateTimeNotifier extends ValueNotifier<DateTime> {
  DateTimeNotifier(DateTime value) : super(value);
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final profileProvider =
          Provider.of<ProfileScreenProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Get auth token
      final token = await authProvider.getAuthToken();
      final userType = await authProvider.getUserType() ?? 'Manager';

      // Set user type immediately for display
      profileProvider.setUserInfo(userType: userType);

      if (token != null && token.isNotEmpty) {
        try {
          await profileProvider.fetchAndSetProfile(
              token: token, userType: userType);
          developer.log('✅ Profile data fetched for Manager',
              name: 'ManagerScreen');
        } catch (e) {
          developer.log('❌ Failed to fetch manager profile: $e',
              name: 'ManagerScreen');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileScreenProvider>(context);

    return Column(
      children: [
        const SizedBox(height: 24),
        ProfileCard(
          userName: profileProvider.userName,
          phone: profileProvider.phone,
          department: profileProvider.department,
          designation: profileProvider.designation,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // Rest of settings items remain unchanged
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
                  final Uri url = Uri.parse('https://d4dx.co/privacy-policy/');
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                },
              ),
              CustomDrawerItem(
                title: 'Contact Us',
                icon: LucideIcons.phone,
                onTap: () {
                  navigatorKey.currentState!.pushNamed(Routes.contactUs);
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
                          onPressed: () => Navigator.of(context).pop(),
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
                        onLogout: () async {
                          final logger = Logger();
                          logger.i(
                              '🔄 [LOGOUT] Manager initiated logout process');
                          developer.log('🔄 Manager initiated logout process',
                              name: 'ManagerScreen');

                          // Reset bottom nav to initial index
                          Provider.of<BottomNavProvider>(
                                  navigatorKey.currentContext!,
                                  listen: false)
                              .setIndex(0);

                          // Call the AuthProvider logout method to clear shared preferences
                          await Provider.of<AuthProvider>(
                                  navigatorKey.currentContext!,
                                  listen: false)
                              .logout();

                          logger.i(
                              '🟢 [LOGOUT] Successfully cleared preferences and updated auth state');
                          developer.log(
                              '🟢 Successfully cleared auth token and preferences',
                              name: 'ManagerScreen');

                          toastification.show(
                            context: context,
                            title: Text('Logged out successfully'),
                            type: ToastificationType.success,
                            autoCloseDuration: const Duration(seconds: 2),
                          );

                          Future.delayed(const Duration(milliseconds: 500), () {
                            logger.i(
                                '🧭 [NAVIGATION] Redirecting to login screen');
                            developer.log('🚀 Redirecting to login screen',
                                name: 'ManagerScreen');
                            navigatePRToGlobal(
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
