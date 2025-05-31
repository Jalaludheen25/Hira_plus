import 'package:flutter/material.dart';
import 'package:hira_plus/screens/mess_staff_screen/provider/mess_bulk_meal_provider.dart';
import 'package:hira_plus/screens/mess_staff_screen/widgets/bulk_meal_card_widget.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import 'package:hira_plus/screens/profile_screen/provider/profile_screen_provider.dart';
import 'package:hira_plus/screens/user_screens/user_home_screen/widgets/custom_drawer.dart';
import 'package:hira_plus/constants/color_class.dart';
import 'package:hira_plus/constants/textstyle_class.dart';
import 'package:shake_flutter/enums/shake_screen.dart';
import 'package:shake_flutter/shake_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hira_plus/screens/mess_staff_screen/provider/mess_staff_meal_provider.dart';
import 'package:pdf/widgets.dart' as pw;
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hira_plus/screens/profile_screen/widgets/logout_confirmation_bottom_sheet.dart';
import 'package:toastification/toastification.dart';
import 'package:hira_plus/utils/navigation_helper.dart';
import 'package:hira_plus/routes/app_routes.dart';
import 'package:hira_plus/screens/bottom_nav/provider/bottom_nav_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../widgets/progress_dialog.dart';
import '../widgets/bottom_button.dart';
import 'package:hira_plus/screens/profile_screen/widgets/profile_card.dart';
import 'package:hira_plus/screens/profile_screen/widgets/powered_by_section.dart';
import 'package:hira_plus/screens/login_screen/provider/auth_provider.dart';
import 'package:logger/logger.dart';

class MessStaffScreen extends StatefulWidget {
  const MessStaffScreen({super.key});

  @override
  State<MessStaffScreen> createState() => _MessStaffScreenState();
}

class _MessStaffScreenState extends State<MessStaffScreen> {
  final Logger _logger = Logger();
  final ValueNotifier<int?> _selectedMealNotifier = ValueNotifier<int?>(null);
  final ValueNotifier<DateTime> _bulkMealDateNotifier = ValueNotifier<DateTime>(DateTime.now());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _logger.i('🏗️ [INIT] Initializing Mess Staff screen');
      developer.log('🏗️ Initializing Mess Staff screen and profile data', name: 'MessStaffScreen');
      
      final profileProvider = Provider.of<ProfileScreenProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Get auth token
      final token = await authProvider.getAuthToken();
      final userType = await authProvider.getUserType() ?? 'Mess Staff';
      
      if (token != null && token.isNotEmpty) {
        // Make sure to set the user type first for immediate display
        profileProvider.setUserInfo(userType: userType);
        
        // Then fetch full profile
        try {
          await profileProvider.fetchAndSetProfile(token: token, userType: userType);
          _logger.i('✅ [PROFILE] Profile data fetched successfully');
          developer.log('✅ Profile data fetched for Mess Staff', name: 'MessStaffScreen');
        } catch (e) {
          _logger.e('❌ [PROFILE] Failed to fetch profile: $e');
          developer.log('❌ Failed to fetch profile: $e', name: 'MessStaffScreen');
        }
      } else {
        // Just set user type if no token
        profileProvider.setUserInfo(userType: userType);
        _logger.w('⚠️ [PROFILE] No token available, using default profile');
      }
      
      // Fetch meal data
      final mealProvider = Provider.of<MessStaffMealProvider>(context, listen: false);
      mealProvider.reset();
      mealProvider.fetchMessStaffMeals(context);

      // Fetch guest meal data
      final guestMealProvider = Provider.of<MessBulkMealProvider>(context, listen: false);
      guestMealProvider.fetchGuestMeals(context);
    });
  }

  @override
  void dispose() {
    _selectedMealNotifier.dispose();
    _bulkMealDateNotifier.dispose();
    super.dispose();
  }

  // Show detailed list bottom sheet
  void _showDetailedListBottomSheet(
    BuildContext context,
    String mealLabel,
    List<Map<String, String>> details,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: ColorClass.brandWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: ColorClass.neutral300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$mealLabel - Detailed List',
                    style: TextStyleClass.poppinsSemiBold(fontSize: 18),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      LucideIcons.x,
                      color: ColorClass.neutral500,
                    ),
                  ),
                ],
              ),
            ),
            
            // Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Total: ${details.length}',
                    style: TextStyleClass.poppinsBold(
                      fontSize: 16,
                      color: ColorClass.brandDarkGreen,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            // List content
            Expanded(
              child: details.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.users,
                            size: 48,
                            color: ColorClass.neutral300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No users found for this meal',
                            style: TextStyleClass.poppinsRegular(
                              fontSize: 16,
                              color: ColorClass.neutral400,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: details.length,
                      itemBuilder: (context, index) {
                        final item = details[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: ColorClass.neutral200,
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'] ?? '',
                                style: TextStyleClass.poppinsMedium(fontSize: 16),
                              ),
                              if (item['type']?.isNotEmpty == true) ...[
                                const SizedBox(height: 2),
                                Text(
                                  item['type']!,
                                  style: TextStyleClass.poppinsRegular(
                                    fontSize: 13,
                                    color: ColorClass.neutral400,
                                  ),
                                ),
                              ],
                              if (item['room']?.isNotEmpty == true) ...[
                                const SizedBox(height: 1),
                                Text(
                                  item['room']!,
                                  style: TextStyleClass.poppinsRegular(
                                    fontSize: 13,
                                    color: ColorClass.neutral400,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Define the pages for the bottom navigation - now just 2 tabs
  List<Widget> _pages(BuildContext context) => [
        // Home tab (previously Meal Summary)
        _buildHomeTab(context),
        // Settings tab (includes profile info now)
        _buildSettingsTab(context),
      ];

  Widget _buildMealCard({
    required IconData icon,
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final hasCount = count > 0;
    return GestureDetector(
      onTap: hasCount ? onTap : null,
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
        decoration: BoxDecoration(
          color: isSelected ? ColorClass.brandLightGreen : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? ColorClass.brandLightGreen
                : ColorClass.neutral200,
            width: 1.5,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: ColorClass.brandLightGreen.withOpacity(0.08),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 28,
              color: hasCount
                  ? ColorClass.brandDarkGreen
                  : ColorClass.neutral300,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyleClass.poppinsRegular(
                fontSize: 12,
                color: hasCount
                    ? ColorClass.brandDarkGreen
                    : ColorClass.neutral400,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              count.toString(),
              style: TextStyleClass.poppinsBold(
                fontSize: 16,
                color: hasCount
                    ? ColorClass.brandDarkGreen
                    : ColorClass.neutral400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context) {
    return Consumer2<MessStaffMealProvider, MessBulkMealProvider>(
      builder: (context, mealProvider, messBulkMealProvider, _) {
        // Get meal counts from provider
        final mealCounts = mealProvider.getTodayMealCounts();

        // Use the counts from API but keep existing structure
        final List<Map<String, dynamic>> mealSummary = [
          {
            'label': 'Breakfast',
            'icon': LucideIcons.sunMedium,
            'count': mealCounts['breakfast'] ?? 0
          },
          {
            'label': 'Lunch',
            'icon': LucideIcons.sun,
            'count': mealCounts['lunch'] ?? 0
          },
          {
            'label': 'Dinner',
            'icon': LucideIcons.moon,
            'count': mealCounts['dinner'] ?? 0
          },
        ];

        // Get today's guest meals
        messBulkMealProvider.getTodayGuestMeals();

        if (mealProvider.isLoading && messBulkMealProvider.isLoading) {
          return const SafeArea(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                mealProvider.fetchMessStaffMeals(context),
                messBulkMealProvider.fetchGuestMeals(context),
              ]);
            },
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Meal Summary Section
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          child: Text('Meal Summary - Today',
                              style: TextStyleClass.poppinsSemiBold(fontSize: 18)),
                        ),
                        const SizedBox(height: 12),
                        
                        // Meal Cards Row - Fixed layout
                        SizedBox(
                          height: 110,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: ValueListenableBuilder<int?>(
                              valueListenable: _selectedMealNotifier,
                              builder: (context, selectedMeal, _) => Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: List.generate(
                                  mealSummary.length,
                                  (index) => _buildMealCard(
                                    icon: mealSummary[index]['icon'] as IconData,
                                    label: mealSummary[index]['label'] as String,
                                    count: mealSummary[index]['count'] as int,
                                    isSelected: selectedMeal == index,
                                    onTap: () {
                                      // Update selection state and show bottom sheet
                                      _selectedMealNotifier.value = index;
                                      final detailedLists = mealProvider.getMealDetailsList(index);
                                      final mealLabel = mealSummary[index]['label'] as String;
                                      mealProvider.selectMeal(index); // Update provider for share/print
                                      _showDetailedListBottomSheet(context, mealLabel, detailedLists);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Bulk Meals Section
                        if (messBulkMealProvider.guestMeals.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 32),
                                
                                // Section header with date picker
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          LucideIcons.users,
                                          size: 20,
                                          color: ColorClass.brandDarkGreen,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Bulk Food Bookings',
                                          style: TextStyleClass.poppinsSemiBold(fontSize: 18),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ValueListenableBuilder<DateTime>(
                                      valueListenable: _bulkMealDateNotifier,
                                      builder: (context, selectedDate, _) => GestureDetector(
                                        onTap: () => _selectBulkMealDate(context),
                                        child: Row(
                                          children: [
                                            Text(
                                              DateFormat('dd MMM yyyy').format(selectedDate),
                                              style: TextStyleClass.poppinsMedium(fontSize: 14),
                                            ),
                                            const SizedBox(width: 4),
                                            const Icon(Icons.calendar_today, size: 16),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                
                                // Bulk meal cards filtered by selected date
                                ValueListenableBuilder<DateTime>(
                                  valueListenable: _bulkMealDateNotifier,
                                  builder: (context, selectedDate, _) {
                                    final filteredGuestMeals = messBulkMealProvider.getGuestMealsForDate(selectedDate);
                                    
                                    if (filteredGuestMeals.isEmpty) {
                                      return Container(
                                        padding: const EdgeInsets.all(20),
                                        child: Center(
                                          child: Column(
                                            children: [
                                              Icon(
                                                LucideIcons.calendarOff,
                                                size: 48,
                                                color: ColorClass.neutral300,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'No bulk bookings for this date',
                                                style: TextStyleClass.poppinsRegular(
                                                  fontSize: 14,
                                                  color: ColorClass.neutral400,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                    
                                    return Column(
                                      children: filteredGuestMeals.map((guestMeal) => Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: BulkMealCardWidget(guestMeal: guestMeal),
                                      )).toList(),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Add bottom padding for better spacing
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                
                // Bottom Buttons (Fixed at bottom)
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      BottomButton(
                        label: 'Share',
                        onTap: () {
                          final selectedIndex = mealProvider.selectedMeal;
                          final mealLabel = mealSummary[selectedIndex]['label'] as String;
                          final detailedLists = mealProvider.getMealDetailsList(selectedIndex);
                          generateAndSharePdf(
                            context, 
                            mealLabel, 
                            detailedLists,
                            messBulkMealProvider,
                            shareInsteadOfOpen: true
                          );
                        },
                      ),
                      BottomButton(
                        label: 'Print',
                        onTap: () {
                          final selectedIndex = mealProvider.selectedMeal;
                          final mealLabel = mealSummary[selectedIndex]['label'] as String;
                          final detailedLists = mealProvider.getMealDetailsList(selectedIndex);
                          generateAndSharePdf(
                            context, 
                            mealLabel, 
                            detailedLists,
                            messBulkMealProvider,
                            shareInsteadOfOpen: false
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Date picker for bulk meals
  void _selectBulkMealDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _bulkMealDateNotifier.value,
      firstDate: DateTime(2022),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _bulkMealDateNotifier.value) {
      _bulkMealDateNotifier.value = picked;
    }
  }

  Widget _buildSettingsTab(BuildContext context) {
    final profileProvider = Provider.of<ProfileScreenProvider>(context);
    
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Use ProfileScreenProvider values for the profile card
              ProfileCard(
                userName: profileProvider.userName,
                phone: profileProvider.phone,
                department: profileProvider.department,
                designation: profileProvider.designation,
              ),
              const SizedBox(height: 32),
              CustomDrawerItem(
                title: 'Feedback',
                icon: LucideIcons.messageCircle,
                onTap: () async {
                  final Uri emailLaunchUri = Uri(
                    scheme: 'mailto',
                    path: 'mail@d4dx.co',
                  );
                  await launchUrl(emailLaunchUri);
                },
              ),
              CustomDrawerItem(
                title: 'Privacy Policy',
                icon: LucideIcons.shieldCheck,
                onTap: () async {
                  final Uri url = Uri.parse(
                      'https://www.termsfeed.com/live/4e2e2e2e-privacy-policy');
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                },
              ),
              CustomDrawerItem(
                title: 'Contact Us',
                icon: LucideIcons.phone,
                onTap: () {
                  // Using navigation helper
                  navigateTo(
                    context: context,
                    route: Routes.contactUs,
                  );
                },
              ),
              CustomDrawerItem(
                title: 'About Us',
                icon: LucideIcons.info,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('About Us'),
                      content:
                          const Text('This is dummy content for About Us.'),
                      actions: [
                        TextButton(
                          onPressed: () => navigateBack(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              CustomDrawerItem(
                title: 'Raise a bug',
                icon: LucideIcons.bug,
                onTap: () {
                  Shake.show(ShakeScreen.home);
                },
              ),
              const Divider(),
              CustomDrawerItem(
                title: 'Logout',
                icon: LucideIcons.logOut,
                isDestructive: true,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    builder: (BuildContext context) {
                      return LogoutConfirmationBottomSheet(
                          onLogout: () async {
                        final logger = Logger();
                        logger.i(
                            '🔄 [LOGOUT] Mess Staff initiated logout process');
                        developer.log(
                            '🔄 Mess Staff initiated logout process',
                            name: 'MessStaffScreen');

                        // First clear all provider data
                        await Provider.of<MessStaffMealProvider>(
                                navigatorKey.currentContext!,
                                listen: false)
                            .clearData();

                        // Clear guest meal provider data
                        await Provider.of<MessBulkMealProvider>(
                                navigatorKey.currentContext!,
                                listen: false)
                            .clearData();

                        // Reset bottom nav to initial index
                        Provider.of<BottomNavProvider>(
                                navigatorKey.currentContext!,
                                listen: false)
                            .setIndex(0);

                        // Call the AuthProvider logout method to clear shared preferences
                        await Provider.of<AuthProvider>(
                                navigatorKey.currentContext!,
                                listen: false)
                            .logout();

                        logger.i(
                            '🟢 [LOGOUT] Successfully cleared preferences and updated auth state');
                        developer.log(
                            '🟢 Successfully cleared auth token and preferences',
                            name: 'MessStaffScreen');

                        toastification.show(
                          context: context,
                          title: const Text('Logged out successfully'),
                          type: ToastificationType.success,
                          autoCloseDuration: const Duration(seconds: 2),
                        );

                        Future.delayed(const Duration(milliseconds: 500), () {
                          logger.i(
                              '🧭 [NAVIGATION] Redirecting to login screen');
                          developer.log('🚀 Redirecting to login screen',
                              name: 'MessStaffScreen');
                          // Using navigation helper
                          navigatePRToGlobal(
                            route: Routes.login,
                          );
                        });
                      }
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              PoweredBySection(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // PDF generation and sharing methods
  Future<void> showProgressDialog(
      BuildContext context, ValueNotifier<double> progress) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProgressDialog(progress: progress),
    );
  }

  Future<void> generateAndSharePdf(
    BuildContext context,
    String mealLabel,
    List<Map<String, String>> details,
    MessBulkMealProvider bulkMealProvider, {
    bool shareInsteadOfOpen = false,
  }) async {
    final progress = ValueNotifier<double>(0.0);
    showProgressDialog(context, progress);

    File? file;
    try {
      final pdf = pw.Document();
      
      // Get bulk meal data for today based on selected meal type
      final todayBulkMeals = bulkMealProvider.getTodayGuestMeals();
      int bulkMealCount = 0;
      String mealType = mealLabel.toLowerCase();
      
      for (final bulkMeal in todayBulkMeals) {
        switch (mealType) {
          case 'breakfast':
            bulkMealCount += bulkMeal.breakfastCount;
            break;
          case 'lunch':
            bulkMealCount += bulkMeal.lunchCount;
            break;
          case 'dinner':
            bulkMealCount += bulkMeal.dinnerCount;
            break;
        }
      }
      
      final total = details.length;
      for (int i = 0; i < total; i++) {
        progress.value = (i + 1) / (total + 1);
        await Future.delayed(const Duration(milliseconds: 200));
      }
      
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('$mealLabel - Detailed List',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text('Date: ${DateTime.now().toString().substring(0, 10)}',
                  style: pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Regular Meals: ${details.length}',
                      style: pw.TextStyle(
                          fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  if (bulkMealCount > 0)
                    pw.Text('Extra Meals ($mealLabel): $bulkMealCount',
                        style: pw.TextStyle(
                            fontSize: 16, 
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green)),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text('Total: ${details.length + bulkMealCount}',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 16),
              
              // Regular meal details
              if (details.isNotEmpty) ...[
                pw.Text('Regular Meals:',
                    style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                ...details.map((item) => pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(item['name'] ?? '',
                            style: pw.TextStyle(
                                fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        pw.Text(item['type'] ?? '',
                            style: pw.TextStyle(fontSize: 12)),
                        pw.Text(item['room'] ?? '',
                            style: pw.TextStyle(fontSize: 12)),
                        pw.SizedBox(height: 6),
                      ],
                    )),
              ],
              
              // Bulk meal details
              if (bulkMealCount > 0) ...[
                pw.SizedBox(height: 16),
                pw.Text('Extra Meals ($mealLabel):',
                    style: pw.TextStyle(
                        fontSize: 16, 
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green)),
                pw.SizedBox(height: 8),
                ...todayBulkMeals.map((bulkMeal) {
                  int mealCount = 0;
                  switch (mealType) {
                    case 'breakfast':
                      mealCount = bulkMeal.breakfastCount;
                      break;
                    case 'lunch':
                      mealCount = bulkMeal.lunchCount;
                      break;
                    case 'dinner':
                      mealCount = bulkMeal.dinnerCount;
                      break;
                  }
                  
                  if (mealCount > 0) {
                    return pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Department: ${bulkMeal.departmentNames}',
                            style: pw.TextStyle(
                                fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Count: $mealCount',
                            style: pw.TextStyle(fontSize: 12)),
                        pw.Text('Date: ${DateFormat('dd MMM yyyy').format(bulkMeal.date)}',
                            style: pw.TextStyle(fontSize: 12)),
                        pw.SizedBox(height: 6),
                      ],
                    );
                  }
                  return pw.SizedBox.shrink();
                }),
              ],
            ],
          ),
        ),
      );
      
      progress.value = 1.0;
      final output = await getTemporaryDirectory();
      file = File('${output.path}/$mealLabel-detailed-list.pdf');
      await file.writeAsBytes(await pdf.save());
      Navigator.of(context, rootNavigator: true).pop();
      
      if (shareInsteadOfOpen) {
        await Share.shareXFiles([XFile(file.path)],
            text: '$mealLabel - Detailed List');
      } else {
        await OpenFile.open(file.path);
        showDialog(
          context: context,
          builder: (ctx) => Dialog(
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PDF Generated',
                    style: TextStyleClass.poppinsBold(
                        fontSize: 20, color: ColorClass.brandDarkGreen),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Would you like to share this PDF?',
                    style: TextStyleClass.poppinsMedium(
                        fontSize: 16, color: ColorClass.neutral400),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: ColorClass.brandDarkGreen,
                          textStyle:
                              TextStyleClass.poppinsSemiBold(fontSize: 16),
                        ),
                        onPressed: () async {
                          // Using navigation helper
                          navigateBack(ctx);
                          if (file != null) {
                            await Share.shareXFiles([XFile(file.path)],
                                text: '$mealLabel - Detailed List');
                          }
                        },
                        child: const Text('Share'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: ColorClass.neutral400,
                          textStyle: TextStyleClass.poppinsMedium(fontSize: 16),
                        ),
                        onPressed: () => navigateBack(ctx),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final logger = Logger();
    logger.i('🏗️ [UI] Building Mess Staff screen');
    developer.log('🏗️ Building Mess Staff screen interface',
        name: 'MessStaffScreen');

    final navProvider = Provider.of<BottomNavProvider>(context);
    final tabTitles = ['Home', 'Settings'];

    return WillPopScope(
      onWillPop: () async {
        return navProvider.shouldExitOnBack(context);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: ColorClass.brandDarkGreen,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            tabTitles[navProvider.selectedIndex],
            style: TextStyleClass.poppinsSemiBold(
              fontSize: 20,
              color: ColorClass.white,
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: _pages(context)[navProvider.selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: ColorClass.brandWhite,
          selectedItemColor: ColorClass.brandDarkGreen,
          unselectedItemColor: Color.fromARGB(255, 63, 94, 43),
          currentIndex: navProvider.selectedIndex,
          unselectedLabelStyle: TextStyleClass.poppinsSemiBold(
            fontSize: 14,
          ),
          onTap: navProvider.setIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.home,
                  size: 28, color: Color.fromARGB(255, 63, 94, 43)),
              activeIcon: Icon(
                LucideIcons.home,
                size: 32,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.settings,
                  size: 28, color: Color.fromARGB(255, 63, 94, 43)),
              activeIcon: Icon(LucideIcons.settings, size: 32),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}