// ignore_for_file: use_build_context_synchronously

import 'dart:developer' as developer;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_utils.dart';

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
  static Future<String> fetchData(String url, BuildContext context) async {
    try {
      await _checkConnectivity();

      developer.log('Making GET request to: $url', time: DateTime.now());

      // Make HTTP GET request with timeout
      final response = await http
          .get(
            Uri.parse(url),
            headers: _headers,
          )
          .timeout(timeoutDuration);

      // Log full response
      developer.log('Response: ${response.body}', time: DateTime.now());

      return _handleResponse(response, context, url);
    } on http.ClientException catch (e, stackTrace) {
      _logError(
        'HTTP ClientException while fetching data from $url',
        e,
        stackTrace,
      );
      _handleHttpError(e, context);
      rethrow;
    } catch (e, stackTrace) {
      _logError(
        'Unexpected error while fetching data from $url',
        e,
        stackTrace,
      );
      if (context.mounted) {
        AppUtils.showInSnackBarNormal(
            'Network error: Please check your connection', context);
      }
      throw NetworkException('An unexpected error occurred: $e');
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
  static void _handleHttpError(
      http.ClientException error, BuildContext context) {
    String message = 'Network error occurred';

    // Log the detailed error
    _logError(
      'HTTP ClientException details',
      {
        'message': message,
        'error': error.toString(),
      },
      null,
    );

    if (context.mounted) {
      AppUtils.showInSnackBarNormal(message, context);
    }
  }

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
  static Future<String> postData(
      String url, dynamic body, BuildContext context) async {
    try {
      await _checkConnectivity();

      developer.log('Making POST request to: $url', time: DateTime.now());
      developer.log('Request body: $body', time: DateTime.now());

      final response = await http
          .post(
            Uri.parse(url),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(timeoutDuration);

      developer.log('Response: ${response.body}', time: DateTime.now());

      return _handleResponse(response, context, url);
    } catch (e, stackTrace) {
      _logError('Error in POST request', e, stackTrace);
      if (context.mounted) {
        AppUtils.showInSnackBarNormal('Error sending data', context);
      }
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

      final response = await http
          .put(
            Uri.parse(url),
            headers: _headers,
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
