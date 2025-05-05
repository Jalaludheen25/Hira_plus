import 'package:flutter/material.dart';
import 'package:canteen_app/constants/color_class.dart';
import 'package:canteen_app/constants/textstyle_class.dart';

class DeleteConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  const DeleteConfirmDialog({
    required this.title,
    required this.content,
    this.confirmText = 'Delete',
    this.cancelText = 'Cancel',
    required this.onConfirm,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title, style: TextStyleClass.poppinsBold(fontSize: 18, color: ColorClass.brandDarkGreen)),
      content: Text(content, style: TextStyleClass.poppinsRegular(fontSize: 16, color: ColorClass.textMain900)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: ColorClass.neutral400,
            textStyle: TextStyleClass.poppinsMedium(fontSize: 16),
          ),
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          style: TextButton.styleFrom(
            foregroundColor: ColorClass.redDark,
            textStyle: TextStyleClass.poppinsBold(fontSize: 16),
          ),
          child: Text(confirmText),
        ),
      ],
    );
  }
} 