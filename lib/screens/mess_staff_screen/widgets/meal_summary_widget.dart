import 'package:flutter/material.dart';
import 'package:hira_plus/constants/color_class.dart';
import 'package:hira_plus/constants/textstyle_class.dart';

class MealSummaryWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final bool isSelected;
  const MealSummaryWidget({
    required this.icon,
    required this.label,
    required this.count,
    this.isSelected = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.40,
      height: 80,
      decoration: BoxDecoration(
        color: isSelected ? ColorClass.brandLightGreen : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isSelected ? ColorClass.brandLightGreen : ColorClass.neutral200,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: ColorClass.brandDarkGreen),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyleClass.poppinsSemiBold(fontSize: 16)),
              Text(count.toString(),
                  style: TextStyleClass.poppinsBold(fontSize: 22)),
            ],
          ),
        ],
      ),
    );
  }
}
