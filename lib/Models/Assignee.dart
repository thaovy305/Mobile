class Assignee {
  final int accountId;
  final String fullname;
  final String? picture;

  Assignee({
    required this.accountId,
    required this.fullname,
    this.picture
  });

  factory Assignee.fromJson(Map<String, dynamic> json) {
    return Assignee(
      accountId: json['accountId'] as int,
      fullname: json['fullname'] as String,
      picture: json['picture'] as String?,
    );
  }
}