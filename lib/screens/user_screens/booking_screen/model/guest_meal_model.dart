class GuestMealModel {
  final String id;
  final DateTime date;
  final DepartmentModel department;
  final String addedBy;
  final int breakfastCount;
  final int lunchCount;
  final int dinnerCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  GuestMealModel({
    required this.id,
    required this.date,
    required this.department,
    required this.addedBy,
    required this.breakfastCount,
    required this.lunchCount,
    required this.dinnerCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GuestMealModel.fromJson(Map<String, dynamic> json) {
    return GuestMealModel(
      id: json['_id'] ?? json['id'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      department: DepartmentModel.fromJson(json['department'] ?? {}),
      addedBy: json['addedBy'] ?? '',
      breakfastCount: json['breakfastCount'] ?? 0,
      lunchCount: json['lunchCount'] ?? 0,
      dinnerCount: json['dinnerCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'department': department.toJson(),
      'addedBy': addedBy,
      'breakfastCount': breakfastCount,
      'lunchCount': lunchCount,
      'dinnerCount': dinnerCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'GuestMealModel(id: $id, date: $date, department: ${department.title}, breakfastCount: $breakfastCount, lunchCount: $lunchCount, dinnerCount: $dinnerCount)';
  }

  /// Get total meal count for the day
  int get totalMealCount => breakfastCount + lunchCount + dinnerCount;

  /// Check if any meals are booked
  bool get hasMeals => totalMealCount > 0;

  /// Create a copy with updated values
  GuestMealModel copyWith({
    String? id,
    DateTime? date,
    DepartmentModel? department,
    String? addedBy,
    int? breakfastCount,
    int? lunchCount,
    int? dinnerCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GuestMealModel(
      id: id ?? this.id,
      date: date ?? this.date,
      department: department ?? this.department,
      addedBy: addedBy ?? this.addedBy,
      breakfastCount: breakfastCount ?? this.breakfastCount,
      lunchCount: lunchCount ?? this.lunchCount,
      dinnerCount: dinnerCount ?? this.dinnerCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class DepartmentModel {
  final String id;
  final String title;

  DepartmentModel({
    required this.id,
    required this.title,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
    };
  }

  @override
  String toString() {
    return 'DepartmentModel(id: $id, title: $title)';
  }
}