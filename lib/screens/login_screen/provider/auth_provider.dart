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
  String _department = '';
  String _designation = '';

  String get phone => _phone;
  String get username => _username;
  String get otp => _otp;
  String get password => _password;
  String get selectedRole => _selectedRole;
  bool get showOTPField => _showOTPField;
  bool get isLoggedIn => _isLoggedIn;
  String get userType => _userType;
  String get department => _department;
  String get designation => _designation;

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

  void setDepartment(String value) {
    if (_department != value) {
      _department = value;
      notifyListeners();
    }
  }

  void setDesignation(String value) {
    if (_designation != value) {
      _designation = value;
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
    _department = '';
    _designation = '';
    developer.log('🧹 Auth provider state reset', name: 'AuthProvider');
    notifyListeners();
  }

  // Helper method to get the appropriate token
  // Future<String?> getAuthToken() async {
  //   try {
  //     final userType = await SharedUtils.getString('user_type') ?? '';
  //     switch (userType) {
  //       case 'Manager':
  //         return await SharedUtils.getString('manager_token');
  //       case 'Mess Staff':
  //         return await SharedUtils.getString('staff_token');
  //       default:
  //         return await SharedUtils.getString('auth_token');
  //     }
  //   } catch (e) {
  //     _logger.e('🔴 [AUTH] Error getting token: $e');
  //     return null;
  //   }
  // }

  // Add these methods to your AuthProvider class
  Future<String?> getAuthToken() async {
    return await SharedUtils.getString('auth_token');
  }

  Future<String?> getUserType() async {
    return await SharedUtils.getString('user_type');
  }

// Make sure these methods are used during login to set user type
  Future<void> handleSuccessfulLogin(String token, String userType) async {
    await SharedUtils.setString('auth_token', token);
    await SharedUtils.setString('user_type', userType);
    _isLoggedIn = true;
    _userType = userType;
    notifyListeners();
  }

  // Updated checkLoginStatus method for AuthProvider class
  Future<bool> checkLoginStatus() async {
    try {
      _logger.i('🔍 [AUTH] Checking login status...');
      developer.log('🔍 Checking login status...', name: 'AuthProvider');

      final token = await SharedUtils.getString('auth_token');
      final userType = await SharedUtils.getString('user_type');

      _isLoggedIn = token.isNotEmpty;
      _userType = userType;

      // Add detailed debug prints for login status check
      _logger.i('🔹 [AUTH] Login check details:');
      _logger.i('   - Token exists: ${token.isNotEmpty}');
      _logger.i('   - Token value: $token');
      _logger.i('   - User type: $_userType');
      _logger.i('   - Is logged in: $_isLoggedIn');

      developer.log('🔍 Detailed login status:', name: 'AuthProvider');
      developer.log('   - Token exists: ${token.isNotEmpty}',
          name: 'AuthProvider');
      developer.log('   - Token value: $token', name: 'AuthProvider');
      developer.log('   - User type: $_userType', name: 'AuthProvider');
      developer.log('   - Is logged in: $_isLoggedIn', name: 'AuthProvider');

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

  // Handle token expiration by clearing credentials
  Future<void> handleTokenExpiration() async {
    try {
      _logger.i('🔄 [AUTH] Handling token expiration...');
      developer.log('🔄 Handling token expiration...', name: 'AuthProvider');

      // Clear the appropriate token based on user type
      switch (_userType) {
        case 'Manager':
          await SharedUtils.setString('manager_token', '');
          await SharedUtils.setString('auth_token', ''); // Clear both tokens
          break;
        case 'Mess Staff':
          await SharedUtils.setString('staff_token', '');
          break;
        default:
          await SharedUtils.setString('auth_token', '');
          break;
      }

      await SharedUtils.setString('user_type', '');
      _isLoggedIn = false;
      _userType = '';
      reset();

      _logger.i('✅ [AUTH] Credentials cleared successfully');
      developer.log('✅ Credentials cleared successfully', name: 'AuthProvider');

      notifyListeners();
    } catch (e) {
      _logger.e('🔴 [AUTH] Error handling token expiration: $e');
      developer.log('🔴 Error handling token expiration: $e',
          name: 'AuthProvider', error: e);
    }
  }

  // Method for authenticating manager (admin)
  Future<void> authenticateManager() async {
    try {
      developer.log('🔵 [AUTH] Authenticating Manager (Admin)...',
          name: 'AuthProvider');
      _logger.i('🔵 [API] Initiating Manager authentication...');

      final url = ApiUrls.adminLogin();
      final requestBody = {
        'phoneNumber': _username,
        'password': _password,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        developer.log('📥 Response data: $data', name: 'AuthProvider');

        if (data.containsKey('token')) {
          final String token = data['token'];

          // Store tokens and update state
          await SharedUtils.setString('manager_token', token);
          await SharedUtils.setString('auth_token', token);
          await SharedUtils.setString('user_type', 'Manager');

          _isLoggedIn = true;
          _userType = 'Manager';

          // Add more detailed debug prints
          developer.log('✅ Manager authentication successful',
              name: 'AuthProvider');
          developer.log('🔑 Manager token stored: $token',
              name: 'AuthProvider');
          developer.log('👤 User type set to: $_userType',
              name: 'AuthProvider');
          developer.log('📍 Login state: isLoggedIn=$_isLoggedIn',
              name: 'AuthProvider');

          // Verify stored values
          final storedToken = await SharedUtils.getString('auth_token');
          final storedType = await SharedUtils.getString('user_type');
          developer.log('✓ Verification - Stored token: $storedToken',
              name: 'AuthProvider');
          developer.log('✓ Verification - Stored user type: $storedType',
              name: 'AuthProvider');

          notifyListeners();
          return;
        }
        throw Exception('Token not found in response');
      }

      throw Exception('Authentication failed (${response.statusCode})');
    } catch (e) {
      _logger.e('🔴 [AUTH] Manager authentication failed: $e');
      throw Exception('Authentication failed. Please try again.');
    }
  }

  // Method to handle test login
  Future<void> handleTestLogin() async {
    try {
      developer.log('🔵 [AUTH] Initiating test login...', name: 'AuthProvider');
      _logger.i('🔵 [API] Starting test login process');

      final url = ApiUrls.testLogin();
      final requestBody = {
        'phoneNumber': _phone,
        'otp': _otp,
      };

      developer.log('📡 Making test login request to: $url',
          name: 'AuthProvider');
      developer.log('📦 Request payload: ${jsonEncode(requestBody)}',
          name: 'AuthProvider');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      developer.log('📥 Response status: ${response.statusCode}',
          name: 'AuthProvider');
      _logger.d('🔹 [API] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!data['success']) {
          throw Exception(data['message'] ?? 'Test login failed');
        }

        final String token = data['token'];
        final userDetails = data['user'];

        // Store user details
        if (userDetails != null) {
          await SharedUtils.setString(
              'user_department', userDetails['department'] ?? '');
          await SharedUtils.setString(
              'user_designation', userDetails['designation'] ?? '');
          setDepartment(userDetails['department'] ?? '');
          setDesignation(userDetails['designation'] ?? '');
        }

        // Store token and update login status
        await SharedUtils.setString('auth_token', token);
        await SharedUtils.setString('user_type', _selectedRole);
        _isLoggedIn = true;
        _userType = _selectedRole;

        developer.log('✅ Test login successful', name: 'AuthProvider');
        developer.log('👤 User details stored', name: 'AuthProvider');
        developer.log('🔑 Token stored in SharedPreferences',
            name: 'AuthProvider');

        notifyListeners();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Test login failed');
      }
    } catch (e) {
      _logger.e('🔴 [AUTH] Test login failed: $e');
      developer.log('🔴 Test login failed: $e', name: 'AuthProvider', error: e);
      throw Exception('Test login failed: ${e.toString()}');
    }
  }

  // For User authentication with phone/OTP
  Future<void> fetchVerifyOtpToken() async {
    try {
      developer.log('🔵 Fetching login token...', name: 'AuthProvider');
      _logger.i('🔵 [API] Fetching login token...');

      // Check for test credentials
      if (_phone == '9998887776' && _otp == '123456') {
        _logger.i('🔵 [TEST] Using test user credentials...');
        developer.log('🔵 Using test user credentials', name: 'AuthProvider');
        await handleTestLogin();
        return;
      }

      final url = ApiUrls.getVerifyOtp();

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

  // New method to request OTP for a phone number
  Future<void> requestOtp(String phoneNumber) async {
    try {
      final url = ApiUrls.getRequestOtp();
      developer.log('📡 Requesting OTP for $phoneNumber at $url',
          name: 'AuthProvider');
      final requestBody = {'phoneNumber': phoneNumber};
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      developer.log('📥 OTP request response status: ${response.statusCode}',
          name: 'AuthProvider');
      if (response.statusCode == 200) {
        developer.log('🟢 OTP sent successfully to $phoneNumber',
            name: 'AuthProvider');
      } else {
        String errorMessage = 'Failed to send OTP';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData != null && errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (e) {}
        throw Exception('$errorMessage (Status: ${response.statusCode})');
      }
    } catch (e) {
      developer.log('❌ Error requesting OTP: $e', name: 'AuthProvider');
      throw Exception('Failed to request OTP. Please try again.');
    }
  }

  Future<bool> simulateSuccessfulAuth() async {
    try {
      // For simulation purposes, we'll make a real API call to get a token if possible
      String token = '';

      try {
        // Try a test API endpoint that works without authentication
        final testUrl = ApiUrls.getMealsForUser();
        final testResponse = await http.get(Uri.parse(testUrl));

        if (testResponse.statusCode == 200) {
          final testData = jsonDecode(testResponse.body);

          // Extract token from test response if available
          if (testData is Map<String, dynamic> &&
              testData.containsKey('token')) {
            token = testData['token']?.toString() ?? '';

            developer.log('🔄 Retrieved real token for simulation',
                name: 'AuthProvider');
          }
        }
      } catch (e) {
        // If network request fails, use empty token
        developer.log('❌ Could not retrieve real token for simulation: $e',
            name: 'AuthProvider');
      }

      developer.log('🧪 Simulating successful auth for ${_selectedRole}',
          name: 'AuthProvider');

      // Store whatever token we were able to get (might be empty)
      await SharedUtils.setString('auth_token', token);
      await SharedUtils.setString('user_type', _selectedRole);

      _isLoggedIn = true;
      _userType = _selectedRole;

      developer.log('✅ Token stored from API or empty if not available',
          name: 'AuthProvider');
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

  // Method for authenticating mess staff
  Future<void> authenticateMessStaff() async {
    try {
      developer.log('🔵 [AUTH] Authenticating Mess Staff...',
          name: 'AuthProvider');
      _logger.i('🔵 [API] Initiating Mess Staff authentication...');

      final url = ApiUrls.getMessStaffLogin();

      // Prepare request body with username and password
      final requestBody = {
        'username': _username,
        'password': _password,
      };

      developer.log('📡 Making Mess Staff auth request to: $url',
          name: 'AuthProvider');
      developer.log('📦 Request payload: ${jsonEncode(requestBody)}',
          name: 'AuthProvider');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      developer.log('📥 Response status: ${response.statusCode}',
          name: 'AuthProvider');
      developer.log('📥 Raw response body: ${response.body}',
          name: 'AuthProvider');
      _logger.d('🔹 [API] Response status: ${response.statusCode}');
      _logger.d('🔹 [API] Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Invalid credentials or server error');
      }

      final data = jsonDecode(response.body);
      _logger.i('🟢 [API] Mess Staff authentication successful!');
      developer.log('🟢 Mess Staff authentication successful!',
          name: 'AuthProvider');
      developer.log('🔑 Full response data: $data', name: 'AuthProvider');

      // Extract token with more robust handling
      String token = '';
      if (data is Map<String, dynamic>) {
        if (data.containsKey('token')) {
          token = data['token']?.toString() ?? '';
        } else if (data.containsKey('access_token')) {
          token = data['access_token']?.toString() ?? '';
        } else if (data.containsKey('auth_token')) {
          token = data['auth_token']?.toString() ?? '';
        } else {
          // Check if token is directly in the response
          if (data.length == 1 && data.values.first is String) {
            token = data.values.first.toString();
          } else {
            token = data.toString();
          }
        }
      } else if (data is String) {
        // Handle case where response might be a string
        token = data;
      }

      // Validate token is not empty
      if (token.isEmpty) {
        throw Exception('Invalid token received from server');
      }

      developer.log('🔑 Token received: $token', name: 'AuthProvider');
      _logger.i('🔑 [AUTH] Token received: $token');

      // Store tokens and update state
      await SharedUtils.setString('auth_token', token);
      await SharedUtils.setString('staff_token', token);
      await SharedUtils.setString('user_type', _selectedRole);

      // Verify token was stored successfully
      final storedToken = await SharedUtils.getString('auth_token');
      developer.log('✅ Verification - Stored token: $storedToken',
          name: 'AuthProvider');

      _isLoggedIn = true;
      _userType = _selectedRole;

      developer.log('📦 Token stored in SharedPreferences',
          name: 'AuthProvider');
      developer.log(
          '🔐 Updated login status - isLoggedIn: $_isLoggedIn, userType: $_userType',
          name: 'AuthProvider');

      notifyListeners();
      return;
    } on http.ClientException catch (e) {
      _logger.e('🔴 [NETWORK] Connection error: $e');
      developer.log('🔴 Network connection error: $e',
          name: 'AuthProvider', error: e);
      throw Exception(
          'Network connection failed. Please check your internet connection.');
    } catch (e) {
      _logger.e('🔴 [ERROR] Mess Staff authentication failed!');
      _logger.e('🔹 Error: $e');
      developer.log('🔴 Mess Staff authentication failed: $e',
          name: 'AuthProvider', error: e);

      // Rethrow with a more user-friendly message if it's not already an Exception
      if (e is! Exception) {
        throw Exception('Authentication failed. Please try again later.');
      }
      throw e;
    }
  }

  // Specific method to check manager login status
  Future<bool> checkManagerLoginStatus() async {
    try {
      _logger.i('🔍 [AUTH] Checking manager login status...');
      developer.log('🔍 Checking manager login status...',
          name: 'AuthProvider');

      final managerToken = await SharedUtils.getString('manager_token');
      final userType = await SharedUtils.getString('user_type');

      _logger.i('🔹 [AUTH] Initial check:');
      _logger.i('   - User type: $userType');
      _logger.i('   - Manager token exists: ${managerToken?.isNotEmpty}');

      // Early return if not a manager
      if (userType != 'Manager') {
        _logger.w('❌ [AUTH] Not a manager account');
        developer.log('❌ Not a manager account', name: 'AuthProvider');
        return false;
      }

      // Check if manager token exists
      if (managerToken?.isEmpty != false) {
        _logger.w('❌ [AUTH] No manager token found');
        developer.log('❌ No manager token found', name: 'AuthProvider');
        await handleTokenExpiration();
        return false;
      }

      // Validate manager token with admin endpoint
      try {
        _logger.i('🔹 [AUTH] Validating manager token...');
        final response = await http.get(
          Uri.parse('${ApiUrls.baseUrl}/admin/users'),
          headers: {'Authorization': 'Bearer $managerToken'},
        ).timeout(const Duration(seconds: 5));

        _logger.i(
            '🔹 [AUTH] Manager token validation response: ${response.statusCode}');
        developer.log(
            '🔹 Manager token validation response: ${response.statusCode}',
            name: 'AuthProvider');

        if (response.statusCode == 200) {
          _isLoggedIn = true;
          _userType = 'Manager';

          _logger.i('✅ [AUTH] Manager token validated successfully');
          developer.log('✅ Manager token validated successfully',
              name: 'AuthProvider');

          notifyListeners();
          return true;
        } else {
          _logger.w(
              '❌ [AUTH] Manager validation failed with status code: ${response.statusCode}');
          developer.log('❌ Manager validation failed: ${response.statusCode}',
              name: 'AuthProvider');

          // Log response body for debugging
          _logger.w('🔹 [AUTH] Response body: ${response.body}');
          developer.log('🔹 Response body: ${response.body}',
              name: 'AuthProvider');

          await handleTokenExpiration();
          return false;
        }
      } catch (e) {
        _logger.e('🔴 [AUTH] Error validating manager token: $e');
        developer.log('🔴 Error validating manager token: $e',
            name: 'AuthProvider');
        await handleTokenExpiration();
        return false;
      }
    } catch (e) {
      _logger.e('🔴 [AUTH] Error checking manager login status: $e');
      developer.log('🔴 Error checking manager login status: $e',
          name: 'AuthProvider');
      await handleTokenExpiration();
      return false;
    }
  }
}
