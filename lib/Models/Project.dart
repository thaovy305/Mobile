class Project {
  final int projectId;
  final String projectName;
  final String projectStatus;
  final String projectKey;
  final String? iconUrl;
  final DateTime? joinedAt;
  final DateTime invitedAt;
  final String? status;

  Project({
    required this.projectId,
    required this.projectName,
    required this.projectStatus,
    required this.projectKey,
    this.iconUrl,
    this.joinedAt,
    required this.invitedAt,
    this.status,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      projectId: json['projectId'] as int? ?? 0, // Giá trị mặc định nếu null
      projectName: json['projectName'] as String? ?? 'Unknown',
      projectStatus: json['projectStatus'] as String? ?? 'UNKNOWN',
      projectKey: json['projectKey'] as String? ?? 'NO_KEY',
      iconUrl: json['iconUrl'] as String?,
      joinedAt: json['joinedAt'] != null ? DateTime.tryParse(json['joinedAt'] as String) : null,
      invitedAt: DateTime.tryParse(json['invitedAt'] as String) ?? DateTime.now(),
      status: json['status'] as String?,
    );
  }
}