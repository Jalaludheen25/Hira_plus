import 'package:hira_plus/utils/shared_utils.dart';
import 'package:flutter/material.dart';
import 'package:hira_plus/constants/api_urls.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:logger/logger.dart';

class AuthProvider extends ChangeNotifier {
  final Logger _logger = Logger();
  String _phone = '';
  String _username = '';
  String _otp = '';
  String _password = '';
  String _selectedRole = 'User';
  bool _showOTPField = false;
  bool _isLoggedIn = false;
  String _userType = '';

  String get phone => _phone;
  String get username => _username;
  String get otp => _otp;
  String get password => _password;
  String get selectedRole => _selectedRole;
  bool get showOTPField => _showOTPField;
  bool get isLoggedIn => _isLoggedIn;
  String get userType => _userType;

  // Helper method to determine if current role uses OTP or password
  bool get isOtpBasedAuth => _selectedRole == 'User';

  void setPhone(String value) {
    if (_phone != value) {
      _phone = value;
      developer.log('📱 Phone number set: $value', name: 'AuthProvider');
      notifyListeners();
    }
  }

  void setUsername(String value) {
    if (_username != value) {
      _username = value;
      developer.log('👤 Username set: $value', name: 'AuthProvider');
      notifyListeners();
    }
  }

  void setOtp(String value) {
    if (_otp != value) {
      _otp = value;
      developer.log('🔢 OTP updated (length: ${value.length})',
          name: 'AuthProvider');
      notifyListeners();
    }
  }

  void setPassword(String value) {
    if (_password != value) {
      _password = value;
      developer.log('🔑 Password updated (length: ${value.length})',
          name: 'AuthProvider');
      notifyListeners();
    }
  }

  void setSelectedRole(String value) {
    if (_selectedRole != value) {
      _selectedRole = value;
      developer.log('👤 Role changed to: $value', name: 'AuthProvider');
      notifyListeners();
    }
  }

  void setShowOTPField(bool value) {
    if (_showOTPField != value) {
      _showOTPField = value;
      developer.log(
          '🔄 Authentication screen state changed: ${value ? "Verification" : "Initial"}',
          name: 'AuthProvider');
      notifyListeners();
    }
  }

  void reset() {
    _phone = '';
    _username = '';
    _otp = '';
    _password = '';
    _selectedRole = 'User';
    _showOTPField = false;
    developer.log('🧹 Auth provider state reset', name: 'AuthProvider');
    notifyListeners();
  }

  Future<bool> checkLoginStatus() async {
    try {
      _logger.i('🔍 [AUTH] Checking login status...');
      developer.log('🔍 Checking login status...', name: 'AuthProvider');

      final token = await SharedUtils.getString('auth_token');
      final userType = await SharedUtils.getString('user_type');

      _isLoggedIn = token.isNotEmpty;
      _userType = userType;

      _logger.i('🔹 [AUTH] isLoggedIn: $_isLoggedIn, userType: $_userType');
      developer.log(
          '🔹 Login status: isLoggedIn=$_isLoggedIn, userType=$_userType',
          name: 'AuthProvider');

      notifyListeners();
      return _isLoggedIn;
    } catch (e) {
      _logger.e('🔴 [AUTH] Error checking login status: $e');
      developer.log('🔴 Error checking login status: $e',
          name: 'AuthProvider', error: e);

      _isLoggedIn = false;
      notifyListeners();
      return false;
    }
  }

  // Method for authenticating mess staff
  Future<void> authenticateMessStaff() async {
    try {
      developer.log('🔵 [AUTH] Authenticating Mess Staff...', name: 'AuthProvider');
      _logger.i('🔵 [API] Initiating Mess Staff authentication...');

      // Check if the username and password match the required values
      if (_username != "mess" || _password != "mess123") {
        throw Exception('Invalid username or password');
      }

      final url = ApiUrls.getMessStaffLogin();

      // Prepare request body with username and password
      final requestBody = {
        'username': _username,
        'password': _password,
      };

      developer.log('📡 Making Mess Staff auth request to: $url', name: 'AuthProvider');
      developer.log('📦 Request payload: ${jsonEncode(requestBody)}', name: 'AuthProvider');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      developer.log('📥 Response status: ${response.statusCode}', name: 'AuthProvider');
      developer.log('📥 Raw response body: ${response.body}', name: 'AuthProvider');
      _logger.d('🔹 [API] Response status: ${response.statusCode}');
      _logger.d('🔹 [API] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _logger.i('🟢 [API] Mess Staff authentication successful!');
        developer.log('🟢 Mess Staff authentication successful!', name: 'AuthProvider');
        developer.log('🔑 Full response data: $data', name: 'AuthProvider');

        // Extract token with more robust handling
        String token;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('token')) {
            token = data['token']?.toString() ?? '';
          } else if (data.containsKey('access_token')) {
            token = data['access_token']?.toString() ?? '';
          } else if (data.containsKey('auth_token')) {
            token = data['auth_token']?.toString() ?? '';
          } else {
            // Check if token is directly in the response
            token = data.toString();
          }
        } else {
          // Handle case where response might be a string
          token = data.toString();
        }

        // Validate token is not empty
        if (token.isEmpty) {
          throw Exception('Invalid token received from server');
        }

        developer.log('🔑 Token received: $token', name: 'AuthProvider');
        _logger.i('🔑 [AUTH] Token received: $token');

        // Store token and update login status
        await SharedUtils.setString('auth_token', token);
        
        // Verify token was stored successfully
        final storedToken = await SharedUtils.getString('auth_token');
        developer.log('✅ Verification - Stored token: $storedToken', name: 'AuthProvider');
        
        await SharedUtils.setString('user_type', _selectedRole);
        _isLoggedIn = true;
        _userType = _selectedRole;

        developer.log('📦 Token stored in SharedPreferences', name: 'AuthProvider');
        developer.log('🔐 Updated login status - isLoggedIn: $_isLoggedIn, userType: $_userType', 
            name: 'AuthProvider');

        notifyListeners();
        return;
      } else {
        _logger.e('🔴 [API] Mess Staff authentication failed! Status: ${response.statusCode}');
        developer.log('🔴 Mess Staff authentication failed! Status: ${response.statusCode}', 
            name: 'AuthProvider');

        // Try to parse error message from response
        String errorMessage = 'Authentication failed';
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
      developer.log('🔴 Network connection error: $e', name: 'AuthProvider', error: e);
      
      throw Exception('Network connection failed. Please check your internet connection.');
    } catch (e) {
      _logger.e('🔴 [ERROR] Mess Staff authentication failed!');
      _logger.e('🔹 Error: $e');
      developer.log('🔴 Mess Staff authentication failed: $e', name: 'AuthProvider', error: e);

      // If all else fails, provide a fallback to demo mode for development
      if (_username == "staff" && _password == "staff123") {
        _logger.i('🔵 [TEST] Falling back to demo mode...');
        developer.log('🔵 Falling back to demo mode', name: 'AuthProvider');
        
        // Create a dummy token for demo login
        final dummyToken = 'demo_staff_token_${DateTime.now().millisecondsSinceEpoch}';
        
        // Store token and update login status
        await SharedUtils.setString('auth_token', dummyToken);
        await SharedUtils.setString('user_type', _selectedRole);
        _isLoggedIn = true;
        _userType = _selectedRole;

        developer.log('📦 Demo token stored in SharedPreferences', name: 'AuthProvider');
        developer.log('🔐 Updated login status - isLoggedIn: $_isLoggedIn, userType: $_userType', 
            name: 'AuthProvider');

        notifyListeners();
        return;
      }

      // Rethrow with a more user-friendly message if it's not already an Exception
      if (e is! Exception) {
        throw Exception('Authentication failed. Please try again later.');
      }
      throw e;
    }
  }

  // For User authentication with phone/OTP
  Future<void> fetchTestLoginToken() async {
    try {
      developer.log('🔵 Fetching login token...', name: 'AuthProvider');
      _logger.i('🔵 [API] Fetching login token...');

      // Test credentials for user role - hardcoded for development
      if (_phone == '9998887776' && _otp == '123456') {
        _logger.i('🔵 [TEST] Using test user credentials...');
        developer.log('🔵 Using test user credentials', name: 'AuthProvider');

        // Create a dummy token for demo login
        final dummyToken =
            'demo_user_token_${DateTime.now().millisecondsSinceEpoch}';

        // Store token and update login status
        await SharedUtils.setString('auth_token', dummyToken);
        await SharedUtils.setString('user_type', _selectedRole);
        _isLoggedIn = true;
        _userType = _selectedRole;

        developer.log('📦 Demo token stored in SharedPreferences',
            name: 'AuthProvider');
        developer.log(
            '🔐 Updated login status - isLoggedIn: $_isLoggedIn, userType: $_userType',
            name: 'AuthProvider');

        notifyListeners();
        return;
      }

      final url = ApiUrls.getTestUser();

      // Prepare request body based on authentication type
      final requestBody = {
        'phoneNumber': _phone,
        'otp': _otp,
      };

      developer.log('📡 Making auth request to: $url', name: 'AuthProvider');
      developer.log('📦 Request type: OTP-based', name: 'AuthProvider');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      developer.log('📥 Response status: ${response.statusCode}',
          name: 'AuthProvider');
      _logger.d('🔹 [API] Response status: ${response.statusCode}');
      _logger.d('🔹 [API] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _logger.i('🟢 [API] Token fetched successfully!');
        developer.log('🟢 Token fetched successfully!', name: 'AuthProvider');

        // Store token and update login status
        await SharedUtils.setString('auth_token', data['token']);
        await SharedUtils.setString('user_type', _selectedRole);
        _isLoggedIn = true;
        _userType = _selectedRole;

        developer.log('📦 Token stored in SharedPreferences',
            name: 'AuthProvider');
        developer.log(
            '🔐 Updated login status - isLoggedIn: $_isLoggedIn, userType: $_userType',
            name: 'AuthProvider');

        notifyListeners();
      } else {
        _logger.e(
            '🔴 [API] Failed to fetch token! Status: ${response.statusCode}');
        developer.log(
            '🔴 Failed to fetch token! Status: ${response.statusCode}',
            name: 'AuthProvider',
            error: response.body);

        // Try to parse error message from response
        String errorMessage = 'Failed to fetch token';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData != null && errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (e) {
          _logger.e('🔴 [API] Could not parse error message: $e');
          developer.log('🔴 Could not parse error message: $e',
              name: 'AuthProvider', error: e);
        }

        throw Exception('$errorMessage (Status: ${response.statusCode})');
      }
    } on http.ClientException catch (e) {
      _logger.e('🔴 [NETWORK] Connection error: $e');
      developer.log('🔴 Network connection error: $e',
          name: 'AuthProvider', error: e);

      throw Exception(
          'Network connection failed. Please check your internet connection.');
    } catch (e) {
      _logger.e('🔴 [ERROR] Token fetch failed!');
      _logger.e('🔹 Error: $e');
      developer.log('🔴 Token fetch failed: $e',
          name: 'AuthProvider', error: e);

      // Rethrow with a more user-friendly message if it's not already an Exception
      if (e is! Exception) {
        throw Exception('Authentication failed. Please try again later.');
      }
      throw e;
    }
  }

  // For simulating successful auth (for testing/demo only)
  Future<bool> simulateSuccessfulAuth() async {
    try {
      // Create a dummy token
      final dummyToken = 'demo_token_${DateTime.now().millisecondsSinceEpoch}';

      developer.log('🧪 Simulating successful auth for ${_selectedRole}',
          name: 'AuthProvider');

      // Store the dummy token
      await SharedUtils.setString('auth_token', dummyToken);
      await SharedUtils.setString('user_type', _selectedRole);

      _isLoggedIn = true;
      _userType = _selectedRole;

      developer.log('✅ Demo token stored: $dummyToken', name: 'AuthProvider');
      notifyListeners();

      return true;
    } catch (e) {
      developer.log('❌ Error in simulated auth: $e',
          name: 'AuthProvider', error: e);
      return false;
    }
  }

  Future<void> logout() async {
    try {
      _logger.i('🔄 [AUTH] Logging out user...');
      developer.log('🔄 Logging out user...', name: 'AuthProvider');

      await SharedUtils.setString('auth_token', '');
      await SharedUtils.setString('user_type', '');
      _isLoggedIn = false;
      _userType = '';
      reset();

      _logger.i('🟢 [AUTH] Logout successful');
      developer.log('🟢 Logout successful', name: 'AuthProvider');

      notifyListeners();
    } catch (e) {
      _logger.e('🔴 [AUTH] Error during logout: $e');
      developer.log('🔴 Error during logout: $e',
          name: 'AuthProvider', error: e);
    }
  }
}
