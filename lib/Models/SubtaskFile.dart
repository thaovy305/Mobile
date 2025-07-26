class SubtaskFile {
  final int id;
  final String subtaskId;
  final String title;
  final String urlFile;
  final String status;
  final DateTime createdAt;

  SubtaskFile({
    required this.id,
    required this.subtaskId,
    required this.title,
    required this.urlFile,
    required this.status,
    required this.createdAt,
  });

  factory SubtaskFile.fromJson(Map<String, dynamic> json) {
    return SubtaskFile(
      id: json['id'],
      subtaskId: json['subtaskId'],
      title: json['title'],
      urlFile: json['urlFile'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
