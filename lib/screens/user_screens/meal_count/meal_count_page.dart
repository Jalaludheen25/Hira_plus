import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hira_plus/constants/color_class.dart';
import 'package:hira_plus/constants/textstyle_class.dart';
import 'package:hira_plus/screens/user_screens/user_home_screen/provider/canteen_home_page_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:developer' as dev;

class MealCountScreen extends StatefulWidget {
  const MealCountScreen({Key? key}) : super(key: key);

  @override
  State<MealCountScreen> createState() => _MealCountScreenState();
}

class _MealCountScreenState extends State<MealCountScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch meals when the screen initializes if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final canteenProvider =
          Provider.of<CanteenHomeProvider>(context, listen: false);
      if (canteenProvider.meals.isEmpty) {
        dev.log('🔄 No meals found, fetching meals for MealCountScreen', name: 'MealCountScreen');
        canteenProvider.fetchUserMeals(context);
      } else {
        dev.log('✅ Meals already loaded, count: ${canteenProvider.meals.length}', name: 'MealCountScreen');
      }
    });
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    dev.log('🏗️ Building MealCountScreen', name: 'MealCountScreen');
    final canteenProvider = Provider.of<CanteenHomeProvider>(context);
    
    // Get current month and year for display
    final now = DateTime.now();
    final currentMonth = _getMonthName(now.month);
    final currentYear = now.year;
    
    // Get meal counts for current month
    final mealCounts = canteenProvider.getCurrentMonthMealCounts();
    final breakfastCount = mealCounts['breakfast'] ?? 0;
    final lunchCount = mealCounts['lunch'] ?? 0;
    final dinnerCount = mealCounts['dinner'] ?? 0;
    
    dev.log('📊 Displaying meal counts: B:$breakfastCount, L:$lunchCount, D:$dinnerCount', 
      name: 'MealCountScreen');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Meal Count',
          style: TextStyleClass.poppinsSemiBold(
              fontSize: 20, color: ColorClass.white),
        ),
        backgroundColor: ColorClass.brandDarkGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: canteenProvider.isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Loading your meals..."),
                ],
              ),
            )
          : _buildContent(
              context, 
              currentMonth, 
              currentYear, 
              breakfastCount, 
              lunchCount, 
              dinnerCount
            ),
    );
  }

  Widget _buildContent(
    BuildContext context, 
    String currentMonth, 
    int currentYear, 
    int breakfastCount, 
    int lunchCount, 
    int dinnerCount,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Marked Meals',
            style: TextStyleClass.poppinsSemiBold(
                fontSize: 22, color: ColorClass.brandDarkGreen),
          ),
          const SizedBox(height: 8),
          Text(
            'Here is a summary of your marked meals for $currentMonth $currentYear.',
            style: TextStyleClass.poppinsRegular(
                fontSize: 15, color: ColorClass.neutral500),
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
    );
  }

  Widget _buildMealCountCard(BuildContext context,
      {required IconData icon,
      required String label,
      required int count,
      required Color color,
      required Color bgColor}) {
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