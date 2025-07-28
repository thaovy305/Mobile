import 'Assignee.dart';
class WorkItem {
  final int projectId;
  final String type;
  final String key;
  final String? taskId;
  final String summary;
  final String status;
  final int commentCount;
  final int? sprintId;
  final String? sprintName;
  final List<Assignee> assignees;
  final String? dueDate;
  final List<String> labels;
  final String createdAt;
  final String updatedAt;
  final int? reporterId;
  final String reporterFullname;
  final String? reporterPicture;

  WorkItem({
    required this.projectId,
    required this.type,
    required this.key,
    this.taskId,
    required this.summary,
    required this.status,
    required this.commentCount,
    this.sprintId,
    this.sprintName,
    required this.assignees,
    this.dueDate,
    required this.labels,
    required this.createdAt,
    required this.updatedAt,
    this.reporterId,
    required this.reporterFullname,
    this.reporterPicture,
  });

  factory WorkItem.fromJson(Map<String, dynamic> json) {
    return WorkItem(
      projectId: json['projectId'] as int,
      type: json['type'] as String,
      key: json['key'] as String,
      taskId: json['taskId'] as String?,
      summary: json['summary'] as String,
      status: json['status'] as String,
      commentCount: json['commentCount'] as int,
      sprintId: json['sprintId'] as int?,
      sprintName: json['sprintName'] as String?,
      assignees:
      (json['assignees'] as List)
          .map((e) => Assignee.fromJson(e as Map<String, dynamic>))
          .toList(),
      dueDate: json['dueDate'] as String?,
      labels: (json['labels'] as List).cast<String>(),
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      reporterId: json['reporterId'] as int?,
      reporterFullname: json['reporterFullname'] as String,
      reporterPicture: json['reporterPicture'] as String?,
    );
  }
}

