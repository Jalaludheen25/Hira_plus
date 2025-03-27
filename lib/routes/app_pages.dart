import 'package:canteen_app/routes/app_routes.dart';
import 'package:canteen_app/screens/bottom_nav/bottom_navigation_bar.dart';
import 'package:canteen_app/screens/login_screen/login_screen.dart';
import 'package:canteen_app/screens/profile_screen/profile_screen.dart';
import 'package:canteen_app/screens/splash_screen/splash_screen.dart';
import 'package:canteen_app/screens/homescreen/home_screen.dart';
import 'package:flutter/material.dart';

Map<String, WidgetBuilder> getRoutes() {
  return {
    Routes.splash: (context) => const SplashScreen(),
    Routes.login: (context) => const LoginScreen(),
    Routes.bottomNav: (context) => const BottomNavigationBarScreen(),
    Routes.profile: (context) => const ProfileScreen(),
    Routes.home: (context) => const CanteenHomePage(),
  };
}
