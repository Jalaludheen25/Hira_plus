class DepartmentModel {
  final bool success;
  final List<String> departments;
  final int total;

  DepartmentModel({
    required this.success,
    required this.departments,
    required this.total,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      success: json['success'] ?? false,
      departments: (json['departments'] as List<dynamic>?)
              ?.map((e) =>
                  e is Map ? (e['title'] ?? '').toString() : e.toString())
              .toList() ??
          [],
      total: json['total'] ?? 0,
    );
  }
}
