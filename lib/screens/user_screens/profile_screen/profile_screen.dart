import 'package:canteen_app/routes/app_routes.dart';
import 'package:canteen_app/utils/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:canteen_app/constants/color_class.dart';
import 'package:canteen_app/constants/ui_styles.dart';

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
        title: const Text('Profile'),
        backgroundColor: ColorClass.primaryBase,
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
      backgroundColor: ColorClass.primaryBase,
      child: FaIcon(FontAwesomeIcons.user, size: 50, color: ColorClass.white),
    );
  }

  Widget _buildProfileDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'John Doe',
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
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: ColorClass.white,
            borderRadius: UiStyles.borderRadius12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ignore: deprecated_member_use
              FaIcon(FontAwesomeIcons.exclamationTriangle,
                  size: 40, color: ColorClass.orangeBase),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to logout?',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: ColorClass.textMain900),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorClass.neutral300,
                      shape: RoundedRectangleBorder(
                          borderRadius: UiStyles.borderRadius12),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorClass.redBase,
                      shape: RoundedRectangleBorder(
                          borderRadius: UiStyles.borderRadius12),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Fluttertoast.showToast(
                        msg: "Logged out successfully",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );
                      Future.delayed(const Duration(milliseconds: 500), () {
                        navigateTo(
                            context: navigatorKey.currentContext!,
                            route: Routes.login);
                      });
                    },
                    child: const Text('Logout'),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
