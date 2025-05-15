// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer' as developer;
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:hira_plus/constants/app_utils.dart';
import 'package:hira_plus/utils/shared_utils.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hira_plus/utils/navigation_helper.dart';
import 'package:hira_plus/routes/app_routes.dart';

import 'package:shared_preferences/shared_preferences.dart';

class HttpServiceUtils {
  static const Duration timeoutDuration = Duration(seconds: 30);

  // Updated headers without hardcoded token
  static Map<String, String> getDefaultHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // Enhanced logging function
  static void _logError(String message, dynamic error, StackTrace? stackTrace) {
    developer.log(
      message,
      error: error,
      stackTrace: stackTrace,
      time: DateTime.now(),
      level: 2000, // Error level
    );

    if (kDebugMode) {
      print('ERROR: $message');
      print('Error details: $error');
      if (stackTrace != null) print('Stack trace: $stackTrace');
    }
  }

  // Update your fetchData method in HttpServiceUtils class
  static Future<dynamic> fetchData(String url, bool token, [int retryCount = 2]) async {
    try {
      Map<String, String> headers = getDefaultHeaders();
      if (token) {
        final authToken = await SharedUtils.getString('auth_token');
        if (authToken.isEmpty) {
          log('❌ No auth token available');
          throw HttpException('Authentication required. Please login again.');
        }
        headers['Authorization'] = 'Bearer $authToken';
      }
      
      log('🌐 Making GET request to: $url');
      
      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(
            const Duration(minutes: 2),
          );
      log('URL: $url');
      log('Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        log('✅ Success: ${response.body.length} bytes received');
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        // Handle authentication error
        log('🔒 Authentication error: Token may be expired or invalid');
        // Call the _handleUnauthorized method to logout and redirect
        await _handleUnauthorized(null);
        throw HttpException('Authentication failed. Please login again.');
      } else if (response.statusCode >= 500 && retryCount > 0) {
        // Retry server errors
        log('⚠️ Server error (${response.statusCode}), retrying... (${retryCount} attempts left)');
        // Wait before retrying to give server time to recover
        await Future.delayed(const Duration(seconds: 2));
        return await fetchData(url, token, retryCount - 1);
      } else if (response.statusCode == 429 && retryCount > 0) {
        // Handle rate limiting with exponential backoff
        log('⏳ Rate limited, retrying with backoff... (${retryCount} attempts left)');
        await Future.delayed(Duration(seconds: 5 * (3 - retryCount)));
        return await fetchData(url, token, retryCount - 1);
      } else {
        log('❌ Error: Failed with status code ${response.statusCode}');
        log('Error Response Body: ${response.body}');
        throw HttpException(
            'Failed to load data. Status: ${response.statusCode}');
      }
    } on TimeoutException {
      if (retryCount > 0) {
        log('⏱️ Request timed out, retrying... (${retryCount} attempts left)');
        await Future.delayed(const Duration(seconds: 2));
        return await fetchData(url, token, retryCount - 1);
      }
      log('⏱️ Request timed out for URL: $url');
      throw const HttpException(
          'Request timed out. Please check your internet connection and try again.');
    } catch (e) {
      log('🐞 Error fetching data from $url: $e');
      rethrow;
    }
  }

  // Enhanced response handler with logging
  static String _handleResponse(String url, http.Response response, [BuildContext? context]) {
    developer.log(
      'Response received from $url',
      error: 'Status Code: ${response.statusCode}',
      time: DateTime.now(),
    );

    switch (response.statusCode) {
      case 200:
      case 201:
        return response.body;

      case 401:
        if (context != null) {
          _handleUnauthorized(context);
        }
        throw NetworkException('Authentication failed', response.statusCode);

      case 500:
        throw NetworkException(
            'Server error: Bad Gateway', response.statusCode);

      default:
        throw NetworkException(
            'Request failed with status: ${response.statusCode}',
            response.statusCode);
    }
  }

  // HTTP error handler

  // Handle unauthorized access
  static Future<void> _handleUnauthorized(BuildContext? context) async {
    try {
      // Clear all authentication data
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // Log the logout action
      developer.log('🔒 Authentication error detected, clearing credentials', 
          time: DateTime.now(), level: 1000);
      
      // Use the global navigator key if context is not provided
      if (context == null || !context.mounted) {
        // We'll use the navigatorKey from navigation_helper.dart
        if (navigatorKey.currentContext != null) {
          // Show a message to the user
          ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
            const SnackBar(
              content: Text('Authentication error. Please login again.'),
              duration: Duration(seconds: 2),
            ),
          );
          
          // Delay the navigation slightly to allow the snackbar to be seen
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.of(navigatorKey.currentContext!)
              .pushNamedAndRemoveUntil(Routes.login, (route) => false);
          });
        }
      } else if (context.mounted) {
        // Use the provided context if it's valid
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication error. Please login again.'),
            duration: Duration(seconds: 2),
          ),
        );
        
        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false);
      }
    } catch (e) {
      developer.log('Error handling unauthorized state: $e', 
        error: e, stackTrace: StackTrace.current, time: DateTime.now(), level: 2000);
    }
  }

  // Enhanced connectivity check
  static Future<void> _checkConnectivity() async {
    if (!await AppUtils.hasInternet()) {
      developer.log(
        'No internet connection detected',
        time: DateTime.now(),
        level: 1000,
      );
      throw NetworkException('No internet connection');
    }
  }

  // POST request method
  static Future<dynamic> postData(String url, dynamic data, [BuildContext? context]) async {
    debugPrint('[log] Making POST request to: $url');
    debugPrint('[log] Request body: $data');

    try {
      // Get authentication token
      Map<String, String> headers = getDefaultHeaders();
      
      final authToken = await SharedUtils.getString('auth_token');
      if (authToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $authToken';
      }
      
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(data),
      );

      debugPrint('[log] Response status: ${response.statusCode}');
      debugPrint('[log] Response: ${response.body}');
      
      return _handleResponse(url, response, context);
    } catch (e) {
      debugPrint('ERROR: Error in POST request');
      debugPrint('Error details: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // PUT request method
  static Future<String> putData(
      String url, dynamic body, [BuildContext? context]) async {
    try {
      await _checkConnectivity();

      developer.log('Making PUT request to: $url', time: DateTime.now());
      developer.log('Request body: $body', time: DateTime.now());
      
      // Get authentication token
      Map<String, String> headers = getDefaultHeaders();
      
      final authToken = await SharedUtils.getString('auth_token');
      if (authToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $authToken';
      }

      final response = await http
          .put(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(timeoutDuration);

      developer.log('Response: ${response.body}', time: DateTime.now());

      return _handleResponse(url, response, context);
    } catch (e, stackTrace) {
      _logError('Error in PUT request', e, stackTrace);
      if (context != null && context.mounted) {
        AppUtils.showInSnackBarNormal('Error updating data', context);
      }
      rethrow;
    }
  }

  // DELETE request method
  static Future<String> deleteData(String url, [BuildContext? context]) async {
    try {
      await _checkConnectivity();

      developer.log('Making DELETE request to: $url', time: DateTime.now());
      
      // Get authentication token
      Map<String, String> headers = getDefaultHeaders();
      
      final authToken = await SharedUtils.getString('auth_token');
      if (authToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $authToken';
      }

      final response = await http
          .delete(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(timeoutDuration);

      developer.log('Response: ${response.body}', time: DateTime.now());

      return _handleResponse(url, response, context);
    } catch (e, stackTrace) {
      _logError('Error in DELETE request', e, stackTrace);
      if (context != null && context.mounted) {
        AppUtils.showInSnackBarNormal('Error deleting data', context);
      }
      rethrow;
    }
  }

// Add this method to your HttpServiceUtils class in service_utils.dart
  static Future<bool> refreshToken(BuildContext context) async {
    try {
      log('🔄 Attempting to refresh authentication token');

      // Get the refresh token from storage (you may need to store this)
      final refreshToken = await SharedUtils.getString('refresh_token');

      if (refreshToken.isEmpty) {
        log('❌ No refresh token available');
        return false;
      }

      // Get authentication headers
      Map<String, String> headers = getDefaultHeaders();

      // Make a request to your refresh token endpoint
      // Replace with your actual refresh token endpoint
      final response = await http.post(
        Uri.parse('https://hiraplusapi.dharmadhara.com/api/auth/refresh-token'),
        headers: headers,
        body: jsonEncode({
          'refreshToken': refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newToken = data['token']; // Adjust based on your API response

        // Save the new token
        await SharedUtils.setString('auth_token', newToken);

        log('✅ Token refreshed successfully');
        return true;
      } else {
        log('❌ Failed to refresh token: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      log('❌ Error refreshing token: $e');
      return false;
    }
  }
}

class NetworkException implements Exception {
  final String message;
  final int? statusCode;

  NetworkException(this.message, [this.statusCode]);

  @override
  String toString() =>
      'NetworkException: $message${statusCode != null ? ' (Status Code: $statusCode)' : ''}';
}