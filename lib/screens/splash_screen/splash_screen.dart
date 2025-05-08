import 'package:Hira_Plus/providers/version_check_provider.dart';
import 'package:Hira_Plus/routes/app_routes.dart';
import 'package:Hira_Plus/utils/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:Hira_Plus/constants/color_class.dart';
import 'package:Hira_Plus/constants/icons_class.dart';
import 'package:Hira_Plus/screens/user_screens/profile_screen/widgets/powered_by_section.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();

    // Future.delayed(const Duration(seconds: 3), () {
    //   navigatePRTo(context: context, route: Routes.login);
    // }
    // );
     // Check for version update
    Future.delayed(const Duration(seconds: 3), () async {
      final versionProvider = Provider.of<VersionCheckProvider>(context, listen: false);
      await versionProvider.checkVersion(); // Ensure you call the version check

      if (versionProvider.needsUpdate) {
        // Navigate to Forced Update Screen if an update is needed
        navigatePRTo(context: context, route: Routes.forceUpdate);
      } else {
        // Navigate to the login screen or home screen if no update is needed
        navigatePRTo(context: context, route: Routes.login);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorClass.brandDarkGreen,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Transform.rotate(
                    angle: _rotateAnimation.value * 2 * 3.14159,
                    child: Image.asset(
                      IconClass.HiraPlus,
                      width: 180,
                      height: 180,
                    ),
                  ),
                );
              },
            ),
          ),
          const Spacer(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
