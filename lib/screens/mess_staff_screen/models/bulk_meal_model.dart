class BulkMealModel {
  final DateTime date;
  final Map<String, DepartmentMeal> departments;
  final TotalCounts totalCounts;

  BulkMealModel({
    required this.date,
    required this.departments,
    required this.totalCounts,
  });

  factory BulkMealModel.fromJson(Map<String, dynamic> json) {
    // Parse departments
    final Map<String, DepartmentMeal> parsedDepartments = {};
    final departmentsJson = json['departments'] as Map<String, dynamic>? ?? {};
    
    departmentsJson.forEach((key, value) {
      parsedDepartments[key] = DepartmentMeal.fromJson(value as Map<String, dynamic>);
    });

    return BulkMealModel(
      date: DateTime.parse(json['date']),
      departments: parsedDepartments,
      totalCounts: TotalCounts.fromJson(json['totalCounts'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> departmentsJson = {};
    departments.forEach((key, value) {
      departmentsJson[key] = value.toJson();
    });

    return {
      'date': date.toIso8601String(),
      'departments': departmentsJson,
      'totalCounts': totalCounts.toJson(),
    };
  }

  // Helper getter for total meal count
  int get totalMealCount => totalCounts.breakfast + totalCounts.lunch + totalCounts.dinner;
  
  // Helper getter for breakfast count
  int get breakfastCount => totalCounts.breakfast;
  
  // Helper getter for lunch count
  int get lunchCount => totalCounts.lunch;
  
  // Helper getter for dinner count  
  int get dinnerCount => totalCounts.dinner;

  // Helper method to get department names as a string
  String get departmentNames {
    return departments.keys.join(', ');
  }

  // Helper method to check if any meals exist
  bool get hasMeals => totalMealCount > 0;
}

class DepartmentMeal {
  final int breakfast;
  final int lunch;
  final int dinner;
  final String addedBy;

  DepartmentMeal({
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.addedBy,
  });

  factory DepartmentMeal.fromJson(Map<String, dynamic> json) {
    return DepartmentMeal(
      breakfast: json['breakfast'] ?? 0,
      lunch: json['lunch'] ?? 0,
      dinner: json['dinner'] ?? 0,
      addedBy: json['addedBy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'breakfast': breakfast,
      'lunch': lunch,
      'dinner': dinner,
      'addedBy': addedBy,
    };
  }

  // Helper getter for total meals in this department
  int get totalMeals => breakfast + lunch + dinner;
}

class TotalCounts {
  final int breakfast;
  final int lunch; 
  final int dinner;

  TotalCounts({
    required this.breakfast,
    required this.lunch,
    required this.dinner,
  });

  factory TotalCounts.fromJson(Map<String, dynamic> json) {
    return TotalCounts(
      breakfast: json['breakfast'] ?? 0,
      lunch: json['lunch'] ?? 0,
      dinner: json['dinner'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'breakfast': breakfast,
      'lunch': lunch,
      'dinner': dinner,
    };
  }

  // Helper getter for total count
  int get total => breakfast + lunch + dinner;
}