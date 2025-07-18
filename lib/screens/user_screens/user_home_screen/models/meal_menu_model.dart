class MealMenuResponse {
  final bool success;
  final int totalMenus;
  final List<Menu> menus;
  final DateRange dateRange;

  MealMenuResponse({
    required this.success,
    required this.totalMenus,
    required this.menus,
    required this.dateRange,
  });

  factory MealMenuResponse.fromJson(Map<String, dynamic> json) {
    return MealMenuResponse(
      success: json['success'] ?? false,
      totalMenus: json['totalMenus'] ?? 0,
      menus: (json['menus'] as List<dynamic>?)
              ?.map((menu) => Menu.fromJson(menu as Map<String, dynamic>))
              .toList() ??
          [],
      dateRange: DateRange.fromJson(json['dateRange'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'totalMenus': totalMenus,
      'menus': menus.map((menu) => menu.toJson()).toList(),
      'dateRange': dateRange.toJson(),
    };
  }
}

class Menu {
  final String id;
  final DateTime date;
  final String day;
  final String breakfast;
  final String lunch;
  final String dinner;
  final String addedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Menu({
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

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      id: json['id'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      day: json['day'] ?? '',
      breakfast: json['breakfast'] ?? '',
      lunch: json['lunch'] ?? '',
      dinner: json['dinner'] ?? '',
      addedBy: json['addedBy'] ?? '',
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
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

  // Helper methods for easier access to meal items
  List<String> get breakfastItems =>
      breakfast.split(',').map((item) => item.trim()).toList();
  List<String> get lunchItems =>
      lunch.split(',').map((item) => item.trim()).toList();
  List<String> get dinnerItems =>
      dinner.split(',').map((item) => item.trim()).toList();

  // Get formatted day name
  String get capitalizedDay =>
      day.substring(0, 1).toUpperCase() + day.substring(1);

  // Get formatted date string
  String get formattedDate {
    const months = [
      '',
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
    return '${date.day} ${months[date.month]} ${date.year}';
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

  // Helper method to get duration
  int get durationInDays => to.difference(from).inDays + 1;

  // Helper method to format date range
  String get formattedRange {
    const months = [
      '',
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

    final fromFormatted = '${from.day} ${months[from.month]}';
    final toFormatted = '${to.day} ${months[to.month]} ${to.year}';

    return '$fromFormatted - $toFormatted';
  }
}
