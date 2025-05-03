import 'package:canteen_app/routes/app_routes.dart';
import 'package:canteen_app/utils/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:canteen_app/constants/color_class.dart';
import 'package:flutter/services.dart';
import 'package:toastification/toastification.dart';
import 'package:pinput/pinput.dart';
import 'package:canteen_app/constants/icons_class.dart';
import 'package:provider/provider.dart';
import 'package:canteen_app/providers/auth_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // Helper method to build the OTP Field using pinput
  Widget _buildOTPField(BuildContext context, AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Enter OTP',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ColorClass.white),
        ),
        const SizedBox(height: 8),
        Pinput(
          length: 6,
          onChanged: (value) {
            authProvider.setOtp(value);
          },
        ),
      ],
    );
  }

  bool isValidPhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }
    // Regex for 10-digit phone number
    return RegExp(r'^[0-9]{10}$').hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Scaffold(
          backgroundColor: ColorClass.brandDarkGreen,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 150),
                    // Logo and Branding
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ColorClass.brandLightGreen.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          IconClass.HiraPlus,
                          width: 48,
                          height: 48,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // App Title with Gradient
                    Center(
                      child: ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            ColorClass.brandLightGreen,
                            ColorClass.brandLightGreen.withOpacity(0.8),
                          ],
                        ).createShader(bounds),
                        child: const Text(
                          'Mess Connect',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Subtitle
                    Center(
                      child: Text(
                        'Your Digital Mess Companion',
                        style: TextStyle(
                          fontSize: 16,
                          color: ColorClass.brandLightGreen.withOpacity(0.8),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // User Type Selection
                    if (!authProvider.showOTPField)
                      GestureDetector(
                        onTap: () async {
                          final selected = await showModalBottomSheet<String>(
                            context: context,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            builder: (context) => _RoleSelectionSheet(selectedRole: authProvider.selectedRole),
                          );
                          if (selected != null && selected != authProvider.selectedRole) {
                            authProvider.setSelectedRole(selected);
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          height: 56,
                          decoration: BoxDecoration(
                            color: ColorClass.brandWhite,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: ColorClass.brandLightGreen.withOpacity(0.1),
                                spreadRadius: 2,
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  _roleIcon(authProvider.selectedRole),
                                  const SizedBox(width: 12),
                                  Text(
                                    authProvider.selectedRole,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                  ),
                                ],
                              ),
                              const Icon(Icons.keyboard_arrow_down_rounded, color: ColorClass.brandDarkGreen, size: 28),
                            ],
                          ),
                        ),
                      ),
                    // Conditionally render the phone number input
                    if (!authProvider.showOTPField)
                      Container(
                        decoration: BoxDecoration(
                          color: ColorClass.brandWhite,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: ColorClass.brandLightGreen.withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          style: TextStyle(
                            fontSize: 16,
                            color: ColorClass.brandDarkGreen,
                            letterSpacing: 1.2,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            labelStyle: TextStyle(
                              color: ColorClass.brandDarkGreen,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            floatingLabelStyle: TextStyle(
                              color: ColorClass.brandDarkGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              letterSpacing: 0.5,
                            ),
                            errorStyle: TextStyle(
                              color: ColorClass.brandLightGreen,
                              fontSize: 12,
                            ),
                            prefixIcon: Icon(
                              Icons.phone_android,
                              color: ColorClass.brandDarkGreen,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: ColorClass.brandLightGreen,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: ColorClass.brandLightGreen,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: ColorClass.brandLightGreen,
                                width: 1,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: ColorClass.brandLightGreen,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: ColorClass.brandWhite,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter phone number';
                            }
                            if (!isValidPhoneNumber(value)) {
                              return 'Please enter valid 10-digit number';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            authProvider.setPhone(value);
                          },
                        ),
                      ),
                    // Conditionally show OTP Field when mobile is entered
                    if (authProvider.showOTPField) _buildOTPField(context, authProvider),
                    const SizedBox(height: 32),
                    // Login Button with Gradient
                    if (!authProvider.showOTPField)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorClass.brandLightGreen,
                            foregroundColor: ColorClass.brandDarkGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () {
                            if (authProvider.selectedRole == 'User') {
                              if (!isValidPhoneNumber(_phoneController.text)) {
                                toastification.show(
                                  context: context,
                                  title: const Text('Please enter a valid 10-digit phone number'),
                                  type: ToastificationType.error,
                                );
                                return;
                              }
                              authProvider.setShowOTPField(true);
                            } else {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => DummyRoleScreen(role: authProvider.selectedRole),
                                ),
                              );
                            }
                          },
                          child: const Text('Continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    // OTP Validate Button
                    if (authProvider.showOTPField)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorClass.brandLightGreen,
                            foregroundColor: ColorClass.brandDarkGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () {
                            if (authProvider.otp.length != 6) {
                              toastification.show(
                                context: context,
                                title: const Text('Please enter a valid 6-digit OTP'),
                                type: ToastificationType.error,
                              );
                              return;
                            }
                            navigatePRTo(context: context, route: Routes.bottomNav);
                            authProvider.reset();
                          },
                          child: const Text('Validate', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    const SizedBox(height: 24),
                    // Help Text
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: ColorClass.brandLightGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: ColorClass.brandLightGreen.withOpacity(0.8),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Need help? Contact Hira Manager',
                              style: TextStyle(
                                color: ColorClass.brandLightGreen.withOpacity(0.8),
                                fontSize: 12,
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
        );
      },
    );
  }

  Widget _roleIcon(String role) {
    switch (role) {
      case 'User':
        return const Icon(LucideIcons.user, color: ColorClass.brandDarkGreen, size: 22);
      case 'Manager':
        return const Icon(LucideIcons.shieldCheck, color: ColorClass.brandDarkGreen, size: 22);
      case 'Mess Staff':
        return const Icon(LucideIcons.utensils, color: ColorClass.brandDarkGreen, size: 22);
      default:
        return const Icon(LucideIcons.user, color: ColorClass.brandDarkGreen, size: 22);
    }
  }
}

// DummyRoleScreen widget
class DummyRoleScreen extends StatelessWidget {
  final String role;
  const DummyRoleScreen({required this.role, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$role Dashboard',),
        backgroundColor: ColorClass.brandDarkGreen,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Text(
          '$role features coming soon!',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _RoleSelectionSheet extends StatelessWidget {
  final String selectedRole;
  const _RoleSelectionSheet({required this.selectedRole});

  @override
  Widget build(BuildContext context) {
    final roles = [
      {'label': 'User', 'icon': LucideIcons.user},
      {'label': 'Manager', 'icon': LucideIcons.shieldCheck},
      {'label': 'Mess Staff', 'icon': LucideIcons.utensils},
    ];
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          const Text('Select Role', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          ...roles.map((role) => ListTile(
                leading: Icon(role['icon'] as IconData, color: ColorClass.brandDarkGreen),
                title: Text(role['label'] as String, style: const TextStyle(fontSize: 16)),
                trailing: selectedRole == role['label']
                    ? const Icon(Icons.check, color: ColorClass.brandLightGreen)
                    : null,
                onTap: () => Navigator.of(context).pop(role['label']),
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
