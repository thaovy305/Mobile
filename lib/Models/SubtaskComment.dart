class SubtaskComment {
  final int id;
  final String subtaskId;
  final int accountId;
  final String accountName;
  final String accountPicture;
  final String content;
  final String createdAt;

  SubtaskComment({
    required this.id,
    required this.subtaskId,
    required this.accountId,
    required this.accountName,
    required this.accountPicture,
    required this.content,
    required this.createdAt,
  });

  factory SubtaskComment.fromJson(Map<String, dynamic> json) {
    return SubtaskComment(
      id: json['id'] ?? 0,
      subtaskId: json['subtaskId'] ?? '',
      accountId: json['accountId'] ?? 0,
      accountName: json['accountName'] ?? 'Unknown',
      accountPicture: json['accountPicture'] ?? 'None',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subtaskId': subtaskId,
      'accountId': accountId,
      'accountName': accountName,
      'accountPicture': accountPicture,
      'content': content,
      'createdAt': createdAt,
    };
  }
}
