class TripModel {
  final String id;
  final String user;
  final Vehicle vehicle;
  final String fromLocation;
  final String toLocation;
  final int startKm;
  final int endKm;
  final String startTime;
  final String endTime;
  final DateTime date;
  final String description;

  TripModel({
    required this.id,
    required this.user,
    required this.vehicle,
    required this.fromLocation,
    required this.toLocation,
    required this.startKm,
    required this.endKm,
    required this.startTime,
    required this.endTime,
    required this.date,
    required this.description,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['_id'] ?? '',
      user: json['user'] ?? '',
      vehicle: json['vehicle'] != null
          ? Vehicle.fromJson(json['vehicle'])
          : Vehicle(id: '', vehicleName: 'Unknown', vehicleNumber: 'Unknown'),
      fromLocation: json['fromLocation'] ?? 'Unknown',
      toLocation: json['toLocation'] ?? 'Unknown',
      startKm: json['startKm'] ?? 0,
      endKm: json['endKm'] ?? 0,
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      date: json['date'] != null
          ? DateTime.tryParse(json['date']) ?? DateTime(2000)
          : DateTime(2000),
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "user": user,
      "vehicle": vehicle.id,
      "fromLocation": fromLocation,
      "toLocation": toLocation,
      "startKm": startKm,
      "endKm": endKm,
      "startTime": startTime,
      "endTime": endTime,
      "date": date.toIso8601String(),
      "description": description,
    };
  }
}

class Vehicle {
  final String id;
  final String vehicleName;
  final String vehicleNumber;

  Vehicle({
    required this.id,
    required this.vehicleName,
    required this.vehicleNumber,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['_id'] ?? '',
      vehicleName: json['vehicleName'] ?? 'Unknown',
      vehicleNumber: json['vehicleNumber'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "vehicleName": vehicleName,
      "vehicleNumber": vehicleNumber,
    };
  }
}
