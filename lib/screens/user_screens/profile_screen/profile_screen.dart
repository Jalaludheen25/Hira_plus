import 'package:canteen_app/constants/textstyle_class.dart';
import 'package:canteen_app/routes/app_routes.dart';
import 'package:canteen_app/utils/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toastification/toastification.dart';
import 'package:canteen_app/constants/color_class.dart';
import 'package:canteen_app/constants/ui_styles.dart';
import 'package:provider/provider.dart';
import 'package:canteen_app/providers/profile_screen_provider.dart';
import 'widgets/logout_confirmation_bottom_sheet.dart';
import 'package:canteen_app/providers/bottom_nav_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('Profile',style: TextStyleClass.primaryFont500(20, ColorClass.white)),
        backgroundColor: ColorClass.brandDarkGreen,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildProfilePicture(),
              const SizedBox(height: 16),
              _buildProfileDetails(),
              const SizedBox(height: 32),
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return CircleAvatar(
      radius: 50,
      backgroundColor: ColorClass.brandDarkGreen,
      child: FaIcon(FontAwesomeIcons.user, size: 50, color: ColorClass.white),
    );
  }

  Widget _buildProfileDetails() {
    return Consumer<ProfileScreenProvider>(
      builder: (context, profileProvider, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            profileProvider.userName,
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ColorClass.textMain900),
          ),
          const SizedBox(height: 8),
          Text(
            'Phone: +1 234567890',
            style: TextStyle(fontSize: 16, color: ColorClass.textSub500),
          ),
          const SizedBox(height: 8),
          Text(
            'Department: Engineering',
            style: TextStyle(fontSize: 16, color: ColorClass.textSub500),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton(
      onPressed: _showLogoutConfirmationBottomSheet,
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorClass.redBase,
        shape: RoundedRectangleBorder(borderRadius: UiStyles.borderRadius12),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: const Text(
        'Logout',
        style: TextStyle(color: ColorClass.white),
      ),
    );
  }

  void _showLogoutConfirmationBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: UiStyles.borderRadius12,
      ),
      builder: (BuildContext context) {
        return LogoutConfirmationBottomSheet(
          onLogout: () {
            Provider.of<BottomNavProvider>(navigatorKey.currentContext!, listen: false).setIndex(0);
            toastification.show(
              context: context,
              title: Text('Logged out successfully'),
              type: ToastificationType.success,
              autoCloseDuration: const Duration(seconds: 2),
            );
            Future.delayed(const Duration(milliseconds: 500), () {
              navigatePRTo(
                context: navigatorKey.currentContext!,
                route: Routes.login,
              );
            });
          },
        );
      },
    );
  }
}
