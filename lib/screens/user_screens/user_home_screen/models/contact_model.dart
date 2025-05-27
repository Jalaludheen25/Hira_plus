class ContactModel {
  final String name;
  final String phoneNumber;
  final String department;
  final String designation;

  ContactModel({
    required this.name,
    required this.phoneNumber,
    required this.department,
    required this.designation,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      department: json['department'] ?? '',
      designation: json['designation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'department': department,
      'designation': designation,
    };
  }
}

class ContactsResponse {
  final bool success;
  final List<ContactModel> users;

  ContactsResponse({
    required this.success,
    required this.users,
  });

  factory ContactsResponse.fromJson(Map<String, dynamic> json) {
    return ContactsResponse(
      success: json['success'] ?? false,
      users: (json['users'] as List<dynamic>?)
          ?.map((userJson) => ContactModel.fromJson(userJson))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'users': users.map((user) => user.toJson()).toList(),
    };
  }
}