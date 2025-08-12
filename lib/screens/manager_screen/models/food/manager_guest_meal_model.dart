import 'package:intl/intl.dart';

class ManagerGuestMealModel {
  final String id;
  final DateTime date;
  final String department;
  final dynamic addedBy; // can be String or Map
  final int breakfastCount;
  final int lunchCount;
  final int dinnerCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  ManagerGuestMealModel({
    required this.id,
    required this.date,
    required this.department,
    required this.addedBy,
    required this.breakfastCount,
    required this.lunchCount,
    required this.dinnerCount,
    required this.createdAt,
    required this.updatedAt,
    this.version = 0,
  });

  factory ManagerGuestMealModel.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse dates
    DateTime parseDate(dynamic dateValue) {
      if (dateValue == null) return DateTime.now();
      if (dateValue is String) {
        try {
          return DateTime.parse(dateValue);
        } catch (e) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    // Helper function to safely parse integers
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      if (value is double) return value.toInt();
      return 0;
    }

    // Helper function to safely parse addedBy
    dynamic parseAddedBy(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is Map && value['name'] != null) return value;
      return value.toString();
    }

    return ManagerGuestMealModel(
      // Handle both _id (MongoDB) and id formats
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      date: parseDate(json['date']),
      department: (json['department'] is Map)
          ? (json['department']['title'] ?? '').toString()
          : json['department']?.toString() ?? '',
      addedBy: parseAddedBy(json['addedBy']),
      breakfastCount: parseInt(json['breakfastCount']),
      lunchCount: parseInt(json['lunchCount']),
      dinnerCount: parseInt(json['dinnerCount']),
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
      version: parseInt(json['__v']), // MongoDB version field
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'date': date.toIso8601String(),
      'department': department,
      'addedBy': addedBy,
      'breakfastCount': breakfastCount,
      'lunchCount': lunchCount,
      'dinnerCount': dinnerCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
    };
  }

  /// For API requests (without MongoDB specific fields)
  Map<String, dynamic> toApiJson() {
    return {
      'date': DateFormat('yyyy-MM-dd').format(date),
      'department': department,
      'addedBy': (addedBy is Map && addedBy['name'] != null)
          ? addedBy['name']
          : addedBy,
      'breakfastCount': breakfastCount,
      'lunchCount': lunchCount,
      'dinnerCount': dinnerCount,
    };
  }

  int get totalMealCount => breakfastCount + lunchCount + dinnerCount;

  /// Returns the booker's name for display
  String get bookerName {
    if (addedBy is Map && addedBy['name'] != null) {
      return addedBy['name'].toString();
    }
    if (addedBy is String) {
      return addedBy;
    }
    return '';
  }

  /// Create a copy with updated fields
  ManagerGuestMealModel copyWith({
    String? id,
    DateTime? date,
    String? department,
    dynamic addedBy,
    int? breakfastCount,
    int? lunchCount,
    int? dinnerCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
  }) {
    return ManagerGuestMealModel(
      id: id ?? this.id,
      date: date ?? this.date,
      department: department ?? this.department,
      addedBy: addedBy ?? this.addedBy,
      breakfastCount: breakfastCount ?? this.breakfastCount,
      lunchCount: lunchCount ?? this.lunchCount,
      dinnerCount: dinnerCount ?? this.dinnerCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
    );
  }

  @override
  String toString() {
    return 'ManagerGuestMealModel(id: $id, date: $date, department: $department, breakfastCount: $breakfastCount, lunchCount: $lunchCount, dinnerCount: $dinnerCount, totalMealCount: $totalMealCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ManagerGuestMealModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
