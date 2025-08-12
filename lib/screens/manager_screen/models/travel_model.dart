class TravelModel {
  final String id;
  final TravelUser user;
  final TravelVehicle vehicle;
  final String fromLocation;
  final String toLocation;
  final int startKm;
  final int endKm;
  final String startTime;
  final String endTime;
  final DateTime date;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  TravelModel({
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
    required this.createdAt,
    required this.updatedAt,
  });

  factory TravelModel.fromJson(Map<String, dynamic> json) {
    return TravelModel(
      id: json['_id'] ?? '',
      user: TravelUser.fromJson(json['user'] ?? {}),
      vehicle: TravelVehicle.fromJson(json['vehicle'] ?? {}),
      fromLocation: json['fromLocation'] ?? '',
      toLocation: json['toLocation'] ?? '',
      startKm: json['startKm'] ?? 0,
      endKm: json['endKm'] ?? 0,
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user.toJson(),
      'vehicle': vehicle.toJson(),
      'fromLocation': fromLocation,
      'toLocation': toLocation,
      'startKm': startKm,
      'endKm': endKm,
      'startTime': startTime,
      'endTime': endTime,
      'date': date.toIso8601String(),
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class TravelUser {
  final String id;
  final String name;
  final String phoneNumber;
  final String department;
  final String designation;
  final String role;

  TravelUser({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.department,
    required this.designation,
    required this.role,
  });

  factory TravelUser.fromJson(Map<String, dynamic> json) {
    return TravelUser(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      department: json['department'] ?? '',
      designation: json['designation'] ?? '',
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'department': department,
      'designation': designation,
      'role': role,
    };
  }
}

class TravelVehicle {
  final String id;

  TravelVehicle({
    required this.id,
  });

  factory TravelVehicle.fromJson(Map<String, dynamic> json) {
    return TravelVehicle(
      id: json['_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
    };
  }
}