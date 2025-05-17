/// Provider for managing admin messages (fetch, create, send)
// part of the public API for manager_screen
import 'package:flutter/material.dart';
import 'package:hira_plus/screens/manager_screen/models/message_model.dart';
import 'package:hira_plus/constants/api_urls.dart';
import 'package:hira_plus/utils/service_utils.dart';

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
    debugPrint('[MessagesProvider] Creating message at: \\${ApiUrls.createMessage()}');
    try {
      final data = {'title': title, 'description': description};
      final response = await HttpServiceUtils.postData(ApiUrls.createMessage(), data);
      debugPrint('[MessagesProvider] Created message response: \\${response.toString()}');
      final message = MessageModel.fromJson(response['data']);
      _isLoading = false;
      notifyListeners();
      return message;
    } catch (e) {
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
    debugPrint('[MessagesProvider] Sending message at: \\${ApiUrls.sendMessage(id)}');
    try {
      await HttpServiceUtils.postData(ApiUrls.sendMessage(id), {});
      debugPrint('[MessagesProvider] Message sent for id: $id');
      // Update sentToUsers for the message
      final idx = _messages.indexWhere((m) => m.id == id);
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
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[MessagesProvider] Error sending message: \\${e.toString()}');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
} 