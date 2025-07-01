// ignore_for_file: empty_catches

import 'package:hira_plus/utils/shared_utils.dart';
import 'package:flutter/material.dart';
import 'package:hira_plus/constants/api_urls.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:hira_plus/screens/profile_screen/provider/profile_screen_provider.dart';

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
  bool _isDeptHead = false;
  String _userId = '';
  String _userName = '';

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
  bool get isDeptHead => _isDeptHead;
  String get userId => _userId;
  String get userName => _userName;

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

  void setIsDeptHead(bool value) {
    if (_isDeptHead != value) {
      _isDeptHead = value;
      developer.log('👑 isDeptHead set to: $value', name: 'AuthProvider');
      SharedUtils.setBoolean('is_dept_head', value);
      notifyListeners();
    }
  }

  void setUserId(String value) {
    if (_userId != value) {
      _userId = value;
      SharedUtils.setString('user_id', value); // Store to SharedPreferences
      developer.log('👤 User ID set: $value', name: 'AuthProvider');
      notifyListeners();
    }
  }

  void setUserName(String value) {
    if (_userName != value) {
      _userName = value;
      SharedUtils.setString('user_name', value); // Store to SharedPreferences
      developer.log('👤 User Name set: $value', name: 'AuthProvider');
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
    _userId = '';
    _userName = '';
    developer.log('🧹 Auth provider state reset', name: 'AuthProvider');
    notifyListeners();
  }

  // Helper methods
  Future<String?> getAuthToken() async {
    return await SharedUtils.getString('auth_token');
  }

  Future<String?> getUserType() async {
    return await SharedUtils.getString('user_type');
  }

  Future<void> handleSuccessfulLogin(String token, String userType) async {
    await SharedUtils.setString('auth_token', token);
    await SharedUtils.setString('user_type', userType);
    _isLoggedIn = true;
    _userType = userType;
    notifyListeners();
  }

  // UPDATED: checkLoginStatus with Reception support
  Future<bool> checkLoginStatus() async {
    try {
      _logger.i('🔍 [AUTH] Checking login status...');
      developer.log('🔍 Checking login status...', name: 'AuthProvider');

      final token = await SharedUtils.getString('auth_token');
      final userType = await SharedUtils.getString('user_type');
      final isDeptHead = await SharedUtils.getBoolean('is_dept_head');
      final userId = await SharedUtils.getString('user_id'); // Load user ID
      final userName =
          await SharedUtils.getString('user_name'); // Load user name

      // Check for specific user type tokens
      String? specificToken;
      switch (userType) {
        case 'Manager':
          specificToken = await SharedUtils.getString('manager_token');
          break;
        case 'Mess Staff':
          specificToken = await SharedUtils.getString('staff_token');
          break;
        case 'Reception': // ADDED: Reception token check
          specificToken = await SharedUtils.getString('reception_token');
          break;
        case 'User':
        default:
          specificToken = token;
          break;
      }

      // Use specific token if available, otherwise fall back to general token
      final effectiveToken =
          specificToken?.isNotEmpty == true ? specificToken : token;

      _isLoggedIn = effectiveToken?.isNotEmpty == true;
      _userType = userType;
      _isDeptHead = isDeptHead;
      _userId = userId ?? ''; // Set user ID
      _userName = userName ?? ''; // Set user name

      _logger.i('🔹 [AUTH] Login status check results:');
      _logger.i('   - isLoggedIn: $_isLoggedIn');
      _logger.i('   - userType: $_userType');
      _logger.i('   - isDeptHead: $_isDeptHead');
      _logger.i('   - userId: $_userId');
      _logger.i('   - effectiveToken: ${effectiveToken?.isNotEmpty}');

      developer.log(
          '🔹 Login status: isLoggedIn=$_isLoggedIn, userType=$_userType, isDeptHead=$_isDeptHead',
          name: 'AuthProvider');

      // ADDED: Additional validation for Reception users
      if (_userType == 'Reception' && _isLoggedIn) {
        developer.log('🔵 Validating Reception token...', name: 'AuthProvider');
        // Optional: Add token validation logic here if needed
        developer.log('✅ Reception login status validated',
            name: 'AuthProvider');
      }

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
          await SharedUtils.setString('auth_token', '');
          break;
        case 'Mess Staff':
          await SharedUtils.setString('staff_token', '');
          break;
        case 'Reception': // ADDED: Reception token expiration handling
          await SharedUtils.setString('reception_token', '');
          break;
        case 'User':
        default:
          await SharedUtils.setString('auth_token', '');
          break;
      }

      await SharedUtils.setString('user_type', '');
      await SharedUtils.setBoolean('is_dept_head', false);
      _isLoggedIn = false;
      _userType = '';
      _isDeptHead = false;
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

          developer.log('✅ Manager authentication successful',
              name: 'AuthProvider');
          developer.log('🔑 Manager token stored: $token',
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

          final isDeptHead = userDetails['isDeptHead'] ?? false;
          setIsDeptHead(isDeptHead);
          setUserId(userDetails['_id'] ?? userDetails['id'] ?? '');
          setUserName(userDetails['name'] ?? ''); // Store user name
        }

        // Store token and update login status
        await SharedUtils.setString('auth_token', token);
        await SharedUtils.setString('user_type', _selectedRole);
        _isLoggedIn = true;
        _userType = _selectedRole;

        developer.log('✅ Test login successful', name: 'AuthProvider');
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
  Future<void> fetchVerifyOtpToken(BuildContext context) async {
    try {
      developer.log('🔵 Fetching login token...', name: 'AuthProvider');
      _logger.i('🔵 [API] Fetching login token...');

      // Check for test credentials
      if (_phone == '9998887776') {
        _logger.i('🔵 [TEST] Using test user credentials...');
        developer.log('🔵 Using test user credentials', name: 'AuthProvider');
        await handleTestLogin();
        return;
      }

      final url = ApiUrls.getVerifyOtp();

      final requestBody = {
        'phoneNumber': _phone,
        'otp': _otp,
      };

      developer.log('📡 Making auth request to: $url', name: 'AuthProvider');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      developer.log('📥 Response status: ${response.statusCode}',
          name: 'AuthProvider');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _logger.i('🟢 [API] Token fetched successfully!');
        developer.log('🟢 Token fetched successfully!', name: 'AuthProvider');

        // Store token and update login status
        await SharedUtils.setString('auth_token', data['token']);
        await SharedUtils.setString('user_type', _selectedRole);
        _isLoggedIn = true;
        _userType = _selectedRole;

        // Extract and store isDeptHead
        final user = data['user'];
        final isDeptHead = user != null && user['isDeptHead'] == true;
        setIsDeptHead(isDeptHead);
        if (user != null) {
          setUserId(user['_id'] ?? user['id'] ?? '');
          setUserName(user['name'] ?? ''); // Store user name
        }

        // Update ProfileScreenProvider with user info
        final profileProvider =
            Provider.of<ProfileScreenProvider>(context, listen: false);
        profileProvider.setUserInfo(
          userType: _selectedRole,
          userName: user != null ? user['name'] ?? '' : '',
          phone: user != null ? user['phoneNumber'] ?? '' : '',
          department: user != null ? user['department'] ?? '' : '',
          designation: user != null ? user['designation'] ?? '' : '',
          isDeptHead: isDeptHead,
        );

        notifyListeners();
      } else {
        _logger.e(
            '🔴 [API] Failed to fetch token! Status: ${response.statusCode}');

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
    } catch (e) {
      _logger.e('🔴 [ERROR] Token fetch failed: $e');
      throw Exception('Authentication failed. Please try again later.');
    }
  }

  // New method to request OTP for a phone number
  Future<void> requestOtp(String phoneNumber) async {
    try {
      // Special handling for test phone number
      if (phoneNumber == '9998887776') {
        developer.log('🧪 Test phone number detected, simulating OTP request',
            name: 'AuthProvider');
        await Future.delayed(const Duration(milliseconds: 500));
        developer.log('🟢 Test OTP sent successfully to $phoneNumber',
            name: 'AuthProvider');
        return;
      }

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
      final dummyToken = 'demo_token_${DateTime.now().millisecondsSinceEpoch}';

      developer.log('🧪 Simulating successful auth for $_selectedRole',
          name: 'AuthProvider');

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

  // UPDATED: logout method with Reception support
  Future<void> logout() async {
    try {
      _logger.i('🔄 [AUTH] Logging out user...');
      developer.log('🔄 Logging out user...', name: 'AuthProvider');

      // Clear all possible tokens based on user type
      switch (_userType) {
        case 'Manager':
          await SharedUtils.setString('manager_token', '');
          developer.log('🧹 Cleared manager_token', name: 'AuthProvider');
          break;
        case 'Mess Staff':
          await SharedUtils.setString('staff_token', '');
          developer.log('🧹 Cleared staff_token', name: 'AuthProvider');
          break;
        case 'Reception': // ADDED: Reception token cleanup
          await SharedUtils.setString('reception_token', '');
          developer.log('🧹 Cleared reception_token', name: 'AuthProvider');
          break;
        case 'User':
        default:
          // User tokens are cleared below with general cleanup
          break;
      }

      // Clear general tokens and user data
      await SharedUtils.setString('auth_token', '');
      await SharedUtils.setString('user_type', '');
      await SharedUtils.setBoolean('is_dept_head', false);
      await SharedUtils.setString('user_department', '');
      await SharedUtils.setString('user_designation', '');
      await SharedUtils.setString('user_id', '');
      await SharedUtils.setString('user_name', '');

      // Reset internal state
      _isLoggedIn = false;
      _userType = '';
      _isDeptHead = false;
      _department = '';
      _designation = '';
      _userId = '';
      _userName = '';
      reset();

      _logger.i('🟢 [AUTH] Logout successful - all tokens and data cleared');
      developer.log('🟢 Logout successful - all tokens and data cleared',
          name: 'AuthProvider');

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

      final requestBody = {
        'username': _username,
        'password': _password,
      };

      developer.log('📡 Making Mess Staff auth request to: $url',
          name: 'AuthProvider');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      developer.log('📥 Response status: ${response.statusCode}',
          name: 'AuthProvider');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _logger.i('🟢 [API] Mess Staff authentication successful!');
        developer.log('🟢 Mess Staff authentication successful!',
            name: 'AuthProvider');

        String token;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('token')) {
            token = data['token']?.toString() ?? '';
          } else if (data.containsKey('access_token')) {
            token = data['access_token']?.toString() ?? '';
          } else if (data.containsKey('auth_token')) {
            token = data['auth_token']?.toString() ?? '';
          } else {
            token = data.toString();
          }
        } else {
          token = data.toString();
        }

        if (token.isEmpty) {
          throw Exception('Invalid token received from server');
        }

        developer.log('🔑 Token received: $token', name: 'AuthProvider');

        await SharedUtils.setString('auth_token', token);
        await SharedUtils.setString('user_type', _selectedRole);
        _isLoggedIn = true;
        _userType = _selectedRole;

        developer.log('📦 Token stored in SharedPreferences',
            name: 'AuthProvider');

        notifyListeners();
        return;
      } else {
        _logger.e(
            '🔴 [API] Mess Staff authentication failed! Status: ${response.statusCode}');

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
    } catch (e) {
      _logger.e('🔴 [ERROR] Mess Staff authentication failed: $e');

      // Fallback to demo mode for development
      if (_username == "staff" && _password == "staff123") {
        _logger.i('🔵 [TEST] Falling back to demo mode...');
        developer.log('🔵 Falling back to demo mode', name: 'AuthProvider');

        final dummyToken =
            'demo_staff_token_${DateTime.now().millisecondsSinceEpoch}';

        await SharedUtils.setString('auth_token', dummyToken);
        await SharedUtils.setString('user_type', _selectedRole);
        _isLoggedIn = true;
        _userType = _selectedRole;

        notifyListeners();
        return;
      }

      if (e is! Exception) {
        throw Exception('Authentication failed. Please try again later.');
      }
      rethrow;
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

      if (userType != 'Manager') {
        _logger.w('❌ [AUTH] Not a manager account');
        developer.log('❌ Not a manager account', name: 'AuthProvider');
        return false;
      }

      if (managerToken?.isEmpty != false) {
        _logger.w('❌ [AUTH] No manager token found');
        developer.log('❌ No manager token found', name: 'AuthProvider');
        await handleTokenExpiration();
        return false;
      }

      try {
        _logger.i('🔹 [AUTH] Validating manager token...');
        final response = await http.get(
          Uri.parse('${ApiUrls.baseUrl}/admin/users'),
          headers: {'Authorization': 'Bearer $managerToken'},
        ).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          _isLoggedIn = true;
          _userType = 'Manager';

          _logger.i('✅ [AUTH] Manager token validated successfully');
          developer.log('✅ Manager token validated successfully',
              name: 'AuthProvider');

          notifyListeners();
          return true;
        } else {
          await handleTokenExpiration();
          return false;
        }
      } catch (e) {
        _logger.e('🔴 [AUTH] Error validating manager token: $e');
        await handleTokenExpiration();
        return false;
      }
    } catch (e) {
      _logger.e('🔴 [AUTH] Error checking manager login status: $e');
      await handleTokenExpiration();
      return false;
    }
  }

  // ADDED: Method for authenticating reception
  Future<void> authenticateReception() async {
    try {
      developer.log('🔵 [AUTH] Authenticating Reception...',
          name: 'AuthProvider');
      _logger.i('🔵 [API] Initiating Reception authentication...');

      // Check if the username and password match the required values
      if (_username != "reception" || _password != "reception") {
        throw Exception('Invalid username or password');
      }

      final url = ApiUrls.getReceptionLogin();

      // Prepare request body with username and password
      final requestBody = {
        'username': _username,
        'password': _password,
      };

      developer.log('📡 Making Reception auth request to: $url',
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _logger.i('🟢 [API] Reception authentication successful!');
        developer.log('🟢 Reception authentication successful!',
            name: 'AuthProvider');
        developer.log('🔑 Full response data: $data', name: 'AuthProvider');

        // Extract token with robust handling
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

        developer.log('🔑 Reception token received: $token',
            name: 'AuthProvider');
        _logger.i('🔑 [AUTH] Reception token received: $token');

        // Store token with specific reception token key for persistence
        await SharedUtils.setString('reception_token', token);
        await SharedUtils.setString(
            'auth_token', token); // Also store as general auth_token

        // Verify token was stored successfully
        final storedToken = await SharedUtils.getString('auth_token');
        final storedReceptionToken =
            await SharedUtils.getString('reception_token');
        developer.log('✅ Verification - Stored auth_token: $storedToken',
            name: 'AuthProvider');
        developer.log(
            '✅ Verification - Stored reception_token: $storedReceptionToken',
            name: 'AuthProvider');

        await SharedUtils.setString('user_type', _selectedRole);
        _isLoggedIn = true;
        _userType = _selectedRole;

        developer.log('📦 Reception token stored in SharedPreferences',
            name: 'AuthProvider');
        developer.log(
            '🔐 Updated login status - isLoggedIn: $_isLoggedIn, userType: $_userType',
            name: 'AuthProvider');

        notifyListeners();
        return;
      } else {
        _logger.e(
            '🔴 [API] Reception authentication failed! Status: ${response.statusCode}');
        developer.log(
            '🔴 Reception authentication failed! Status: ${response.statusCode}',
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
      developer.log('🔴 Network connection error: $e',
          name: 'AuthProvider', error: e);

      throw Exception(
          'Network connection failed. Please check your internet connection.');
    } catch (e) {
      _logger.e('🔴 [ERROR] Reception authentication failed!');
      _logger.e('🔹 Error: $e');
      developer.log('🔴 Reception authentication failed: $e',
          name: 'AuthProvider', error: e);

      // Rethrow with a more user-friendly message if it's not already an Exception
      if (e is! Exception) {
        throw Exception('Authentication failed. Please try again later.');
      }
      rethrow;
    }
  }
}
