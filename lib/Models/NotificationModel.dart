class NotificationModel {
  final int id;
  final int createdBy;
  final String createdByName;
  final String type;
  final String priority;
  final String message;
  final String relatedEntityType;
  final int relatedEntityId;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.createdBy,
    required this.createdByName,
    required this.type,
    required this.priority,
    required this.message,
    required this.relatedEntityType,
    required this.relatedEntityId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      createdBy: json['createdBy'],
      createdByName: json['createdByName'],
      type: json['type'],
      priority: json['priority'],
      message: json['message'],
      relatedEntityType: json['relatedEntityType'],
      relatedEntityId: json['relatedEntityId'],
      isRead: json['isRead'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
