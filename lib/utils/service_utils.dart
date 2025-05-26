import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hira_plus/utils/shared_utils.dart';
import 'dart:developer' as developer;
import 'package:logger/logger.dart';

class HttpServiceUtils {
  static final Logger _logger = Logger();
  static const int timeoutDuration = 30; // seconds

  /// Fetch data from API with GET request
  static Future<dynamic> fetchData(String url, bool requiresAuth) async {
    try {
      _logger.i('🌐 [HTTP_GET] Starting GET request to: $url');
      _logger.d('🔐 [HTTP_GET] Requires auth: $requiresAuth');
      developer.log('🌐 Starting GET request to: $url', name: 'HttpServiceUtils');

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (requiresAuth) {
        final token = await SharedUtils.getString('auth_token');
        if (token.isEmpty) {
          _logger.e('❌ [HTTP_GET] No auth token found');
          developer.log('❌ No auth token found', name: 'HttpServiceUtils');
          throw const HttpException('Authentication token not found. Please login again.');
        }
        headers['Authorization'] = 'Bearer $token';
        _logger.d('🔑 [HTTP_GET] Auth token added to headers');
      }

      _logger.d('📋 [HTTP_GET] Request headers: $headers');
      developer.log('📋 Making authenticated request', name: 'HttpServiceUtils');

      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(const Duration(seconds: timeoutDuration));

      _logger.i('📨 [HTTP_GET] Response received - Status: ${response.statusCode}');
      _logger.d('📨 [HTTP_GET] Response headers: ${response.headers}');
      _logger.d('📨 [HTTP_GET] Response body length: ${response.body.length}');
      developer.log('📨 GET response: ${response.statusCode}', name: 'HttpServiceUtils');

      return _handleResponse(response, 'GET', url);

    } on SocketException catch (e) {
      _logger.e('🔌 [HTTP_GET] Network error: $e');
      developer.log('🔌 Network error: $e', name: 'HttpServiceUtils', error: e);
      throw const HttpException('No internet connection. Please check your network.');
    } on HttpException catch (e) {
      _logger.e('🚫 [HTTP_GET] HTTP exception: $e');
      developer.log('🚫 HTTP exception: $e', name: 'HttpServiceUtils', error: e);
      rethrow;
    } catch (e, stackTrace) {
      _logger.e('💥 [HTTP_GET] Unexpected error: $e');
      _logger.e('💥 [HTTP_GET] StackTrace: $stackTrace');
      developer.log('💥 Unexpected GET error: $e', name: 'HttpServiceUtils', error: e, stackTrace: stackTrace);
      throw HttpException('Request failed: ${e.toString()}');
    }
  }

  /// Post data to API
  static Future<dynamic> postData(String url, Map<String, dynamic> data, [BuildContext? context]) async {
    try {
      _logger.i('🚀 [HTTP_POST] Starting POST request to: $url');
      _logger.d('📦 [HTTP_POST] Request payload: $data');
      developer.log('🚀 Starting POST request to: $url', name: 'HttpServiceUtils');

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // Try to get auth token (optional for some endpoints like banner creation)
      final token = await SharedUtils.getString('auth_token');
      if (token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        _logger.d('🔑 [HTTP_POST] Auth token added to headers');
        developer.log('🔑 Auth token added', name: 'HttpServiceUtils');
      } else {
        _logger.d('⚠️ [HTTP_POST] No auth token available');
        developer.log('⚠️ No auth token available', name: 'HttpServiceUtils');
      }

      _logger.d('📋 [HTTP_POST] Request headers: $headers');

      final jsonBody = jsonEncode(data);
      _logger.d('📝 [HTTP_POST] JSON body: $jsonBody');

      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: jsonBody,
          )
          .timeout(const Duration(seconds: timeoutDuration));

      _logger.i('📨 [HTTP_POST] Response received - Status: ${response.statusCode}');
      _logger.d('📨 [HTTP_POST] Response headers: ${response.headers}');
      _logger.d('📨 [HTTP_POST] Response body: ${response.body}');
      developer.log('📨 POST response: ${response.statusCode}', name: 'HttpServiceUtils');

      return _handleResponse(response, 'POST', url);

    } on SocketException catch (e) {
      _logger.e('🔌 [HTTP_POST] Network error: $e');
      developer.log('🔌 Network error: $e', name: 'HttpServiceUtils', error: e);
      throw const HttpException('No internet connection. Please check your network.');
    } on HttpException catch (e) {
      _logger.e('🚫 [HTTP_POST] HTTP exception: $e');
      developer.log('🚫 HTTP exception: $e', name: 'HttpServiceUtils', error: e);
      rethrow;
    } catch (e, stackTrace) {
      _logger.e('💥 [HTTP_POST] Unexpected error: $e');
      _logger.e('💥 [HTTP_POST] StackTrace: $stackTrace');
      developer.log('💥 Unexpected POST error: $e', name: 'HttpServiceUtils', error: e, stackTrace: stackTrace);
      throw HttpException('Request failed: ${e.toString()}');
    }
  }

  /// Put data to API
  static Future<dynamic> putData(String url, Map<String, dynamic> data, [BuildContext? context]) async {
    try {
      _logger.i('🔄 [HTTP_PUT] Starting PUT request to: $url');
      _logger.d('📦 [HTTP_PUT] Request payload: $data');
      developer.log('🔄 Starting PUT request to: $url', name: 'HttpServiceUtils');

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      final token = await SharedUtils.getString('auth_token');
      if (token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        _logger.d('🔑 [HTTP_PUT] Auth token added to headers');
      }

      final jsonBody = jsonEncode(data);
      _logger.d('📝 [HTTP_PUT] JSON body: $jsonBody');

      final response = await http
          .put(
            Uri.parse(url),
            headers: headers,
            body: jsonBody,
          )
          .timeout(const Duration(seconds: timeoutDuration));

      _logger.i('📨 [HTTP_PUT] Response received - Status: ${response.statusCode}');
      _logger.d('📨 [HTTP_PUT] Response body: ${response.body}');
      developer.log('📨 PUT response: ${response.statusCode}', name: 'HttpServiceUtils');

      return _handleResponse(response, 'PUT', url);

    } on SocketException catch (e) {
      _logger.e('🔌 [HTTP_PUT] Network error: $e');
      developer.log('🔌 Network error: $e', name: 'HttpServiceUtils', error: e);
      throw const HttpException('No internet connection. Please check your network.');
    } on HttpException catch (e) {
      _logger.e('🚫 [HTTP_PUT] HTTP exception: $e');
      developer.log('🚫 HTTP exception: $e', name: 'HttpServiceUtils', error: e);
      rethrow;
    } catch (e, stackTrace) {
      _logger.e('💥 [HTTP_PUT] Unexpected error: $e');
      _logger.e('💥 [HTTP_PUT] StackTrace: $stackTrace');
      developer.log('💥 Unexpected PUT error: $e', name: 'HttpServiceUtils', error: e, stackTrace: stackTrace);
      throw HttpException('Request failed: ${e.toString()}');
    }
  }

  /// Delete data from API
  static Future<dynamic> deleteData(String url, [BuildContext? context]) async {
    try {
      _logger.i('🗑️ [HTTP_DELETE] Starting DELETE request to: $url');
      developer.log('🗑️ Starting DELETE request to: $url', name: 'HttpServiceUtils');

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      final token = await SharedUtils.getString('auth_token');
      if (token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        _logger.d('🔑 [HTTP_DELETE] Auth token added to headers');
      }

      final response = await http
          .delete(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(const Duration(seconds: timeoutDuration));

      _logger.i('📨 [HTTP_DELETE] Response received - Status: ${response.statusCode}');
      _logger.d('📨 [HTTP_DELETE] Response body: ${response.body}');
      developer.log('📨 DELETE response: ${response.statusCode}', name: 'HttpServiceUtils');

      return _handleResponse(response, 'DELETE', url);

    } on SocketException catch (e) {
      _logger.e('🔌 [HTTP_DELETE] Network error: $e');
      developer.log('🔌 Network error: $e', name: 'HttpServiceUtils', error: e);
      throw const HttpException('No internet connection. Please check your network.');
    } on HttpException catch (e) {
      _logger.e('🚫 [HTTP_DELETE] HTTP exception: $e');
      developer.log('🚫 HTTP exception: $e', name: 'HttpServiceUtils', error: e);
      rethrow;
    } catch (e, stackTrace) {
      _logger.e('💥 [HTTP_DELETE] Unexpected error: $e');
      _logger.e('💥 [HTTP_DELETE] StackTrace: $stackTrace');
      developer.log('💥 Unexpected DELETE error: $e', name: 'HttpServiceUtils', error: e, stackTrace: stackTrace);
      throw HttpException('Request failed: ${e.toString()}');
    }
  }

  /// Handle HTTP response based on status code
  static dynamic _handleResponse(http.Response response, String method, String url) {
    final statusCode = response.statusCode;
    final body = response.body;

    _logger.d('🔍 [RESPONSE_HANDLER] Processing $method response for $url');
    _logger.d('🔍 [RESPONSE_HANDLER] Status: $statusCode, Body length: ${body.length}');
    developer.log('🔍 Processing $method response: $statusCode', name: 'HttpServiceUtils');

    switch (statusCode) {
      case 200:
      case 201:
      case 202:
        _logger.i('✅ [RESPONSE_HANDLER] Success response: $statusCode');
        developer.log('✅ Success response: $statusCode', name: 'HttpServiceUtils');
        
        if (body.isEmpty) {
          _logger.d('📭 [RESPONSE_HANDLER] Empty response body');
          return {};
        }

        try {
          final decodedData = jsonDecode(body);
          _logger.d('📋 [RESPONSE_HANDLER] Decoded JSON response');
          return decodedData;
        } catch (e) {
          _logger.w('⚠️ [RESPONSE_HANDLER] Failed to decode JSON, returning raw body');
          developer.log('⚠️ Failed to decode JSON response', name: 'HttpServiceUtils');
          return body;
        }

      case 204:
        _logger.i('✅ [RESPONSE_HANDLER] No content response: $statusCode');
        developer.log('✅ No content response: $statusCode', name: 'HttpServiceUtils');
        return {};

      case 400:
        _logger.e('❌ [RESPONSE_HANDLER] Bad request: $statusCode');
        developer.log('❌ Bad request: $statusCode', name: 'HttpServiceUtils');
        
        // Try to extract the actual error message from response
        try {
          final errorData = jsonDecode(body);
          final message = errorData['message'] ?? errorData['error'] ?? 'Bad request. Please check your input.';
          throw HttpException(message);
        } catch (e) {
          // If JSON parsing fails, show generic message
          throw const HttpException('Bad request. Please check your input.');
        }

      case 401:
        _logger.e('🔐 [RESPONSE_HANDLER] Unauthorized: $statusCode');
        developer.log('🔐 Unauthorized: $statusCode', name: 'HttpServiceUtils');
        throw const HttpException('Unauthorized. Please login again.');

      case 403:
        _logger.e('🚫 [RESPONSE_HANDLER] Forbidden: $statusCode');
        developer.log('🚫 Forbidden: $statusCode', name: 'HttpServiceUtils');
        throw const HttpException('Access forbidden. You don\'t have permission to perform this action.');

      case 404:
        _logger.e('🔍 [RESPONSE_HANDLER] Not found: $statusCode');
        developer.log('🔍 Not found: $statusCode', name: 'HttpServiceUtils');
        throw const HttpException('Resource not found.');

      case 422:
        _logger.e('📝 [RESPONSE_HANDLER] Validation error: $statusCode');
        developer.log('📝 Validation error: $statusCode', name: 'HttpServiceUtils');
        
        try {
          final errorData = jsonDecode(body);
          final message = errorData['message'] ?? 'Validation failed';
          throw HttpException(message);
        } catch (e) {
          throw const HttpException('Validation failed. Please check your input.');
        }

      case 500:
        _logger.e('🔥 [RESPONSE_HANDLER] Server error: $statusCode');
        developer.log('🔥 Server error: $statusCode', name: 'HttpServiceUtils');
        throw const HttpException('Server error. Please try again later.');

      case 502:
      case 503:
      case 504:
        _logger.e('⚡ [RESPONSE_HANDLER] Service unavailable: $statusCode');
        developer.log('⚡ Service unavailable: $statusCode', name: 'HttpServiceUtils');
        throw const HttpException('Service temporarily unavailable. Please try again later.');

      default:
        _logger.e('❓ [RESPONSE_HANDLER] Unexpected status code: $statusCode');
        developer.log('❓ Unexpected status code: $statusCode', name: 'HttpServiceUtils');
        throw HttpException('Request failed with status code: $statusCode');
    }
  }

  /// Check network connectivity
  static Future<bool> checkConnectivity() async {
    try {
      _logger.d('🔍 [CONNECTIVITY] Checking network connectivity');
      developer.log('🔍 Checking network connectivity', name: 'HttpServiceUtils');
      
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      
      final isConnected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      
      _logger.i('🌐 [CONNECTIVITY] Network status: ${isConnected ? 'Connected' : 'Disconnected'}');
      developer.log('🌐 Network status: ${isConnected ? 'Connected' : 'Disconnected'}', name: 'HttpServiceUtils');
      
      return isConnected;
    } catch (e) {
      _logger.e('❌ [CONNECTIVITY] Network check failed: $e');
      developer.log('❌ Network check failed: $e', name: 'HttpServiceUtils', error: e);
      return false;
    }
  }
}