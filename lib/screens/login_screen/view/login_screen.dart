// imports remain unchanged
import 'package:hira_plus/routes/app_routes.dart';
import 'package:hira_plus/utils/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:hira_plus/constants/color_class.dart';
import 'package:flutter/services.dart';
import 'package:toastification/toastification.dart';
import 'package:pinput/pinput.dart';
import 'package:hira_plus/constants/icons_class.dart';
import 'package:provider/provider.dart';
import 'package:hira_plus/screens/login_screen/provider/auth_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:logger/logger.dart';
import 'package:hira_plus/utils/shared_utils.dart';
import 'dart:developer' as developer;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final Logger _logger = Logger();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    developer.log('🚀 Login screen initialized', name: 'LoginScreen');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    developer.log('🧹 Login screen disposed', name: 'LoginScreen');
    super.dispose();
  }

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

  // Method to build the password field for staff/manager login
  Widget _buildPasswordField(BuildContext context, AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Enter Password',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ColorClass.white),
        ),
        const SizedBox(height: 8),
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
            controller: _passwordController,
            obscureText: true,
            style: TextStyle(
              fontSize: 16,
              color: ColorClass.brandDarkGreen,
              letterSpacing: 1.2,
            ),
            decoration: InputDecoration(
              labelText: 'Password',
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
                Icons.lock_outline,
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
              filled: true,
              fillColor: ColorClass.brandWhite,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
            onChanged: (value) {
              authProvider.setPassword(value);
              developer.log('Password field updated (length: ${value.length})', name: 'LoginScreen');
            },
          ),
        ),
      ],
    );
  }

  bool isValidPhoneNumber(String? value) {
    if (value == null || value.isEmpty) return false;
    return RegExp(r'^[0-9]{10}$').hasMatch(value);
  }

  bool isValidUsername(String? value) {
    return value != null && value.isNotEmpty && value.length >= 3; // Basic validation
  }

  bool isValidPassword(String? value) {
    return value != null && value.length >= 4; // Basic validation
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Determine if we should use OTP-based or username-based authentication
        final bool useOtpAuth = authProvider.selectedRole == 'User';
        
        developer.log('🔍 Building login screen: role=${authProvider.selectedRole}, useOtpAuth=$useOtpAuth', 
            name: 'LoginScreen');
        
        return Scaffold(
          backgroundColor: ColorClass.brandDarkGreen,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 150),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ColorClass.brandLightGreen.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          IconClass.hiraPlus,
                          width: 48,
                          height: 48,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
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

                    if (!authProvider.showOTPField)
                      GestureDetector(
                        onTap: () async {
                          final selected = await showModalBottomSheet<String>(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20)),
                            ),
                            builder: (context) => _RoleSelectionSheet(
                                selectedRole: authProvider.selectedRole),
                          );
                          if (selected != null &&
                              selected != authProvider.selectedRole) {
                            developer.log('👤 Role selection changed: $selected', name: 'LoginScreen');
                            
                            // Clear text fields when role changes
                            bool wasOtpAuth = authProvider.selectedRole == 'User';
                            bool willBeOtpAuth = selected == 'User';
                            
                            if (wasOtpAuth != willBeOtpAuth) {
                              _phoneController.clear();
                              _usernameController.clear();
                              _passwordController.clear();
                              
                              developer.log('🧹 Cleared input fields due to auth type change', 
                                  name: 'LoginScreen');
                            }
                            
                            // Update the role
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
                                color:
                                    ColorClass.brandLightGreen.withOpacity(0.1),
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
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                              const Icon(Icons.keyboard_arrow_down_rounded,
                                  color: ColorClass.brandDarkGreen, size: 28),
                            ],
                          ),
                        ),
                      ),
                      
                    // Conditionally show phone number or username field
                    if (!authProvider.showOTPField)
                      Container(
                        decoration: BoxDecoration(
                          color: ColorClass.brandWhite,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  ColorClass.brandLightGreen.withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: useOtpAuth
                            ? _buildPhoneField(authProvider)
                            : _buildUsernameField(authProvider),
                      ),
                    
                    // Show either OTP or password field on the second screen
                    if (authProvider.showOTPField)
                      useOtpAuth 
                        ? _buildOTPField(context, authProvider)
                        : _buildPasswordField(context, authProvider),

                    const SizedBox(height: 32),

                    // Continue Button - shown in initial screen
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
                            // Validate based on role
                            if (useOtpAuth) {
                              if (!isValidPhoneNumber(_phoneController.text.trim())) {
                                developer.log('❌ Invalid phone number', name: 'LoginScreen');
                                toastification.show(
                                  context: context,
                                  title: const Text('Please enter a valid 10-digit phone number'),
                                  type: ToastificationType.error,
                                  autoCloseDuration: const Duration(seconds: 2),
                                );
                                return;
                              }
                              authProvider.setPhone(_phoneController.text.trim());
                            } else {
                              if (!isValidUsername(_usernameController.text.trim())) {
                                developer.log('❌ Invalid username', name: 'LoginScreen');
                                toastification.show(
                                  context: context,
                                  title: const Text('Please enter a valid username (at least 3 characters)'),
                                  type: ToastificationType.error,
                                  autoCloseDuration: const Duration(seconds: 2),
                                );
                                return;
                              }
                              authProvider.setUsername(_usernameController.text.trim());
                            }
                            
                            // Log the transition
                            developer.log('➡️ Moving to ${useOtpAuth ? "OTP" : "password"} entry screen', 
                                name: 'LoginScreen');
                            
                            authProvider.setShowOTPField(true);
                          },
                          child: const Text('Continue',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),

                    // Validate Button - shown in verification screen
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
                          onPressed: () async {
                            // Validate based on authentication type
                            if (useOtpAuth) {
                              // Handle OTP validation
                              if (authProvider.otp.length != 6) {
                                _logger.w('🟠 [VALIDATION] Invalid OTP length: ${authProvider.otp.length}');
                                developer.log('❌ Invalid OTP length: ${authProvider.otp.length}', 
                                    name: 'LoginScreen');
                                
                                toastification.show(
                                  context: context,
                                  title: const Text('Please enter a valid 6-digit OTP'),
                                  type: ToastificationType.error,
                                  autoCloseDuration: const Duration(seconds: 2),
                                );
                                return;
                              }
                              
                              try {
                                await authProvider.fetchTestLoginToken();
                                developer.log('✅ User authentication successful', 
                                    name: 'LoginScreen');
                              } catch (e) {
                                developer.log('❌ User authentication error: $e', 
                                    name: 'LoginScreen', error: e);
                                
                                toastification.show(
                                  context: context,
                                  title: Text('Authentication failed: ${e.toString().contains('Exception:') ? 
                                    e.toString().split('Exception:')[1].trim() : 'Please try again'}'),
                                  type: ToastificationType.error,
                                  autoCloseDuration: const Duration(seconds: 2),
                                );
                                return;
                              }
                            } else {
                              // Handle password validation
                              if (!isValidPassword(_passwordController.text)) {
                                developer.log('❌ Invalid password format', name: 'LoginScreen');
                                
                                toastification.show(
                                  context: context,
                                  title: const Text('Password must be at least 4 characters'),
                                  type: ToastificationType.error,
                                  autoCloseDuration: const Duration(seconds: 2),
                                );
                                return;
                              }
                              
                              try {
                                if (authProvider.selectedRole == 'Mess Staff') {
                                  // For Mess Staff, use specific authentication method
                                  await authProvider.authenticateMessStaff();
                                  if (!mounted) return;
                                  developer.log('✅ Mess Staff authentication successful', 
                                      name: 'LoginScreen');
                                } else if (authProvider.selectedRole == 'Manager') {
                                  // For Manager role, use proper manager authentication
                                  await authProvider.authenticateManager();
                                  if (!mounted) return;
                                  developer.log('✅ Manager authentication successful', 
                                      name: 'LoginScreen');
                                } else {
                                  // For other roles, use simulation
                                  await authProvider.simulateSuccessfulAuth();
                                  if (!mounted) return;
                                  developer.log('✅ Authentication successful for ${authProvider.selectedRole}', 
                                      name: 'LoginScreen');
                                }

                                if (!mounted) return;

                                _logger.i('🟢 [NAVIGATION] Redirecting to ${authProvider.selectedRole} screen');
                                developer.log('🚀 Redirecting to ${authProvider.selectedRole} screen', 
                                    name: 'LoginScreen');

                                // Save user type to shared preferences
                                await SharedUtils.setString('user_type', authProvider.selectedRole);

                                if (!mounted) return;

                                // Navigate to appropriate screen based on role
                                if (authProvider.selectedRole == 'Mess Staff') {
                                  navigatePRToGlobal(route: Routes.messStaff);
                                } else if (authProvider.selectedRole == 'Manager') {
                                  navigatePRToGlobal(route: Routes.manager);
                                } else {
                                  navigatePRToGlobal(route: Routes.bottomNav);
                                }

                                // Reset the verification state
                                if (mounted) {
                                  authProvider.setShowOTPField(false);
                                }
                                _logger.i('🔄 [STATE] Login flow completed');
                                developer.log('✅ Login flow completed successfully', name: 'LoginScreen');
                              } catch (e) {
                                if (!mounted) return;
                                
                                developer.log('❌ Authentication error: $e', 
                                    name: 'LoginScreen', error: e);
                                
                                toastification.show(
                                  context: context,
                                  title: Text('Authentication failed: ${e.toString().contains('Exception:') ? 
                                    e.toString().split('Exception:')[1].trim() : 'Please try again'}'),
                                  type: ToastificationType.error,
                                  autoCloseDuration: const Duration(seconds: 2),
                                );
                                return;
                              }
                            }
                          },
                          child: Text(
                            useOtpAuth ? 'Validate' : 'Login',
                            style: const TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold
                            )
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

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
                              color:
                                  ColorClass.brandLightGreen.withOpacity(0.8),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Need help? Contact Hira Manager',
                              style: TextStyle(
                                color:
                                    ColorClass.brandLightGreen.withOpacity(0.8),
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
  
  // Helper method to build the phone field
  Widget _buildPhoneField(AuthProvider authProvider) {
    return TextFormField(
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
        filled: true,
        fillColor: ColorClass.brandWhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      onChanged: (value) {
        authProvider.setPhone(value);
      },
    );
  }
  
  // Helper method to build the username field
  Widget _buildUsernameField(AuthProvider authProvider) {
    return TextFormField(
      controller: _usernameController,
      keyboardType: TextInputType.text,
      style: TextStyle(
        fontSize: 16,
        color: ColorClass.brandDarkGreen,
        letterSpacing: 0.5,
      ),
      decoration: InputDecoration(
        labelText: 'Username',
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
          Icons.person_outline,
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
        filled: true,
        fillColor: ColorClass.brandWhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      onChanged: (value) {
        authProvider.setUsername(value);
        developer.log('Username field updated: $value', name: 'LoginScreen');
      },
    );
  }

  Widget _roleIcon(String role) {
    switch (role) {
      case 'User':
        return const Icon(LucideIcons.user,
            color: ColorClass.brandDarkGreen, size: 22);
      case 'Manager':
        return const Icon(LucideIcons.shieldCheck,
            color: ColorClass.brandDarkGreen, size: 22);
      case 'Mess Staff':
        return const Icon(LucideIcons.utensils,
            color: ColorClass.brandDarkGreen, size: 22);
      default:
        return const Icon(LucideIcons.user,
            color: ColorClass.brandDarkGreen, size: 22);
    }
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
    
    developer.log('📋 Building role selection sheet, current: $selectedRole', name: 'RoleSheet');
    
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          const Text('Select Role',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          ...roles.map((role) => ListTile(
                leading: Icon(role['icon'] as IconData,
                    color: ColorClass.brandDarkGreen),
                title: Text(role['label'] as String,
                    style: const TextStyle(fontSize: 16)),
                trailing: selectedRole == role['label']
                    ? const Icon(Icons.check, color: ColorClass.brandLightGreen)
                    : null,
                onTap: () {
                  developer.log('👆 Role selected: ${role['label']}', name: 'RoleSheet');
                  Navigator.of(context).pop(role['label']);
                },
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}