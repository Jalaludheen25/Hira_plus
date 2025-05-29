import 'package:flutter/material.dart';
import 'package:hira_plus/constants/color_class.dart';
import 'package:hira_plus/constants/textstyle_class.dart';
import 'package:hira_plus/screens/manager_screen/provider/manager_bulk_food_provider.dart';
import 'package:hira_plus/screens/manager_screen/models/manager_guest_meal_model.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:hira_plus/utils/navigation_helper.dart';
import 'manager_bulk_food_mark_screen.dart';
import 'dart:developer' as developer;
import 'package:logger/logger.dart';

class ManagerBulkFoodListScreen extends StatefulWidget {
  const ManagerBulkFoodListScreen({Key? key}) : super(key: key);

  @override
  State<ManagerBulkFoodListScreen> createState() => _ManagerBulkFoodListScreenState();
}

class _ManagerBulkFoodListScreenState extends State<ManagerBulkFoodListScreen> {
  late ManagerBulkFoodProvider _provider;
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    _logger.i('🏗️ [INIT] Initializing Manager Bulk Food List Screen');
    developer.log('🏗️ Initializing Manager Bulk Food List Screen', name: 'ManagerBulkFoodListScreen');
    
    _provider = ManagerBulkFoodProvider();
    Future.microtask(() {
      _logger.i('🔄 [DATA] Fetching guest meals data');
      developer.log('🔄 Fetching guest meals data', name: 'ManagerBulkFoodListScreen');
      _provider.fetchGuestMeals(context);
    });
  }

  @override
  void dispose() {
    _logger.i('🧹 [DISPOSE] Disposing Manager Bulk Food List Screen');
    developer.log('🧹 Disposing Manager Bulk Food List Screen', name: 'ManagerBulkFoodListScreen');
    _provider.dispose();
    super.dispose();
  }

  void _navigateToMarkScreen() {
    _logger.i('🧭 [NAVIGATION] Navigating to mark screen for new booking');
    developer.log('🧭 Navigating to mark screen for new booking', name: 'ManagerBulkFoodListScreen');
    
    navigateToWidget(
      context: context,
      route: ChangeNotifierProvider.value(
        value: _provider,
        child: const ManagerBulkFoodMarkScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<ManagerBulkFoodProvider>(
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
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  _logger.i('🔙 [NAVIGATION] Navigating back from bulk food list');
                  developer.log('🔙 Navigating back from bulk food list', name: 'ManagerBulkFoodListScreen');
                  navigateBack(context);
                },
              ),
            ),
            body: _buildBody(provider),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: _navigateToMarkScreen,
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

  Widget _buildBody(ManagerBulkFoodProvider provider) {
    if (provider.isLoading) {
      _logger.d('🔄 [UI] Showing loading state');
      developer.log('🔄 Showing loading state', name: 'ManagerBulkFoodListScreen');
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
      _logger.e('❌ [ERROR] Error state: ${provider.errorMessage}');
      developer.log('❌ Error state: ${provider.errorMessage}', name: 'ManagerBulkFoodListScreen');
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
              onPressed: () {
                _logger.i('🔄 [ACTION] Retry button pressed');
                developer.log('🔄 Retry button pressed', name: 'ManagerBulkFoodListScreen');
                provider.fetchGuestMeals(context);
              },
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
      developer.log('📭 Showing empty state', name: 'ManagerBulkFoodListScreen');
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
    
    _logger.d('📋 [UI] Showing bookings list with ${provider.guestMeals.length} items');
    developer.log('📋 Showing bookings list with ${provider.guestMeals.length} items', name: 'ManagerBulkFoodListScreen');
    
    return RefreshIndicator(
      onRefresh: () {
        _logger.i('🔄 [ACTION] Pull to refresh triggered');
        developer.log('🔄 Pull to refresh triggered', name: 'ManagerBulkFoodListScreen');
        return provider.fetchGuestMeals(context);
      },
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

  Widget _buildBookingCard(ManagerGuestMealModel guestMeal) {
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
                              guestMeal.department,
                              style: TextStyleClass.poppinsRegular(
                                fontSize: 14,
                                color: ColorClass.neutral500,
                              ),
                              maxLines: 1,
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
            const SizedBox(height: 16),
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
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

  void _showDeleteDialog(ManagerGuestMealModel guestMeal) {
    _logger.i('🗑️ [ACTION] Delete dialog shown for booking: ${guestMeal.id}');
    developer.log('🗑️ Delete dialog shown for booking: ${guestMeal.id}', name: 'ManagerBulkFoodListScreen');
    
    // Store provider reference before showing dialog to avoid context issues
    final provider = _provider;
    
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
                _logger.d('❌ [ACTION] Delete cancelled');
                developer.log('❌ Delete cancelled', name: 'ManagerBulkFoodListScreen');
                Navigator.of(dialogContext).pop();
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
                Navigator.of(dialogContext).pop();
                
                _logger.i('🗑️ [API] Attempting to delete booking with id: ${guestMeal.id}');
                developer.log('🗑️ Attempting to delete booking with id: ${guestMeal.id}', name: 'ManagerBulkFoodListScreen');
                
                final success = await provider.deleteGuestMeal(context, guestMeal.id);
                
                _logger.i('📥 [API] Delete result for id ${guestMeal.id}: $success');
                developer.log('📥 Delete result for id ${guestMeal.id}: $success', name: 'ManagerBulkFoodListScreen');
                
                if (success) {
                  _logger.i('✅ [SUCCESS] Booking deleted successfully');
                  developer.log('✅ Booking deleted successfully', name: 'ManagerBulkFoodListScreen');
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Booking deleted successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } else {
                  _logger.e('❌ [ERROR] Failed to delete booking');
                  developer.log('❌ Failed to delete booking', name: 'ManagerBulkFoodListScreen');
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to delete booking'),
                        backgroundColor: Colors.red,
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

  void _editBooking(ManagerGuestMealModel guestMeal) {
    _logger.i('✏️ [NAVIGATION] Navigating to edit booking: ${guestMeal.id}');
    developer.log('✏️ Navigating to edit booking: ${guestMeal.id}', name: 'ManagerBulkFoodListScreen');
    
    navigateToWidget(
      context: context,
      route: ChangeNotifierProvider.value(
        value: _provider,
        child: ManagerBulkFoodMarkScreen(
          editingMeal: guestMeal,
        ),
      ),
    );
  }
}
