class Meeting {
  final int id;
  final String meetingTopic;
  final DateTime startTime;
  final DateTime endTime;
  final String meetingUrl;
  final String status;
  final int attendees;
  final String? projectName;
  final String participantStatus;

  Meeting({
    required this.id,
    required this.meetingTopic,
    required this.startTime,
    required this.endTime,
    required this.meetingUrl,
    required this.status,
    required this.attendees,
    required this.projectName,
    required this.participantStatus,
  });

  factory Meeting.fromJson(
    Map<String, dynamic> json,
    String participantStatus,
  ) {
    return Meeting(
      id: json['id'],
      meetingTopic: json['meetingTopic'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      meetingUrl: json['meetingUrl'],
      status: json['status'],
      attendees: json['attendees'],
      projectName: json['projectName'],
      participantStatus: participantStatus,
    );
  }
}
