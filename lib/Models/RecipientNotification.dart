class RecipientNotification {
  final int notificationId;
  final String accountName;
  final String notificationMessage;
  final String? status;
  final bool isRead;
  final DateTime createdAt;

  RecipientNotification({
    required this.notificationId,
    required this.accountName,
    required this.notificationMessage,
    required this.status,
    required this.isRead,
    required this.createdAt,
  });

  factory RecipientNotification.fromJson(Map<String, dynamic> json) {
    return RecipientNotification(
      notificationId: json['notificationId'],
      accountName: json['accountName'] ?? '',
      notificationMessage: json['notificationMessage'] ?? '',
      status: json['status'],
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}