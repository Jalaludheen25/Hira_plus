class RouteModel {
  final String? id;
  final String? routeName;
  final String? startLocation;
  final String? endLocation;
  final String? vehicleId;
  final String? driverId;
  final String? vehicleName;
  final String? driverName;
  final String? status;
  final String? description;
  final String? createdAt;
  final String? updatedAt;
  final int? startKm;
  final int? endKm;
  final String? startTime;
  final String? endTime;
  final String? date;

  RouteModel({
    this.id,
    this.routeName,
    this.startLocation,
    this.endLocation,
    this.vehicleId,
    this.driverId,
    this.vehicleName,
    this.driverName,
    this.status,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.startKm,
    this.endKm,
    this.startTime,
    this.endTime,
    this.date,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    // Handle vehicle object
    final vehicle = json['vehicle'];
    String? vehicleName;
    String? vehicleId;

    if (vehicle is Map<String, dynamic>) {
      vehicleName = vehicle['vehicleName']?.toString();
      vehicleId = vehicle['_id']?.toString();
    } else if (vehicle is String) {
      vehicleId = vehicle;
    }

    return RouteModel(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      routeName: '${json['fromLocation']} to ${json['toLocation']}',
      startLocation: json['fromLocation']?.toString(),
      endLocation: json['toLocation']?.toString(),
      vehicleId: vehicleId ?? json['vehicle_id']?.toString(),
      driverId: json['user']?.toString() ?? json['driver_id']?.toString(),
      vehicleName: vehicleName ?? json['vehicle_name']?.toString(),
      driverName: json['driver_name']?.toString(),
      status: json['status']?.toString() ?? 'active',
      description: json['description']?.toString(),
      createdAt:
          json['createdAt']?.toString() ?? json['created_at']?.toString(),
      updatedAt:
          json['updatedAt']?.toString() ?? json['updated_at']?.toString(),
      startKm: json['startKm'] != null
          ? int.tryParse(json['startKm'].toString())
          : null,
      endKm:
          json['endKm'] != null ? int.tryParse(json['endKm'].toString()) : null,
      startTime: json['startTime']?.toString(),
      endTime: json['endTime']?.toString(),
      date: json['date']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'route_name': routeName,
      'start_location': startLocation,
      'end_location': endLocation,
      'vehicle_id': vehicleId,
      'driver_id': driverId,
      'vehicle_name': vehicleName,
      'driver_name': driverName,
      'status': status,
      'description': description,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
