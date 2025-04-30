import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:canteen_app/constants/color_class.dart';

class CustomDrawerItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDestructive;
  final bool isDisabled;
  final Widget? trailing;

  const CustomDrawerItem({
    Key? key,
    required this.title,
    required this.icon,
    this.onTap,
    this.isDestructive = false,
    this.isDisabled = false,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? ColorClass.redBase : ColorClass.brandDarkGreen),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive
              ? ColorClass.redBase
              : isDisabled
                  ? ColorClass.neutral400
                  : ColorClass.brandDarkGreen,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: isDisabled ? null : onTap,
      trailing: trailing,
    );
  }
}

class CustomDrawer extends StatelessWidget {
  final String userName;
  final String appVersion;
  final VoidCallback? onLogout;
  final VoidCallback? onProfile;
  final VoidCallback? onHome;
  final VoidCallback? onFeedback;
  final VoidCallback? onPrivacy;
  final VoidCallback? onContact;
  final VoidCallback? onAbout;
  final VoidCallback? onRaiseBug;

  const CustomDrawer({
    Key? key,
    required this.userName,
    required this.appVersion,
    this.onLogout,
    this.onProfile,
    this.onHome,
    this.onFeedback,
    this.onPrivacy,
    this.onContact,
    this.onAbout,
    this.onRaiseBug,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // User Name Section
            Container(
              width: double.infinity,
              color: ColorClass.brandLightGreen,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: ColorClass.brandDarkGreen,
                    child: Icon(LucideIcons.user, color: ColorClass.brandLightGreen, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ColorClass.brandDarkGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  CustomDrawerItem(
                    title: 'Home',
                    icon: LucideIcons.home,
                    onTap: onHome,
                  ),
                  CustomDrawerItem(
                    title: 'Profile',
                    icon: LucideIcons.user,
                    onTap: onProfile,
                  ),
                  CustomDrawerItem(
                    title: 'Feedback',
                    icon: LucideIcons.messageCircle,
                    onTap: onFeedback,
                  ),
                  CustomDrawerItem(
                    title: 'Privacy Policy',
                    icon: LucideIcons.shieldCheck,
                    onTap: onPrivacy,
                  ),
                  CustomDrawerItem(
                    title: 'Contact Us',
                    icon: LucideIcons.phone,
                    onTap: onContact,
                  ),
                  CustomDrawerItem(
                    title: 'About Us',
                    icon: LucideIcons.info,
                    onTap: onAbout,
                  ),
                  CustomDrawerItem(
                    title: 'Raise a bug',
                    icon: LucideIcons.bug,
                    onTap: onRaiseBug,
                  ),
                  const Divider(),
                  CustomDrawerItem(
                    title: 'Logout',
                    icon: LucideIcons.logOut,
                    isDestructive: true,
                    onTap: onLogout,
                  ),
                ],
              ),
            ),
            // App Version at the bottom
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: CustomDrawerItem(
                title: 'App version $appVersion',
                icon: LucideIcons.terminal,
                isDisabled: true,
                onTap: null,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 