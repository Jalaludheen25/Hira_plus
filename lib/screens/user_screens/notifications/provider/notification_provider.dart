import 'package:flutter/material.dart';
import '../model/notification_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      const String url = 'https://hiraplusapi.dharmadhara.com/api/auth/notifications';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['notifications'] != null) {
          _notifications = (data['notifications'] as List)
              .map((n) => NotificationModel.fromJson(n))
              .toList();
        } else {
          _notifications = [];
        }
      } else {
        _error = 'Failed to load notifications';
      }
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
} 