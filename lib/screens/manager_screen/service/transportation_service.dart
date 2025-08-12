import 'dart:developer';
import 'package:hira_plus/constants/api_urls.dart';
import 'package:hira_plus/screens/manager_screen/models/vehicle_model.dart';
import 'package:hira_plus/screens/manager_screen/models/route_model.dart';
import 'package:hira_plus/screens/manager_screen/models/travel_model.dart';
import 'package:hira_plus/utils/service_utils.dart';

/// Transportation Service with Dummy Data Support
///
/// This service includes dummy data fallbacks for when the backend APIs are not ready.
/// When the backend is complete, remove the dummy data sections and uncomment the API calls.
///
/// TODO: Remove all dummy data and print statements when backend is ready
class TransportationService {
  // Vehicle Services
  static Future<List<VehicleModel>> getVehicles() async {
    try {
      log('Fetching vehicles from API: ${ApiUrls.getVehicles()}');
      final response = await HttpServiceUtils.fetchData(ApiUrls.getVehicles(), true);
      
      log('Vehicle API Response: $response');
      
      final List<dynamic> vehiclesJson = response['vehicles'] ?? [];
      
      if (vehiclesJson.isEmpty) {
        log('No vehicles found in API response');
        return [];
      }
      
      final vehicles = vehiclesJson.map((json) => VehicleModel.fromJson(json)).toList();
      log('Successfully parsed ${vehicles.length} vehicles');
      
      return vehicles;
    } catch (e) {
      log('Error fetching vehicles: $e');
      throw Exception('Error fetching vehicles: $e');
    }
  }

  static Future<bool> addVehicle(Map<String, dynamic> vehicleData) async {
    try {
      log('Adding vehicle with data: $vehicleData');
      await HttpServiceUtils.postData(ApiUrls.addVehicle(), vehicleData);
      log('Vehicle added successfully');
      return true;
    } catch (e) {
      log('Error adding vehicle: $e');
      throw Exception('Error adding vehicle: $e');
    }
  }

  static Future<bool> editVehicle(
      String vehicleId, Map<String, dynamic> vehicleData) async {
    try {
      await HttpServiceUtils.putData(
          ApiUrls.editVehicle(vehicleId), vehicleData);
      return true;
    } catch (e) {
      throw Exception('Error editing vehicle: $e');
    }
  }

  static Future<bool> deleteVehicle(String vehicleId) async {
    try {
      await HttpServiceUtils.deleteData(ApiUrls.deleteVehicle(vehicleId));
      return true;
    } catch (e) {
      throw Exception('Error deleting vehicle: $e');
    }
  }

  // Travel/Route Services
  static Future<List<TravelModel>> getAllTravels() async {
    try {
      log('Fetching all travels from API: ${ApiUrls.getAllTravels()}');
      final response =
          await HttpServiceUtils.fetchData(ApiUrls.getAllTravels(), true);

      log('API Response: $response');

      final List<dynamic> travelsJson = response is List ? response : [];

      if (travelsJson.isEmpty) {
        log('No travels found in API response');
        return [];
      }

      final travels =
          travelsJson.map((json) => TravelModel.fromJson(json)).toList();
      log('Successfully parsed ${travels.length} travels');

      return travels;
    } catch (e) {
      log('Error fetching travels: $e');
      throw Exception('Error fetching travels: $e');
    }
  }

  // Keep the old method for backward compatibility but use the new API
  static Future<List<RouteModel>> getTravels() async {
    try {
      // Get real travel data and convert to RouteModel for backward compatibility
      final travels = await getAllTravels();

      return travels
          .map((travel) => RouteModel(
                id: travel.id,
                routeName: '${travel.fromLocation} to ${travel.toLocation}',
                startLocation: travel.fromLocation,
                endLocation: travel.toLocation,
                vehicleId: travel.vehicle.id,
                driverId: travel.user.id,
                driverName: travel.user.name,
                vehicleName:
                    'Vehicle ${travel.vehicle.id}', // We'll need vehicle details from another API
                description: travel.description,
                status: _getTravelStatus(travel),
                startKm: travel.startKm,
                endKm: travel.endKm,
                startTime: travel.startTime,
                endTime: travel.endTime,
                date: travel.date.toIso8601String(),
                createdAt: travel.createdAt.toIso8601String(),
                updatedAt: travel.updatedAt.toIso8601String(),
              ))
          .toList();
    } catch (e) {
      log('Error in getTravels: $e');
      throw Exception('Error fetching travels: $e');
    }
  }

  static String _getTravelStatus(TravelModel travel) {
    // Determine status based on travel data
    final now = DateTime.now();
    final travelDate = travel.date;

    if (travelDate.day == now.day &&
        travelDate.month == now.month &&
        travelDate.year == now.year) {
      return 'active'; // Today's travel
    } else if (travelDate.isBefore(now)) {
      return 'completed'; // Past travel
    } else {
      return 'scheduled'; // Future travel
    }
  }

  static Future<bool> addTravel(Map<String, dynamic> travelData) async {
    try {
      log('Adding travel with data: $travelData');
      await HttpServiceUtils.postData(ApiUrls.addTravel(), travelData);
      log('Travel added successfully');
      return true;
    } catch (e) {
      log('Error adding travel: $e');
      throw Exception('Error adding travel: $e');
    }
  }

  static Future<bool> editTravel(
      String travelId, Map<String, dynamic> travelData) async {
    try {
      log('Editing travel $travelId with data: $travelData');
      await HttpServiceUtils.putData(ApiUrls.editTravel(travelId), travelData);
      log('Travel edited successfully');
      return true;
    } catch (e) {
      log('Error editing travel: $e');
      throw Exception('Error editing travel: $e');
    }
  }

  static Future<bool> deleteTravel(String travelId) async {
    try {
      log('Deleting travel: $travelId');
      await HttpServiceUtils.deleteData(ApiUrls.deleteTravel(travelId));
      log('Travel deleted successfully');
      return true;
    } catch (e) {
      log('Error deleting travel: $e');
      throw Exception('Error deleting travel: $e');
    }
  }
}
