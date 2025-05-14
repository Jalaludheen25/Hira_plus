import 'package:flutter/material.dart';
import 'package:Hira_Plus/constants/color_class.dart';
import 'package:Hira_Plus/constants/textstyle_class.dart';

class DetailedList extends StatelessWidget {
  final List<Map<String, String>> details;

  const DetailedList({Key? key, required this.details}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: details.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final detail = details[index];
        return Container(
          decoration: BoxDecoration(
            color: ColorClass.neutral100,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail['name'] ?? '',
                      style: TextStyleClass.poppinsMedium(
                        fontSize: 14,
                        color: ColorClass.textMain900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detail['type'] ?? '',
                      style: TextStyleClass.poppinsRegular(
                        fontSize: 12,
                        color: ColorClass.neutral400,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  detail['room'] ?? '',
                  textAlign: TextAlign.end,
                  style: TextStyleClass.poppinsRegular(
                    fontSize: 12,
                    color: ColorClass.neutral400,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 