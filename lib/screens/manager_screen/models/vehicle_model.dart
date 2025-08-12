class VehicleModel {
  final String? id;
  final String? vehicleName;
  final String? vehicleNumber;
  final String? vehicleType;
  final int? capacity;
  final String? status;
  final String? createdAt;
  final String? updatedAt;

  VehicleModel({
    this.id,
    this.vehicleName,
    this.vehicleNumber,
    this.vehicleType,
    this.capacity,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      vehicleName:
          json['vehicleName']?.toString() ?? json['vehicle_name']?.toString(),
      vehicleNumber: json['vehicleNumber']?.toString() ??
          json['vehicle_number']?.toString(),
      vehicleType:
          json['vehicleType']?.toString() ?? json['vehicle_type']?.toString(),
      capacity: json['capacity'] != null
          ? int.tryParse(json['capacity'].toString())
          : null,
      status: json['status']?.toString() ??
          'available', // Default to available since API doesn't provide status
      createdAt:
          json['createdAt']?.toString() ?? json['created_at']?.toString(),
      updatedAt:
          json['updatedAt']?.toString() ?? json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_name': vehicleName,
      'vehicle_number': vehicleNumber,
      'vehicle_type': vehicleType,
      'capacity': capacity,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
