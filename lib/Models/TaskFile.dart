class TaskFile {
  final int id;
  final String taskId;
  final String title;
  final String urlFile;
  final String status;
  final DateTime createdAt;

  TaskFile({
    required this.id,
    required this.taskId,
    required this.title,
    required this.urlFile,
    required this.status,
    required this.createdAt,
  });

  factory TaskFile.fromJson(Map<String, dynamic> json) {
    return TaskFile(
      id: json['id'],
      taskId: json['taskId'],
      title: json['title'],
      urlFile: json['urlFile'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
