import 'package:canteen_app/constants/color_class.dart';
import 'package:canteen_app/providers/multi_provider.dart';
import 'package:canteen_app/routes/app_pages.dart';
import 'package:canteen_app/routes/app_routes.dart';
import 'package:canteen_app/utils/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: getProviders(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        title: 'Canteen App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: ColorClass.primaryBase),
          useMaterial3: true,
        ),
        initialRoute: Routes.splash,
        routes: getRoutes(),
      ),
    );
  }
}
