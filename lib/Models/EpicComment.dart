class EpicComment {
  final int id;
  final String epicId;
  final int accountId;
  final String accountName;
  final String accountPicture;
  final String content;
  final String createdAt;

  EpicComment({
    required this.id,
    required this.epicId,
    required this.accountId,
    required this.accountName,
    required this.accountPicture,
    required this.content,
    required this.createdAt,
  });

  factory EpicComment.fromJson(Map<String, dynamic> json) {
    return EpicComment(
      id: json['id'] ?? 0,
      epicId: json['epicId'] ?? '',
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
      'epicId': epicId,
      'accountId': accountId,
      'accountName': accountName,
      'accountPicture': accountPicture,
      'content': content,
      'createdAt': createdAt,
    };
  }
}
