import 'package:flutter/material.dart';
import 'package:canteen_app/constants/textstyle_class.dart';

class BottomButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const BottomButton({required this.label, required this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F4F3),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyleClass.poppinsSemiBold(fontSize: 16, color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }
} 