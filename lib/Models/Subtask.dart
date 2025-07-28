class Subtask {
  final String? id;
  final String? taskId;
  final int? assignedBy;
  final String? assignedByName;
  final String? assignedByPicture;
  final String? title;
  final String? description;
  final int? reporterId;
  final String? reporterName;
  final String? reporterPicture;
  String? status;
  final String? priority;
  final bool? manualInput;
  final bool? generationAiInput;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? createdBy;

  Subtask({
    this.id,
    this.taskId,
    this.assignedBy,
    this.assignedByName,
    this.title,
    this.description,
    this.reporterId,
    this.reporterName,
    this.reporterPicture,
    this.status,
    this.priority,
    this.manualInput,
    this.generationAiInput,
    this.createdAt,
    this.updatedAt,
    this.startDate,
    this.endDate,
    this.assignedByPicture,
    this.createdBy,
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
      createdBy: json['createdBy'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'assignedBy': assignedBy,
      'assignedByName': assignedByName,
      'assignedByPicture': assignedByPicture,
      'title': title,
      'description': description,
      'reporterId': reporterId,
      'reporterName': reporterName,
      'reporterPicture': reporterPicture,
      'status': status,
      'priority': priority,
      'manualInput': manualInput,
      'generationAiInput': generationAiInput,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'createdBy': createdBy,
    };
  }
}
