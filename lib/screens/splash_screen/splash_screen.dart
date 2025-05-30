import 'package:hira_plus/screens/login_screen/provider/auth_provider.dart';
import 'package:hira_plus/screens/forced_update_screen/provider/version_check_provider.dart';
import 'package:hira_plus/routes/app_routes.dart';
import 'package:hira_plus/utils/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:hira_plus/constants/color_class.dart';
import 'package:hira_plus/constants/icons_class.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;

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
    _checkVersionAndAuth();
  }

  // Separate method to handle version and auth checks
  Future<void> _checkVersionAndAuth() async {
    try {
      await Future.delayed(const Duration(seconds: 3));
      
      if (!mounted) return;

      // First check if app needs update
      final versionProvider = Provider.of<VersionCheckProvider>(context, listen: false);
      await versionProvider.checkVersion();

      if (!mounted) return;

      if (versionProvider.needsUpdate) {
        _logger.i('🔄 [VERSION] Update needed, navigating to force update screen');
        if (mounted) {
          navigatePRTo(context: context, route: Routes.forceUpdate);
        }
        return;
      }

      if (!mounted) return;

      // Check login status if no update is needed
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isLoggedIn = await authProvider.checkLoginStatus();

      if (!mounted) return;

      if (isLoggedIn) {
        _logger.i('🔑 [AUTH] User is logged in, user type: ${authProvider.userType}');

        // Navigate to appropriate screen based on user type
        if (!mounted) return;
        
        if (authProvider.userType == 'Manager') {
          _logger.i('🔍 [AUTH] Starting manager validation...');
          developer.log('🔍 Starting manager validation...');
          
          final isManagerValid = await authProvider.checkManagerLoginStatus();
          
          if (!mounted) return;

          if (isManagerValid) {
            _logger.i('✅ [AUTH] Manager validation successful');
            developer.log('✅ Manager validation successful');
            _logger.i('🧭 [NAVIGATION] Directing to Manager screen');
            navigatePRToGlobal(route: Routes.manager);
          } else {
            _logger.w('❌ [AUTH] Manager validation failed');
            developer.log('❌ Manager validation failed');
            _logger.w('🔄 [NAVIGATION] Redirecting to login screen');
            if (mounted) {
              navigatePRTo(context: context, route: Routes.login);
            }
          }
        } else if (authProvider.userType == 'Mess Staff') {
          _logger.i('🧭 [NAVIGATION] Directing to Mess Staff screen');
          navigatePRToGlobal(route: Routes.messStaff);
        } else if (authProvider.userType == 'Reception') {
          navigatePRToGlobal(route: Routes.reception);
        } else {
          _logger.i('🧭 [NAVIGATION] Directing to User screen');
          navigatePRToGlobal(route: Routes.bottomNav);
        }
      } else {
        _logger.i('🔒 [AUTH] User not logged in');
        developer.log('🔒 User not logged in');
        _logger.i('🧭 [NAVIGATION] Navigating to login screen');
        if (mounted) {
          navigatePRTo(context: context, route: Routes.login);
        }
      }
    } catch (e) {
      _logger.e('🔴 [ERROR] Error in splash screen: $e');
      developer.log('🔴 Error in splash screen: $e');
      if (mounted) {
        navigatePRTo(context: context, route: Routes.login);
      }
    }
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
