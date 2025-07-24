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
    final data = json['data'];
    return Task(
      id: data['id'],
      title: data['title'],
      description: data['description'],
      reporterName: data['reporterName'],
      reporterPicture: data['reporterPicture'],
      status: data['status'],
      type: data['type'],
      sprintName: data['sprintName'],
      plannedStartDate: data['plannedStartDate'],
      plannedEndDate: data['plannedEndDate'],
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
    );
  }
}
