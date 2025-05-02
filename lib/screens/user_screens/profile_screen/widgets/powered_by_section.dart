import 'package:flutter/material.dart';
import 'package:canteen_app/constants/color_class.dart';
import 'package:canteen_app/constants/icons_class.dart';
import 'package:canteen_app/constants/textstyle_class.dart';

class PoweredBySection extends StatelessWidget {
  const PoweredBySection();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Powered by', style: TextStyleClass.poppinsMedium(fontSize: 14, color: ColorClass.neutral400)),
        const SizedBox(height: 8),
        Image.asset(IconClass.d4dxLogo, height: 76),
      ],
    );
  }
} 