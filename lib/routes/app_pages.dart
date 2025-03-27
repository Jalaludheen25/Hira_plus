import 'package:canteen_app/routes/app_routes.dart';
import 'package:canteen_app/screens/login_screens/login_screen.dart';
import 'package:canteen_app/screens/splash_screen/splash_screen.dart';
import 'package:flutter/material.dart';

Map<String, WidgetBuilder> getRoutes() {
  return {
    Routes.splash: (context) => const SplashScreen(),
    Routes.login: (context) => const LoginScreen(),
  };
}
