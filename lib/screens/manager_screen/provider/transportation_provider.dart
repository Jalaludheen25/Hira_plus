import 'package:flutter/material.dart';
import 'package:hira_plus/screens/manager_screen/models/vehicle_model.dart';
import 'package:hira_plus/screens/manager_screen/models/route_model.dart';
import 'package:hira_plus/screens/manager_screen/models/user_model.dart';
import 'package:hira_plus/screens/manager_screen/service/transportation_service.dart';
import 'package:hira_plus/screens/manager_screen/service/users_service.dart';

class TransportationProvider extends ChangeNotifier {
  List<VehicleModel> _vehicles = [];
  List<RouteModel> _routes = [];
  List<UserModel> _drivers = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<VehicleModel> get vehicles => _vehicles;
  List<RouteModel> get routes => _routes;
  List<UserModel> get drivers => _drivers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get available drivers (users with driver role)
  List<UserModel> get availableDrivers =>
      _drivers.where((user) => user.role == 'driver').toList();

  // Get in-route items (routes with active status)
  List<RouteModel> get inRouteItems => _routes
      .where(
          (route) => route.status == 'active' || route.status == 'in_progress')
      .toList();

  // Get recent routes (completed or inactive)
  List<RouteModel> get recentRoutes => _routes
      .where(
          (route) => route.status == 'completed' || route.status == 'inactive')
      .toList();

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Fetch all transportation data
  Future<void> fetchAllData() async {
    _setLoading(true);
    _setError(null);

    try {
      await Future.wait([
        fetchVehicles(),
        fetchRoutes(),
        fetchDrivers(),
      ]);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Vehicle operations
  Future<void> fetchVehicles() async {
    try {
      _vehicles = await TransportationService.getVehicles();
      notifyListeners();
    } catch (e) {
      _setError('Failed to fetch vehicles: $e');
    }
  }

  Future<bool> addVehicle(Map<String, dynamic> vehicleData) async {
    try {
      final success = await TransportationService.addVehicle(vehicleData);
      if (success) {
        await fetchVehicles(); // Refresh the list
      }
      return success;
    } catch (e) {
      _setError('Failed to add vehicle: $e');
      return false;
    }
  }

  Future<bool> editVehicle(
      String vehicleId, Map<String, dynamic> vehicleData) async {
    try {
      final success =
          await TransportationService.editVehicle(vehicleId, vehicleData);
      if (success) {
        await fetchVehicles(); // Refresh the list
      }
      return success;
    } catch (e) {
      _setError('Failed to edit vehicle: $e');
      return false;
    }
  }

  Future<bool> deleteVehicle(String vehicleId) async {
    try {
      final success = await TransportationService.deleteVehicle(vehicleId);
      if (success) {
        await fetchVehicles(); // Refresh the list
      }
      return success;
    } catch (e) {
      _setError('Failed to delete vehicle: $e');
      return false;
    }
  }

  // Travel/Route operations
  Future<void> fetchRoutes() async {
    try {
      _routes = await TransportationService.getTravels();
      notifyListeners();
    } catch (e) {
      _setError('Failed to fetch travels: $e');
    }
  }

  Future<bool> addRoute(Map<String, dynamic> routeData) async {
    try {
      final success = await TransportationService.addTravel(routeData);
      if (success) {
        await fetchRoutes(); // Refresh the list
      }
      return success;
    } catch (e) {
      _setError('Failed to add travel: $e');
      return false;
    }
  }

  Future<bool> editRoute(String routeId, Map<String, dynamic> routeData) async {
    try {
      final success =
          await TransportationService.editTravel(routeId, routeData);
      if (success) {
        await fetchRoutes(); // Refresh the list
      }
      return success;
    } catch (e) {
      _setError('Failed to edit travel: $e');
      return false;
    }
  }

  Future<bool> deleteRoute(String routeId) async {
    try {
      final success = await TransportationService.deleteTravel(routeId);
      if (success) {
        await fetchRoutes(); // Refresh the list
      }
      return success;
    } catch (e) {
      _setError('Failed to delete travel: $e');
      return false;
    }
  }

  // Driver operations
  Future<void> fetchDrivers() async {
    try {
      _drivers = await UsersService.getUsers();
      notifyListeners();
    } catch (e) {
      _setError('Failed to fetch drivers: $e');
    }
  }

  Future<bool> updateUserRole(String userId, String role) async {
    try {
      final success = await UsersService.updateUserRole(userId, role);
      if (success) {
        await fetchDrivers(); // Refresh the list
      }
      return success;
    } catch (e) {
      _setError('Failed to update user role: $e');
      return false;
    }
  }

  Future<UserModel?> addUser({
    required String phoneNumber,
    required String name,
    required String department,
    required String designation,
    bool isDeptHead = false,
    String status = 'active',
    bool isFreeFood = false,
    bool isIntern = false,
    String role = 'user',
  }) async {
    try {
      final userData = UsersService.formatUserData(
        phoneNumber: phoneNumber,
        name: name,
        department: department,
        designation: designation,
        isDeptHead: isDeptHead,
        status: status,
        isFreeFood: isFreeFood,
        isIntern: isIntern,
        role: role,
      );

      final newUser = await UsersService.addUser(userData);
      if (newUser != null) {
        await fetchDrivers(); // Refresh the list
      }
      return newUser;
    } catch (e) {
      _setError('Failed to add user: $e');
      return null;
    }
  }

  // Helper methods
  VehicleModel? getVehicleById(String vehicleId) {
    try {
      return _vehicles.firstWhere((vehicle) => vehicle.id == vehicleId);
    } catch (e) {
      return null;
    }
  }

  UserModel? getDriverById(String driverId) {
    try {
      return _drivers.firstWhere((driver) => driver.id == driverId);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
