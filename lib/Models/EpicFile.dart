class EpicFile {
  final int id;
  final String epicId;
  final String title;
  final String urlFile;
  final String status;
  final DateTime createdAt;

  EpicFile({
    required this.id,
    required this.epicId,
    required this.title,
    required this.urlFile,
    required this.status,
    required this.createdAt,
  });

  factory EpicFile.fromJson(Map<String, dynamic> json) {
    return EpicFile(
      id: json['id'],
      epicId: json['epicId'],
      title: json['title'],
      urlFile: json['urlFile'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
