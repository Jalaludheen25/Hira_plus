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

  /// GET /mess-staff/menu/date (fetch all menus)
  Future<List<MenuModel>> getAllMenus() async {
    try {
      log('📅 Fetching all menus', name: 'MenuService');
      final response = await http.get(
        Uri.parse(ApiUrls.getAllMessStaffMenus()),
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

  /// POST /mess-staff/menu/date
  Future<MenuModel?> addMenuByDate(Map<String, dynamic> menu) async {
    try {
      log('➕ Adding menu: $menu', name: 'MenuService');
      final response = await http.post(
        Uri.parse(ApiUrls.postMessStaffMenuByDate()),
        headers: await _getAuthHeaders(),
        body: json.encode(menu),
      );
      log('Response status: ${response.statusCode}', name: 'MenuService');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        log('Response data: ${jsonEncode(data)}', name: 'MenuService');
        if (data['success'] == true && data['menu'] != null) {
          return MenuModel.fromJson(data['menu']);
        }
      }
      return null;
    } catch (e) {
      log('❌ Error adding menu: $e', name: 'MenuService');
      rethrow;
    }
  }

  /// PUT /mess-staff/menu/date
  Future<MenuModel?> updateMenuByDate(Map<String, dynamic> menu) async {
    try {
      log('✏️ Updating menu: $menu', name: 'MenuService');
      final response = await http.put(
        Uri.parse(ApiUrls.putMessStaffMenuByDate()),
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

  /// DELETE /mess-staff/menu/date
  Future<bool> deleteMenuByDate(String date) async {
    try {
      log('🗑️ Deleting menu for date: $date', name: 'MenuService');
      final response = await http.delete(
        Uri.parse(ApiUrls.deleteMessStaffMenuByDate()),
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