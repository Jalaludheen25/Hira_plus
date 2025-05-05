import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:canteen_app/providers/bottom_nav_provider.dart';
import 'package:canteen_app/constants/color_class.dart';
import 'package:canteen_app/constants/textstyle_class.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:canteen_app/screens/mess_staff_screen/widgets/meal_summary_widget.dart';
import 'package:canteen_app/screens/mess_staff_screen/widgets/detailed_list.dart';
import 'package:canteen_app/screens/mess_staff_screen/widgets/bottom_button.dart';
import 'package:canteen_app/screens/manager_screen/marking_list_screen.dart';
import 'package:canteen_app/screens/manager_screen/users_list_screen.dart';
import 'package:canteen_app/screens/user_screens/profile_screen/profile_screen.dart';
import 'package:canteen_app/providers/profile_screen_provider.dart';
import 'package:canteen_app/screens/user_screens/user_home_screen/widgets/custom_drawer.dart';
import 'package:canteen_app/screens/user_screens/profile_screen/widgets/profile_card.dart';
import 'package:canteen_app/screens/user_screens/profile_screen/widgets/powered_by_section.dart';
import 'package:canteen_app/screens/user_screens/profile_screen/widgets/logout_confirmation_bottom_sheet.dart';
import 'package:canteen_app/utils/navigation_helper.dart';
import 'package:canteen_app/routes/app_routes.dart';
import 'package:shake_flutter/shake_flutter.dart';
import 'package:shake_flutter/enums/shake_screen.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';

class ManagerScreen extends StatelessWidget {
  const ManagerScreen({Key? key}) : super(key: key);

  static final List<Map<String, dynamic>> mealSummary = [
    {'label': 'Breakfast', 'icon': LucideIcons.sunMedium, 'count': 45},
    {'label': 'Lunch', 'icon': LucideIcons.sun, 'count': 60},
    {'label': 'Dinner', 'icon': LucideIcons.moon, 'count': 50},
  ];

  static final List<List<Map<String, String>>> detailedLists = [
    [
      {'name': 'Jenny Miller', 'type': 'Vegetarian', 'room': 'Room 102'},
      {'name': 'Lisa Smith', 'type': 'Regular', 'room': 'Room 103'},
    ],
    [
      {'name': 'Sara Johnson', 'type': 'Vegan', 'room': 'Room 104'},
      {'name': 'Tom Brown', 'type': 'Vegetarian', 'room': 'Room 105'},
    ],
    [
      {'name': 'Emily White', 'type': 'Regular', 'room': 'Room 106'},
      {'name': 'John Doe', 'type': 'Vegan', 'room': 'Room 107'},
    ],
  ];

  static List<Widget> _pages(BuildContext context) => [
    // Dashboard tab
    SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Meal Summary', style: TextStyleClass.poppinsSemiBold(fontSize: 18)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children: [
                MealSummaryWidget(
                  icon: LucideIcons.sunMedium,
                  label: 'Breakfast',
                  count: 45,
                  isSelected: false,
                ),
                MealSummaryWidget(
                  icon: LucideIcons.sun,
                  label: 'Lunch',
                  count: 60,
                  isSelected: false,
                ),
                MealSummaryWidget(
                  icon: LucideIcons.moon,
                  label: 'Dinner',
                  count: 50,
                  isSelected: false,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    // Markings tab
    MarkingListScreen(showAppBar: false),
    // Users tab
    UsersListScreen(),
    // Settings tab
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<BottomNavProvider>(context);
    final tabTitles = ['Dashboard', 'Markings', 'Users', 'Settings'];
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: MarkingListScreen(showAppBar: false),
            )
          : _pages(context)[navProvider.selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: ColorClass.brandWhite,
        selectedItemColor: ColorClass.brandDarkGreen,
        unselectedItemColor: ColorClass.brandLightGreen,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.layoutDashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.clipboardList),
            label: 'Markings',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.users),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: navProvider.selectedIndex,
        onTap: navProvider.setIndex,
      ),
    );
  }
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
                  final Uri url = Uri.parse('https://www.termsfeed.com/live/4e2e2e2e-privacy-policy');
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
                      content: const Text('This is dummy content for About Us.'),
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
                        onLogout: () {
                          Provider.of<BottomNavProvider>(navigatorKey.currentContext!, listen: false).setIndex(0);
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