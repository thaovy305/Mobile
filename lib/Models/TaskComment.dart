class TaskComment {
  final int id;
  final String taskId;
  final int accountId;
  final String accountName;
  final String accountPicture;
  final String content;
  final String createdAt;

  TaskComment({
    required this.id,
    required this.taskId,
    required this.accountId,
    required this.accountName,
    required this.accountPicture,
    required this.content,
    required this.createdAt,
  });

  factory TaskComment.fromJson(Map<String, dynamic> json) {
    return TaskComment(
      id: json['id'] ?? 0,
      taskId: json['taskId'] ?? '',
      accountId: json['accountId'] ?? 0,
      accountName: json['accountName'] ?? 'Unknown',
      accountPicture: json['accountPicture'] ?? 'None',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'accountId': accountId,
      'accountName': accountName,
      'accountPicture': accountPicture,
      'content': content,
      'createdAt': createdAt,
    };
  }
}
