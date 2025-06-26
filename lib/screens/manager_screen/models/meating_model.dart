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
  final int midmorningSnacks;
  final int lunch;
  final int eveningsnacks;
  final int dinner;
  final String department;
  final String status;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int rent;
  final int morningSnacksCount;
  final int morningTeaCount;
  final int eveningSnacksCount;
  final int eveningTeaCount;

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
    required this.midmorningSnacks,
    required this.lunch,
    required this.eveningsnacks,
    required this.dinner,
    required this.department,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.rent,
    required this.morningSnacksCount,
    required this.morningTeaCount,
    required this.eveningSnacksCount,
    required this.eveningTeaCount,
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    return MeetingModel(
      id: json['_id'] ?? '',
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
      midmorningSnacks:
          json['midmorningSnacks'] ?? json['morningSnacksCount'] ?? 0,
      lunch: json['lunch'] ?? 0,
      eveningsnacks: json['eveningsnacks'] ?? json['eveningSnacksCount'] ?? 0,
      dinner: json['dinner'] ?? 0,
      department: (json['department'] is Map)
          ? (json['department']['title'] ?? '')
          : json['department'] ?? '',
      status: json['status'] ?? 'pending',
      createdBy: json['createdBy'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      rent: json['rent'] ?? 0,
      morningSnacksCount:
          json['morningSnacksCount'] ?? json['midmorningSnacks'] ?? 0,
      morningTeaCount: json['morningTeaCount'] ?? 0,
      eveningSnacksCount:
          json['eveningSnacksCount'] ?? json['eveningsnacks'] ?? 0,
      eveningTeaCount: json['eveningTeaCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'startDatetime': startDatetime.toIso8601String(),
      'endDatetime': endDatetime.toIso8601String(),
      'hall': hall,
      'noOfPersons': noOfPersons,
      'foodRequired': foodRequired,
      'breakfast': breakfast,
      'midmorningSnacks': morningSnacksCount,
      'morningSnacksCount': morningSnacksCount,
      'morningTeaCount': morningTeaCount,
      'lunch': lunch,
      'eveningsnacks': eveningSnacksCount,
      'eveningSnacksCount': eveningSnacksCount,
      'eveningTeaCount': eveningTeaCount,
      'dinner': dinner,
      'department': department,
      'rent': rent,
    };
  }

  // Helper methods
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isRejected => status.toLowerCase() == 'rejected';

  String get statusDisplayText {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending Approval';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  int get totalFoodCount =>
      breakfast +
      morningSnacksCount +
      morningTeaCount +
      lunch +
      eveningSnacksCount +
      eveningTeaCount +
      dinner;
}
