// To parse this JSON data, do
//
//     final usersByMealModel = usersByMealModelFromJson(jsonString);

import 'dart:convert';

List<UsersByMealModel> usersByMealModelFromJson(String str) =>
    List<UsersByMealModel>.from(
        json.decode(str).map((x) => UsersByMealModel.fromJson(x)));

String usersByMealModelToJson(List<UsersByMealModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UsersByMealModel {
  String? userId;
  String? name;
  String? phoneNumber;
  String? department;
  String? designation;
  DateTime? date;

  UsersByMealModel({
    this.userId,
    this.name,
    this.phoneNumber,
    this.department,
    this.designation,
    this.date,
  });

  factory UsersByMealModel.fromJson(Map<String, dynamic> json) =>
      UsersByMealModel(
        userId: json["userId"],
        name: json["name"],
        phoneNumber: json["phoneNumber"],
        department: (json["department"] is Map)
            ? json["department"]["title"]
            : json["department"],
        designation: json["designation"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
      );

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "name": name,
        "phoneNumber": phoneNumber,
        "department": department,
        "designation": designation,
        "date": date?.toIso8601String(),
      };
}
