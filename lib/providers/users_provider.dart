import 'package:flutter/material.dart';

class UsersProvider extends ChangeNotifier {
  final List<Map<String, String>> _users = [
    {'name': 'Lily Chen', 'username': '@lilychen'},
    {'name': 'Amanda Smith', 'username': '@amandasmith'},
    {'name': 'John Lee', 'username': '@johnlee'},
    {'name': 'Katie Perry', 'username': '@katieperry'},
    {'name': 'Catherine Smith', 'username': '@catherinesmith'},
  ];

  List<Map<String, String>> get users => List.unmodifiable(_users);

  List<Map<String, String>> searchUsers(String query) {
    final search = query.toLowerCase();
    return _users.where((user) =>
      user['name']!.toLowerCase().contains(search) ||
      user['username']!.toLowerCase().contains(search)
    ).toList();
  }

  void updateUser(int index, String name, String username) {
    _users[index]['name'] = name;
    _users[index]['username'] = username;
    notifyListeners();
  }

  void deleteUser(int index) {
    _users.removeAt(index);
    notifyListeners();
  }

  void addUser(String name, String username) {
    _users.add({'name': name, 'username': username});
    notifyListeners();
  }
} 