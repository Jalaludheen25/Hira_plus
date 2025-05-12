import 'package:Hira_Plus/utils/shared_utils.dart';
import 'package:flutter/material.dart';
import 'package:Hira_Plus/constants/api_urls.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';

class AuthProvider extends ChangeNotifier {
  final Logger _logger = Logger();
  String _phone = '';
  String _otp = '';
  String _selectedRole = 'User';
  bool _showOTPField = false;
  bool _isLoggedIn = false;
  String _userType = '';

  String get phone => _phone;
  String get otp => _otp;
  String get selectedRole => _selectedRole;
  bool get showOTPField => _showOTPField;
  bool get isLoggedIn => _isLoggedIn;
  String get userType => _userType;

  void setPhone(String value) {
    if (_phone != value) {
      _phone = value;
      notifyListeners();
    }
  }

  void setOtp(String value) {
    if (_otp != value) {
      _otp = value;
      notifyListeners();
    }
  }

  void setSelectedRole(String value) {
    if (_selectedRole != value) {
      _selectedRole = value;
      notifyListeners();
    }
  }

  void setShowOTPField(bool value) {
    if (_showOTPField != value) {
      _showOTPField = value;
      notifyListeners();
    }
  }

  void reset() {
    _phone = '';
    _otp = '';
    _selectedRole = 'User';
    _showOTPField = false;
    notifyListeners();
  }

  void useDummyCredentials() {
    _phone = '9998887776';
    _otp = '123456';
    _selectedRole = 'User';
    _showOTPField = true;
    notifyListeners();
  }

  Future<bool> checkLoginStatus() async {
    try {
      _logger.i('🔍 [AUTH] Checking login status...');
      final token = await SharedUtils.getString('auth_token');
      final userType = await SharedUtils.getString('user_type');

      _isLoggedIn = token.isNotEmpty;
      _userType = userType;

      _logger.i('🔹 [AUTH] isLoggedIn: $_isLoggedIn, userType: $_userType');
      notifyListeners();
      return _isLoggedIn;
    } catch (e) {
      _logger.e('🔴 [AUTH] Error checking login status: $e');
      _isLoggedIn = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchTestLoginToken() async {
    try {
      _logger.i('🔵 [API] Fetching test login token...');
      final response = await http.post(
        Uri.parse(ApiUrls.getTestUser()),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': '9998887776',
          'otp': '123456',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _logger.i('🟢 [API] Token fetched successfully!');
        _logger.d('🔹 Token: ${data['token']}');
        
        // Store token and update login status
        await SharedUtils.setString('auth_token', data['token']);
        _isLoggedIn = true;
        _userType = _selectedRole; // Set user type based on selected role
        
        _logger.i('📦 Token stored in SharedPreferences');
        _logger.i('🔐 [AUTH] Updated login status - isLoggedIn: $_isLoggedIn, userType: $_userType');
        
        notifyListeners();
      } else {
        _logger.e(
            '🔴 [API] Failed to fetch token! Status: ${response.statusCode}');
        _logger.e('🔹 Response: ${response.body}');
        throw Exception('Failed to fetch token');
      }
    } catch (e) {
      _logger.e('🔴 [ERROR] Token fetch failed!');
      _logger.e('🔹 Error: $e');
      throw Exception('Error: $e');
    }
  }

  Future<void> logout() async {
    try {
      _logger.i('🔄 [AUTH] Logging out user...');
      await SharedUtils.setString('auth_token', '');
      await SharedUtils.setString('user_type', '');
      _isLoggedIn = false;
      _userType = '';
      reset();
      _logger.i('🟢 [AUTH] Logout successful');
      notifyListeners();
    } catch (e) {
      _logger.e('🔴 [AUTH] Error during logout: $e');
    }
  }
}
