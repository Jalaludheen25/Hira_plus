// To parse this JSON data, do
//
//     final messStaffScreenModel = messStaffScreenModelFromJson(jsonString);

import 'dart:convert';

MessStaffScreenModel messStaffScreenModelFromJson(String str) => MessStaffScreenModel.fromJson(json.decode(str));

String messStaffScreenModelToJson(MessStaffScreenModel data) => json.encode(data.toJson());

class MessStaffScreenModel {
    TotalCounts? totalCounts;
    DailyCounts? dailyCounts;
    Meals? meals;

    MessStaffScreenModel({
        this.totalCounts,
        this.dailyCounts,
        this.meals,
    });

    factory MessStaffScreenModel.fromJson(Map<String, dynamic> json) => MessStaffScreenModel(
        totalCounts: json["totalCounts"] == null ? null : TotalCounts.fromJson(json["totalCounts"]),
        dailyCounts: json["dailyCounts"] == null ? null : DailyCounts.fromJson(json["dailyCounts"]),
        meals: json["meals"] == null ? null : Meals.fromJson(json["meals"]),
    );

    Map<String, dynamic> toJson() => {
        "totalCounts": totalCounts?.toJson(),
        "dailyCounts": dailyCounts?.toJson(),
        "meals": meals?.toJson(),
    };
}

class DailyCounts {
    TotalCounts? the20240315;
    TotalCounts? the20250315;
    TotalCounts? the20250326;
    TotalCounts? the20250426;
    TotalCounts? the20250427;
    TotalCounts? the20250428;
    TotalCounts? the20250508;
    TotalCounts? the20250509;
    TotalCounts? the20250512;
    TotalCounts? the20250513;
    TotalCounts? the20250514;
    TotalCounts? the20250515;
    TotalCounts? the20250516;
    TotalCounts? the20250517;
    TotalCounts? the20250518;
    TotalCounts? the20250523;
    TotalCounts? the20250603;
    TotalCounts? the20250604;

    DailyCounts({
        this.the20240315,
        this.the20250315,
        this.the20250326,
        this.the20250426,
        this.the20250427,
        this.the20250428,
        this.the20250508,
        this.the20250509,
        this.the20250512,
        this.the20250513,
        this.the20250514,
        this.the20250515,
        this.the20250516,
        this.the20250517,
        this.the20250518,
        this.the20250523,
        this.the20250603,
        this.the20250604,
    });

    factory DailyCounts.fromJson(Map<String, dynamic> json) => DailyCounts(
        the20240315: json["2024-03-15"] == null ? null : TotalCounts.fromJson(json["2024-03-15"]),
        the20250315: json["2025-03-15"] == null ? null : TotalCounts.fromJson(json["2025-03-15"]),
        the20250326: json["2025-03-26"] == null ? null : TotalCounts.fromJson(json["2025-03-26"]),
        the20250426: json["2025-04-26"] == null ? null : TotalCounts.fromJson(json["2025-04-26"]),
        the20250427: json["2025-04-27"] == null ? null : TotalCounts.fromJson(json["2025-04-27"]),
        the20250428: json["2025-04-28"] == null ? null : TotalCounts.fromJson(json["2025-04-28"]),
        the20250508: json["2025-05-08"] == null ? null : TotalCounts.fromJson(json["2025-05-08"]),
        the20250509: json["2025-05-09"] == null ? null : TotalCounts.fromJson(json["2025-05-09"]),
        the20250512: json["2025-05-12"] == null ? null : TotalCounts.fromJson(json["2025-05-12"]),
        the20250513: json["2025-05-13"] == null ? null : TotalCounts.fromJson(json["2025-05-13"]),
        the20250514: json["2025-05-14"] == null ? null : TotalCounts.fromJson(json["2025-05-14"]),
        the20250515: json["2025-05-15"] == null ? null : TotalCounts.fromJson(json["2025-05-15"]),
        the20250516: json["2025-05-16"] == null ? null : TotalCounts.fromJson(json["2025-05-16"]),
        the20250517: json["2025-05-17"] == null ? null : TotalCounts.fromJson(json["2025-05-17"]),
        the20250518: json["2025-05-18"] == null ? null : TotalCounts.fromJson(json["2025-05-18"]),
        the20250523: json["2025-05-23"] == null ? null : TotalCounts.fromJson(json["2025-05-23"]),
        the20250603: json["2025-06-03"] == null ? null : TotalCounts.fromJson(json["2025-06-03"]),
        the20250604: json["2025-06-04"] == null ? null : TotalCounts.fromJson(json["2025-06-04"]),
    );

    Map<String, dynamic> toJson() => {
        "2024-03-15": the20240315?.toJson(),
        "2025-03-15": the20250315?.toJson(),
        "2025-03-26": the20250326?.toJson(),
        "2025-04-26": the20250426?.toJson(),
        "2025-04-27": the20250427?.toJson(),
        "2025-04-28": the20250428?.toJson(),
        "2025-05-08": the20250508?.toJson(),
        "2025-05-09": the20250509?.toJson(),
        "2025-05-12": the20250512?.toJson(),
        "2025-05-13": the20250513?.toJson(),
        "2025-05-14": the20250514?.toJson(),
        "2025-05-15": the20250515?.toJson(),
        "2025-05-16": the20250516?.toJson(),
        "2025-05-17": the20250517?.toJson(),
        "2025-05-18": the20250518?.toJson(),
        "2025-05-23": the20250523?.toJson(),
        "2025-06-03": the20250603?.toJson(),
        "2025-06-04": the20250604?.toJson(),
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

class Meals {
    The202? the20240315;
    The202? the20250315;
    The202? the20250326;
    The202? the20250426;
    The202? the20250427;
    The202? the20250428;
    The202? the20250508;
    The202? the20250509;
    The202? the20250512;
    The202? the20250513;
    The202? the20250514;
    The202? the20250515;
    The202? the20250516;
    The202? the20250517;
    The202? the20250518;
    The202? the20250523;
    The202? the20250603;
    The202? the20250604;

    Meals({
        this.the20240315,
        this.the20250315,
        this.the20250326,
        this.the20250426,
        this.the20250427,
        this.the20250428,
        this.the20250508,
        this.the20250509,
        this.the20250512,
        this.the20250513,
        this.the20250514,
        this.the20250515,
        this.the20250516,
        this.the20250517,
        this.the20250518,
        this.the20250523,
        this.the20250603,
        this.the20250604,
    });

    factory Meals.fromJson(Map<String, dynamic> json) => Meals(
        the20240315: json["2024-03-15"] == null ? null : The202.fromJson(json["2024-03-15"]),
        the20250315: json["2025-03-15"] == null ? null : The202.fromJson(json["2025-03-15"]),
        the20250326: json["2025-03-26"] == null ? null : The202.fromJson(json["2025-03-26"]),
        the20250426: json["2025-04-26"] == null ? null : The202.fromJson(json["2025-04-26"]),
        the20250427: json["2025-04-27"] == null ? null : The202.fromJson(json["2025-04-27"]),
        the20250428: json["2025-04-28"] == null ? null : The202.fromJson(json["2025-04-28"]),
        the20250508: json["2025-05-08"] == null ? null : The202.fromJson(json["2025-05-08"]),
        the20250509: json["2025-05-09"] == null ? null : The202.fromJson(json["2025-05-09"]),
        the20250512: json["2025-05-12"] == null ? null : The202.fromJson(json["2025-05-12"]),
        the20250513: json["2025-05-13"] == null ? null : The202.fromJson(json["2025-05-13"]),
        the20250514: json["2025-05-14"] == null ? null : The202.fromJson(json["2025-05-14"]),
        the20250515: json["2025-05-15"] == null ? null : The202.fromJson(json["2025-05-15"]),
        the20250516: json["2025-05-16"] == null ? null : The202.fromJson(json["2025-05-16"]),
        the20250517: json["2025-05-17"] == null ? null : The202.fromJson(json["2025-05-17"]),
        the20250518: json["2025-05-18"] == null ? null : The202.fromJson(json["2025-05-18"]),
        the20250523: json["2025-05-23"] == null ? null : The202.fromJson(json["2025-05-23"]),
        the20250603: json["2025-06-03"] == null ? null : The202.fromJson(json["2025-06-03"]),
        the20250604: json["2025-06-04"] == null ? null : The202.fromJson(json["2025-06-04"]),
    );

    Map<String, dynamic> toJson() => {
        "2024-03-15": the20240315?.toJson(),
        "2025-03-15": the20250315?.toJson(),
        "2025-03-26": the20250326?.toJson(),
        "2025-04-26": the20250426?.toJson(),
        "2025-04-27": the20250427?.toJson(),
        "2025-04-28": the20250428?.toJson(),
        "2025-05-08": the20250508?.toJson(),
        "2025-05-09": the20250509?.toJson(),
        "2025-05-12": the20250512?.toJson(),
        "2025-05-13": the20250513?.toJson(),
        "2025-05-14": the20250514?.toJson(),
        "2025-05-15": the20250515?.toJson(),
        "2025-05-16": the20250516?.toJson(),
        "2025-05-17": the20250517?.toJson(),
        "2025-05-18": the20250518?.toJson(),
        "2025-05-23": the20250523?.toJson(),
        "2025-06-03": the20250603?.toJson(),
        "2025-06-04": the20250604?.toJson(),
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

    UserId({
        this.id,
        this.phoneNumber,
    });

    factory UserId.fromJson(Map<String, dynamic> json) => UserId(
        id: json["_id"],
        phoneNumber: json["phoneNumber"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "phoneNumber": phoneNumber,
    };
}
