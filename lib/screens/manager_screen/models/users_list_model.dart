// To parse this JSON data, do
//
//     final usersListModel = usersListModelFromJson(jsonString);

import 'dart:convert';

List<UsersListModel> usersListModelFromJson(String str) =>
    List<UsersListModel>.from(
        json.decode(str).map((x) => UsersListModel.fromJson(x)));

String usersListModelToJson(List<UsersListModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UsersListModel {
  String? id;
  String? name;
  String? phoneNumber;
  String? department;
  String? departmentId;
  String? designation;
  bool? isVerified;
  DateTime? createdAt;
  bool? isDeptHead;

  UsersListModel({
    this.id,
    this.name,
    this.phoneNumber,
    this.department,
    this.departmentId,
    this.designation,
    this.isVerified,
    this.createdAt,
    this.isDeptHead,
  });

  factory UsersListModel.fromJson(Map<String, dynamic> json) => UsersListModel(
        id: json["_id"],
        name: json["name"],
        phoneNumber: json["phoneNumber"],
        department: (json["department"] is Map)
            ? json["department"]["title"]
            : json["department"],
        departmentId:
            (json["department"] is Map) ? json["department"]["_id"] : null,
        designation: json["designation"],
        isVerified: json["isVerified"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        isDeptHead: json["isDeptHead"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "phoneNumber": phoneNumber,
        "department": departmentId ?? department,
        "departmentId": departmentId,
        "designation": designation,
        "isVerified": isVerified,
        "createdAt": createdAt?.toIso8601String(),
        "isDeptHead": isDeptHead,
      };
}
