import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hira_plus/constants/api_urls.dart';
import 'package:hira_plus/screens/driver_screen/model/driver_route_model.dart';
import 'package:hira_plus/utils/shared_utils.dart';
import 'package:http/http.dart' as http;

class DriverProvider extends ChangeNotifier {
  List<TripModel> _trips = [];
  bool _isLoading = false;

  List<TripModel> get trips => _trips;
  bool get isLoading => _isLoading;

  Future<void> fetchTrips() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Get user ID from SharedPreferences
      final userId = await SharedUtils.getString('user_id');
      debugPrint('Fetching trips for user ID: $userId');

      final url = ApiUrls.getTrips(userId);
      debugPrint('Fetching trips from: $url');

      final response = await http.get(Uri.parse(url));
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        debugPrint('Parsed data length: ${data.length}');
        _trips = data.map((e) => TripModel.fromJson(e)).toList();
        debugPrint('Trips loaded: ${_trips.length}');
      } else {
        debugPrint('Failed to load trips. Status: ${response.statusCode}');
        throw Exception('Failed to load trips: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Failed to load trips: $e');
      _trips = []; // Clear trips on error
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> postTrip(TripModel trip, String token) async {
    final url = Uri.parse(ApiUrls.createTrip());
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // Get user ID from SharedPreferences
    final userId = await SharedUtils.getString('user_id');
    debugPrint('Creating trip for user ID: $userId');

    final body = jsonEncode({
      "user": userId, // Use dynamic user ID instead of hardcoded
      "vehicle": trip.vehicle.id,
      "fromLocation": trip.fromLocation,
      "toLocation": trip.toLocation,
      "startKm": trip.startKm,
      "endKm": trip.endKm,
      "startTime": trip.startTime,
      "endTime": trip.endTime,
      "date": trip.date.toIso8601String(),
      "description": trip.description,
    });

    debugPrint('=== POST TRIP DEBUG ===');
    debugPrint('URL: $url');
    debugPrint('Headers: $headers');
    debugPrint('Body: $body');

    try {
      final response = await http.post(url, headers: headers, body: body);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        debugPrint('Post trip successful');
        await fetchTrips(); // Refresh data
        return true;
      } else {
        debugPrint(
            'Failed to post trip. Status: ${response.statusCode}, Body: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error posting trip: $e');
      return false;
    }
  }

  // Helper method to get trip by ID
  TripModel? getTripById(String tripId) {
    try {
      return _trips.firstWhere((trip) => trip.id == tripId);
    } catch (e) {
      return null;
    }
  }

  // Helper method to refresh trips
  Future<void> refreshTrips() async {
    await fetchTrips();
  }
}
