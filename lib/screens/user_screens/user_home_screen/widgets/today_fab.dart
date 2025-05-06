import 'package:flutter/material.dart';
import 'package:Hira_Plus/constants/color_class.dart';
import 'package:Hira_Plus/constants/textstyle_class.dart';

class TodayFAB extends StatelessWidget {
  final VoidCallback onPressed;
  const TodayFAB({required this.onPressed, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      label: Text(
        'Today',
        style: TextStyleClass.poppinsRegular(
          fontSize: 14,
          color: ColorClass.brandDarkGreen,
        ),
      ),
      backgroundColor: ColorClass.brandLightGreen,
    );
  }
} 