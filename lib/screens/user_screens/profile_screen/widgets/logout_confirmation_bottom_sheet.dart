import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:Hira_Plus/constants/color_class.dart';
import 'package:Hira_Plus/constants/textstyle_class.dart';
import 'package:Hira_Plus/constants/ui_styles.dart';

class LogoutConfirmationBottomSheet extends StatelessWidget {
  final VoidCallback onLogout;
  const LogoutConfirmationBottomSheet({Key? key, required this.onLogout}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: ColorClass.white,
        borderRadius: UiStyles.borderRadius12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(FontAwesomeIcons.exclamationTriangle, size: 40, color: ColorClass.orangeBase),
          const SizedBox(height: 12),
          Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ColorClass.textMain900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorClass.neutral300,
                  shape: RoundedRectangleBorder(
                    borderRadius: UiStyles.borderRadius12,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorClass.neutral300,
                  shape: RoundedRectangleBorder(
                    borderRadius: UiStyles.borderRadius12,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  onLogout();
                },
                child: const Text('Logout', style: TextStyle(color: ColorClass.redBase),),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 