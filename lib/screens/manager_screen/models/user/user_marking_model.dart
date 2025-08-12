// To parse this JSON data, do
//
//     final usersMarkingModel = usersMarkingModelFromJson(jsonString);

import 'dart:convert';

List<UsersMarkingModel> usersMarkingModelFromJson(String str) =>
    List<UsersMarkingModel>.from(
        json.decode(str).map((x) => UsersMarkingModel.fromJson(x)));

String usersMarkingModelToJson(List<UsersMarkingModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UsersMarkingModel {
  String? id;
  String? phoneNumber;
  String? name;
  String? department;
  String? designation;
  bool? isVerified;
  List<Meal>? meals;

  UsersMarkingModel({
    this.id,
    this.phoneNumber,
    this.name,
    this.department,
    this.designation,
    this.isVerified,
    this.meals,
  });

  factory UsersMarkingModel.fromJson(Map<String, dynamic> json) =>
      UsersMarkingModel(
        id: json["_id"],
        phoneNumber: json["phoneNumber"],
        name: json["name"],
        department: (json["department"] is Map)
            ? json["department"]["title"]
            : json["department"],
        designation: json["designation"],
        isVerified: json["isVerified"],
        meals: json["meals"] == null
            ? []
            : List<Meal>.from(json["meals"]!.map((x) => Meal.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "phoneNumber": phoneNumber,
        "name": name,
        "department": department,
        "designation": designation,
        "isVerified": isVerified,
        "meals": meals == null
            ? []
            : List<dynamic>.from(meals!.map((x) => x.toJson())),
      };
}

class Meal {
  String? id;
  DateTime? date;
  String? userId;
  int? v;
  bool? breakfast;
  DateTime? createdAt;
  bool? dinner;
  bool? lunch;
  DateTime? updatedAt;

  Meal({
    this.id,
    this.date,
    this.userId,
    this.v,
    this.breakfast,
    this.createdAt,
    this.dinner,
    this.lunch,
    this.updatedAt,
  });

  factory Meal.fromJson(Map<String, dynamic> json) => Meal(
        id: json["_id"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        userId: json["userId"],
        v: json["__v"],
        breakfast: json["breakfast"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        dinner: json["dinner"],
        lunch: json["lunch"],
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "date": date?.toIso8601String(),
        "userId": userId,
        "__v": v,
        "breakfast": breakfast,
        "createdAt": createdAt?.toIso8601String(),
        "dinner": dinner,
        "lunch": lunch,
        "updatedAt": updatedAt?.toIso8601String(),
      };
}
