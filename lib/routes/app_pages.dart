import 'package:Hira_Plus/routes/app_routes.dart';
import 'package:Hira_Plus/screens/bottom_nav/bottom_navigation_bar.dart';
import 'package:Hira_Plus/screens/login_screen/login_screen.dart';
import 'package:Hira_Plus/screens/user_screens/profile_screen/profile_screen.dart';
import 'package:Hira_Plus/screens/splash_screen/splash_screen.dart';
import 'package:Hira_Plus/screens/user_screens/user_home_screen/user_home_screen.dart';
import 'package:Hira_Plus/screens/user_screens/contact_us/contact_us_screen.dart';
import 'package:Hira_Plus/screens/user_screens/meal_count/meal_count_page.dart';
import 'package:Hira_Plus/screens/mess_staff_screen/mess_staff_screen.dart';
import 'package:Hira_Plus/screens/manager_screen/manager_screen.dart';
import 'package:Hira_Plus/screens/manager_screen/marking_list_screen.dart';
import 'package:Hira_Plus/screens/manager_screen/users_list_screen.dart';
import 'package:Hira_Plus/screens/forced_update_screen/force_update_screen.dart';
import 'package:flutter/material.dart';

Map<String, WidgetBuilder> getRoutes() {
  return {
    Routes.splash: (context) => const SplashScreen(),
    Routes.login: (context) => const LoginScreen(),
    Routes.bottomNav: (context) => const BottomNavigationBarScreen(),
    Routes.profile: (context) => const ProfileScreen(),
    Routes.home: (context) => const UserHomeScreen(),
    Routes.contactUs: (context) => const ContactUsScreen(),
    Routes.mealCount: (context) => const MealCountScreen(),
    Routes.messStaff: (context) => const MessStaffScreen(),
    Routes.manager: (context) => const ManagerScreen(),
    Routes.markingList: (context) => MarkingListScreen(),
    Routes.usersList: (context) => UsersListScreen(),
    Routes.forceUpdate: (context) => const ForceUpdatePage(),
  };
}
