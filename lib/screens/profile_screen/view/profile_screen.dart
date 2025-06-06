import 'package:hira_plus/constants/textstyle_class.dart';
import 'package:hira_plus/screens/login_screen/provider/auth_provider.dart';
import 'package:hira_plus/routes/app_routes.dart';
import 'package:hira_plus/screens/user_screens/user_home_screen/widgets/custom_drawer.dart';
import 'package:hira_plus/utils/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:hira_plus/constants/color_class.dart';
import 'package:provider/provider.dart';
import 'package:hira_plus/screens/profile_screen/provider/profile_screen_provider.dart';
import '../widgets/logout_confirmation_bottom_sheet.dart';
import 'package:hira_plus/screens/bottom_nav/provider/bottom_nav_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shake_flutter/shake_flutter.dart';
import 'package:shake_flutter/enums/shake_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../widgets/profile_card.dart';
import '../widgets/powered_by_section.dart';
import 'package:logger/logger.dart';

class ProfileScreen extends StatefulWidget {
  final Logger _logger = Logger();
  ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final profileProvider =
          Provider.of<ProfileScreenProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = await authProvider.getAuthToken();
      if (token != null && token.isNotEmpty) {
        await profileProvider.fetchAndSetProfile(
            token: token,
            userType: authProvider.userType.toLowerCase().replaceAll(' ', '_'));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileScreenProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile',
            style: TextStyleClass.primaryFont500(20, ColorClass.white)),
        backgroundColor: ColorClass.brandDarkGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 14),
            ProfileCard(
              userName: profileProvider.userName,
              phone: profileProvider.phone,
              department: profileProvider.department,
              designation: profileProvider.designation,
              isDeptHead: profileProvider.isDeptHead,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
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
                      final Uri url =
                          Uri.parse('https://d4dx.co/privacy-policy/');
                      await launchUrl(url,
                          mode: LaunchMode.externalApplication);
                    },
                  ),
                  CustomDrawerItem(
                    title: 'Contact Us',
                    icon: LucideIcons.phone,
                    onTap: () {
                      navigatorKey.currentState!.pushNamed(Routes.contactUs);
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
                              onPressed: () => Navigator.of(context).pop(),
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
                              widget._logger.i(
                                  '🔄 [LOGOUT] User initiated logout process');

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
                              widget._logger.i(
                                  '🟢 [LOGOUT] Successfully cleared preferences and updated auth state');

                              toastification.show(
                                context: context,
                                title: const Text('Logged out successfully'),
                                type: ToastificationType.success,
                                autoCloseDuration: const Duration(seconds: 2),
                              );

                              Future.delayed(const Duration(milliseconds: 500),
                                  () {
                                widget._logger.i(
                                    '🧭 [NAVIGATION] Redirecting to login screen');
                                navigatePRTo(
                                  context: navigatorKey.currentContext!,
                                  route: Routes.login,
                                );
                              });
                            },
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
      ),
    );
  }
}
