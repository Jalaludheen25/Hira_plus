import 'package:flutter/material.dart';
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
import '../widgets/meal_summary_widget.dart';
import '../widgets/progress_dialog.dart';
import '../widgets/detailed_list.dart';
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

  @override
  void initState() {
    super.initState();
    // Set mess staff info for profile card
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = Provider.of<ProfileScreenProvider>(context, listen: false);
      profileProvider.setUserInfo(
        userType: 'mess_staff',
        userName: '',
        phone: '',
      );
    });
    // Fetch data when screen is initialized
    _logger.i('🏗️ [UI] Initializing Mess Staff screen');
    developer.log('🏗️ Initializing Mess Staff screen',
        name: 'MessStaffScreen');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      developer.log('🔄 Fetching fresh meal data on screen load',
          name: 'MessStaffScreen');
      final mealProvider =
          Provider.of<MessStaffMealProvider>(context, listen: false);
      mealProvider.reset(); // Reset the state without clearing cache
      mealProvider.fetchMessStaffMeals(context);
    });
  }

  // Define the pages for the bottom navigation - now just 2 tabs
  List<Widget> _pages(BuildContext context) => [
        // Home tab (previously Meal Summary)
        _buildHomeTab(context),
        // Settings tab (includes profile info now)
        _buildSettingsTab(context),
      ];

  Widget _buildHomeTab(BuildContext context) {
    return Consumer<MessStaffMealProvider>(
      builder: (context, mealProvider, _) {
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

        // Get the selected meal details
        final detailedLists =
            mealProvider.getMealDetailsList(mealProvider.selectedMeal);

        if (mealProvider.isLoading) {
          return const SafeArea(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        
        final screenHeight = MediaQuery.of(context).size.height;
        final detailedListHeight = screenHeight * 0.35; // 35% of screen height

        return SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Meal Summary',
                          style: TextStyleClass.poppinsSemiBold(fontSize: 18)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12.0,
                        runSpacing: 12.0,
                        children: List.generate(
                            mealSummary.length,
                            (index) => GestureDetector(
                                  onTap: () {
                                    mealProvider.selectMeal(index);
                                  },
                                  child: MealSummaryWidget(
                                    icon:
                                        mealSummary[index]['icon'] as IconData,
                                    label:
                                        mealSummary[index]['label'] as String,
                                    count: mealSummary[index]['count'] as int,
                                    isSelected:
                                        mealProvider.selectedMeal == index,
                                  ),
                                )),
                      ),
                      const SizedBox(height: 24),
                      Text('Detailed List',
                          style: TextStyleClass.poppinsSemiBold(fontSize: 18)),
                      const SizedBox(height: 8),

                      // Container with fixed height for detailed list
                      Container(
                        height: detailedListHeight,
                        child: SingleChildScrollView(
                          child: DetailedList(details: detailedLists),
                        ),
                      ),

                      const Spacer(),

                      // Bottom buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          BottomButton(
                            label: 'Share',
                            onTap: () {
                              final selectedIndex = mealProvider.selectedMeal;
                              final mealLabel =
                                  mealSummary[selectedIndex]['label'] as String;
                              generateAndSharePdf(
                                  context, mealLabel, detailedLists,
                                  shareInsteadOfOpen: true);
                            },
                          ),
                          BottomButton(
                            label: 'Print',
                            onTap: () {
                              final selectedIndex = mealProvider.selectedMeal;
                              final mealLabel =
                                  mealSummary[selectedIndex]['label'] as String;
                              generateAndSharePdf(
                                  context, mealLabel, detailedLists,
                                  shareInsteadOfOpen: false);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsTab(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Profile card at the top of settings
          ProfileCard(
            userName: Provider.of<ProfileScreenProvider>(context).userName,
            phone: Provider.of<ProfileScreenProvider>(context).phone,
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
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
                            // In the logout confirmation bottom sheet
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
              ],
            ),
          ),
          const SizedBox(height: 16),
          PoweredBySection(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

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
    List<Map<String, String>> details, {
    bool shareInsteadOfOpen = false,
  }) async {
    final progress = ValueNotifier<double>(0.0);
    showProgressDialog(context, progress);

    File? file;
    try {
      final pdf = pw.Document();
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
              pw.Text('Date: ' +
                  DateTime.now().toString().substring(0, 10),
                  style: pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 8),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text('Total: \\${details.length}',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 16),
              ...details.map((item) => pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(item['name'] ?? '',
                          style: pw.TextStyle(
                              fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      pw.Text(item['type'] ?? '',
                          style: pw.TextStyle(fontSize: 12)),
                      pw.Text(item['room'] ?? '',
                          style: pw.TextStyle(fontSize: 12)),
                      pw.SizedBox(height: 8),
                    ],
                  )),
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
    final tabTitles = ['Home', 'Settings']; // Updated names

    return Scaffold(
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
    );
  }
}
