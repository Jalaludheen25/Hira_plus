// To parse this JSON data, do
//
//     final messStaffScreenModel = messStaffScreenModelFromJson(jsonString);

import 'dart:convert';

MessStaffScreenModel messStaffScreenModelFromJson(String str) => MessStaffScreenModel.fromJson(json.decode(str));

String messStaffScreenModelToJson(MessStaffScreenModel data) => json.encode(data.toJson());

class MessStaffScreenModel {
    TotalCounts? totalCounts;
    Map<String, TotalCounts>? dailyCounts;
    Map<String, The202>? meals;

    MessStaffScreenModel({
        this.totalCounts,
        this.dailyCounts,
        this.meals,
    });

    factory MessStaffScreenModel.fromJson(Map<String, dynamic> json) => MessStaffScreenModel(
        totalCounts: json["totalCounts"] == null ? null : TotalCounts.fromJson(json["totalCounts"]),
        dailyCounts: json["dailyCounts"] == null ? null : Map.from(json["dailyCounts"]).map((k, v) => MapEntry<String, TotalCounts>(k, TotalCounts.fromJson(v))),
        meals: json["meals"] == null ? null : Map.from(json["meals"]).map((k, v) => MapEntry<String, The202>(k, The202.fromJson(v))),
    );

    Map<String, dynamic> toJson() => {
        "totalCounts": totalCounts?.toJson(),
        "dailyCounts": dailyCounts == null ? null : Map.from(dailyCounts!).map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
        "meals": meals == null ? null : Map.from(meals!).map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
    };
}

class TotalCounts {
    int? breakfast;
    int? lunch;
    int? dinner;
    int? total;

    TotalCounts({
        this.breakfast,
        this.lunch,
        this.dinner,
        this.total,
    });

    factory TotalCounts.fromJson(Map<String, dynamic> json) => TotalCounts(
        breakfast: json["breakfast"],
        lunch: json["lunch"],
        dinner: json["dinner"],
        total: json["total"],
    );

    Map<String, dynamic> toJson() => {
        "breakfast": breakfast,
        "lunch": lunch,
        "dinner": dinner,
        "total": total,
    };
}

class The202 {
    List<Breakfast>? breakfast;
    List<Breakfast>? lunch;
    List<Breakfast>? dinner;

    The202({
        this.breakfast,
        this.lunch,
        this.dinner,
    });

    factory The202.fromJson(Map<String, dynamic> json) => The202(
        breakfast: json["breakfast"] == null ? [] : List<Breakfast>.from(json["breakfast"]!.map((x) => Breakfast.fromJson(x))),
        lunch: json["lunch"] == null ? [] : List<Breakfast>.from(json["lunch"]!.map((x) => Breakfast.fromJson(x))),
        dinner: json["dinner"] == null ? [] : List<Breakfast>.from(json["dinner"]!.map((x) => Breakfast.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "breakfast": breakfast == null ? [] : List<dynamic>.from(breakfast!.map((x) => x.toJson())),
        "lunch": lunch == null ? [] : List<dynamic>.from(lunch!.map((x) => x.toJson())),
        "dinner": dinner == null ? [] : List<dynamic>.from(dinner!.map((x) => x.toJson())),
    };
}

class Breakfast {
    String? id;
    UserId? userId;
    String? date;
    bool? breakfast;
    bool? lunch;
    bool? dinner;
    String? createdAt;
    String? updatedAt;
    int? v;

    Breakfast({
        this.id,
        this.userId,
        this.date,
        this.breakfast,
        this.lunch,
        this.dinner,
        this.createdAt,
        this.updatedAt,
        this.v,
    });

    factory Breakfast.fromJson(Map<String, dynamic> json) => Breakfast(
        id: json["_id"],
        userId: json["userId"] == null ? null : UserId.fromJson(json["userId"]),
        date: json["date"],
        breakfast: json["breakfast"],
        lunch: json["lunch"],
        dinner: json["dinner"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
        v: json["__v"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId?.toJson(),
        "date": date,
        "breakfast": breakfast,
        "lunch": lunch,
        "dinner": dinner,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "__v": v,
    };
}

class UserId {
    String? id;
    String? phoneNumber;
    String? name;
    String? department;

    UserId({
        this.id,
        this.phoneNumber,
        this.name,
        this.department,
    });

    factory UserId.fromJson(Map<String, dynamic> json) => UserId(
        id: json["_id"],
        phoneNumber: json["phoneNumber"],
        name: json["name"],
        department: json["department"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "phoneNumber": phoneNumber,
        "name": name,
        "department": department,
    };
}
