import 'package:flutter/material.dart';
import 'package:hira_plus/screens/mess_staff_screen/provider/meeting_food_provider.dart';
import 'package:hira_plus/screens/mess_staff_screen/provider/mess_bulk_meal_provider.dart';
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
import 'package:hira_plus/screens/profile_screen/widgets/profile_card.dart';
import 'package:hira_plus/screens/profile_screen/widgets/powered_by_section.dart';
import 'package:hira_plus/screens/login_screen/provider/auth_provider.dart';
import 'package:logger/logger.dart';
import 'package:hira_plus/screens/mess_staff_screen/models/meeting_food_model.dart';
import 'package:hira_plus/constants/global_variables.dart';
import 'food_menu_list_screen.dart';

class MessStaffScreen extends StatefulWidget {
  const MessStaffScreen({super.key});

  @override
  State<MessStaffScreen> createState() => _MessStaffScreenState();
}

class _MessStaffScreenState extends State<MessStaffScreen> {
  final Logger _logger = Logger();
  final ValueNotifier<int?> _selectedMealNotifier = ValueNotifier<int?>(null);
  final ValueNotifier<DateTime> _bulkMealDateNotifier =
      ValueNotifier<DateTime>(DateTime.now());
  final ValueNotifier<DateTime> _meetingFoodDateNotifier =
      ValueNotifier<DateTime>(DateTime.now());
  bool _showPrintShareBar = false;

  // Track expanded meeting cards
  final Set<String> _expandedMeetings = <String>{};

  // Track expanded guest meal cards
  final Set<String> _expandedGuestMeals = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _logger.i('🏗️ [INIT] Initializing Mess Staff screen');
      developer.log('🏗️ Initializing Mess Staff screen and profile data',
          name: 'MessStaffScreen');

      final profileProvider =
          Provider.of<ProfileScreenProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Get auth token
      final token = await authProvider.getAuthToken();
      final userType = await authProvider.getUserType() ?? 'Mess Staff';

      if (token != null && token.isNotEmpty) {
        profileProvider.setUserInfo(userType: userType);

        try {
          await profileProvider.fetchAndSetProfile(
              token: token, userType: userType);
          _logger.i('✅ [PROFILE] Profile data fetched successfully');
          developer.log('✅ Profile data fetched for Mess Staff',
              name: 'MessStaffScreen');
        } catch (e) {
          _logger.e('❌ [PROFILE] Failed to fetch profile: $e');
          developer.log('❌ Failed to fetch profile: $e',
              name: 'MessStaffScreen');
        }
      } else {
        profileProvider.setUserInfo(userType: userType);
        _logger.w('⚠️ [PROFILE] No token available, using default profile');
      }

      // Fetch meal data
      final mealProvider =
          Provider.of<MessStaffMealProvider>(context, listen: false);
      mealProvider.reset();
      mealProvider.fetchMessStaffMeals(context);

      // Fetch guest meal data
      final guestMealProvider =
          Provider.of<MessBulkMealProvider>(context, listen: false);
      guestMealProvider.fetchGuestMeals(context);

      // Fetch meeting food requirements
      final meetingFoodProvider =
          Provider.of<MeetingFoodProvider>(context, listen: false);
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
      builder: (context) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setState) {
            final filteredDetails = searchQuery.isEmpty
                ? details
                : details
                    .where((item) => (item['name'] ?? '')
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()))
                    .toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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

                  // Search bar
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: TextField(
                      onChanged: (value) => setState(() {
                        searchQuery = value;
                      }),
                      decoration: InputDecoration(
                        hintText: 'Search user name',
                        prefixIcon: Icon(LucideIcons.search,
                            color: ColorClass.neutral400, size: 20),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: ColorClass.neutral300),
                        ),
                      ),
                    ),
                  ),

                  // Count
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Total: ${filteredDetails.length}',
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
                    child: filteredDetails.isEmpty
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
                                  'No users found',
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
                            itemCount: filteredDetails.length,
                            itemBuilder: (context, index) {
                              final item = filteredDetails[index];
                              return Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
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
                                      style: TextStyleClass.poppinsMedium(
                                          fontSize: 16),
                                    ),
                                    Row(
                                      children: [
                                        if (item['type']?.isNotEmpty == true)
                                          Text(
                                            item['type'] ?? '',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        Text(
                                          ' | ',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (item['room']?.isNotEmpty ==
                                            true) ...[
                                          const SizedBox(height: 1),
                                          Text(
                                            item['room']!,
                                            style:
                                                TextStyleClass.poppinsRegular(
                                              fontSize: 13,
                                              color: ColorClass.neutral400,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Define the pages for the bottom navigation - now 3 tabs
  List<Widget> _pages(BuildContext context) => [
        // Home tab (Meal Summary + Meeting Food if available)
        _buildHomeTab(context),
        // Add Food Menu tab (now single-day menu management)
        const FoodMenuListScreen(),
        // Settings tab
        _buildSettingsTab(context),
      ];

  Widget _buildMealSummaryCard(BuildContext context,
      List<Map<String, dynamic>> mealSummary, int? selectedMeal) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: ColorClass.brandWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorClass.brandLightGreen, width: 1.2),
      ),
      child: Row(
        children: List.generate(mealSummary.length, (index) {
          final isSelected = selectedMeal == index;
          return Expanded(
            child: GestureDetector(
              onTap: mealSummary[index]['count'] > 0
                  ? () {
                      _selectedMealNotifier.value = index;
                      final detailedLists = Provider.of<MessStaffMealProvider>(
                              context,
                              listen: false)
                          .getMealDetailsList(index);
                      final mealLabel = mealSummary[index]['label'] as String;
                      Provider.of<MessStaffMealProvider>(context, listen: false)
                          .selectMeal(index);
                      _showDetailedListBottomSheet(
                          context, mealLabel, detailedLists);
                    }
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: isSelected
                      ? ColorClass.brandDarkGreen
                      : ColorClass.brandLightGreen.withOpacity(0.4),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(index == 0 ? 16 : 0),
                    bottomLeft: Radius.circular(index == 0 ? 16 : 0),
                    topRight: Radius.circular(
                        index == mealSummary.length - 1 ? 16 : 0),
                    bottomRight: Radius.circular(
                        index == mealSummary.length - 1 ? 16 : 0),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      mealSummary[index]['icon'],
                      size: 28,
                      color:
                          isSelected ? Colors.white : ColorClass.brandDarkGreen,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      mealSummary[index]['label'],
                      style: TextStyleClass.poppinsRegular(
                        fontSize: 13,
                        color: isSelected
                            ? Colors.white
                            : ColorClass.brandDarkGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mealSummary[index]['count'].toString(),
                      style: TextStyleClass.poppinsBold(
                        fontSize: 18,
                        color: isSelected
                            ? Colors.white
                            : ColorClass.brandDarkGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  void _togglePrintShareBar() {
    setState(() {
      _showPrintShareBar = !_showPrintShareBar;
    });
  }

  void _toggleMeetingExpansion(String meetingId) {
    setState(() {
      if (_expandedMeetings.contains(meetingId)) {
        _expandedMeetings.remove(meetingId);
      } else {
        _expandedMeetings.add(meetingId);
      }
    });
  }

  void _toggleGuestMealExpansion(String guestMealId) {
    setState(() {
      if (_expandedGuestMeals.contains(guestMealId)) {
        _expandedGuestMeals.remove(guestMealId);
      } else {
        _expandedGuestMeals.add(guestMealId);
      }
    });
  }

  // Method to refresh all data
  Future<void> _refreshData() async {
    _logger.i('🔄 [REFRESH] User initiated data refresh');
    developer.log('🔄 User initiated data refresh', name: 'MessStaffScreen');

    try {
      // Fetch meal data
      final mealProvider =
          Provider.of<MessStaffMealProvider>(context, listen: false);

      // Fetch guest meal data
      final guestMealProvider =
          Provider.of<MessBulkMealProvider>(context, listen: false);

      // Fetch meeting food requirements
      final meetingFoodProvider =
          Provider.of<MeetingFoodProvider>(context, listen: false);

      // Execute all fetch operations in parallel for better performance
      await Future.wait([
        mealProvider.fetchMessStaffMeals(context),
        guestMealProvider.fetchGuestMeals(context),
        meetingFoodProvider.fetchMeetingFoodRequirements(context),
      ]);

      _logger.i('✅ [REFRESH] All data refreshed successfully');
      developer.log('✅ All data refreshed successfully',
          name: 'MessStaffScreen');

      // Show success message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  LucideIcons.check,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text('Data refreshed successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      _logger.e('❌ [REFRESH] Error refreshing data: $e');
      developer.log('❌ Error refreshing data: $e', name: 'MessStaffScreen');

      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh data. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  List<Widget> _buildFoodItemRows(List<dynamic> foodItems) {
    List<Widget> foodRows = [];
    for (int i = 0; i < foodItems.length; i += 3) {
      final rowItems = foodItems.skip(i).take(3).toList();
      foodRows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: rowItems
              .map((food) => Expanded(
                    child: Column(
                      children: [
                        Icon(_getFoodIcon(food.name),
                            size: 20, color: ColorClass.brandDarkGreen),
                        const SizedBox(height: 2),
                        Text(food.name.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyleClass.poppinsRegular(
                                fontSize: 9, color: ColorClass.brandDarkGreen)),
                        Text(food.count.toString(),
                            style: TextStyleClass.poppinsBold(
                                fontSize: 13,
                                color: ColorClass.brandDarkGreen)),
                      ],
                    ),
                  ))
              .toList(),
        ),
      );

      // Add spacing between rows if not the last row
      if (i + 3 < foodItems.length) {
        foodRows.add(const SizedBox(height: 12));
      }
    }
    return foodRows;
  }

  Widget _buildAnimatedPrintShareBar(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      left: 0,
      right: 0,
      bottom: _showPrintShareBar ? 0 : -80,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _showPrintShareBar ? 1.0 : 0.0,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: ColorClass.neutral200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.share, color: ColorClass.brandDarkGreen),
                  tooltip: 'Share',
                  onPressed: () {
                    _togglePrintShareBar();
                    final mealProvider = Provider.of<MessStaffMealProvider>(
                        context,
                        listen: false);
                    final messBulkMealProvider =
                        Provider.of<MessBulkMealProvider>(context,
                            listen: false);
                    final meetingFoodProvider =
                        Provider.of<MeetingFoodProvider>(context,
                            listen: false);
                    final selectedIndex = mealProvider.selectedMeal;
                    final mealSummary = [
                      {'label': 'Breakfast'},
                      {'label': 'Lunch'},
                      {'label': 'Dinner'},
                    ];
                    final mealLabel =
                        mealSummary[selectedIndex]['label'] as String;
                    final detailedLists =
                        mealProvider.getMealDetailsList(selectedIndex);
                    generateAndShareAllPdf(
                      context,
                      mealLabel,
                      detailedLists,
                      messBulkMealProvider,
                      meetingFoodProvider,
                      shareInsteadOfOpen: true,
                    );
                  },
                ),
                const SizedBox(width: 8),
                Text('Share',
                    style: TextStyleClass.poppinsMedium(
                        fontSize: 15, color: ColorClass.brandDarkGreen)),
                const SizedBox(width: 24),
                IconButton(
                  icon: Icon(Icons.print, color: ColorClass.brandDarkGreen),
                  tooltip: 'Print',
                  onPressed: () {
                    _togglePrintShareBar();
                    final mealProvider = Provider.of<MessStaffMealProvider>(
                        context,
                        listen: false);
                    final messBulkMealProvider =
                        Provider.of<MessBulkMealProvider>(context,
                            listen: false);
                    final meetingFoodProvider =
                        Provider.of<MeetingFoodProvider>(context,
                            listen: false);
                    final selectedIndex = mealProvider.selectedMeal;
                    final mealSummary = [
                      {'label': 'Breakfast'},
                      {'label': 'Lunch'},
                      {'label': 'Dinner'},
                    ];
                    final mealLabel =
                        mealSummary[selectedIndex]['label'] as String;
                    final detailedLists =
                        mealProvider.getMealDetailsList(selectedIndex);
                    generateAndShareAllPdf(
                      context,
                      mealLabel,
                      detailedLists,
                      messBulkMealProvider,
                      meetingFoodProvider,
                      shareInsteadOfOpen: false,
                    );
                  },
                ),
                const SizedBox(width: 8),
                Text('Print',
                    style: TextStyleClass.poppinsMedium(
                        fontSize: 15, color: ColorClass.brandDarkGreen)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context) {
    _logger.i('[UI] Building Home Tab');
    return Consumer3<MessStaffMealProvider, MessBulkMealProvider,
        MeetingFoodProvider>(
      builder: (context, mealProvider, messBulkMealProvider,
          meetingFoodProvider, _) {
        _logger.i('[Provider] Home Tab Consumer build, isLoading:  [33m${mealProvider.isLoading} [0m, isLoading:  [33m${messBulkMealProvider.isLoading} [0m, isLoading:  [33m${meetingFoodProvider.isLoading} [0m');
        final mealCounts = mealProvider.getTodayMealCounts();
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
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshData,
                    color: ColorClass.brandDarkGreen,
                    backgroundColor: ColorClass.brandWhite,
                    strokeWidth: 2.5,
                    displacement: 40,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Meal Summary',
                                        style: TextStyleClass.poppinsSemiBold(
                                            fontSize: 18)),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          DateFormat('EEEE')
                                              .format(DateTime.now()),
                                          style: TextStyleClass.poppinsRegular(
                                              fontSize: 13,
                                              color: ColorClass.neutral400),
                                        ),
                                        Text(
                                          DateFormat('dd MMMM yyyy')
                                              .format(DateTime.now()),
                                          style: TextStyleClass.poppinsMedium(
                                              fontSize: 12,
                                              color: ColorClass.neutral400),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      LucideIcons.arrowDown,
                                      size: 12,
                                      color: ColorClass.neutral300,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Pull down to refresh',
                                      style: TextStyleClass.poppinsRegular(
                                          fontSize: 11,
                                          color: ColorClass.neutral300),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          ValueListenableBuilder<int?>(
                            valueListenable: _selectedMealNotifier,
                            builder: (context, selectedMeal, _) =>
                                _buildMealSummaryCard(
                                    context, mealSummary, selectedMeal),
                          ),
                          _buildGuestFoodBookingSection(
                              context, messBulkMealProvider),
                          _buildFoodForMeetingSection(
                              context, meetingFoodProvider),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Refactored Guest Food Booking Section ---
  Widget _buildGuestFoodBookingSection(
      BuildContext context, MessBulkMealProvider messBulkMealProvider) {
    _logger.i('[UI] Building Guest Food Booking Section');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.users,
                  size: 20, color: ColorClass.brandDarkGreen),
              const SizedBox(width: 8),
              Text('Guest Food Booking',
                  style: TextStyleClass.poppinsSemiBold(fontSize: 17)),
              const Spacer(),
              ValueListenableBuilder<DateTime>(
                valueListenable: _bulkMealDateNotifier,
                builder: (context, selectedDate, _) => OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: ColorClass.neutral200),
                    backgroundColor: ColorClass.brandWhite,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  ),
                  onPressed: () => _selectBulkMealDate(context),
                  icon: Icon(LucideIcons.calendar,
                      size: 16, color: ColorClass.brandDarkGreen),
                  label: Text(
                    DateFormat('dd MMM yyyy').format(selectedDate),
                    style: TextStyleClass.poppinsMedium(
                        fontSize: 13, color: ColorClass.brandDarkGreen),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder<DateTime>(
            valueListenable: _bulkMealDateNotifier,
            builder: (context, selectedDate, _) {
              final filteredGuestMeals =
                  messBulkMealProvider.getGuestMealsForDate(selectedDate);
              if (filteredGuestMeals.isEmpty) {
                return Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: ColorClass.brandLightGreen.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(LucideIcons.calendarOff,
                            size: 48, color: ColorClass.neutral300),
                        const SizedBox(height: 8),
                        Text('No guest bookings for this date',
                            style: TextStyleClass.poppinsRegular(
                                fontSize: 14, color: ColorClass.neutral400)),
                      ],
                    ),
                  ),
                );
              }
              return Column(
                children: filteredGuestMeals.map((guestMeal) {
                  // Create a unique ID for each guest meal card
                  final guestMealId =
                      '${guestMeal.date.toIso8601String()}_${guestMeal.departmentNames}';
                  final isExpanded = _expandedGuestMeals.contains(guestMealId);
                  final totalMealCount = guestMeal.totalMealCount;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: ColorClass.brandWhite,
                      borderRadius: BorderRadius.circular(14),
                      border:
                          Border.all(color: ColorClass.neutral200, width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header - Always visible
                        GestureDetector(
                          onTap: () => _toggleGuestMealExpansion(guestMealId),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: ColorClass.brandWhite,
                              borderRadius: isExpanded
                                  ? const BorderRadius.only(
                                      topLeft: Radius.circular(14),
                                      topRight: Radius.circular(14),
                                    )
                                  : BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildDepartmentNamesWidget(guestMeal.departmentNames),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Total: $totalMealCount meals',
                                        style: TextStyleClass.poppinsRegular(
                                            fontSize: 12,
                                            color: ColorClass.neutral700),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  isExpanded
                                      ? LucideIcons.chevronUp
                                      : LucideIcons.chevronDown,
                                  color: ColorClass.brandDarkGreen,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Expandable content - Department-wise breakdown
                        if (isExpanded) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 14),
                            decoration: BoxDecoration(
                              color:
                                  ColorClass.brandLightGreen.withOpacity(0.13),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(14),
                                bottomRight: Radius.circular(14),
                              ),
                            ),
                            child: Column(
                              children: [
                                // Total counts row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildGuestMealCountCard(
                                        'BREAKFAST',
                                        LucideIcons.sunMedium,
                                        guestMeal.breakfastCount),
                                    _buildGuestMealCountCard('LUNCH',
                                        LucideIcons.sun, guestMeal.lunchCount),
                                    _buildGuestMealCountCard('DINNER',
                                        LucideIcons.moon, guestMeal.dinnerCount),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Department breakdown
                                ...guestMeal.departments.entries.map((entry) {
                                  final departmentName = entry.key;
                                  final departmentMeal = entry.value;
                                  final departmentTotal = departmentMeal.totalMeals;
                                  
                                  if (departmentTotal == 0) return const SizedBox.shrink();
                                  
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: ColorClass.brandWhite,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: ColorClass.neutral200,
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          departmentName,
                                          style: TextStyleClass.poppinsSemiBold(
                                            fontSize: 13,
                                            color: ColorClass.brandDarkGreen,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            _buildDepartmentMealCountCard(
                                              'B',
                                              LucideIcons.sunMedium,
                                              departmentMeal.breakfast,
                                            ),
                                            _buildDepartmentMealCountCard(
                                              'L',
                                              LucideIcons.sun,
                                              departmentMeal.lunch,
                                            ),
                                            _buildDepartmentMealCountCard(
                                              'D',
                                              LucideIcons.moon,
                                              departmentMeal.dinner,
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: ColorClass.brandDarkGreen,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'Total: $departmentTotal',
                                                style: TextStyleClass.poppinsBold(
                                                  fontSize: 11,
                                                  color: ColorClass.brandWhite,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGuestMealCountCard(String label, IconData icon, int count) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon,
              size: 22,
              color: count > 0
                  ? ColorClass.brandDarkGreen
                  : ColorClass.neutral300),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyleClass.poppinsRegular(
                  fontSize: 11,
                  color: count > 0
                      ? ColorClass.brandDarkGreen
                      : ColorClass.neutral400)),
          const SizedBox(height: 2),
          Text(count.toString(),
              style: TextStyleClass.poppinsBold(
                  fontSize: 15,
                  color: count > 0
                      ? ColorClass.brandDarkGreen
                      : ColorClass.neutral400)),
        ],
      ),
    );
  }

  Widget _buildDepartmentMealCountCard(String label, IconData icon, int count) {
    return Column(
      children: [
        Icon(icon,
            size: 16,
            color: count > 0
                ? ColorClass.brandDarkGreen
                : ColorClass.neutral300),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyleClass.poppinsRegular(
                fontSize: 9,
                color: count > 0
                    ? ColorClass.brandDarkGreen
                    : ColorClass.neutral400)),
        const SizedBox(height: 1),
        Text(count.toString(),
            style: TextStyleClass.poppinsBold(
                fontSize: 12,
                color: count > 0
                    ? ColorClass.brandDarkGreen
                    : ColorClass.neutral400)),
      ],
    );
  }

  Widget _buildDepartmentNamesWidget(String departmentNames) {
    final departments = departmentNames.split(', ');
    
    if (departments.length <= 2) {
      // For 1-2 departments, show in a single line
      return Text(
        departmentNames,
        style: TextStyleClass.poppinsSemiBold(
          fontSize: 15,
          color: ColorClass.brandDarkGreen,
        ),
      );
    } else if (departments.length <= 4) {
      // For 3-4 departments, show in two lines
      final firstLine = departments.take(2).join(', ');
      final secondLine = departments.skip(2).join(', ');
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            firstLine,
            style: TextStyleClass.poppinsSemiBold(
              fontSize: 15,
              color: ColorClass.brandDarkGreen,
            ),
          ),
          Text(
            secondLine,
            style: TextStyleClass.poppinsSemiBold(
              fontSize: 15,
              color: ColorClass.brandDarkGreen,
            ),
          ),
        ],
      );
    } else {
      // For 5+ departments, show first 3 + "and X more"
      final firstThree = departments.take(3).join(', ');
      final remainingCount = departments.length - 3;
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            firstThree,
            style: TextStyleClass.poppinsSemiBold(
              fontSize: 15,
              color: ColorClass.brandDarkGreen,
            ),
          ),
          Text(
            'and $remainingCount more',
            style: TextStyleClass.poppinsMedium(
              fontSize: 13,
              color: ColorClass.neutral600,
            ),
          ),
        ],
      );
    }
  }

  // --- Refactored Food For Meeting Section ---
  Widget _buildFoodForMeetingSection(
      BuildContext context, MeetingFoodProvider meetingFoodProvider) {
    _logger.i('[UI] Building Food For Meeting Section');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.calendar,
                  size: 20, color: ColorClass.brandDarkGreen),
              const SizedBox(width: 8),
              Text('Food For Meeting',
                  style: TextStyleClass.poppinsSemiBold(fontSize: 17)),
              const Spacer(),
              ValueListenableBuilder<DateTime>(
                valueListenable: _meetingFoodDateNotifier,
                builder: (context, selectedDate, _) => OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: ColorClass.neutral200),
                    backgroundColor: ColorClass.brandWhite,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  ),
                  onPressed: () =>
                      _selectMeetingFoodDate(context, meetingFoodProvider),
                  icon: Icon(LucideIcons.calendar,
                      size: 16, color: ColorClass.brandDarkGreen),
                  label: Text(
                    DateFormat('dd MMM yyyy').format(selectedDate),
                    style: TextStyleClass.poppinsMedium(
                        fontSize: 13, color: ColorClass.brandDarkGreen),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder<DateTime>(
            valueListenable: _meetingFoodDateNotifier,
            builder: (context, selectedDate, _) {
              final meetings = meetingFoodProvider
                  .getMeetingsForDate(selectedDate)
                  .where((m) => m.foodCounts.activeFoodItems.isNotEmpty)
                  .toList();
              if (meetings.isEmpty) {
                return Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: ColorClass.brandLightGreen.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(LucideIcons.calendarOff,
                            size: 48, color: ColorClass.neutral300),
                        const SizedBox(height: 8),
                        Text('No meetings for this date',
                            style: TextStyleClass.poppinsRegular(
                                fontSize: 14, color: ColorClass.neutral400)),
                      ],
                    ),
                  ),
                );
              }
              return Column(
                children: meetings.map((meeting) {
                  final foodItems = meeting.foodCounts.activeFoodItems;
                  final isExpanded = _expandedMeetings.contains(meeting.id);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: ColorClass.brandWhite,
                      borderRadius: BorderRadius.circular(14),
                      border:
                          Border.all(color: ColorClass.neutral200, width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header - Always visible
                        GestureDetector(
                          onTap: () => _toggleMeetingExpansion(meeting.id),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: ColorClass.brandWhite,
                              borderRadius: isExpanded
                                  ? const BorderRadius.only(
                                      topLeft: Radius.circular(14),
                                      topRight: Radius.circular(14),
                                    )
                                  : BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(meeting.title,
                                          style: TextStyleClass.poppinsSemiBold(
                                              fontSize: 15,
                                              color:
                                                  ColorClass.brandDarkGreen)),
                                      const SizedBox(height: 4),
                                      Text(
                                        meeting.department,
                                        style: TextStyleClass.poppinsRegular(
                                            fontSize: 12,
                                            color: ColorClass.neutral700),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  isExpanded
                                      ? LucideIcons.chevronUp
                                      : LucideIcons.chevronDown,
                                  color: ColorClass.brandDarkGreen,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Expandable content - Food items
                        if (isExpanded && foodItems.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 14),
                            decoration: BoxDecoration(
                              color:
                                  ColorClass.brandLightGreen.withOpacity(0.13),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(14),
                                bottomRight: Radius.circular(14),
                              ),
                            ),
                            child: Column(
                              children: _buildFoodItemRows(foodItems),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  IconData _getFoodIcon(String name) {
    switch (name.toLowerCase()) {
      case 'breakfast':
        return LucideIcons.sunMedium;
      case 'lunch':
        return LucideIcons.sun;
      case 'dinner':
        return LucideIcons.moon;
      case 'evening snacks':
      case 'eve. snacks':
        return LucideIcons.cookie;
      case 'mid morning snacks':
        return LucideIcons.cookie;
      case 'morning tea':
        return LucideIcons.cupSoda;
      case 'evening tea':
        return LucideIcons.cupSoda;
      default:
        return LucideIcons.utensils;
    }
  }

  Widget _buildSettingsTab(BuildContext context) {
    _logger.i('[UI] Building Settings Tab');
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
                  final Uri url = Uri.parse(GlobalVariables.privacyPolicyUrl);
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
                onTap: () async {
                  final Uri url = Uri.parse(GlobalVariables.aboutUsUrl);
                  await launchUrl(url, mode: LaunchMode.externalApplication);
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
                      return LogoutConfirmationBottomSheet(onLogout: () async {
                        final logger = Logger();
                        logger.i(
                            '🔄 [LOGOUT] Mess Staff initiated logout process');
                        developer.log('🔄 Mess Staff initiated logout process',
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
                          logger
                              .i('🧭 [NAVIGATION] Redirecting to login screen');
                          developer.log('🚀 Redirecting to login screen',
                              name: 'MessStaffScreen');
                          navigatePRToGlobal(
                            route: Routes.login,
                          );
                        });
                      });
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
      final todayMeetingTotals =
          meetingFoodProvider.getTotalCountsForDate(selectedDate);
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
      pw.Widget buildHeader() {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header with title and total count on the right
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  '$mealLabel - Detailed List',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey600),
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Total Count',
                        style: pw.TextStyle(
                            fontSize: 12, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        grandTotal.toString(),
                        style: pw.TextStyle(
                            fontSize: 20, fontWeight: pw.FontWeight.bold),
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
                      pw.Text('Regular Meals',
                          style: pw.TextStyle(fontSize: 12)),
                      pw.Text(regularMealCount.toString(),
                          style: pw.TextStyle(
                              fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text('Bulk Meals', style: pw.TextStyle(fontSize: 12)),
                      pw.Text(bulkMealCount.toString(),
                          style: pw.TextStyle(
                              fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text('Meeting Food',
                          style: pw.TextStyle(fontSize: 12)),
                      pw.Text(meetingFoodCount.toString(),
                          style: pw.TextStyle(
                              fontSize: 16, fontWeight: pw.FontWeight.bold)),
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
              children: batch
                  .map((item) => pw.Container(
                        padding: const pw.EdgeInsets.only(bottom: 8),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              item['name'] ?? '',
                              style: pw.TextStyle(
                                  fontSize: 14, fontWeight: pw.FontWeight.bold),
                            ),
                            if ((item['type'] ?? '').isNotEmpty)
                              pw.Text(item['type']!,
                                  style: pw.TextStyle(fontSize: 12)),
                            if ((item['room'] ?? '').isNotEmpty)
                              pw.Text(item['room']!,
                                  style: pw.TextStyle(fontSize: 12)),
                          ],
                        ),
                      ))
                  .toList(),
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
            'Bulk Food Meals ($bulkMealCount)',
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
                      style: pw.TextStyle(
                          fontSize: 14, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text('Count: $mealCount',
                        style: pw.TextStyle(fontSize: 12)),
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
            'Meeting Food Requirements ($meetingFoodCount)',
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
                        style: pw.TextStyle(
                            fontSize: 14, fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Text(
                        'Count',
                        style: pw.TextStyle(
                            fontSize: 14, fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Divider(),
                pw.SizedBox(height: 8),

                // Food items - show all food items including those with 0 count for completeness
                ...todayMeetingTotals.foodItems.map(
                  (item) => pw.Padding(
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
                            style: pw.TextStyle(
                                fontSize: 12, fontWeight: pw.FontWeight.bold),
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
                        style: pw.TextStyle(
                            fontSize: 14, fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Text(
                        todayMeetingTotals.totalCount.toString(),
                        style: pw.TextStyle(
                            fontSize: 14, fontWeight: pw.FontWeight.bold),
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
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          header: (pw.Context context) {
            return context.pageNumber == 1
                ? buildHeader()
                : pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 20),
                    child: pw.Text(
                      '$mealLabel - Detailed List (Continued)',
                      style: pw.TextStyle(
                          fontSize: 18, fontWeight: pw.FontWeight.bold),
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
      file = File(
          '${output.path}/$mealLabel-complete-summary-${DateTime.now().toString().substring(0, 10)}.pdf');
      await file.writeAsBytes(await pdf.save());
      Navigator.of(context, rootNavigator: true).pop();

      if (shareInsteadOfOpen) {
        await Share.shareXFiles([XFile(file.path)],
            text: '$mealLabel Complete Summary');
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
                          navigateBack(ctx);
                          if (file != null) {
                            await Share.shareXFiles([XFile(file.path)],
                                text: '$mealLabel Complete Summary');
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

  // Date picker for meeting food requirements
  void _selectMeetingFoodDate(
      BuildContext context, MeetingFoodProvider provider) async {
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

  @override
  Widget build(BuildContext context) {
    final logger = Logger();
    logger.i('🏗️ [UI] Building Mess Staff screen');
    developer.log('🏗️ Building Mess Staff screen interface',
        name: 'MessStaffScreen');

    final navProvider = Provider.of<BottomNavProvider>(context);
    final tabTitles = ['Home', 'Add Food Menu', 'Settings']; // Now 3 tabs

    return WillPopScope(
      onWillPop: () async {
        return navProvider.shouldExitOnBack(context);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: navProvider.selectedIndex == 1
            ? null
            : AppBar(
                backgroundColor: ColorClass.brandDarkGreen,
                iconTheme: const IconThemeData(color: Colors.white),
                title: Text(
                  tabTitles[navProvider.selectedIndex],
                  style: TextStyleClass.poppinsSemiBold(
                    fontSize: 20,
                    color: ColorClass.white,
                  ),
                ),
                centerTitle: false,
                elevation: 0,
              ),
        body: Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _togglePrintShareBar,
              child: _pages(context)[navProvider.selectedIndex],
            ),
            if (navProvider.selectedIndex == 0) _buildAnimatedPrintShareBar(context),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: ColorClass.brandWhite,
          selectedItemColor: ColorClass.brandDarkGreen,
          unselectedItemColor: ColorClass.neutral400,
          currentIndex: navProvider.selectedIndex,
          unselectedLabelStyle: TextStyleClass.poppinsSemiBold(
            fontSize: 14,
          ),
          onTap: navProvider.setIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.home, size: 22, color: ColorClass.neutral400),
              activeIcon: Icon(LucideIcons.home, size: 28),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.plusCircle, size: 22, color: ColorClass.neutral400),
              activeIcon: Icon(LucideIcons.plusCircle, size: 28),
              label: 'Add Food Menu',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.settings, size: 22, color: ColorClass.neutral400),
              activeIcon: Icon(LucideIcons.settings, size: 28),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
