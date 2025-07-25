class TaskAssignment {
final int id;
final String taskId;
final int accountId;
final String? status;
final DateTime? assignedAt;
final DateTime? completedAt;
final double? hourlyRate;
final String? accountFullname;
final String? accountPicture;

TaskAssignment({
required this.id,
required this.taskId,
required this.accountId,
this.status,
this.assignedAt,
this.completedAt,
this.hourlyRate,
this.accountFullname,
this.accountPicture,
});

factory TaskAssignment.fromJson(Map<String, dynamic> json) {
return TaskAssignment(
id: json['id'] as int,
taskId: json['taskId'] as String,
accountId: json['accountId'] as int,
status: json['status'] as String?,
assignedAt: json['assignedAt'] != null ? DateTime.parse(json['assignedAt']) : null,
completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
hourlyRate: json['hourlyRate'] as double?,
accountFullname: json['accountFullname'] as String?,
accountPicture: json['accountPicture'] as String?,
);
}

Map<String, dynamic> toJson() {
return {
'id': id,
'taskId': taskId,
'accountId': accountId,
'status': status,
'assignedAt': assignedAt?.toIso8601String(),
'completedAt': completedAt?.toIso8601String(),
'hourlyRate': hourlyRate,
'accountFullname': accountFullname,
'accountPicture': accountPicture,
};
}
}
