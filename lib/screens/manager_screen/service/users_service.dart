import 'dart:developer';
import 'package:hira_plus/constants/api_urls.dart';
import 'package:hira_plus/screens/manager_screen/models/user_model.dart';
import 'package:hira_plus/utils/service_utils.dart';

class UsersService {
  // Helper method to format user data for API
  static Map<String, dynamic> formatUserData({
    required String phoneNumber,
    required String name,
    required String department,
    required String designation,
    bool isDeptHead = false,
    String status = 'active',
    bool isFreeFood = false,
    bool isIntern = false,
    String role = 'user',
  }) {
    return {
      'phoneNumber': phoneNumber,
      'name': name,
      'department': department,
      'designation': designation,
      'isDeptHead': isDeptHead,
      'status': status,
      'isFreeFood': isFreeFood,
      'isIntern': isIntern,
      'role': role,
    };
  }

  // Get all users
  static Future<List<UserModel>> getUsers() async {
    try {
      log('UsersService: Fetching users from ${ApiUrls.getUsers()}');
      final response =
          await HttpServiceUtils.fetchData(ApiUrls.getUsers(), true);
      log('UsersService: Raw response: $response');

      final List<dynamic> usersJson = response is List ? response : [];
      log('UsersService: Found ${usersJson.length} users in response');

      final users = usersJson.map((json) {
        log('UsersService: Processing user: $json');
        return UserModel.fromJson(json);
      }).toList();

      log('UsersService: Parsed ${users.length} users');
      for (var user in users) {
        log('User: ${user.name} - Role: ${user.role} - isDriver: ${user.role == 'driver'}');
      }

      return users;
    } catch (e) {
      log('UsersService: Error fetching users: $e');
      throw Exception('Error fetching users: $e');
    }
  }

  // Update user role
  static Future<bool> updateUserRole(String userId, String role) async {
    try {
      final data = {
        'isDriver': role == 'driver',
        'role': role,
      };

      await HttpServiceUtils.putData(ApiUrls.updateUserRole(userId), data);
      return true;
    } catch (e) {
      throw Exception('Error updating user role: $e');
    }
  }

  // Add new user
  static Future<UserModel?> addUser(Map<String, dynamic> userData) async {
    try {
      final response =
          await HttpServiceUtils.postData(ApiUrls.createUser(), userData);

      // Handle the response format: {"message": "User added successfully", "user": {...}}
      if (response != null && response['user'] != null) {
        return UserModel.fromJson(response['user']);
      }
      return null;
    } catch (e) {
      throw Exception('Error adding user: $e');
    }
  }

  // Add new user (simple boolean return for backward compatibility)
  static Future<bool> addUserSimple(Map<String, dynamic> userData) async {
    try {
      await HttpServiceUtils.postData(ApiUrls.createUser(), userData);
      return true;
    } catch (e) {
      throw Exception('Error adding user: $e');
    }
  }

  // Update user
  static Future<bool> updateUser(
      String userId, Map<String, dynamic> userData) async {
    try {
      await HttpServiceUtils.putData(ApiUrls.updateUserRole(userId), userData);
      return true;
    } catch (e) {
      throw Exception('Error updating user: $e');
    }
  }

  // Delete user
  static Future<bool> deleteUser(String userId) async {
    try {
      await HttpServiceUtils.deleteData(ApiUrls.updateUserRole(userId));
      return true;
    } catch (e) {
      throw Exception('Error deleting user: $e');
    }
  }
}
