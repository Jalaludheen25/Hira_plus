// models/meeting_food_requirements_model.dart

class MeetingFoodModel {
  final bool success;
  final DateRange dateRange;
  final OverallTotals overallTotals;
  final Map<String, DailyRequirement> dailyRequirements;

  MeetingFoodModel({
    required this.success,
    required this.dateRange,
    required this.overallTotals,
    required this.dailyRequirements,
  });

  factory MeetingFoodModel.fromJson(Map<String, dynamic> json) {
    Map<String, DailyRequirement> dailyReqs = {};

    if (json['dailyRequirements'] != null) {
      (json['dailyRequirements'] as Map<String, dynamic>).forEach((key, value) {
        dailyReqs[key] = DailyRequirement.fromJson(value);
      });
    }

    return MeetingFoodModel(
      success: json['success'] ?? false,
      dateRange: DateRange.fromJson(json['dateRange'] ?? {}),
      overallTotals: OverallTotals.fromJson(json['overallTotals'] ?? {}),
      dailyRequirements: dailyReqs,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> dailyReqsMap = {};
    dailyRequirements.forEach((key, value) {
      dailyReqsMap[key] = value.toJson();
    });

    return {
      'success': success,
      'dateRange': dateRange.toJson(),
      'overallTotals': overallTotals.toJson(),
      'dailyRequirements': dailyReqsMap,
    };
  }
}

class DateRange {
  final DateTime from;
  final DateTime to;

  DateRange({
    required this.from,
    required this.to,
  });

  factory DateRange.fromJson(Map<String, dynamic> json) {
    return DateRange(
      from: DateTime.parse(json['from'] ?? DateTime.now().toIso8601String()),
      to: DateTime.parse(json['to'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from': from.toIso8601String(),
      'to': to.toIso8601String(),
    };
  }
}

class OverallTotals {
  final int breakfast;
  final int midmorningSnacks;
  final int morningTeaCount;
  final int lunch;
  final int eveningsnacks;
  final int eveningTeaCount;
  final int dinner;

  OverallTotals({
    required this.breakfast,
    required this.midmorningSnacks,
    required this.morningTeaCount,
    required this.lunch,
    required this.eveningsnacks,
    required this.eveningTeaCount,
    required this.dinner,
  });

  factory OverallTotals.fromJson(Map<String, dynamic> json) {
    return OverallTotals(
      breakfast: json['breakfast'] ?? 0,
      midmorningSnacks:
          json['midmorningSnacks'] ?? json['morningSnacksCount'] ?? 0,
      morningTeaCount: json['morningTeaCount'] ?? 0,
      lunch: json['lunch'] ?? 0,
      eveningsnacks: json['eveningsnacks'] ?? json['eveningSnacksCount'] ?? 0,
      eveningTeaCount: json['eveningTeaCount'] ?? 0,
      dinner: json['dinner'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'breakfast': breakfast,
      'midmorningSnacks': midmorningSnacks,
      'morningTeaCount': morningTeaCount,
      'lunch': lunch,
      'eveningsnacks': eveningsnacks,
      'eveningTeaCount': eveningTeaCount,
      'dinner': dinner,
    };
  }

  // Get total count of all meals
  int get totalCount =>
      breakfast +
      midmorningSnacks +
      morningTeaCount +
      lunch +
      eveningsnacks +
      eveningTeaCount +
      dinner;

  // Get list of food items with their counts
  List<FoodItem> get foodItems => [
        FoodItem(name: 'Breakfast', count: breakfast),
        FoodItem(name: 'Mid Morning Snacks', count: midmorningSnacks),
        FoodItem(name: 'Morning Tea', count: morningTeaCount),
        FoodItem(name: 'Lunch', count: lunch),
        FoodItem(name: 'Evening Snacks', count: eveningsnacks),
        FoodItem(name: 'Evening Tea', count: eveningTeaCount),
        FoodItem(name: 'Dinner', count: dinner),
      ];

  // Get only food items that have count > 0
  List<FoodItem> get activeFoodItems =>
      foodItems.where((item) => item.count > 0).toList();
}

class DailyRequirement {
  final DateTime date;
  final OverallTotals totalCounts;
  final List<Meeting> meetings;

  DailyRequirement({
    required this.date,
    required this.totalCounts,
    required this.meetings,
  });

  factory DailyRequirement.fromJson(Map<String, dynamic> json) {
    List<Meeting> meetingsList = [];
    if (json['meetings'] != null) {
      meetingsList = (json['meetings'] as List)
          .map((meeting) => Meeting.fromJson(meeting))
          .toList();
    }

    return DailyRequirement(
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      totalCounts: OverallTotals.fromJson(json['totalCounts'] ?? {}),
      meetings: meetingsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'totalCounts': totalCounts.toJson(),
      'meetings': meetings.map((meeting) => meeting.toJson()).toList(),
    };
  }
}

class Meeting {
  final String id;
  final String title;
  final String department;
  final DateTime startTime;
  final DateTime endTime;
  final String hall;
  final int noOfPersons;
  final OverallTotals foodCounts;
  final String createdBy;

  Meeting({
    required this.id,
    required this.title,
    required this.department,
    required this.startTime,
    required this.endTime,
    required this.hall,
    required this.noOfPersons,
    required this.foodCounts,
    required this.createdBy,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      department: (json['department'] is Map)
          ? (json['department']['title'] ?? '')
          : json['department'] ?? '',
      startTime:
          DateTime.parse(json['startTime'] ?? DateTime.now().toIso8601String()),
      endTime:
          DateTime.parse(json['endTime'] ?? DateTime.now().toIso8601String()),
      hall: json['hall'] ?? '',
      noOfPersons: json['noOfPersons'] ?? 0,
      foodCounts: OverallTotals.fromJson(json['foodCounts'] ?? {}),
      createdBy: json['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'department': department,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'hall': hall,
      'noOfPersons': noOfPersons,
      'foodCounts': foodCounts.toJson(),
      'createdBy': createdBy,
    };
  }

  // Get formatted time range
  String get timeRange {
    final startTimeFormatted =
        "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}";
    final endTimeFormatted =
        "${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}";
    return "$startTimeFormatted - $endTimeFormatted";
  }

  // Get formatted date
  String get dateFormatted {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return "${startTime.day} ${months[startTime.month - 1]} ${startTime.year}";
  }
}

class FoodItem {
  final String name;
  final int count;

  FoodItem({
    required this.name,
    required this.count,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'count': count,
    };
  }
}
