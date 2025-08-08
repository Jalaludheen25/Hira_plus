// Vehicle model
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
      vehicleName: json['vehicleName'] ?? '',
      vehicleNumber: json['vehicleNumber'] ?? '',
    );
  }

  String get displayName => '$vehicleName ($vehicleNumber)';
}