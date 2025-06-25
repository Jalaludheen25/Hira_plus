class TodayCheckInModel {
  final bool success;
  final int totalCheckedIn;
  final Map<String, List<CheckedInUser>> byDepartment;
  final List<CheckIn> checkIns;

  TodayCheckInModel({
    required this.success,
    required this.totalCheckedIn,
    required this.byDepartment,
    required this.checkIns,
  });

  factory TodayCheckInModel.fromJson(Map<String, dynamic> json) {
    final byDept = <String, List<CheckedInUser>>{};
    if (json['byDepartment'] != null) {
      (json['byDepartment'] as Map<String, dynamic>).forEach((key, value) {
        byDept[key] = (value as List<dynamic>)
            .map((e) => CheckedInUser.fromJson(e))
            .toList();
      });
    }
    return TodayCheckInModel(
      success: json['success'] ?? false,
      totalCheckedIn: json['totalCheckedIn'] ?? 0,
      byDepartment: byDept,
      checkIns: (json['checkIns'] as List<dynamic>? ?? [])
          .map((e) => CheckIn.fromJson(e))
          .toList(),
    );
  }
}

class CheckedInUser {
  final String name;
  final String designation;
  final DateTime checkedInTime;

  CheckedInUser({
    required this.name,
    required this.designation,
    required this.checkedInTime,
  });

  factory CheckedInUser.fromJson(Map<String, dynamic> json) {
    return CheckedInUser(
      name: json['name'] ?? '',
      designation: json['designation'] ?? '',
      checkedInTime: DateTime.tryParse(json['checkedInTime'] ?? '') ?? DateTime.now(),
    );
  }
}

class CheckIn {
  final String id;
  final DateTime date;
  final CheckInUser user;
  final DateTime checkedInTime;
  final DateTime? checkoutTime;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  CheckIn({
    required this.id,
    required this.date,
    required this.user,
    required this.checkedInTime,
    this.checkoutTime,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CheckIn.fromJson(Map<String, dynamic> json) {
    return CheckIn(
      id: json['_id'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      user: CheckInUser.fromJson(json['user'] ?? {}),
      checkedInTime: DateTime.tryParse(json['checkedInTime'] ?? '') ?? DateTime.now(),
      checkoutTime: json['checkoutTime'] != null ? DateTime.tryParse(json['checkoutTime']) : null,
      status: json['status'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class CheckInUser {
  final String id;
  final String name;
  final String department;
  final String designation;

  CheckInUser({
    required this.id,
    required this.name,
    required this.department,
    required this.designation,
  });

  factory CheckInUser.fromJson(Map<String, dynamic> json) {
    return CheckInUser(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      department: json['department'] is Map
          ? (json['department']['title'] ?? '')
          : json['department'] ?? '',
      designation: json['designation'] ?? '',
    );
  }
} 