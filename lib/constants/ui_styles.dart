import 'package:canteen_app/constants/color_class.dart';
import 'package:flutter/material.dart';

class UiStyles {
  static BoxDecoration primaryButtonDecoration(
      {Color color = ColorClass.primaryBase}) {
    return BoxDecoration(
      color: ColorClass.white,
      borderRadius: BorderRadius.circular(24.0),
    );
  }

  static BorderRadius borderRadius16 = BorderRadius.circular(16.0);
  static BorderRadius borderRadius12 = BorderRadius.circular(12.0);
  static BorderRadius borderRadius10 = BorderRadius.circular(10);
  static BorderRadius borderRadius5 = BorderRadius.circular(5.0);

  static const double actionIconHeight = 20.0;
  static const double actionIconWidth = 20.0;

  static BoxDecoration boxShadow() {
    return BoxDecoration(
      color: ColorClass.white,
      borderRadius: borderRadius16,
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF6E6C6C).withOpacity(0.14),
          offset: const Offset(0, -0.8269794583320618),
          blurRadius: 28,
          spreadRadius: 0,
        ),
      ],
    );
  }
}
