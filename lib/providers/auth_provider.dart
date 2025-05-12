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

  String get phone => _phone;
  String get otp => _otp;
  String get selectedRole => _selectedRole;
  bool get showOTPField => _showOTPField;

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
        await SharedUtils.setString('auth_token', data['token']);
        _logger.i('📦 Token stored in SharedPreferences');
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
}
