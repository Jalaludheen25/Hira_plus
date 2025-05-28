import 'package:flutter/material.dart';
import 'package:hira_plus/constants/color_class.dart';
import 'package:hira_plus/constants/textstyle_class.dart';
import 'package:hira_plus/screens/user_screens/booking_screen/view/bulk_food_list_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bookings',
          style: TextStyleClass.primaryFont500(20, ColorClass.white),
        ),
        backgroundColor: ColorClass.brandDarkGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: ColorClass.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Bulk Food Booking Card
            _buildBookingCard(
              context: context,
              title: 'Bulk Food Booking',
              subtitle: 'Book meals for guests in bulk',
              icon: LucideIcons.utensils,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BulkFoodListScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // Hall Booking Card (Dummy)
            _buildBookingCard(
              context: context,
              title: 'Hall Booking',
              subtitle: 'Book halls for events (Coming Soon)',
              icon: LucideIcons.building,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Hall booking feature coming soon!'),
                    backgroundColor: ColorClass.brandDarkGreen,
                  ),
                );
              },
              isEnabled: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isEnabled = true,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isEnabled ? ColorClass.brandWhite : ColorClass.neutral100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isEnabled ? ColorClass.brandLightGreen : ColorClass.neutral200,
            width: 1.5,
          ),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: ColorClass.brandLightGreen.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isEnabled
                    ? ColorClass.brandLightGreen.withOpacity(0.2)
                    : ColorClass.neutral200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 28,
                color: isEnabled ? ColorClass.brandDarkGreen : ColorClass.neutral400,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyleClass.poppinsSemiBold(
                      fontSize: 18,
                      color: isEnabled ? ColorClass.brandDarkGreen : ColorClass.neutral400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyleClass.poppinsRegular(
                      fontSize: 14,
                      color: isEnabled ? ColorClass.neutral500 : ColorClass.neutral400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              color: isEnabled ? ColorClass.brandDarkGreen : ColorClass.neutral400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}