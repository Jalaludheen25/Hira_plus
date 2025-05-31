import 'package:hira_plus/screens/login_screen/provider/auth_provider.dart';
import 'package:hira_plus/screens/forced_update_screen/provider/version_check_provider.dart';
import 'package:hira_plus/routes/app_routes.dart';
import 'package:hira_plus/utils/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:hira_plus/constants/color_class.dart';
import 'package:hira_plus/constants/icons_class.dart';
import 'package:hira_plus/screens/profile_screen/widgets/powered_by_section.dart';
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
  late Animation<double> _fadeAnimation;
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1B3932), // Darker green at top
              Color(0xFF2D5A4F), // Medium green
              Color(0xFF4A8F77), // Lighter green at bottom
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Top section with center logo
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: _buildImageWithFallback(
                                IconClass.splashLogo,
                                width: 160,
                                height: 160,
                                fallbackIcon: Icons.home_work,
                                fallbackColor: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  
                  // Bottom spacer to leave room for building image
                  Expanded(
                    flex: 2,
                    child: SizedBox(),
                  ),
                ],
              ),
            ),
            
            // PoweredBy section positioned in the center of the building image
            Positioned(
              bottom: 80, // Adjust this value to center it on your building image
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Image.asset(IconClass.dxLogoWhite,width: 58,height: 58,),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Bottom building image positioned absolutely at the bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: _buildImageWithFallback(
                        IconClass.splashImage,
                        width: MediaQuery.of(context).size.width,
                        height: null, // Let it determine height automatically
                        fallbackIcon: Icons.business,
                        fallbackColor: Colors.white70,
                        fitType: BoxFit.fitWidth, // Show full image, fit to width
                      ),
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

  // Helper method to build image with fallback
  Widget _buildImageWithFallback(
    String assetPath, {
    required double width,
    double? height, // Made nullable to allow auto height
    required IconData fallbackIcon,
    required Color fallbackColor,
    BoxFit fitType = BoxFit.contain,
  }) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fitType,
      errorBuilder: (context, error, stackTrace) {
        // Fallback widget when image fails to load
        _logger.w('🖼️ [IMAGE] Failed to load image: $assetPath - Error: $error');
        return Container(
          width: width,
          height: height ?? 150, // Default height for fallback
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: fitType == BoxFit.cover ? BorderRadius.zero : BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Icon(
            fallbackIcon,
            size: width * 0.3,
            color: fallbackColor,
          ),
        );
      },
    );
  }
}