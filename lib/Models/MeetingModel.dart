// class Meeting {
//   final int id;
//   final String meetingTopic;
//   final DateTime startTime;
//   final DateTime endTime;
//   final String meetingUrl;
//   final String status;
//   final int attendees;
//   final String? projectName;
//   final String participantStatus;

//   Meeting({
//     required this.id,
//     required this.meetingTopic,
//     required this.startTime,
//     required this.endTime,
//     required this.meetingUrl,
//     required this.status,
//     required this.attendees,
//     required this.projectName,
//     required this.participantStatus,
//   });

//   factory Meeting.fromJson(
//     Map<String, dynamic> json,
//     String participantStatus,
//   ) {
//     return Meeting(
//       id: json['id'],
//       meetingTopic: json['meetingTopic'],
//       startTime: DateTime.parse(json['startTime']),
//       endTime: DateTime.parse(json['endTime']),
//       meetingUrl: json['meetingUrl'],
//       status: json['status'],
//       attendees: json['attendees'],
//       projectName: json['projectName'],
//       participantStatus: participantStatus,
//     );
//   }
// }
import 'package:flutter/foundation.dart';

@immutable
class Meeting {
  final int id;
  final String meetingTopic;
  final DateTime startTime;
  final DateTime endTime;
  final String meetingUrl;
  final String? status; // Meeting status (ACTIVE, CANCELLED...)
  final String? participantStatus; // Present / Absent / Active
  final String? projectName;
  final int? attendees;

  const Meeting({
    required this.id,
    required this.meetingTopic,
    required this.startTime,
    required this.endTime,
    required this.meetingUrl,
    this.status,
    this.participantStatus,
    this.projectName,
    this.attendees,
  });

  /// Parse JSON từ API, participantStatus truyền ngoài vào
  factory Meeting.fromJson(dynamic raw, String participantStatus) {
    final int id =
        (raw['id'] ?? raw['meetingId']) is String
            ? int.tryParse(raw['id'] ?? raw['meetingId']) ?? 0
            : (raw['id'] ?? raw['meetingId'] ?? 0) as int;

    final topic = (raw['meetingTopic'] ?? raw['title'] ?? '').toString();

    final startIso = (raw['startTime'] ?? raw['start'] ?? '').toString();
    final endIso = (raw['endTime'] ?? raw['end'] ?? '').toString();

    final start = DateTime.tryParse(startIso);
    final end = DateTime.tryParse(endIso);

    final safeStart = start ?? DateTime.now();
    final safeEnd =
        (end != null && end.isAfter(safeStart))
            ? end
            : safeStart.add(const Duration(hours: 1));

    return Meeting(
      id: id,
      meetingTopic: topic.isEmpty ? 'Untitled meeting' : topic,
      startTime: safeStart.toLocal(),
      endTime: safeEnd.toLocal(),
      meetingUrl: (raw['meetingUrl'] ?? raw['roomUrl'] ?? '').toString(),
      status: (raw['status'] ?? raw['meetingStatus'])?.toString(),
      participantStatus: participantStatus,
      projectName:
          (raw['projectName'] ?? '').toString().isEmpty
              ? null
              : raw['projectName'].toString(),
      attendees: raw['attendees'] is int ? raw['attendees'] as int : null,
    );
  }
}
