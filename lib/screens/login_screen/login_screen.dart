import 'package:canteen_app/routes/app_routes.dart';
import 'package:canteen_app/utils/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:canteen_app/constants/color_class.dart';
import 'package:flutter/services.dart';
import 'package:toastification/toastification.dart';
import 'package:pinput/pinput.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _showOTPField = false;
  String _otp = "";

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // Helper method to build the OTP Field using pinput
  Widget _buildOTPField() {
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
            setState(() {
              _otp = value;
            });
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
    return Scaffold(
      backgroundColor:
          ColorClass.primaryBase, // Changed from backgroundColor to primaryBase
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
                      color: ColorClass.white.withOpacity(
                          0.1), // Changed from primaryBase to white
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.restaurant_menu,
                      size: 48,
                      color:
                          ColorClass.white, // Changed from primaryBase to white
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // App Title with Gradient
                Center(
                  child: ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        ColorClass.white, // Changed from primaryBase to white
                        ColorClass.white.withOpacity(
                            0.8), // Changed from primaryBase to white
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
                      color: ColorClass.white
                          .withOpacity(0.8), // Changed from neutral500
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // Conditionally render the phone number input
                if (!_showOTPField)
                  Container(
                    decoration: BoxDecoration(
                      color: ColorClass.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: ColorClass.neutral300.withOpacity(0.1),
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
                        color: ColorClass.neutral800,
                        letterSpacing: 1.2,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        labelStyle: TextStyle(
                          color: ColorClass.primaryBase,
                          fontSize: 14,
                        ),
                        errorStyle: TextStyle(
                          color: ColorClass.redBase,
                          fontSize: 12,
                        ),
                        prefixIcon: Icon(
                          Icons.phone_android,
                          color: ColorClass.primaryBase,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: ColorClass.neutral200,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: ColorClass.primaryBase,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: ColorClass.redBase,
                            width: 1,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: ColorClass.redBase,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: ColorClass.white,
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
                        setState(() {});
                      },
                    ),
                  ),
                // Conditionally show OTP Field when mobile is entered
                if (_showOTPField) _buildOTPField(),
                const SizedBox(height: 32),
                // Login Button with Gradient
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        ColorClass.white, // Changed from primaryBase to white
                        ColorClass.white.withOpacity(
                            0.8), // Changed from primaryBase to white
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ColorClass.white.withOpacity(
                            0.3), // Changed from primaryBase to white
                        spreadRadius: 0,
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      if (!_showOTPField) {
                        if (!isValidPhoneNumber(_phoneController.text)) {
                          toastification.show(
                            context: context,
                            title: Text('Please enter a valid phone number'),
                            type: ToastificationType.error,
                            autoCloseDuration: const Duration(seconds: 2),
                          );
                          return;
                        } else {
                          toastification.show(
                            context: context,
                            title: Text('OTP Sent'),
                            type: ToastificationType.success,
                            autoCloseDuration: const Duration(seconds: 2),
                          );
                          setState(() {
                            _showOTPField = true;
                          });
                          return;
                        }
                      } else {
                        if (_otp.length != 6) {
                          toastification.show(
                            context: context,
                            title: Text('Please enter a valid 6-digit OTP'),
                            type: ToastificationType.error,
                            autoCloseDuration: const Duration(seconds: 2),
                          );
                          return;
                        }
                        navigateTo(context: context, route: Routes.bottomNav);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _showOTPField ? 'Validate' : 'Send OTP',
                      style: const TextStyle(
                        color: ColorClass.primaryBase,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
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
                      color: ColorClass.white
                          .withOpacity(0.1), // Changed from neutral100
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: ColorClass.white
                              .withOpacity(0.8), // Changed from neutral500
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Need help? Contact Hira Manager',
                          style: TextStyle(
                            color: ColorClass.white
                                .withOpacity(0.8), // Changed from neutral500
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
  }
}
