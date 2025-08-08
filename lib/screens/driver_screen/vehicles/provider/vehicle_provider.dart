// Vehicle Provider
import 'package:flutter/material.dart';
import 'package:hira_plus/constants/api_urls.dart';
import 'package:hira_plus/screens/driver_screen/vehicles/model/vehicle_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class VehicleProvider extends ChangeNotifier {
  List<Vehicle> vehicles = [];
  Vehicle? selectedVehicle;
  bool isLoading = false;
  String? errorMessage;

  // Load vehicles from API
  Future<void> loadVehicles() async {
    debugPrint('=== LOADING VEHICLES STARTED ===');
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final url = ApiUrls.getVehicles();
      debugPrint('Making request to: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Parsed data: $data');

        if (data['vehicles'] != null) {
          vehicles = (data['vehicles'] as List)
              .map((json) => Vehicle.fromJson(json))
              .toList();
          debugPrint('Loaded ${vehicles.length} vehicles');
          for (var vehicle in vehicles) {
            debugPrint('Vehicle: ${vehicle.displayName}');
          }
          errorMessage = null;
        } else {
          debugPrint('No vehicles key found in response');
          vehicles = [];
          errorMessage = 'No vehicles found in response';
        }
      } else {
        debugPrint('Failed to load vehicles: ${response.statusCode}');
        vehicles = [];
        errorMessage = 'Failed to load vehicles: ${response.statusCode}';
      }
    } catch (e) {
      debugPrint('Error loading vehicles: $e');
      vehicles = [];
      errorMessage = 'Error loading vehicles: $e';
    }

    isLoading = false;
    notifyListeners();
    debugPrint('=== LOADING VEHICLES COMPLETED ===');
  }

  // Select vehicle
  void selectVehicle(Vehicle? vehicle) {
    selectedVehicle = vehicle;
    notifyListeners();
  }
}
