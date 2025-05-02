import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:canteen_app/constants/color_class.dart';
import 'package:canteen_app/constants/textstyle_class.dart';
import 'package:canteen_app/providers/date_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MealCountScreen extends StatelessWidget {
  const MealCountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mealPreferences = Provider.of<DateProvider>(context).mealPreferences;
    int breakfastCount = 0;
    int lunchCount = 0;
    int dinnerCount = 0;
    mealPreferences.forEach((date, meals) {
      if (meals['Breakfast'] == true) breakfastCount++;
      if (meals['Lunch'] == true) lunchCount++;
      if (meals['Dinner'] == true) dinnerCount++;
    });
    return Scaffold(
      appBar: AppBar(
        title:  Text('Meal Count',style: TextStyleClass.poppinsSemiBold(fontSize: 20, color: ColorClass.white),),
        backgroundColor: ColorClass.brandDarkGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Marked Meals',
              style: TextStyleClass.poppinsSemiBold(fontSize: 22, color: ColorClass.brandDarkGreen),
            ),
            const SizedBox(height: 8),
            Text(
              'Here is a summary of your marked meals.',
              style: TextStyleClass.poppinsRegular(fontSize: 15, color: ColorClass.neutral500),
            ),
            const SizedBox(height: 32),
            _buildMealCountCard(
              context,
              icon: FontAwesomeIcons.mugHot,
              label: 'Breakfast',
              count: breakfastCount,
              color: ColorClass.orangeBase,
              bgColor: ColorClass.orangeLight,
            ),
            const SizedBox(height: 20),
            _buildMealCountCard(
              context,
              icon: FontAwesomeIcons.utensils,
              label: 'Lunch',
              count: lunchCount,
              color: ColorClass.greenBase,
              bgColor: ColorClass.greenLight,
            ),
            const SizedBox(height: 20),
            _buildMealCountCard(
              context,
              icon: FontAwesomeIcons.bowlFood,
              label: 'Dinner',
              count: dinnerCount,
              color: ColorClass.blueBase,
              bgColor: ColorClass.blueLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCountCard(BuildContext context, {required IconData icon, required String label, required int count, required Color color, required Color bgColor}) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.10),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.18), width: 1.2),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color,
            radius: 28,
            child: FaIcon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Text(
              label,
              style: TextStyleClass.poppinsSemiBold(fontSize: 20, color: color),
            ),
          ),
          Text(
            count.toString(),
            style: TextStyleClass.poppinsBold(fontSize: 32, color: color),
          ),
        ],
      ),
    );
  }
} 