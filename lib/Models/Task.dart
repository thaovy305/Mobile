class Task {
  final String id;
  final String title;
  final String? description;
  final String? reporterName;
  final String? reporterPicture;
  final String? status;
  final String? type;
  final String? sprintName;
  final String? plannedStartDate;
  final String? plannedEndDate;
  final String? createdAt;
  final String? updatedAt;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.reporterName,
    this.reporterPicture,
    this.status,
    this.type,
    this.sprintName,
    this.plannedStartDate,
    this.plannedEndDate,
    this.createdAt,
    this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      reporterName: json['reporterName'],
      reporterPicture: json['reporterPicture'],
      status: json['status'],
      type: json['type'],
      sprintName: json['sprintName'],
      plannedStartDate: json['plannedStartDate'],
      plannedEndDate: json['plannedEndDate'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
