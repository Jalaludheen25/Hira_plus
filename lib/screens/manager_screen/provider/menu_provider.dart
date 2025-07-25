import 'package:flutter/material.dart';
import 'package:hira_plus/screens/manager_screen/service/menu_service.dart';
import '../models/menu_model.dart';

class MenuProvider extends ChangeNotifier {
  final MenuService _menuService;
  MenuModel? _menu;
  List<MenuModel> _menus = [];
  bool _isLoading = false;
  String? _error;

  MenuProvider({MenuService? menuService})
      : _menuService = menuService ?? MenuService();

  MenuModel? get menu => _menu;
  List<MenuModel> get menus => _menus;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  void _setMenu(MenuModel? menu) {
    _menu = menu;
    notifyListeners();
  }

  void _setMenus(List<MenuModel> menus) {
    _menus = menus;
    notifyListeners();
  }

  Future<void> fetchAllMenus() async {
    _setLoading(true);
    _setError(null);
    try {
      final menus = await _menuService.getAllMenus();
      _setMenus(menus);
      if (menus.isEmpty) {
        _setError('No menus found');
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addMenuByDate(Map<String, dynamic> menu) async {
    _setLoading(true);
    _setError(null);
    try {
      final addedMenu = await _menuService.addMenuByDate(menu);
      _setMenu(addedMenu);
      if (addedMenu != null) {
        return true;
      } else {
        _setError('Failed to add menu');
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
    return false;
  }

  Future<bool> updateMenuByDate(Map<String, dynamic> menu) async {
    _setLoading(true);
    _setError(null);
    try {
      final updatedMenu = await _menuService.updateMenuByDate(menu);
      _setMenu(updatedMenu);
      if (updatedMenu != null) {
        return true;
      } else {
        _setError('Failed to update menu');
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
    return false;
  }

  Future<bool> deleteMenuByDate(String date) async {
    _setLoading(true);
    _setError(null);
    try {
      final success = await _menuService.deleteMenuByDate(date);
      if (success) {
        _setMenu(null);
        return true;
      } else {
        _setError('Failed to delete menu');
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
    return false;
  }

  void clearMenu() {
    _menu = null;
    notifyListeners();
  }
}
