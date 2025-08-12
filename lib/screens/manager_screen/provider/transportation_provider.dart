import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:hira_plus/screens/manager_screen/models/vehicle_model.dart';
import 'package:hira_plus/screens/manager_screen/models/route_model.dart';
import 'package:hira_plus/screens/manager_screen/models/user_model.dart';
import 'package:hira_plus/screens/manager_screen/models/travel_model.dart';
import 'package:hira_plus/screens/manager_screen/service/transportation_service.dart';
import 'package:hira_plus/screens/manager_screen/service/users_service.dart';

class TransportationProvider extends ChangeNotifier {
  List<VehicleModel> _vehicles = [];
  List<RouteModel> _routes = [];
  List<TravelModel> _travels = [];
  List<UserModel> _drivers = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<VehicleModel> get vehicles => _vehicles;
  List<RouteModel> get routes => _routes;
  List<TravelModel> get travels => _travels;
  List<UserModel> get drivers => _drivers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get available drivers (users with driver role who are not currently in active route)
  List<UserModel> get availableDrivers {
    log('TransportationProvider: Getting available drivers');
    final now = DateTime.now();
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    // Get all drivers with 'driver' role
    final allDrivers = _drivers.where((user) => user.role == 'driver').toList();
    log('Drivers with driver role: ${allDrivers.length}');

    // Log all drivers we have
    log('All drivers in system:');
    for (var driver in allDrivers) {
      log('  Driver: ${driver.name} - ID: ${driver.id} - Role: ${driver.role}');
    }

    // Log all travels with user info
    log('All travels with users:');
    for (var travel in _travels) {
      log('  Travel: ${travel.user.name} - User ID: ${travel.user.id} - Date: ${travel.date} - End: ${travel.endTime}');
    }

    // Get drivers who are currently in active routes (current time < end time)
    final driversInActiveRoute = _travels
        .where((travel) {
          final travelDate = travel.date;
          final isToday = travelDate.day == now.day &&
              travelDate.month == now.month &&
              travelDate.year == now.year;

          if (!isToday) return false;

          // Check if route is still active (current time < end time)
          try {
            final currentMinutes = _parseTime(currentTime);
            final endMinutes = _parseTime(travel.endTime);
            final isActive = currentMinutes < endMinutes;

            log('Driver ${travel.user.name} (${travel.user.id}) - End: ${travel.endTime} - Current: $currentTime - Active: $isActive (${currentMinutes} < ${endMinutes})');

            return isActive;
          } catch (e) {
            log('Error parsing time for driver ${travel.user.name}: $e');
            return false;
          }
        })
        .map((travel) => travel.user.id)
        .toSet();

    log('Drivers in active routes: $driversInActiveRoute');

    final availableDrivers = allDrivers
        .where((user) => !driversInActiveRoute.contains(user.id))
        .toList();

    log('Available drivers: ${availableDrivers.length}');
    for (var driver in availableDrivers) {
      log('  Available: ${driver.name} - ID: ${driver.id}');
    }

    return availableDrivers;
  }

  // Get available vehicles (vehicles not currently in active route)
  List<VehicleModel> get availableVehicles {
    log('TransportationProvider: Getting available vehicles');
    final now = DateTime.now();
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    // Log all vehicles we have
    log('All vehicles in system:');
    for (var vehicle in _vehicles) {
      log('  Vehicle: ${vehicle.vehicleName} - ID: ${vehicle.id}');
    }

    // Log all travels
    log('All travels:');
    for (var travel in _travels) {
      log('  Travel: ${travel.user.name} - Vehicle ID: ${travel.vehicle.id} - Date: ${travel.date} - End: ${travel.endTime}');
    }

    // Get vehicles that are currently in active routes (current time < end time)
    final vehiclesInActiveRoute = _travels
        .where((travel) {
          final travelDate = travel.date;
          final isToday = travelDate.day == now.day &&
              travelDate.month == now.month &&
              travelDate.year == now.year;

          if (!isToday) return false;

          // Check if route is still active (current time < end time)
          try {
            final currentMinutes = _parseTime(currentTime);
            final endMinutes = _parseTime(travel.endTime);
            final isActive = currentMinutes < endMinutes;

            log('Vehicle ${travel.vehicle.id} - End: ${travel.endTime} - Current: $currentTime - Active: $isActive (${currentMinutes} < ${endMinutes})');

            return isActive;
          } catch (e) {
            log('Error parsing time for vehicle ${travel.vehicle.id}: $e');
            return false;
          }
        })
        .map((travel) => travel.vehicle.id)
        .toSet();

    log('Vehicles in active routes: $vehiclesInActiveRoute');

    final availableVehicles = _vehicles
        .where((vehicle) => !vehiclesInActiveRoute.contains(vehicle.id))
        .toList();

    log('Available vehicles: ${availableVehicles.length}');
    for (var vehicle in availableVehicles) {
      log('  Available: ${vehicle.vehicleName} - ID: ${vehicle.id}');
    }

    return availableVehicles;
  }

  // Helper method to check if current time is within travel time range
  bool _isTimeInRange(String currentTime, String startTime, String endTime) {
    try {
      final current = _parseTime(currentTime);
      final start = _parseTime(startTime);
      final end = _parseTime(endTime);

      return current >= start && current <= end;
    } catch (e) {
      log('Error parsing time: $e');
      return false;
    }
  }

  // Helper method to parse time string to minutes
  int _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length != 2)
      throw FormatException('Invalid time format: $timeStr');

    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);

    return hours * 60 + minutes;
  }

  // Get in-route items (active travels - current time < end time)
  List<TravelModel> get inRouteItems {
    log('TransportationProvider: Getting in-route items');
    final now = DateTime.now();
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final activeTravels = _travels.where((travel) {
      final travelDate = travel.date;
      final isToday = travelDate.day == now.day &&
          travelDate.month == now.month &&
          travelDate.year == now.year;

      if (!isToday) return false;

      // Simple logic: if current time < end time, it's still active
      final endTime = travel.endTime;

      try {
        final currentMinutes = _parseTime(currentTime);
        final endMinutes = _parseTime(endTime);
        final isActive =
            currentMinutes < endMinutes; // Route is active if current < end

        log('Travel: ${travel.user.name} - End: $endTime - Current: $currentTime - Active: $isActive (${currentMinutes} < ${endMinutes})');

        return isActive;
      } catch (e) {
        log('Error parsing time for travel: $e');
        return false;
      }
    }).toList();

    log('In-route items (currently active): ${activeTravels.length}');

    return activeTravels;
  }

  // Get recent routes (completed travels - current time > end time)
  List<TravelModel> get recentRoutes {
    log('TransportationProvider: Getting recent routes');
    final now = DateTime.now();
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final recentTravels = _travels.where((travel) {
      final travelDate = travel.date;
      final isToday = travelDate.day == now.day &&
          travelDate.month == now.month &&
          travelDate.year == now.year;

      if (isToday) {
        // For today's travels, check if they have ended (current time > end time)
        final endTime = travel.endTime;
        try {
          final currentMinutes = _parseTime(currentTime);
          final endMinutes = _parseTime(endTime);
          final hasEnded =
              currentMinutes > endMinutes; // Route ended if current > end

          log('Today\'s Travel: ${travel.user.name} - End: $endTime - Current: $currentTime - Ended: $hasEnded (${currentMinutes} > ${endMinutes})');

          return hasEnded;
        } catch (e) {
          log('Error parsing time for travel: $e');
          return false;
        }
      } else {
        // For past dates, include all travels
        return travelDate.isBefore(now);
      }
    }).toList();

    log('Recent routes (completed travels): ${recentTravels.length}');

    return recentTravels;
  }

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
    log('TransportationProvider: Starting to fetch all data');
    _setLoading(true);
    _setError(null);

    try {
      await Future.wait([
        fetchVehicles(),
        fetchTravels(),
        fetchDrivers(),
      ]);
      log('TransportationProvider: Successfully fetched all data');
    } catch (e) {
      log('TransportationProvider: Error fetching data: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Vehicle operations
  Future<void> fetchVehicles() async {
    try {
      log('TransportationProvider: Fetching vehicles');
      _vehicles = await TransportationService.getVehicles();
      log('TransportationProvider: Fetched ${_vehicles.length} vehicles');

      // Log vehicle details for debugging
      for (var vehicle in _vehicles) {
        log('Vehicle: ${vehicle.vehicleName} - ID: ${vehicle.id} - Number: ${vehicle.vehicleNumber}');
      }

      notifyListeners();
    } catch (e) {
      log('TransportationProvider: Error fetching vehicles: $e');
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

  // Travel operations
  Future<void> fetchTravels() async {
    try {
      log('TransportationProvider: Fetching travels');
      _travels = await TransportationService.getAllTravels();
      log('TransportationProvider: Fetched ${_travels.length} travels');

      // Log travel details for debugging
      for (var travel in _travels) {
        log('Travel: ${travel.user.name} (${travel.user.id}) - Vehicle: ${travel.vehicle.id} - Date: ${travel.date} - ${travel.fromLocation} to ${travel.toLocation}');
      }

      notifyListeners();
    } catch (e) {
      log('TransportationProvider: Error fetching travels: $e');
      _setError('Failed to fetch travels: $e');
    }
  }

  // Keep the old method for backward compatibility
  Future<void> fetchRoutes() async {
    try {
      log('TransportationProvider: Fetching routes (backward compatibility)');
      _routes = await TransportationService.getTravels();
      log('TransportationProvider: Fetched ${_routes.length} routes');
      notifyListeners();
    } catch (e) {
      log('TransportationProvider: Error fetching routes: $e');
      _setError('Failed to fetch routes: $e');
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
      log('TransportationProvider: Fetching drivers');
      _drivers = await UsersService.getUsers();
      log('TransportationProvider: Fetched ${_drivers.length} drivers');

      // Log driver details for debugging
      for (var driver in _drivers) {
        log('Driver: ${driver.name} - Role: ${driver.role} - ID: ${driver.id}');
      }

      notifyListeners();
    } catch (e) {
      log('TransportationProvider: Error fetching drivers: $e');
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
