import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
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
}
