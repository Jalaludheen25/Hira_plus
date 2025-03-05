import 'package:canteen_app/constants/color_class.dart';
import 'package:canteen_app/screens/homescreen/home_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Canteen App',
      theme: ThemeData(
     
        colorScheme: ColorScheme.fromSeed(seedColor: ColorClass.primaryBase),
        useMaterial3: true,
      ),
      home:   CanteenHomePage(),
    );
  }
}


