import 'package:flutter/material.dart';
import 'package:hira_plus/constants/color_class.dart';
import 'package:hira_plus/constants/textstyle_class.dart';
import 'package:hira_plus/screens/mess_staff_screen/models/bulk_meal_model.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

class BulkMealCardWidget extends StatelessWidget {
  final BulkMealModel guestMeal;

  const BulkMealCardWidget({
    Key? key,
    required this.guestMeal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(guestMeal.date);
    final totalMeals = guestMeal.totalMealCount;
    
    return Container(
      decoration: BoxDecoration(
        color: ColorClass.brandWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ColorClass.brandLightGreen.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ColorClass.brandLightGreen.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formattedDate,
                        style: TextStyleClass.poppinsSemiBold(
                          fontSize: 16,
                          color: ColorClass.brandDarkGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            LucideIcons.building,
                            size: 14,
                            color: ColorClass.neutral400,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              guestMeal.departmentNames,
                              style: TextStyleClass.poppinsRegular(
                                fontSize: 14,
                                color: ColorClass.neutral500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: ColorClass.brandLightGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Total: $totalMeals',
                    style: TextStyleClass.poppinsSemiBold(
                      fontSize: 12,
                      color: ColorClass.brandDarkGreen,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMealInfo('Breakfast', guestMeal.breakfastCount, LucideIcons.sunMedium),
                _buildMealInfo('Lunch', guestMeal.lunchCount, LucideIcons.sun),
                _buildMealInfo('Dinner', guestMeal.dinnerCount, LucideIcons.moon),
              ],
            ),
            if (guestMeal.departments.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(color: ColorClass.neutral200),
              const SizedBox(height: 8),
              Text(
                'Department Breakdown:',
                style: TextStyleClass.poppinsSemiBold(
                  fontSize: 14,
                  color: ColorClass.brandDarkGreen,
                ),
              ),
              const SizedBox(height: 8),
              ...guestMeal.departments.entries.map((entry) => _buildDepartmentRow(entry.key, entry.value)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMealInfo(String label, int count, IconData icon) {
    final hasCount = count > 0;
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: hasCount ? ColorClass.brandDarkGreen : ColorClass.neutral300,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyleClass.poppinsRegular(
              fontSize: 10,
              color: hasCount ? ColorClass.brandDarkGreen : ColorClass.neutral400,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            count.toString(),
            style: TextStyleClass.poppinsBold(
              fontSize: 14,
              color: hasCount ? ColorClass.brandDarkGreen : ColorClass.neutral400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentRow(String departmentName, DepartmentMeal departmentMeal) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              departmentName,
              style: TextStyleClass.poppinsRegular(
                fontSize: 12,
                color: ColorClass.neutral600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSmallMealCount('B', departmentMeal.breakfast),
                _buildSmallMealCount('L', departmentMeal.lunch),
                _buildSmallMealCount('D', departmentMeal.dinner),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallMealCount(String label, int count) {
    final hasCount = count > 0;
    return Container(
      width: 24,
      height: 20,
      decoration: BoxDecoration(
        color: hasCount ? ColorClass.brandLightGreen.withOpacity(0.3) : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: hasCount ? ColorClass.brandDarkGreen : ColorClass.neutral300,
          width: 0.5,
        ),
      ),
      child: Center(
        child: Text(
          count.toString(),
          style: TextStyleClass.poppinsBold(
            fontSize: 10,
            color: hasCount ? ColorClass.brandDarkGreen : ColorClass.neutral400,
          ),
        ),
      ),
    );
  }
}