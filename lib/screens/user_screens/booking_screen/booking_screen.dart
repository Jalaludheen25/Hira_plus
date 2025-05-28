import 'package:flutter/material.dart';
import 'package:hira_plus/constants/color_class.dart';
import 'package:hira_plus/constants/textstyle_class.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            'Bookings',
            style: TextStyleClass.primaryFont500(20, ColorClass.white),
          ),
          backgroundColor: ColorClass.brandDarkGreen,
          elevation: 0,
          iconTheme: const IconThemeData(color: ColorClass.white),
        ),
      body: const Center(child: Text('Bookings Screen (Dept Head Only)')),
    );
  }
}