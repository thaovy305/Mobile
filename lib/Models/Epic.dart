class Epic {
  final String id;
  final int projectId;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String reporterFullname;
  final String reporterPicture;
  final String assignedByFullname;
  final String assignedByPicture;
  final String sprintName;
  final String sprintGoal;

  Epic({
    required this.id,
    required this.projectId,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.reporterFullname,
    required this.reporterPicture,
    required this.assignedByFullname,
    required this.assignedByPicture,
    required this.sprintName,
    required this.sprintGoal,
  });

  factory Epic.fromJson(Map<String, dynamic> json) {
    return Epic(
      id: json['id'],
      projectId: json['projectId'],
      name: json['name'],
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      status: json['status'],
      reporterFullname: json['reporterFullname'],
      reporterPicture: json['reporterPicture'],
      assignedByFullname: json['assignedByFullname'],
      assignedByPicture: json['assignedByPicture'],
      sprintName: json['sprintName'],
      sprintGoal: json['sprintGoal'],
    );
  }
}
