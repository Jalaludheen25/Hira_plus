import 'package:flutter/material.dart';
import 'package:hira_plus/constants/api_urls.dart';
import 'package:hira_plus/screens/profile_screen/models/profile_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;

class ProfileScreenProvider extends ChangeNotifier {
  String _userName = '';
  String _phone = '';
  String _userType = '';
  String _department = '';
  String _designation = '';

  String get userName {
    // Case-insensitive comparison and handle different formats
    final userTypeLower = _userType.toLowerCase().replaceAll(' ', '_');
    if (userTypeLower == 'manager') {
      return 'Administrator';
    } else if (userTypeLower == 'mess_staff') {
      return 'Mess Staff';
    } else {
      return _userName.isNotEmpty ? _userName : 'User';
    }
  }

  String get phone => _phone;
  String get userType => _userType;
  String get department => _department;
  String get designation => _designation;

  void setUserInfo({
    required String userType,
    String userName = '',
    String phone = '',
    String department = '',
    String designation = '',
  }) {
    _userType = userType;
    _userName = userName;
    _phone = phone;
    _department = department;
    _designation = designation;
    developer.log('ProfileScreenProvider: Set user info - userType=$userType, userName=$userName, phone=$phone', 
        name: 'ProfileProvider');
    notifyListeners();
  }

  set phone(String value) {
    if (_phone != value) {
      _phone = value;
      notifyListeners();
    }
  }

  Future<void> fetchAndSetProfile({required String token, required String userType}) async {
    try {
      final url = ApiUrls.getProfileMe();
      developer.log('[PROFILE] Fetching profile from: $url', name: 'ProfileScreenProvider');
      
      // Set the userType immediately to ensure correct display even if API fails
      _userType = userType;
      notifyListeners();
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      developer.log('[PROFILE] Response status: ${response.statusCode}', name: 'ProfileScreenProvider');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        developer.log('[PROFILE] Decoded data: ${data.toString()}', name: 'ProfileScreenProvider');
        
        final profile = ProfileModel.fromJson(data['user']);
        developer.log('[PROFILE] Parsed profile: name=${profile.name}, phone=${profile.phoneNumber}', 
            name: 'ProfileScreenProvider');
        
        setUserInfo(
          userType: userType,
          userName: profile.name,
          phone: profile.phoneNumber,
          department: profile.department,
          designation: profile.designation,
        );
        
        developer.log('[PROFILE] Profile info set successfully', name: 'ProfileScreenProvider');
      } else {
        // Even if API fails, keep the user type for correct display
        developer.log('[PROFILE] API call failed: ${response.statusCode}, falling back to userType only',
            name: 'ProfileScreenProvider');
        
        // For failed API calls, set default values based on userType
        String defaultName = 'User';
        if (userType.toLowerCase().contains('manager')) {
          defaultName = 'Administrator';
        } else if (userType.toLowerCase().contains('mess')) {
          defaultName = 'Mess Staff';
        }
        
        setUserInfo(
          userType: userType,
          userName: defaultName,
          phone: '',
        );
      }
    } catch (e) {
      developer.log('[PROFILE] Error fetching profile: $e', name: 'ProfileScreenProvider');
      // Handle error by setting default values
      String defaultName = 'User';
      if (userType.toLowerCase().contains('manager')) {
        defaultName = 'Administrator';
      } else if (userType.toLowerCase().contains('mess')) {
        defaultName = 'Mess Staff';
      }
      
      setUserInfo(
        userType: userType,
        userName: defaultName,
        phone: '',
      );
    }
  }
}