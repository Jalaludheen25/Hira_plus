import 'package:hira_plus/screens/login_screen/provider/auth_provider.dart';
import 'package:hira_plus/screens/forced_update_screen/provider/version_check_provider.dart';
import 'package:hira_plus/routes/app_routes.dart';
import 'package:hira_plus/utils/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:hira_plus/constants/color_class.dart';
import 'package:hira_plus/constants/icons_class.dart';
import 'package:logger/logger.dart';
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
  final Logger _logger = Logger();

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

    // Check for version update and login status
    Future.delayed(const Duration(seconds: 3), () async {
      // First check if app needs update
      final versionProvider =
          Provider.of<VersionCheckProvider>(context, listen: false);
      await versionProvider.checkVersion();

      if (versionProvider.needsUpdate) {
        _logger
            .i('🔄 [VERSION] Update needed, navigating to force update screen');
        navigatePRTo(context: context, route: Routes.forceUpdate);
        return;
      }

      // Check login status if no update is needed
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isLoggedIn = await authProvider.checkLoginStatus();

      if (isLoggedIn) {
        _logger.i(
            '🔑 [AUTH] User is logged in, user type: ${authProvider.userType}');

        // Navigate to appropriate screen based on user type
        if (authProvider.userType == 'Mess Staff') {
          _logger.i('🧭 [NAVIGATION] Directing to Mess Staff screen');
          navigatePRToGlobal(route: Routes.messStaff);
        } else if (authProvider.userType == 'Manager') {
          _logger.i('🧭 [NAVIGATION] Directing to Manager screen');
          navigatePRToGlobal(route: Routes.manager);
        } else {
          _logger.i('🧭 [NAVIGATION] Directing to User screen');
          navigatePRToGlobal(route: Routes.bottomNav);
        }
      } else {
        _logger.i('🔒 [AUTH] User not logged in, navigating to login screen');
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
                      IconClass.hiraPlus,
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
