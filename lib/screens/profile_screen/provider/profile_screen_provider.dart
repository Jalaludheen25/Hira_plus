import 'package:flutter/material.dart';
import 'package:hira_plus/constants/api_urls.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;

class ProfileModel {
  final String id;
  final String name;
  final String phoneNumber;
  final String department;
  final String designation;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProfileModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.department,
    required this.designation,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      department: json['department'] ?? '',
      designation: json['designation'] ?? '',
      isVerified: json['isVerified'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class ProfileScreenProvider extends ChangeNotifier {
  String _userName = '';
  String _phone = '';
  String _userType = '';
  String _department = '';
  String _designation = '';

  String get userName {
    if (_userType == 'manager') {
      return 'Manager';
    } else if (_userType == 'mess_staff') {
      return 'Mess Staff';
    } else {
      return _userName;
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
    notifyListeners();
  }

  set phone(String value) {
    if (_phone != value) {
      _phone = value;
      notifyListeners();
    }
  }

  Future<void> fetchAndSetProfile({required String token, required String userType}) async {
    final url = ApiUrls.getProfileMe();
    developer.log('[PROFILE] Fetching profile from: $url', name: 'ProfileScreenProvider');
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    developer.log('[PROFILE] Response status: \\${response.statusCode}', name: 'ProfileScreenProvider');
    developer.log('[PROFILE] Response body: \\${response.body}', name: 'ProfileScreenProvider');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      developer.log('[PROFILE] Decoded data: \\${data.toString()}', name: 'ProfileScreenProvider');
      final profile = ProfileModel.fromJson(data['user']);
      developer.log('[PROFILE] Parsed profile: name=\\${profile.name}, phone=\\${profile.phoneNumber}, dept=\\${profile.department}, desig=\\${profile.designation}', name: 'ProfileScreenProvider');
      setUserInfo(
        userType: userType,
        userName: profile.name,
        phone: profile.phoneNumber,
        department: profile.department,
        designation: profile.designation,
      );
      developer.log('[PROFILE] Set user info: userType=\\${userType}, name=\\${profile.name}', name: 'ProfileScreenProvider');
    } else {
      developer.log('[PROFILE] Failed to fetch profile: status=\\${response.statusCode}', name: 'ProfileScreenProvider');
      throw Exception('Failed to fetch profile');
    }
  }
} 