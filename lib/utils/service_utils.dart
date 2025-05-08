// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer' as developer;
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:Hira_Plus/constants/app_utils.dart';
import 'package:Hira_Plus/constants/global_variables.dart';
import 'package:Hira_Plus/providers/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

class HttpServiceUtils {
  static const Duration timeoutDuration = Duration(seconds: 30);

  static final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
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

  // Main fetch method with enhanced error handling
  static Future<dynamic> fetchData(String url, bool token) async {
    try {
      Map<String, String> headers = {
        'Accept': 'application/json',
      };
      if (token) {
        final prefs = await SharedPreferences.getInstance();
        final authToken = GlobalVariables.dummyToken;
        if (authToken == null) {
          throw Exception('No auth token found. Please login.');
        }
        headers['Authorization'] = 'Bearer $authToken';
      }
      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(
            const Duration(
                minutes: 2), // Increased from 30 seconds to 2 minutes
          );
      log('URL: $url');
      log('Response: ${response.body}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw HttpException(
            'Failed to load data. Status: ${response.statusCode}');
      }
    } on TimeoutException {
      debugPrint('Request timed out for URL: $url');
      throw const HttpException(
          'Request timed out. Please check your internet connection and try again.');
    } catch (e) {
      debugPrint('Error fetching data from $url: $e');
      rethrow;
    }
  }

  // Enhanced response handler with logging
  static String _handleResponse(
      http.Response response, BuildContext context, String url) {
    developer.log(
      'Response received from $url',
      error: 'Status Code: ${response.statusCode}',
      time: DateTime.now(),
    );

    switch (response.statusCode) {
      case 200:
        return response.body;

      case 401:
        _handleUnauthorized(context);
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
  static Future<dynamic> postData(String url, dynamic data, BuildContext context) async {
    debugPrint('[log] Making POST request to: $url');
    debugPrint('[log] Request body: $data');

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${GlobalVariables.dummyToken}',
        },
        body: jsonEncode(data),
      );

      debugPrint('[log] Response: ${response.body}');
      return _handleResponse(response, context, url);
    } catch (e) {
      debugPrint('ERROR: Error in POST request');
      debugPrint('Error details: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // PUT request method
  static Future<String> putData(
      String url, dynamic body, BuildContext context) async {
    try {
      await _checkConnectivity();

      developer.log('Making PUT request to: $url', time: DateTime.now());
      developer.log('Request body: $body', time: DateTime.now());

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = GlobalVariables.dummyToken;
      if (token == null) {
        throw Exception('User is not authenticated');
      }
      final headers = {
        ..._headers,
        'Authorization': 'Bearer $token',
      };

      final response = await http
          .put(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(timeoutDuration);

      developer.log('Response: ${response.body}', time: DateTime.now());

      return _handleResponse(response, context, url);
    } catch (e, stackTrace) {
      _logError('Error in PUT request', e, stackTrace);
      if (context.mounted) {
        AppUtils.showInSnackBarNormal('Error updating data', context);
      }
      rethrow;
    }
  }

  // DELETE request method
  static Future<String> deleteData(String url, BuildContext context) async {
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

      return _handleResponse(response, context, url);
    } catch (e, stackTrace) {
      _logError('Error in DELETE request', e, stackTrace);
      if (context.mounted) {
        AppUtils.showInSnackBarNormal('Error deleting data', context);
      }
      rethrow;
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
