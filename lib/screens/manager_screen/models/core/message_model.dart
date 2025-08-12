class MessageModel {
  final String id;
  final String title;
  final String description;
  final bool sentToUsers;
  final DateTime createdAt;
  final int v;

  MessageModel({
    required this.id,
    required this.title,
    required this.description,
    required this.sentToUsers,
    required this.createdAt,
    required this.v,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    int vValue;
    if (json['__v'] is int) {
      vValue = json['__v'] as int;
    } else if (json['__v'] is String) {
      vValue = int.tryParse(json['__v']) ?? 0;
    } else {
      vValue = 0;
    }
    return MessageModel(
      id: json['_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      sentToUsers: json['sentToUsers'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      v: vValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'sentToUsers': sentToUsers,
      'createdAt': createdAt.toIso8601String(),
      '__v': v,
    };
  }
} 