import 'package:hira_plus/constants/api_urls.dart';
import 'package:hira_plus/screens/manager_screen/models/vehicle_model.dart';
import 'package:hira_plus/screens/manager_screen/models/route_model.dart';
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
      // Try to fetch from API first, fallback to dummy data if it fails
      try {
        final response =
            await HttpServiceUtils.fetchData(ApiUrls.getVehicles(), true);
        final List<dynamic> vehiclesJson = response is List
            ? response
            : (response['vehicles'] ?? response['data'] ?? []);
        return vehiclesJson.map((json) => VehicleModel.fromJson(json)).toList();
      } catch (apiError) {
        // If API fails, use dummy data
        print('API failed, using dummy vehicle data: $apiError');
        await Future.delayed(
            Duration(milliseconds: 300)); // Simulate network delay

        final List<Map<String, dynamic>> dummyVehicles = [
          {
            '_id': 'vehicle1',
            'vehicleName': 'Bus A1',
            'vehicleNumber': 'KA-01-1234',
            'vehicleType': 'Bus',
            'capacity': 40,
            'status': 'available'
          },
          {
            '_id': 'vehicle2',
            'vehicleName': 'Van B2',
            'vehicleNumber': 'KA-02-5678',
            'vehicleType': 'Van',
            'capacity': 12,
            'status': 'available'
          },
          {
            '_id': 'vehicle3',
            'vehicleName': 'Car C3',
            'vehicleNumber': 'KA-03-9012',
            'vehicleType': 'Car',
            'capacity': 4,
            'status': 'in_use'
          },
          {
            '_id': 'vehicle4',
            'vehicleName': 'Truck D4',
            'vehicleNumber': 'KA-04-3456',
            'vehicleType': 'Truck',
            'capacity': 2,
            'status': 'maintenance'
          }
        ];

        return dummyVehicles
            .map((json) => VehicleModel.fromJson(json))
            .toList();
      }
    } catch (e) {
      throw Exception('Error fetching vehicles: $e');
    }
  }

  static Future<bool> addVehicle(Map<String, dynamic> vehicleData) async {
    try {
      // Try API first, fallback to dummy success
      try {
        await HttpServiceUtils.postData(ApiUrls.addVehicle(), vehicleData);
        return true;
      } catch (apiError) {
        // If API fails, simulate successful addition
        print('API failed, simulating vehicle addition: $apiError');
        await Future.delayed(
            Duration(milliseconds: 800)); // Simulate network delay
        print('Dummy: Vehicle added successfully with data: $vehicleData');
        return true;
      }
    } catch (e) {
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
  static Future<List<RouteModel>> getTravels() async {
    try {
      // TODO: Replace with actual API call when backend is ready
      // final response = await HttpServiceUtils.fetchData(ApiUrls.getTravels(), true);

      // Using dummy data for now
      await Future.delayed(
          Duration(milliseconds: 500)); // Simulate network delay

      final List<Map<String, dynamic>> dummyTravels = [
        {
          '_id': '1',
          'user': {
            '_id': 'user1',
            'name': 'John Driver',
            'department': 'Transportation'
          },
          'vehicle': {
            '_id': 'vehicle1',
            'vehicleName': 'Bus A1',
            'vehicleNumber': 'KA-01-1234'
          },
          'fromLocation': 'Main Campus',
          'toLocation': 'City Center',
          'startKm': 1000,
          'endKm': 1025,
          'startTime': '08:00',
          'endTime': '09:00',
          'date': '2025-01-07',
          'description': 'Morning route to city center',
          'status': 'active'
        },
        {
          '_id': '2',
          'user': {
            '_id': 'user2',
            'name': 'Mike Driver',
            'department': 'Transportation'
          },
          'vehicle': {
            '_id': 'vehicle2',
            'vehicleName': 'Van B2',
            'vehicleNumber': 'KA-02-5678'
          },
          'fromLocation': 'Hostel Block',
          'toLocation': 'Airport',
          'startKm': 2000,
          'endKm': 2050,
          'startTime': '14:00',
          'endTime': '15:30',
          'date': '2025-01-07',
          'description': 'Airport pickup service',
          'status': 'completed'
        },
        {
          '_id': '3',
          'user': {
            '_id': 'user3',
            'name': 'Sarah Driver',
            'department': 'Transportation'
          },
          'vehicle': {
            '_id': 'vehicle3',
            'vehicleName': 'Car C3',
            'vehicleNumber': 'KA-03-9012'
          },
          'fromLocation': 'Admin Block',
          'toLocation': 'Railway Station',
          'startKm': 3000,
          'endKm': 3020,
          'startTime': '16:00',
          'endTime': '17:00',
          'date': '2025-01-07',
          'description': 'Evening railway station drop',
          'status': 'active'
        }
      ];

      return dummyTravels.map((json) => RouteModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error fetching travels: $e');
    }
  }

  static Future<bool> addTravel(Map<String, dynamic> travelData) async {
    try {
      // TODO: Replace with actual API call when backend is ready
      // await HttpServiceUtils.postData(ApiUrls.addTravel(), travelData);

      // Simulate successful addition with dummy data
      await Future.delayed(
          Duration(milliseconds: 800)); // Simulate network delay
      print('Dummy: Travel added successfully with data: $travelData');
      return true;
    } catch (e) {
      throw Exception('Error adding travel: $e');
    }
  }

  static Future<bool> editTravel(
      String travelId, Map<String, dynamic> travelData) async {
    try {
      // TODO: Replace with actual API call when backend is ready
      // await HttpServiceUtils.putData(ApiUrls.editTravel(travelId), travelData);

      // Simulate successful edit with dummy data
      await Future.delayed(
          Duration(milliseconds: 600)); // Simulate network delay
      print(
          'Dummy: Travel $travelId edited successfully with data: $travelData');
      return true;
    } catch (e) {
      throw Exception('Error editing travel: $e');
    }
  }

  static Future<bool> deleteTravel(String travelId) async {
    try {
      // TODO: Replace with actual API call when backend is ready
      // await HttpServiceUtils.deleteData(ApiUrls.deleteTravel(travelId));

      // Simulate successful deletion with dummy data
      await Future.delayed(
          Duration(milliseconds: 400)); // Simulate network delay
      print('Dummy: Travel $travelId deleted successfully');
      return true;
    } catch (e) {
      throw Exception('Error deleting travel: $e');
    }
  }
}
