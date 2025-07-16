import 'package:flutter/foundation.dart';

class MenuModel {
  final String id;
  final DateTime date;
  final String day;
  final String breakfast;
  final String lunch;
  final String dinner;
  final String addedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  MenuModel({
    required this.id,
    required this.date,
    required this.day,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.addedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      day: json['day'] as String,
      breakfast: json['breakfast'] as String,
      lunch: json['lunch'] as String,
      dinner: json['dinner'] as String,
      addedBy: json['addedBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'day': day,
      'breakfast': breakfast,
      'lunch': lunch,
      'dinner': dinner,
      'addedBy': addedBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
} 