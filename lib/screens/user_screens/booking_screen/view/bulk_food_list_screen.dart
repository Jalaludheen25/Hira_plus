import 'package:flutter/material.dart';
import 'package:hira_plus/constants/color_class.dart';
import 'package:hira_plus/constants/textstyle_class.dart';
import 'package:hira_plus/screens/user_screens/booking_screen/view/bulk_food_booking_screen.dart';
import 'package:hira_plus/screens/user_screens/booking_screen/provider/bulk_food_provider.dart';
import 'package:hira_plus/screens/user_screens/booking_screen/model/guest_meal_model.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:developer' as developer;
import 'package:logger/logger.dart';
import 'package:flutter/cupertino.dart';

class BulkFoodListScreen extends StatefulWidget {
  const BulkFoodListScreen({Key? key}) : super(key: key);

  @override
  State<BulkFoodListScreen> createState() => _BulkFoodListScreenState();
}

class _BulkFoodListScreenState extends State<BulkFoodListScreen> {
  final Logger _logger = Logger();
  late BulkFoodProvider _provider;

  @override
  void initState() {
    super.initState();
    _logger.i('📋 [BULK_LIST] Initializing Bulk Food List screen');
    developer.log('📋 Initializing Bulk Food List screen',
        name: 'BulkFoodList');

    // Initialize provider and fetch data immediately
    _provider = BulkFoodProvider();

    _logger.i('🔄 [INIT] Auto-fetching guest meals on screen load');
    developer.log('🔄 Auto-fetching guest meals on screen load',
        name: 'BulkFoodList');

    // Fetch data immediately without waiting for post frame callback
    Future.microtask(() => _provider.fetchGuestMeals(context));
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  void _navigateToBookingScreen() {
    _logger.i('🚀 [NAVIGATION] Navigating to bulk food booking screen');
    developer.log('🚀 Navigating to bulk food booking screen',
        name: 'BulkFoodList');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BulkFoodBookingScreen(),
      ),
    );
  }

  void _editBooking(GuestMealModel guestMeal) {
    _logger.i('✏️ [EDIT] Editing booking: ${guestMeal.id}');
    developer.log('✏️ Editing booking: ${guestMeal.id}', name: 'BulkFoodList');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BulkFoodBookingScreen(
          editingMeal: guestMeal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<BulkFoodProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: ColorClass.brandWhite,
            appBar: AppBar(
              title: Text(
                'Bulk Food Bookings',
                style: TextStyleClass.poppinsSemiBold(
                  fontSize: 20,
                  color: ColorClass.white,
                ),
              ),
              backgroundColor: ColorClass.brandDarkGreen,
              elevation: 0,
              iconTheme: const IconThemeData(color: ColorClass.white),
            ),
            body: _buildBody(provider),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: _navigateToBookingScreen,
              backgroundColor: ColorClass.brandDarkGreen,
              foregroundColor: Colors.white,
              icon: const Icon(LucideIcons.plus),
              label: const Text('New Booking'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BulkFoodProvider provider) {
    if (provider.isLoading) {
      _logger.d('⏳ [UI] Showing loading state');
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoActivityIndicator(radius: 20),
            SizedBox(height: 16),
            Text('Loading bookings...'),
          ],
        ),
      );
    }

    if (provider.errorMessage.isNotEmpty) {
      _logger.w('⚠️ [UI] Showing error state: ${provider.errorMessage}');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.alertCircle,
              size: 48,
              color: ColorClass.neutral400,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                provider.errorMessage,
                textAlign: TextAlign.center,
                style: TextStyleClass.poppinsMedium(
                  fontSize: 16,
                  color: ColorClass.neutral500,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => provider.fetchGuestMeals(context),
              icon: const Icon(LucideIcons.refreshCw),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorClass.brandDarkGreen,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (provider.guestMeals.isEmpty) {
      _logger.d('📭 [UI] Showing empty state');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.calendarOff,
              size: 64,
              color: ColorClass.neutral300,
            ),
            const SizedBox(height: 16),
            Text(
              'No Bookings Found',
              style: TextStyleClass.poppinsSemiBold(
                fontSize: 20,
                color: ColorClass.neutral500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first bulk food booking using the "New Booking" button below',
              textAlign: TextAlign.center,
              style: TextStyleClass.poppinsRegular(
                fontSize: 16,
                color: ColorClass.neutral400,
              ),
            ),
          ],
        ),
      );
    }

    _logger.d('📋 [UI] Showing ${provider.guestMeals.length} bookings');
    return RefreshIndicator(
      onRefresh: () => provider.fetchGuestMeals(context),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: provider.guestMeals.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final guestMeal = provider.guestMeals[index];
          return _buildBookingCard(guestMeal);
        },
      ),
    );
  }

  Widget _buildBookingCard(GuestMealModel guestMeal) {
    final formattedDate =
        DateFormat('EEEE, MMMM d, yyyy').format(guestMeal.date);
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
            // Header Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formattedDate,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyleClass.poppinsSemiBold(
                          fontSize: 16,
                          color: ColorClass.brandDarkGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        guestMeal.department,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyleClass.poppinsRegular(
                          fontSize: 14,
                          color: ColorClass.neutral500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Total meals badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

            // Meal breakdown
            SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMealInfo(
                    'Breakfast',
                    guestMeal.breakfastCount,
                    LucideIcons.sunMedium,
                  ),
                  _buildMealInfo(
                    'Lunch',
                    guestMeal.lunchCount,
                    LucideIcons.sun,
                  ),
                  _buildMealInfo(
                    'Dinner',
                    guestMeal.dinnerCount,
                    LucideIcons.moon,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editBooking(guestMeal),
                    icon: Icon(
                      LucideIcons.edit,
                      size: 14,
                      color: ColorClass.brandDarkGreen,
                    ),
                    label: Text(
                      'Edit',
                      style: TextStyleClass.poppinsMedium(
                        fontSize: 12,
                        color: ColorClass.brandDarkGreen,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: ColorClass.brandLightGreen),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showDeleteDialog(guestMeal),
                    icon: Icon(
                      LucideIcons.trash2,
                      size: 14,
                      color: ColorClass.redDark,
                    ),
                    label: Text(
                      'Delete',
                      style: TextStyleClass.poppinsMedium(
                        fontSize: 12,
                        color: ColorClass.redDark,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: ColorClass.redLight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                    ),
                  ),
                ),
              ],
            ),

            // Timestamps
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Created: ${DateFormat('MMM d, h:mm a').format(guestMeal.createdAt)}',
                  style: TextStyleClass.poppinsRegular(
                    fontSize: 11,
                    color: ColorClass.neutral400,
                  ),
                ),
                if (guestMeal.createdAt != guestMeal.updatedAt)
                  Text(
                    'Updated: ${DateFormat('MMM d, h:mm a').format(guestMeal.updatedAt)}',
                    style: TextStyleClass.poppinsRegular(
                      fontSize: 11,
                      color: ColorClass.neutral400,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealInfo(String label, int count, IconData icon) {
    final hasCount = count > 0;

    return Container(
      width: 80, // Fixed width to prevent overflow
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
              color:
                  hasCount ? ColorClass.brandDarkGreen : ColorClass.neutral400,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            count.toString(),
            style: TextStyleClass.poppinsBold(
              fontSize: 14,
              color:
                  hasCount ? ColorClass.brandDarkGreen : ColorClass.neutral400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(GuestMealModel guestMeal) {
    _logger.i('🗑️ [DELETE] Confirmation dialog for: ${guestMeal.id}');
    developer.log('🗑️ Delete confirmation for: ${guestMeal.id}',
        name: 'BulkFoodList');

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'Delete Booking',
            style: TextStyleClass.poppinsSemiBold(
              fontSize: 18,
              color: ColorClass.brandDarkGreen,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this booking for ${DateFormat('MMMM d, yyyy').format(guestMeal.date)}?',
            style: TextStyleClass.poppinsRegular(
              fontSize: 16,
              color: ColorClass.neutral600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _logger.d('❌ [DELETE] Deletion cancelled');
                developer.log('❌ Deletion cancelled', name: 'BulkFoodList');
              },
              child: Text(
                'Cancel',
                style: TextStyleClass.poppinsMedium(
                  fontSize: 14,
                  color: ColorClass.neutral500,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                // Close dialog first
                Navigator.of(dialogContext).pop();

                _logger.i('🗑️ [DELETE] Deleting booking: ${guestMeal.id}');
                developer.log('🗑️ Deleting booking: ${guestMeal.id}',
                    name: 'BulkFoodList');

                // Store the context reference before async operation
                final scaffoldContext = context;

                try {
                  final provider =
                      Provider.of<BulkFoodProvider>(context, listen: false);
                  final success =
                      await provider.deleteGuestMeal(context, guestMeal.id);

                  // Double check if the widget is still mounted and context is still valid
                  if (mounted && scaffoldContext.mounted) {
                    if (success) {
                      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                        const SnackBar(
                          content: Text('Booking deleted successfully'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                        SnackBar(
                          content: Text(provider.errorMessage.isNotEmpty
                              ? provider.errorMessage
                              : 'Failed to delete booking'),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  // Log the error but don't try to show SnackBar if widget is disposed
                  _logger.e('💥 [DELETE] Error during deletion: $e');
                  developer.log('💥 Error during deletion: $e',
                      name: 'BulkFoodList');

                  // Only show SnackBar if widget is still mounted
                  if (mounted && scaffoldContext.mounted) {
                    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                      SnackBar(
                        content:
                            Text('Failed to delete booking: ${e.toString()}'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                }
              },
              child: Text(
                'Delete',
                style: TextStyleClass.poppinsMedium(
                  fontSize: 14,
                  color: ColorClass.redDark,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
