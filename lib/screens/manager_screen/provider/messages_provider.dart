/// Provider for managing admin messages (fetch, create, send)
// part of the public API for manager_screen
import 'package:flutter/material.dart';
import 'package:hira_plus/screens/manager_screen/models/message_model.dart';
import 'package:hira_plus/constants/api_urls.dart';
import 'package:hira_plus/utils/service_utils.dart';
import 'dart:developer' as developer;
import 'dart:convert';

class MessagesProvider extends ChangeNotifier {
  List<MessageModel> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMessages() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    debugPrint('[MessagesProvider] Fetching messages from: \\${ApiUrls.getMessages()}');
    try {
      final response = await HttpServiceUtils.fetchData(ApiUrls.getMessages(), true);
      debugPrint('[MessagesProvider] Fetched messages response: \\${response.toString()}');
      if (response is List) {
        _messages = response.map((e) => MessageModel.fromJson(e)).toList();
      } else {
        _messages = [];
      }
    } catch (e) {
      debugPrint('[MessagesProvider] Error fetching messages: \\${e.toString()}');
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<MessageModel?> createMessage(String title, String description) async {
    _isLoading = true;
    notifyListeners();
    developer.log('[MessagesProvider] Creating message', name: 'MessagesProvider',
      error: null, stackTrace: StackTrace.current, 
      time: DateTime.now(),
      sequenceNumber: 1,
      level: 800,
    );
    developer.log('Title: $title, Description: $description', name: 'MessagesProvider.createMessage');
    debugPrint('[MessagesProvider] Creating message at: \\${ApiUrls.createMessage()}');
    try {
      final data = {'title': title, 'description': description};
      developer.log('POST data: $data', name: 'MessagesProvider.createMessage');
      final response = await HttpServiceUtils.postData(ApiUrls.createMessage(), data);
      developer.log('POST response: $response', name: 'MessagesProvider.createMessage');
      debugPrint('[MessagesProvider] Created message response: \\${response.toString()}');
      final decoded = jsonDecode(response);
      final message = MessageModel.fromJson(decoded['data']);
      developer.log('Parsed MessageModel: \\${message.toString()}', name: 'MessagesProvider.createMessage');
      _isLoading = false;
      notifyListeners();
      return message;
    } catch (e, stack) {
      developer.log('Error creating message', name: 'MessagesProvider.createMessage', error: e, stackTrace: stack, level: 1000);
      debugPrint('[MessagesProvider] Error creating message: \\${e.toString()}');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> sendMessage(String id) async {
    _isLoading = true;
    notifyListeners();
    developer.log('[MessagesProvider] Sending message', name: 'MessagesProvider',
      error: null, stackTrace: StackTrace.current, 
      time: DateTime.now(),
      sequenceNumber: 1,
      level: 800,
    );
    developer.log('Message ID: $id', name: 'MessagesProvider.sendMessage');
    debugPrint('[MessagesProvider] Sending message at: \\${ApiUrls.sendMessage(id)}');
    try {
      developer.log('POST to: \\${ApiUrls.sendMessage(id)}', name: 'MessagesProvider.sendMessage');
      final response = await HttpServiceUtils.postData(ApiUrls.sendMessage(id), {});
      final decoded = jsonDecode(response);
      developer.log('Send message response: $decoded', name: 'MessagesProvider.sendMessage');
      debugPrint('[MessagesProvider] Send message response: $decoded');
      // Update sentToUsers for the message
      final idx = _messages.indexWhere((m) => m.id == id);
      developer.log('Index of message in list: $idx', name: 'MessagesProvider.sendMessage');
      if (idx != -1) {
        _messages[idx] = MessageModel(
          id: _messages[idx].id,
          title: _messages[idx].title,
          description: _messages[idx].description,
          sentToUsers: true,
          createdAt: _messages[idx].createdAt,
          v: _messages[idx].v,
        );
        // Move the sent message to the top
        final sentMsg = _messages.removeAt(idx);
        _messages.insert(0, sentMsg);
        developer.log('Moved sent message to top', name: 'MessagesProvider.sendMessage');
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e, stack) {
      developer.log('Error sending message', name: 'MessagesProvider.sendMessage', error: e, stackTrace: stack, level: 1000);
      debugPrint('[MessagesProvider] Error sending message: \\${e.toString()}');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
} 