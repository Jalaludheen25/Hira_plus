import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/menu_model.dart';
import '../../../constants/api_urls.dart';
import '../../../utils/shared_utils.dart';
import 'dart:developer';

class MenuService {
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await SharedUtils.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// GET /manager/menu/date (fetch all menus)
  Future<List<MenuModel>> getAllMenus() async {
    try {
      log('📅 Fetching all menus', name: 'MenuService');
      final response = await http.get(
        Uri.parse(ApiUrls.getAllManagerMenus()),
        headers: await _getAuthHeaders(),
      );
      log('Response status: ${response.statusCode}', name: 'MenuService');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        log('Response data: ${jsonEncode(data)}', name: 'MenuService');
        if (data['success'] == true && data['menus'] != null) {
          final List<dynamic> menusJson = data['menus'];
          return menusJson.map((json) => MenuModel.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      log('❌ Error fetching all menus: $e', name: 'MenuService');
      rethrow;
    }
  }

  /// POST /manager/menu/date
  Future<MenuModel?> addMenuByDate(Map<String, dynamic> menu) async {
    try {
      log('➕ Adding menu: $menu', name: 'MenuService');
      final response = await http.post(
        Uri.parse(ApiUrls.postManagerMenuByDate()),
        headers: await _getAuthHeaders(),
        body: json.encode(menu),
      );
      log('Response status: ${response.statusCode}', name: 'MenuService');
      log('Response body: ${response.body}', name: 'MenuService');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        log('Response data: ${jsonEncode(data)}', name: 'MenuService');
        if (data['success'] == true && data['menu'] != null) {
          return MenuModel.fromJson(data['menu']);
        } else if (data['success'] == true) {
          log('✅ Menu added successfully but no menu data returned',
              name: 'MenuService');
          return null; // Success but no data to return
        } else {
          // Handle specific error cases
          final message = data['message'] ?? 'Failed to add menu';
          if (message.toLowerCase().contains('already') ||
              message.toLowerCase().contains('exists') ||
              message.toLowerCase().contains('duplicate')) {
            throw Exception('MENU_ALREADY_EXISTS');
          } else {
            throw Exception(message);
          }
        }
      } else if (response.statusCode == 409) {
        // Conflict - menu already exists for this date
        throw Exception('MENU_ALREADY_EXISTS');
      } else {
        log('❌ HTTP Error ${response.statusCode}: ${response.body}',
            name: 'MenuService');
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      log('❌ Error adding menu: $e', name: 'MenuService');
      rethrow;
    }
  }

  /// PUT /manager/menu/date
  Future<MenuModel?> updateMenuByDate(Map<String, dynamic> menu) async {
    try {
      log('✏️ Updating menu: $menu', name: 'MenuService');
      final response = await http.put(
        Uri.parse(ApiUrls.putManagerMenuByDate()),
        headers: await _getAuthHeaders(),
        body: json.encode(menu),
      );
      log('Response status: ${response.statusCode}', name: 'MenuService');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        log('Response data: ${jsonEncode(data)}', name: 'MenuService');
        if (data['success'] == true && data['menu'] != null) {
          return MenuModel.fromJson(data['menu']);
        }
      }
      return null;
    } catch (e) {
      log('❌ Error updating menu: $e', name: 'MenuService');
      rethrow;
    }
  }

  /// DELETE /manager/menu/date
  Future<bool> deleteMenuByDate(String date) async {
    try {
      log('🗑️ Deleting menu for date: $date', name: 'MenuService');
      final response = await http.delete(
        Uri.parse(ApiUrls.deleteManagerMenuByDate()),
        headers: await _getAuthHeaders(),
        body: json.encode({'date': date}),
      );
      log('Response status: ${response.statusCode}', name: 'MenuService');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        log('Response data: ${jsonEncode(data)}', name: 'MenuService');
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      log('❌ Error deleting menu: $e', name: 'MenuService');
      rethrow;
    }
  }
}
