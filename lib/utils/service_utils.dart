// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer' as developer;
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:hira_plus/constants/app_utils.dart';
import 'package:hira_plus/constants/global_variables.dart';
import 'package:hira_plus/utils/shared_utils.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


import 'package:shared_preferences/shared_preferences.dart';

class HttpServiceUtils {
  static const Duration timeoutDuration = Duration(seconds: 30);

  static final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer ${GlobalVariables.dummyToken}',
  };

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
  static Future<dynamic> fetchData(String url, bool token) async {
    try {
      Map<String, String> headers = {
        'Accept': 'application/json',
      };
      if (token) {
        final authToken = await SharedUtils.getString('auth_token');
        headers['Authorization'] = 'Bearer $authToken';
        headers['Authorization'] = 'Bearer ${GlobalVariables.dummyToken}';
      }
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
        // Try to refresh the token first
        log('🔒 Authentication error: Token may be expired or invalid');

        // Create a BuildContext parameter for this method to use refreshToken
        // Or make it not require a context by adjusting the refresh token logic

        /* Uncomment when you've implemented the context parameter or modified refreshToken
      final refreshed = await refreshToken();
      if (refreshed) {
        // Retry the request with the new token
        return await fetchData(url, token);
      }
      */
      } else {
        log('❌ Error: Failed with status code ${response.statusCode}');
        log('Error Response Body: ${response.body}');
        throw HttpException(
            'Failed to load data. Status: ${response.statusCode}');
      }
    } on TimeoutException {
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
  static Future<void> _handleUnauthorized(BuildContext context) async {
    if (context.mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/splash');
      }
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
      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode(data),
      );

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

      final response = await http
          .put(
            Uri.parse(url),
            headers: _headers,
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

      final response = await http
          .delete(
            Uri.parse(url),
            headers: _headers,
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

      // Make a request to your refresh token endpoint
      // Replace with your actual refresh token endpoint
      final response = await http.post(
        Uri.parse('https://hiraplusapi.dharmadhara.com/api/auth/refresh-token'),
        headers: {
          'Content-Type': 'application/json',
        },
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