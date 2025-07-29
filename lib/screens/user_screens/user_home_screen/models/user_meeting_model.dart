class MeetingModel {
  final String id;
  final String title;
  final String description;
  final DateTime startDatetime;
  final DateTime endDatetime;
  final String hall;
  final int noOfPersons;
  final bool foodRequired;
  final int breakfast;
  final int morningSnacksCount;
  final int morningTeaCount;
  final int lunch;
  final int eveningSnacksCount;
  final int eveningTeaCount;
  final int dinner;
  final String department;
  final String status;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int rent;
  final int? v; // for __v

  MeetingModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startDatetime,
    required this.endDatetime,
    required this.hall,
    required this.noOfPersons,
    required this.foodRequired,
    required this.breakfast,
    required this.morningSnacksCount,
    required this.morningTeaCount,
    required this.lunch,
    required this.eveningSnacksCount,
    required this.eveningTeaCount,
    required this.dinner,
    required this.department,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.rent,
    this.v,
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    return MeetingModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startDatetime:
          DateTime.tryParse(json['startDatetime'] ?? '') ?? DateTime.now(),
      endDatetime:
          DateTime.tryParse(json['endDatetime'] ?? '') ?? DateTime.now(),
      hall: json['hall'] ?? '',
      noOfPersons: json['noOfPersons'] ?? 0,
      foodRequired: json['foodRequired'] ?? false,
      breakfast: json['breakfast'] ?? 0,
      morningSnacksCount: json['morningSnacksCount'] ?? 0,
      morningTeaCount: json['morningTeaCount'] ?? 0,
      lunch: json['lunch'] ?? 0,
      eveningSnacksCount: json['eveningSnacksCount'] ?? 0,
      eveningTeaCount: json['eveningTeaCount'] ?? 0,
      dinner: json['dinner'] ?? 0,
      department: _parseDepartment(json['department']),
      status: json['status'] ?? 'pending',
      createdBy: json['createdBy']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      rent: json['rent'] ?? 0,
      v: json['__v'] ?? json['v'],
    );
  }

  // Helper method to parse department from various formats
  static String _parseDepartment(dynamic department) {
    if (department == null) return '';

    if (department is String) {
      return department;
    } else if (department is Map) {
      // Handle department as object with title field
      return department['title']?.toString() ??
          department['name']?.toString() ??
          department['_id']?.toString() ??
          '';
    } else {
      return department.toString();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'startDatetime': startDatetime.toIso8601String(),
      'endDatetime': endDatetime.toIso8601String(),
      'hall': hall,
      'noOfPersons': noOfPersons,
      'foodRequired': foodRequired,
      'breakfast': breakfast,
      'morningSnacksCount': morningSnacksCount,
      'morningTeaCount': morningTeaCount,
      'lunch': lunch,
      'eveningSnacksCount': eveningSnacksCount,
      'eveningTeaCount': eveningTeaCount,
      'dinner': dinner,
      'department': department,
      'status': status,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'rent': rent,
      '__v': v,
    };
  }

  // Helper getters for status checking
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isRejected => status.toLowerCase() == 'rejected';

  // Helper getter for total food count
  int get totalFoodCount => breakfast + lunch + dinner;

  // Helper method to get food breakdown as a string
  String get foodBreakdown {
    List<String> items = [];
    if (breakfast > 0) items.add('Breakfast: $breakfast');
    if (lunch > 0) items.add('Lunch: $lunch');
    if (dinner > 0) items.add('Dinner: $dinner');
    return items.isEmpty ? 'No food required' : items.join(', ');
  }

  @override
  String toString() {
    return 'MeetingModel(id: $id, title: $title, status: $status, startDatetime: $startDatetime)';
  }
}
