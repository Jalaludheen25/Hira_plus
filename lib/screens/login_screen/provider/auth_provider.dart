import 'package:hira_plus/utils/shared_utils.dart';
import 'package:flutter/material.dart';
import 'package:hira_plus/constants/api_urls.dart';
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

      _logger.d('🔹 [API] Response status: ${response.statusCode}');
      _logger.d('🔹 [API] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _logger.i('🟢 [API] Token fetched successfully!');
        _logger.d('🔹 Token: ${data['token']}');

        // Store token and update login status
        await SharedUtils.setString('auth_token', data['token']);
        await SharedUtils.setString('user_type', _selectedRole);
        _isLoggedIn = true;
        _userType = _selectedRole; // Set user type based on selected role

        _logger.i('📦 Token stored in SharedPreferences');
        _logger.i(
            '🔐 [AUTH] Updated login status - isLoggedIn: $_isLoggedIn, userType: $_userType');

        notifyListeners();
      } else {
        _logger.e(
            '🔴 [API] Failed to fetch token! Status: ${response.statusCode}');
        _logger.e('🔹 Response: ${response.body}');

        // Try to parse error message from response
        String errorMessage = 'Failed to fetch token';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData != null && errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (e) {
          _logger.e('🔴 [API] Could not parse error message: $e');
        }

        throw Exception('$errorMessage (Status: ${response.statusCode})');
      }
    } on http.ClientException catch (e) {
      _logger.e('🔴 [NETWORK] Connection error: $e');
      throw Exception(
          'Network connection failed. Please check your internet connection.');
    } catch (e) {
      _logger.e('🔴 [ERROR] Token fetch failed!');
      _logger.e('🔹 Error: $e');

      // Rethrow with a more user-friendly message if it's not already an Exception
      if (e is! Exception) {
        throw Exception('Authentication failed. Please try again later.');
      }
      throw e;
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
