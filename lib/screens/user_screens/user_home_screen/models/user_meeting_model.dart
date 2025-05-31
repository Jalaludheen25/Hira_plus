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
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    return MeetingModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startDatetime: DateTime.tryParse(json['startDatetime'] ?? '') ?? DateTime.now(),
      endDatetime: DateTime.tryParse(json['endDatetime'] ?? '') ?? DateTime.now(),
      hall: json['hall'] ?? '',
      noOfPersons: json['noOfPersons'] ?? 0,
      foodRequired: json['foodRequired'] ?? false,
      breakfast: json['breakfast'] ?? 0,
      midmorningSnacks: json['midmorningSnacks'] ?? 0,
      lunch: json['lunch'] ?? 0,
      eveningsnacks: json['eveningsnacks'] ?? 0,
      dinner: json['dinner'] ?? 0,
      department: json['department'] ?? '',
      status: json['status'] ?? '',
      createdBy: json['createdBy'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
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
      'midmorningSnacks': midmorningSnacks,
      'lunch': lunch,
      'eveningsnacks': eveningsnacks,
      'dinner': dinner,
      'department': department,
      'status': status,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper getters for status checking
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isRejected => status.toLowerCase() == 'rejected';

  // Helper getter for total food count
  int get totalFoodCount => breakfast + midmorningSnacks + lunch + eveningsnacks + dinner;

  // Helper method to get food breakdown as a string
  String get foodBreakdown {
    List<String> items = [];
    if (breakfast > 0) items.add('Breakfast: $breakfast');
    if (midmorningSnacks > 0) items.add('Morning Snacks: $midmorningSnacks');
    if (lunch > 0) items.add('Lunch: $lunch');
    if (eveningsnacks > 0) items.add('Evening Snacks: $eveningsnacks');
    if (dinner > 0) items.add('Dinner: $dinner');
    return items.isEmpty ? 'No food required' : items.join(', ');
  }

  @override
  String toString() {
    return 'MeetingModel(id: $id, title: $title, status: $status, startDatetime: $startDatetime)';
  }
}