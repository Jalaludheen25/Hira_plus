import 'dart:developer' as dev;
import 'dart:io';

import 'package:hira_plus/constants/api_urls.dart';
import 'package:hira_plus/constants/global_variables.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

class VersionCheckProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _newVersion;
  bool _forceUpdate = false;
  String? _changes;
  bool _needsUpdate = false;
  bool _isAuthenticated = false; // Add authentication state

  // Add this flag for development
  static const bool _simulateForceUpdate =
      false; // Set to true to test force update

  bool get isLoading => _isLoading;
  bool get needsUpdate => _needsUpdate;
  String? get newVersion => _newVersion;
  bool get forceUpdate => _forceUpdate;
  String? get changes => _changes;
  bool get isAuthenticated =>
      _isAuthenticated; // Getter for authentication state

  // Method to set authentication state
  void setAuthenticationState(bool isAuthenticated) {
    _isAuthenticated = isAuthenticated;
    notifyListeners();
  }

  Future<void> checkVersion() async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_simulateForceUpdate) {
        // Simulate a force update scenario for testing using new API response keys
        if (Platform.isAndroid) {
          _newVersion = '1.0.0';
          _changes = '- Initial Release';
          _forceUpdate = false;
        } else {
          _newVersion = '1.0.0';
          _changes = '- Initial Release';
          _forceUpdate = false;
        }
        final currentVersion = GlobalVariables.appVersion;
        final newVersionNumber = _newVersion!.split('+')[0];
        _needsUpdate = _compareVersions(currentVersion, newVersionNumber);
        dev.log(
            '[VersionCheckProvider] Simulated version check: currentVersion: $currentVersion, newVersion: $_newVersion, needsUpdate: $_needsUpdate',
            name: 'VersionCheckProvider');
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Get current installed version
      final currentVersion = GlobalVariables.appVersion;

      // Fetch version info from API
      final response = await http.get(
        Uri.parse(
          ApiUrls.getForceUpdate(),
        ),
      );
      if (response.statusCode == 200) {
        dev.log('Version check response: ${response.body}',
            name: 'VersionCheckProvider');

        final data = json.decode(response.body)['data'];

        // Use if-else to set properties based on platform
        if (Platform.isAndroid) {
          _newVersion = data['android_version'];
          _changes = data['android_update_content'];
          _forceUpdate = data['android_force_update'];
        } else if (Platform.isIOS) {
          _newVersion = data['ios_version'];
          _changes = data['ios_update_content'];
          _forceUpdate = data['ios_force_update'];
        }

        // Compare versions (ignoring build number after +)
        final currentVersionNumber = currentVersion.split('+')[0];
        final newVersionNumber = _newVersion!.split('+')[0];

        // Compare version numbers
        _needsUpdate = _compareVersions(currentVersionNumber, newVersionNumber);
        dev.log(
            '[VersionCheckProvider] Version check: currentVersion: $currentVersionNumber, newVersion: $newVersionNumber, needsUpdate: $_needsUpdate',
            name: 'VersionCheckProvider');

        _isLoading = false;
        notifyListeners();
      } else {
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      dev.log('Error checking version: $e',
          name: 'VersionCheckProvider', error: e);
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _compareVersions(String current, String new_) {
    List<int> currentParts = current.split('.').map(int.parse).toList();
    List<int> newParts = new_.split('.').map(int.parse).toList();

    for (int i = 0; i < currentParts.length; i++) {
      if (newParts[i] > currentParts[i]) return true;
      if (newParts[i] < currentParts[i]) return false;
    }
    return false;
  }

  void launchAppStore({required BuildContext context}) async {
    // Replace these URLs with your actual app store URLs
    const String iOSUrl = '';

    if (Platform.isAndroid) {
      await launchUrl(Uri.parse(
          'https://play.google.com/store/apps/details?id=com.d4dx.hiraplus'));
    } else {
      await launchUrl(Uri.parse(iOSUrl));
    }
  }
}
