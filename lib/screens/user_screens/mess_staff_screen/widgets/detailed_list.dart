import 'package:flutter/material.dart';
import 'package:canteen_app/constants/textstyle_class.dart';
import 'package:canteen_app/constants/color_class.dart';

class DetailedList extends StatelessWidget {
  final List<Map<String, String>> details;
  const DetailedList({required this.details, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...details.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item['name'] ?? '', style: TextStyleClass.poppinsMedium(fontSize: 16)),
              const SizedBox(height: 2),
              Text(item['type'] ?? '', style: TextStyleClass.poppinsRegular(fontSize: 13, color: ColorClass.neutral400)),
              Text(item['room'] ?? '', style: TextStyleClass.poppinsRegular(fontSize: 13, color: ColorClass.neutral400)),
            ],
          ),
        )),
      ],
    );
  }
} 