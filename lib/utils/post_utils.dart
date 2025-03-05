import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PostService {
  Future<bool> postData(String url, Map<String, dynamic> data) async {
    try {
      debugPrint('Posting to URL: $url');
      debugPrint('Data: ${jsonEncode(data)}');

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(data),
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      // Consider both 200 and 201 as success
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error posting data: $e');
      return false;
    }
  }
}
