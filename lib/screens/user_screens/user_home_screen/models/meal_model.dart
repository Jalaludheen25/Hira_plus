import 'package:flutter/foundation.dart';

class MealModel {
  final String id;
  final DateTime date;
  final String userId;
  final bool breakfast;
  final bool lunch;
  final bool dinner;
  final DateTime createdAt;
  final DateTime updatedAt;

  MealModel({
    required this.id,
    required this.date,
    required this.userId,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    try {
      return MealModel(
        id: json['_id'] ?? '',
        date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
        userId: json['userId'] ?? '',
        breakfast: json['breakfast'] ?? false,
        lunch: json['lunch'] ?? false,
        dinner: json['dinner'] ?? false,
        createdAt: DateTime.parse(
            json['createdAt'] ?? DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(
            json['updatedAt'] ?? DateTime.now().toIso8601String()),
      );
    } catch (e) {
      debugPrint('Error parsing meal model: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'date': date.toIso8601String(),
      'userId': userId,
      'breakfast': breakfast,
      'lunch': lunch,
      'dinner': dinner,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class BannerModel {
  final String id;
  final String title;
  final String bannerImage;
  final DateTime createdAt;
  final DateTime updatedAt;

  BannerModel({
    required this.id,
    required this.title,
    required this.bannerImage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      bannerImage: json['bannerImage'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
