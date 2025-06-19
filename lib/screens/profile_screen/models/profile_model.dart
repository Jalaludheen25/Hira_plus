class ProfileModel {
  final String id;
  final String name;
  final String phoneNumber;
  final String department;
  final String designation;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeptHead;

  ProfileModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.department,
    required this.designation,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeptHead,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      department: (json['department'] is Map)
          ? (json['department']['title'] ?? '')
          : json['department'] ?? '',
      designation: json['designation'] ?? '',
      isVerified: json['isVerified'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      isDeptHead: json['isDeptHead'] ?? false,
    );
  }
}
