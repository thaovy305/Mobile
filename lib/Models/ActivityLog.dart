class ActivityLog {
  final int? id;
  final int? projectId;
  final String? taskId;
  final String? subtaskId;
  final String? relatedEntityType;
  final String? relatedEntityId;
  final String? actionType;
  final String? fieldChanged;
  final String? oldValue;
  final String? newValue;
  final String? message;
  final int? createdBy;
  final String? createdByName;
  final DateTime? createdAt;

  ActivityLog({
    this.id,
    this.projectId,
    this.taskId,
    this.subtaskId,
    this.relatedEntityType,
    this.relatedEntityId,
    this.actionType,
    this.fieldChanged,
    this.oldValue,
    this.newValue,
    this.message,
    this.createdBy,
    this.createdByName,
    this.createdAt,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'],
      projectId: json['projectId'],
      taskId: json['taskId'],
      subtaskId: json['subtaskId'],
      relatedEntityType: json['relatedEntityType'],
      relatedEntityId: json['relatedEntityId'],
      actionType: json['actionType'],
      fieldChanged: json['fieldChanged'],
      oldValue: json['oldValue'],
      newValue: json['newValue'],
      message: json['message'],
      createdBy: json['createdBy'],
      createdByName: json['createdByName'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'taskId': taskId,
      'subtaskId': subtaskId,
      'relatedEntityType': relatedEntityType,
      'relatedEntityId': relatedEntityId,
      'actionType': actionType,
      'fieldChanged': fieldChanged,
      'oldValue': oldValue,
      'newValue': newValue,
      'message': message,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}