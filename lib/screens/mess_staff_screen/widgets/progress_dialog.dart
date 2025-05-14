import 'package:flutter/material.dart';
import 'package:hira_plus/constants/color_class.dart';
import 'package:hira_plus/constants/textstyle_class.dart';

class ProgressDialog extends StatelessWidget {
  final ValueNotifier<double> progress;
  const ProgressDialog({required this.progress, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: progress,
      builder: (context, value, _) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: ColorClass.neutral200,
                valueColor:
                    AlwaysStoppedAnimation<Color>(ColorClass.brandLightGreen),
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 24),
              Text(
                '${(value * 100).toStringAsFixed(0)}%',
                style: TextStyleClass.poppinsBold(
                    fontSize: 22, color: ColorClass.brandDarkGreen),
              ),
              const SizedBox(height: 10),
              Text(
                'Generating PDF...',
                style: TextStyleClass.poppinsMedium(
                    fontSize: 16, color: ColorClass.neutral400),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
