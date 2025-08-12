class UserModel {
  final String? id;
  final String? name;
  final String? phoneNumber;
  final String? department;
  final String? designation;
  final String? role;
  final bool? isVerified;
  final bool? isDeptHead;
  final String? createdAt;
  final String? updatedAt;

  UserModel({
    this.id,
    this.name,
    this.phoneNumber,
    this.department,
    this.designation,
    this.role,
    this.isVerified,
    this.isDeptHead,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      name: json['name']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      department: json['department'] is Map
          ? json['department']['title']?.toString()
          : json['department']?.toString(),
      designation: json['designation']?.toString(),
      role: json['isDriver'] == true ? 'driver' : 'user',
      isVerified: json['isVerified'] as bool?,
      isDeptHead: json['isDeptHead'] as bool?,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'department': department,
      'designation': designation,
      'role': role,
      'isDriver': role == 'driver',
      'isVerified': isVerified,
      'isDeptHead': isDeptHead,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
