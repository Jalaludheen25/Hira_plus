import 'package:flutter/material.dart';
import 'package:hira_plus/screens/mess_staff_screen/provider/meeting_food_provider.dart';
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
import 'package:hira_plus/screens/mess_staff_screen/models/meeting_food_model.dart';
import 'package:hira_plus/screens/mess_staff_screen/widgets/meeting_food_widget.dart';

class MessStaffScreen extends StatefulWidget {
  const MessStaffScreen({super.key});

  @override
  State<MessStaffScreen> createState() => _MessStaffScreenState();
}

class _MessStaffScreenState extends State<MessStaffScreen> {
  final Logger _logger = Logger();
  final ValueNotifier<int?> _selectedMealNotifier = ValueNotifier<int?>(null);
  final ValueNotifier<DateTime> _bulkMealDateNotifier = ValueNotifier<DateTime>(DateTime.now());
  final ValueNotifier<DateTime> _meetingFoodDateNotifier = ValueNotifier<DateTime>(DateTime.now());

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
        profileProvider.setUserInfo(userType: userType);
        
        try {
          await profileProvider.fetchAndSetProfile(token: token, userType: userType);
          _logger.i('✅ [PROFILE] Profile data fetched successfully');
          developer.log('✅ Profile data fetched for Mess Staff', name: 'MessStaffScreen');
        } catch (e) {
          _logger.e('❌ [PROFILE] Failed to fetch profile: $e');
          developer.log('❌ Failed to fetch profile: $e', name: 'MessStaffScreen');
        }
      } else {
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

      // Fetch meeting food requirements
      final meetingFoodProvider = Provider.of<MeetingFoodProvider>(context, listen: false);
      meetingFoodProvider.fetchMeetingFoodRequirements(context);
    });
  }

  @override
  void dispose() {
    _selectedMealNotifier.dispose();
    _bulkMealDateNotifier.dispose();
    _meetingFoodDateNotifier.dispose();
    super.dispose();
  }

  // Show detailed list bottom sheet for regular meals
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

  // Method to generate PDF for meeting food requirements
  Future<void> _generateMeetingFoodPdf(BuildContext context, {bool shareInsteadOfOpen = false}) async {
    final meetingFoodProvider = context.read<MeetingFoodProvider>();
    final selectedDate = _meetingFoodDateNotifier.value;
    final todayMeetingTotals = meetingFoodProvider.getTotalCountsForDate(selectedDate);
    // Filter meetings to only those with food requirements
    final List<Meeting> meetings = meetingFoodProvider
        .getMeetingsForDate(selectedDate)
        .where((meeting) => meeting.foodCounts.activeFoodItems.isNotEmpty)
        .toList();
    
    if (todayMeetingTotals == null || meetings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No meeting food data available to export')),
      );
      return;
    }

    try {
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Text(
                'Meeting Food Requirements',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Date: ${DateFormat('dd MMM yyyy').format(selectedDate)}',
                style: pw.TextStyle(fontSize: 16),
              ),
              pw.SizedBox(height: 16),
              // Food items summary
              pw.Text(
                'Food Requirements:',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),
              ...todayMeetingTotals.activeFoodItems.map((item) => 
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('${item.name}:', style: pw.TextStyle(fontSize: 14)),
                      pw.Text('${item.count}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              // Meetings details
              pw.Text(
                'Meeting Details (${meetings.length} meetings):',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 12),
              ...meetings.map((meeting) => 
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Department: ${meeting.department}', style: pw.TextStyle(fontSize: 12)),
                    pw.Text('Created by: ${meeting.createdBy}', style: pw.TextStyle(fontSize: 12)),
                    if (meeting.foodCounts.activeFoodItems.isNotEmpty) ...[
                      pw.SizedBox(height: 4),
                      pw.Text('Food Requirements:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      ...meeting.foodCounts.activeFoodItems.map((food) => 
                        pw.Text('  • ${food.name}: ${food.count}', style: pw.TextStyle(fontSize: 11)),
                      ),
                    ],
                    pw.SizedBox(height: 12),
                    pw.Divider(),
                    pw.SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File('${output.path}/meeting-food-requirements-${DateFormat('yyyy-MM-dd').format(selectedDate)}.pdf');
      await file.writeAsBytes(await pdf.save());

      if (shareInsteadOfOpen) {
        await Share.shareXFiles([XFile(file.path)],
            text: 'Meeting Food Requirements - ${DateFormat('dd MMM yyyy').format(selectedDate)}');
      } else {
        await OpenFile.open(file.path);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(shareInsteadOfOpen 
              ? 'PDF shared successfully' 
              : 'PDF generated and opened'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Define the pages for the bottom navigation - back to 2 tabs
  List<Widget> _pages(BuildContext context) => [
        // Home tab (Meal Summary + Meeting Food if available)
        _buildHomeTab(context),
        // Settings tab
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
    return Consumer3<MessStaffMealProvider, MessBulkMealProvider, MeetingFoodProvider>(
      builder: (context, mealProvider, messBulkMealProvider, meetingFoodProvider, _) {
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
                meetingFoodProvider.fetchMeetingFoodRequirements(context),
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
                                ).toList(),
                              ),
                            ),
                          ),
                        ),
                        // Bulk Meals Section
                        _buildBulkMealsSection(context, messBulkMealProvider),
                        // Meeting Food Widget (new implementation)
                        const MeetingFoodWidget(),
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
                          final mealSummary = [
                            {'label': 'Breakfast'},
                            {'label': 'Lunch'},
                            {'label': 'Dinner'},
                          ];
                          final mealLabel = mealSummary[selectedIndex]['label'] as String;
                          final detailedLists = mealProvider.getMealDetailsList(selectedIndex);
                          generateAndShareAllPdf(
                            context,
                            mealLabel,
                            detailedLists,
                            messBulkMealProvider,
                            meetingFoodProvider,
                            shareInsteadOfOpen: true
                          );
                        },
                      ),
                      BottomButton(
                        label: 'Print',
                        onTap: () {
                          final selectedIndex = mealProvider.selectedMeal;
                          final mealSummary = [
                            {'label': 'Breakfast'},
                            {'label': 'Lunch'},
                            {'label': 'Dinner'},
                          ];
                          final mealLabel = mealSummary[selectedIndex]['label'] as String;
                          final detailedLists = mealProvider.getMealDetailsList(selectedIndex);
                          generateAndShareAllPdf(
                            context,
                            mealLabel,
                            detailedLists,
                            messBulkMealProvider,
                            meetingFoodProvider,
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

  // Meeting Food Requirements Section as a separate widget
  Widget _buildMeetingFoodSection(BuildContext context, MeetingFoodProvider meetingFoodProvider) {
    return ValueListenableBuilder<DateTime>(
      valueListenable: _meetingFoodDateNotifier,
      builder: (context, selectedDate, _) {
        // Filter meetings to only those with food requirements
        final List<Meeting> meetings = meetingFoodProvider
            .getMeetingsForDate(selectedDate)
            .where((meeting) => meeting.foodCounts.activeFoodItems.isNotEmpty)
            .toList();
        final bool hasMeetings = meetings.isNotEmpty;
        final meetingTotals = meetingFoodProvider.getTotalCountsForDate(selectedDate);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              // Meeting Food Section Header with Date Picker
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorClass.brandLightGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ColorClass.brandLightGreen.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              LucideIcons.calendar,
                              size: 20,
                              color: ColorClass.brandDarkGreen,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Meeting Food Requirements',
                              style: TextStyleClass.poppinsSemiBold(fontSize: 18),
                            ),
                          ],
                        ),
                        if (hasMeetings && meetingTotals != null && meetingTotals.totalCount > 0) ...[
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => _generateMeetingFoodPdf(context, shareInsteadOfOpen: true),
                                icon: Icon(LucideIcons.share2, color: ColorClass.brandDarkGreen, size: 20),
                                tooltip: 'Share Meeting Food PDF',
                              ),
                              IconButton(
                                onPressed: () => _generateMeetingFoodPdf(context, shareInsteadOfOpen: false),
                                icon: Icon(LucideIcons.printer, color: ColorClass.brandDarkGreen, size: 20),
                                tooltip: 'Print Meeting Food PDF',
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Date picker
                    GestureDetector(
                      onTap: () => _selectMeetingFoodDate(context, meetingFoodProvider),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: ColorClass.brandLightGreen),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.calendar, size: 16, color: ColorClass.brandDarkGreen),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('dd MMM yyyy').format(selectedDate),
                              style: TextStyleClass.poppinsMedium(fontSize: 14),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.keyboard_arrow_down, color: ColorClass.brandDarkGreen, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Show meeting food details if available
              if (hasMeetings) ...[
                if (meetingTotals != null && meetingTotals.totalCount > 0) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ColorClass.brandLightGreen.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ColorClass.brandLightGreen.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Meeting Food:',
                              style: TextStyleClass.poppinsMedium(fontSize: 16),
                            ),
                            Text(
                              meetingTotals.totalCount.toString(),
                              style: TextStyleClass.poppinsBold(
                                fontSize: 18,
                                color: ColorClass.brandDarkGreen,
                              ),
                            ),
                          ],
                        ),
                        if (meetingTotals.activeFoodItems.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: meetingTotals.activeFoodItems
                                .map((foodItem) => _buildMeetingFoodCountCard(foodItem))
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  'Meetings (${meetings.length})',
                  style: TextStyleClass.poppinsSemiBold(fontSize: 16),
                ),
                const SizedBox(height: 8),
                ...meetings.map((meeting) => _buildMeetingCard(meeting)).toList(),
              ] else ...[
                Container(
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
                          'No meetings for this date',
                          style: TextStyleClass.poppinsRegular(
                            fontSize: 14,
                            color: ColorClass.neutral400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // Bulk Meals Section as a separate widget
  Widget _buildBulkMealsSection(BuildContext context, MessBulkMealProvider messBulkMealProvider) {
    if (messBulkMealProvider.guestMeals.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
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
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: ColorClass.brandLightGreen),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.calendar, size: 16, color: ColorClass.brandDarkGreen),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('dd MMM yyyy').format(selectedDate),
                          style: TextStyleClass.poppinsMedium(fontSize: 14),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.keyboard_arrow_down, color: ColorClass.brandDarkGreen, size: 16),
                      ],
                    ),
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
    );
  }

  // Date picker for meeting food requirements
    void _selectMeetingFoodDate(BuildContext context, MeetingFoodProvider provider) async {
    final availableDates = provider.availableDates;
    
    if (availableDates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No meeting dates available')),
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _meetingFoodDateNotifier.value,
      firstDate: availableDates.first,
      lastDate: availableDates.last,
      selectableDayPredicate: (date) => provider.hasDataForDate(date),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ColorClass.brandDarkGreen,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _meetingFoodDateNotifier.value) {
      _meetingFoodDateNotifier.value = picked;
    }
  }

  // Date picker for bulk meals
  void _selectBulkMealDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _bulkMealDateNotifier.value,
      firstDate: DateTime(2022),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ColorClass.brandDarkGreen,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _bulkMealDateNotifier.value) {
      _bulkMealDateNotifier.value = picked;
    }
  }

  // Helper method to build meeting food count cards
  Widget _buildMeetingFoodCountCard(dynamic foodItem) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: ColorClass.brandDarkGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: ColorClass.brandDarkGreen.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            foodItem.name,
            style: TextStyleClass.poppinsRegular(
              fontSize: 12,
              color: ColorClass.brandDarkGreen,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: ColorClass.brandDarkGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              foodItem.count.toString(),
              style: TextStyleClass.poppinsBold(
                fontSize: 10,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build meeting cards
  Widget _buildMeetingCard(dynamic meeting) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ColorClass.neutral200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meeting title and time
          Row(
            children: [
              Expanded(
                child: Text(
                  meeting.title,
                  style: TextStyleClass.poppinsSemiBold(fontSize: 15),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ColorClass.brandLightGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  meeting.timeRange,
                  style: TextStyleClass.poppinsRegular(
                    fontSize: 11,
                    color: ColorClass.brandDarkGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Department and created by
          Row(
            children: [
              Icon(LucideIcons.building, size: 14, color: ColorClass.neutral400),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Department: ${meeting.department}',
                  style: TextStyleClass.poppinsRegular(
                    fontSize: 13,
                    color: ColorClass.neutral600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(LucideIcons.user, size: 14, color: ColorClass.neutral400),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Created by: ${meeting.createdBy}',
                  style: TextStyleClass.poppinsRegular(
                    fontSize: 13,
                    color: ColorClass.neutral600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(LucideIcons.mapPin, size: 14, color: ColorClass.neutral400),
              const SizedBox(width: 4),
              Text(
                'Hall: ${meeting.hall}',
                style: TextStyleClass.poppinsRegular(
                  fontSize: 13,
                  color: ColorClass.neutral600,
                ),
              ),
              const SizedBox(width: 12),
              Icon(LucideIcons.users, size: 14, color: ColorClass.neutral400),
              const SizedBox(width: 4),
              Text(
                'Persons: ${meeting.noOfPersons}',
                style: TextStyleClass.poppinsRegular(
                  fontSize: 13,
                  color: ColorClass.neutral600,
                ),
              ),
            ],
          ),
          
          // Food requirements for this meeting
          if (meeting.foodCounts.activeFoodItems.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Food Requirements:',
              style: TextStyleClass.poppinsMedium(fontSize: 13),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: meeting.foodCounts.activeFoodItems
                  .map((foodItem) => _buildMeetingFoodCountCard(foodItem))
                  .toList(),
            ),
          ],
        ],
      ),
    );
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

                        // Clear meeting food provider data
                        await Provider.of<MeetingFoodProvider>(
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

  // Combined PDF generation for all three sections
Future<void> generateAndShareAllPdf(
  BuildContext context,
  String mealLabel,
  List<Map<String, String>> details,
  MessBulkMealProvider bulkMealProvider,
  MeetingFoodProvider meetingFoodProvider, {
  bool shareInsteadOfOpen = false,
}) async {
  final progress = ValueNotifier<double>(0.0);
  showProgressDialog(context, progress);
  File? file;
  
  try {
    final pdf = pw.Document();
    final todayBulkMeals = bulkMealProvider.getTodayGuestMeals();
    
    // Calculate bulk meal count for the specific meal type
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
    
    // Get meeting food data
    final selectedDate = _meetingFoodDateNotifier.value;
    final todayMeetingTotals = meetingFoodProvider.getTotalCountsForDate(selectedDate);
    final List<Meeting> meetings = meetingFoodProvider
        .getMeetingsForDate(selectedDate)
        .where((meeting) => meeting.foodCounts.activeFoodItems.isNotEmpty)
        .toList();
    
    // Calculate total meeting food count
    int meetingFoodCount = todayMeetingTotals?.totalCount ?? 0;
    
    // Calculate grand total
    int regularMealCount = details.length;
    int grandTotal = regularMealCount + bulkMealCount + meetingFoodCount;
    
    // Helper function to create header
    pw.Widget _buildHeader() {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header with title and total count on the right
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                '$mealLabel - Detailed List',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey600),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Total Count',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      grandTotal.toString(),
                      style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Date: ${DateTime.now().toString().substring(0, 10)}',
            style: pw.TextStyle(fontSize: 14),
          ),
          pw.SizedBox(height: 16),
          
          // Count breakdown
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                pw.Column(
                  children: [
                    pw.Text('Regular Meals', style: pw.TextStyle(fontSize: 12)),
                    pw.Text(regularMealCount.toString(), style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Text('Bulk Meals', style: pw.TextStyle(fontSize: 12)),
                    pw.Text(bulkMealCount.toString(), style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Text('Meeting Food', style: pw.TextStyle(fontSize: 12)),
                    pw.Text(meetingFoodCount.toString(), style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
        ],
      );
    }

    // Helper function to create page footer
    pw.Widget _buildPageFooter(int pageNumber) {
      return pw.Container(
        alignment: pw.Alignment.center,
        margin: const pw.EdgeInsets.only(top: 20),
        child: pw.Text(
          'Page $pageNumber',
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
      );
    }

    // Create content widgets list
    List<pw.Widget> contentWidgets = [];

    // --- Regular Meal Section ---
    if (details.isNotEmpty) {
      contentWidgets.add(
        pw.Text(
          'Regular Meals (${details.length})',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
      );
      contentWidgets.add(pw.SizedBox(height: 8));
      
      // Add regular meal items in batches to prevent overflow
      const int itemsPerBatch = 15; // Adjust based on your needs
      for (int i = 0; i < details.length; i += itemsPerBatch) {
        final batch = details.skip(i).take(itemsPerBatch).toList();
        contentWidgets.add(
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: batch.map((item) => pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    item['name'] ?? '',
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                  ),
                  if ((item['type'] ?? '').isNotEmpty)
                    pw.Text(item['type']!, style: pw.TextStyle(fontSize: 12)),
                  if ((item['room'] ?? '').isNotEmpty)
                    pw.Text(item['room']!, style: pw.TextStyle(fontSize: 12)),
                ],
              ),
            )).toList(),
          ),
        );
        
        // Add page break if not the last batch
        if (i + itemsPerBatch < details.length) {
          contentWidgets.add(pw.NewPage());
        }
      }
      contentWidgets.add(pw.SizedBox(height: 20));
    }

    // --- Bulk Meal Section ---
    if (bulkMealCount > 0) {
      contentWidgets.add(
        pw.Text(
          'Bulk Food Meals (${bulkMealCount})',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
      );
      contentWidgets.add(pw.SizedBox(height: 8));
      
      final bulkMealWidgets = <pw.Widget>[];
      for (final bulkMeal in todayBulkMeals) {
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
          bulkMealWidgets.add(
            pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Department: ${bulkMeal.departmentNames}',
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text('Count: $mealCount', style: pw.TextStyle(fontSize: 12)),
                  pw.Text(
                    'Date: ${DateFormat('dd MMM yyyy').format(bulkMeal.date)}',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        }
      }
      
      contentWidgets.addAll(bulkMealWidgets);
      contentWidgets.add(pw.SizedBox(height: 20));
    }

    // --- Meeting Food Section ---
    if (todayMeetingTotals != null && todayMeetingTotals.totalCount > 0) {
      contentWidgets.add(
        pw.Text(
          'Meeting Food Requirements (${meetingFoodCount})',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
      );
      contentWidgets.add(pw.SizedBox(height: 8));
      contentWidgets.add(
        pw.Text(
          'Date: ${DateFormat('dd MMM yyyy').format(selectedDate)}',
          style: pw.TextStyle(fontSize: 14),
        ),
      );
      contentWidgets.add(pw.SizedBox(height: 12));
      
      // Food requirements table
      contentWidgets.add(
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400),
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Column(
            children: [
              // Table header
              pw.Row(
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(
                      'Food Item',
                      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Text(
                      'Count',
                      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Divider(),
              pw.SizedBox(height: 8),
              
              // Food items
              ...todayMeetingTotals.activeFoodItems.map((item) => 
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 6),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        flex: 3,
                        child: pw.Text(
                          item.name,
                          style: pw.TextStyle(fontSize: 12),
                        ),
                      ),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Text(
                          item.count.toString(),
                          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Total row
              pw.Divider(),
              pw.SizedBox(height: 6),
              pw.Row(
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(
                      'Total Meeting Food',
                      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Text(
                      todayMeetingTotals.totalCount.toString(),
                      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
      contentWidgets.add(pw.SizedBox(height: 12));
      
      // Meeting count summary
      contentWidgets.add(
        pw.Text(
          'From ${meetings.length} meeting(s) on ${DateFormat('dd MMM yyyy').format(selectedDate)}',
          style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
        ),
      );
    }

    // Build pages with automatic page breaks
    int pageNumber = 1;
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        header: (pw.Context context) {
          return context.pageNumber == 1 ? _buildHeader() : pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 20),
            child: pw.Text(
              '$mealLabel - Detailed List (Continued)',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          );
        },
        footer: (pw.Context context) {
          final currentPage = context.pageNumber;
          final totalPages = context.pagesCount;
          return pw.Container(
            alignment: pw.Alignment.center,
            margin: const pw.EdgeInsets.only(top: 20),
            child: pw.Text(
              'Page $currentPage of $totalPages',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
          );
        },
        build: (pw.Context context) {
          return contentWidgets;
        },
      ),
    );
    
    progress.value = 1.0;
    final output = await getTemporaryDirectory();
    file = File('${output.path}/$mealLabel-complete-summary-${DateTime.now().toString().substring(0, 10)}.pdf');
    await file.writeAsBytes(await pdf.save());
    Navigator.of(context, rootNavigator: true).pop();
    
    if (shareInsteadOfOpen) {
      await Share.shareXFiles([XFile(file.path)], text: '$mealLabel Complete Summary');
    } else {
      await OpenFile.open(file.path);
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PDF Generated',
                  style: TextStyleClass.poppinsBold(fontSize: 20, color: ColorClass.brandDarkGreen),
                ),
                const SizedBox(height: 12),
                Text(
                  'Would you like to share this PDF?',
                  style: TextStyleClass.poppinsMedium(fontSize: 16, color: ColorClass.neutral400),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: ColorClass.brandDarkGreen,
                        textStyle: TextStyleClass.poppinsSemiBold(fontSize: 16),
                      ),
                      onPressed: () async {
                        navigateBack(ctx);
                        if (file != null) {
                          await Share.shareXFiles([XFile(file.path)], text: '$mealLabel Complete Summary');
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
    final tabTitles = ['Home', 'Settings']; // Back to 2 tabs

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