class Subtask {
  final String id;
  final String taskId;
  final int? assignedBy;
  final String? assignedByName;
  final String? assignedByPicture;
  final String title;
  final String? description;
  final int? reporterId;
  final String? reporterName;
  final String? reporterPicture;
  String status;
  final String priority;
  final bool? manualInput;
  final bool? generationAiInput;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? startDate;
  final DateTime? endDate;

  Subtask({
    required this.id,
    required this.taskId,
    required this.assignedBy,
    required this.assignedByName,
    required this.title,
    required this.description,
    this.reporterId,
    this.reporterName,
    this.reporterPicture,
    required this.status,
    required this.priority,
    required this.manualInput,
    required this.generationAiInput,
    required this.createdAt,
    required this.updatedAt,
    this.startDate,
    this.endDate,
    required this.assignedByPicture,
  });

  factory Subtask.fromJson(Map<String, dynamic> json) {
    return Subtask(
      id: json['id'],
      taskId: json['taskId'],
      assignedBy: json['assignedBy'],
      assignedByName: json['assignedByName'],
      assignedByPicture: json['assignedByPicture'],
      title: json['title'],
      description: json['description'],
      reporterId: json['reporterId'],
      reporterName: json['reporterName'],
      reporterPicture: json['reporterPicture'],
      status: json['status'],
      priority: json['priority'],
      manualInput: json['manualInput'],
      generationAiInput: json['generationAiInput'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      startDate: json['startDate'] != null ? DateTime.tryParse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate']) : null,
    );
  }
}
