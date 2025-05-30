class ReceptionUser {
  final String id;
  final String name;
  final String department;
  final String designation;
  final String? phoneNumber;
  final bool? isVerified;

  ReceptionUser({
    required this.id,
    required this.name,
    required this.department,
    required this.designation,
    this.phoneNumber,
    this.isVerified,
  });

  factory ReceptionUser.fromJson(Map<String, dynamic> json) {
    return ReceptionUser(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      department: json['department'] ?? '',
      designation: json['designation'] ?? '',
      phoneNumber: json['phoneNumber'],
      isVerified: json['isVerified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'department': department,
      'designation': designation,
      'phoneNumber': phoneNumber,
      'isVerified': isVerified,
    };
  }
}

class ReceptionAttendance {
  final String id;
  final DateTime date;
  final ReceptionUser user;
  final DateTime checkedInTime;
  final DateTime? checkoutTime;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  ReceptionAttendance({
    required this.id,
    required this.date,
    required this.user,
    required this.checkedInTime,
    this.checkoutTime,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory ReceptionAttendance.fromJson(Map<String, dynamic> json) {
    return ReceptionAttendance(
      id: json['_id'] ?? '',
      date: DateTime.parse(json['date']),
      user: ReceptionUser.fromJson(json['user'] ?? {}),
      checkedInTime: DateTime.parse(json['checkedInTime']),
      checkoutTime: json['checkoutTime'] != null ? DateTime.parse(json['checkoutTime']) : null,
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      v: json['__v'] ?? 0,
    );
  }
}