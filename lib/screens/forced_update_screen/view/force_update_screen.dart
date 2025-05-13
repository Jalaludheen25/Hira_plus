import 'package:hira_plus/constants/icons_class.dart';
import 'package:flutter/material.dart';
import 'package:hira_plus/constants/color_class.dart';
import 'package:hira_plus/constants/textstyle_class.dart';
import 'package:hira_plus/screens/forced_update_screen/provider/version_check_provider.dart';
import 'package:provider/provider.dart';
import 'package:hira_plus/routes/app_routes.dart';
import 'package:hira_plus/utils/navigation_helper.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ForceUpdatePage extends StatefulWidget {
  const ForceUpdatePage({super.key});

  @override
  State<ForceUpdatePage> createState() => _ForceUpdatePageState();
}

class _ForceUpdatePageState extends State<ForceUpdatePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildWhatsNewSection(BuildContext context, String? changes) {
    if (changes == null || changes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorClass.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ColorClass.neutral500,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.utensils,
                size: 20,
                color: ColorClass.greenDark,
              ),
              const SizedBox(width: 8),
              Text(
                'What\'s New',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: ColorClass.textPrimary,
                      letterSpacing: 0.5,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...changes.split('\n').map((change) {
            if (change.trim().isEmpty) return const SizedBox.shrink();

            final cleanedChange =
                change.trim().replaceAll(RegExp(r'^[-•]\s*'), '');
            IconData icon = _getIconForChange(cleanedChange.toLowerCase());

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: ColorClass.greenDark.withOpacity(0.7),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      cleanedChange,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.4,
                          ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  IconData _getIconForChange(String change) {
    if (change.contains('meal') || change.contains('food')) {
      return LucideIcons.utensils;
    } else if (change.contains('bug') || change.contains('fix')) {
      return LucideIcons.bug;
    } else if (change.contains('info') || change.contains('update')) {
      return LucideIcons.info;
    }
    return LucideIcons.checkCircle;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<VersionCheckProvider>(
        builder: (context, provider, child) {
          return Stack(
            children: [
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // App Logo
                        Image.asset(IconClass.d4dxLogo, height: 80),
                        const SizedBox(height: 20),
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Update Icon with Gradient Animation
                                TweenAnimationBuilder<double>(
                                  duration: const Duration(seconds: 1),
                                  tween: Tween(begin: 0, end: 1),
                                  builder: (context, value, child) {
                                    return Transform.rotate(
                                      angle: value * 2 * 3.14,
                                      child: Container(
                                        padding: const EdgeInsets.all(24),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              ColorClass.greenDark,
                                              ColorClass.primaryLight,
                                            ],
                                          ),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: ColorClass.black
                                                  .withOpacity(0.4),
                                              blurRadius: 20,
                                              spreadRadius: value * 5,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.system_update_rounded,
                                          size: 56,
                                          color: ColorClass.white,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 40),
                                // Title with Gradient
                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                    colors: [
                                      ColorClass.greenDark,
                                      ColorClass.neutral700,
                                    ],
                                  ).createShader(bounds),
                                  child: Text(
                                    'Update Available!',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.2,
                                        ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Version Info with Animation
                                TweenAnimationBuilder<double>(
                                  duration: const Duration(milliseconds: 800),
                                  tween: Tween(begin: 0, end: 1),
                                  builder: (context, value, child) {
                                    return Opacity(
                                      opacity: value,
                                      child: Transform.translate(
                                        offset: Offset(0, 20 * (1 - value)),
                                        child: Text(
                                          'New Version: v${provider.newVersion}',
                                          style: TextStyleClass.popinsDefault(
                                            color: ColorClass.greenDark,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 30),
                                // Mandatory Update Badge
                                if (provider.forceUpdate)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .errorContainer,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error
                                              .withOpacity(0.3),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.warning_rounded,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Mandatory Update',
                                          style: TextStyleClass.popinsDefault(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                const SizedBox(height: 32),
                                // What's New Section
                                _buildWhatsNewSection(
                                    context, provider.changes),
                                const SizedBox(height: 40),
                                // Update Button
                                ElevatedButton(
                                  onPressed: () {
                                    provider.launchAppStore(context: context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 32, vertical: 16),
                                    backgroundColor: ColorClass.greenDark,
                                    foregroundColor:
                                        Theme.of(context).colorScheme.onPrimary,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Update Now',
                                        style: TextStyleClass.popinsDefault(
                                          color: ColorClass.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 18,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                    ],
                                  ),
                                ),
                                // Skip button only if not force update
                                if (!provider.forceUpdate)
                                  TextButton(
                                    onPressed: () {
                                      navigateReplaceTo(
                                        context: context,
                                        route: provider.isAuthenticated
                                            ? Routes.home
                                            : Routes.login,
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 12),
                                      foregroundColor: ColorClass.greenDark,
                                    ),
                                    child: Text(
                                      'Skip for now',
                                      style: TextStyleClass.popinsDefault(
                                        color: ColorClass.greenDark,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
