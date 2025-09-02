// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../Helper/UriHelper.dart';
// import '../Models/MeetingModel.dart';

// Future<List<Meeting>> fetchMeetings(int accountId) async {
//   final scheduleRes = await http.get(
//     UriHelper.build('/meetings/account/$accountId/schedule'),
//   );

//   final participantRes = await http.get(
//     UriHelper.build('/meeting-participants/$accountId'),
//   );

//   if (scheduleRes.statusCode == 200 && participantRes.statusCode == 200) {
//     final scheduleJson = jsonDecode(scheduleRes.body);
//     final participantJson = jsonDecode(participantRes.body);

//     final List<dynamic> scheduleList =
//         scheduleJson is List
//             ? scheduleJson
//             : (scheduleJson['data'] ?? []) as List<dynamic>;

//     final List<dynamic> participantList =
//         participantJson is List
//             ? participantJson
//             : (participantJson['data'] ?? []) as List<dynamic>;

//     return scheduleList.where((m) => m['status'] != 'CANCELLED').map((meeting) {
//       final matchedParticipant = participantList.firstWhere(
//         (p) => p['meetingId'] == meeting['id'],
//         orElse: () => {'status': 'Active'},
//       );

//       return Meeting.fromJson(meeting, matchedParticipant['status']);
//     }).toList();
//   } else {
//     throw Exception('Failed to fetch data');
//   }
// }
// lib/Meeting/MeetingService.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Helper/UriHelper.dart';
import '../Models/MeetingModel.dart';

Future<Map<String, String>> _authHeaders() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken') ?? '';
  return {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
    'Accept': '*/*',
  };
}

/// Lấy lịch họp + merge participantStatus cho account hiện tại
Future<List<Meeting>> fetchMeetings(int accountId) async {
  final headers = await _authHeaders();

  // 1) Lấy danh sách meeting theo account
  final scheduleRes = await http.get(
    UriHelper.build('/meetings/account/$accountId/schedule'),
    headers: headers,
  );
  if (scheduleRes.statusCode != 200) {
    throw Exception('Failed to fetch schedule: ${scheduleRes.statusCode}');
  }

  final scheduleJson = jsonDecode(scheduleRes.body);
  final List<dynamic> scheduleList =
      scheduleJson is List ? scheduleJson : (scheduleJson['data'] ?? []);

  Meeting mapMeeting(dynamic m, String participantStatus) {
    return Meeting.fromJson(m, participantStatus);
  }

  // 2) Thử endpoint participants theo account
  List<dynamic> participantList = const [];
  bool usedAccountEndpoint = false;

  try {
    final participantRes = await http.get(
      UriHelper.build('/meeting-participants/$accountId'),
      headers: headers,
    );

    if (participantRes.statusCode == 200) {
      final participantJson = jsonDecode(participantRes.body);
      participantList =
          participantJson is List
              ? participantJson
              : (participantJson['data'] ?? []);
      usedAccountEndpoint = true;
    }
  } catch (_) {
    usedAccountEndpoint = false;
  }

  // 3) Merge
  if (usedAccountEndpoint) {
    return scheduleList.map<Meeting>((m) {
      final matched = participantList.firstWhere(
        (p) => p['meetingId'] == m['id'],
        orElse: () => {'status': 'Active'},
      );
      final ps = (matched['status'] ?? 'Active') as String;
      return mapMeeting(m, ps);
    }).toList();
  } else {
    final meetings = <Meeting>[];
    for (final m in scheduleList) {
      String participantStatus = 'Active';
      try {
        final meetingId = m['id'];
        final res = await http.get(
          UriHelper.build('/meeting-participants/meeting/$meetingId'),
          headers: headers,
        );
        if (res.statusCode == 200) {
          final List<dynamic> participants = jsonDecode(res.body);
          final current = participants.firstWhere(
            (p) => p['accountId'] == accountId,
            orElse: () => null,
          );
          if (current != null) {
            participantStatus = (current['status'] ?? 'Active') as String;
          }
        }
      } catch (_) {}
      meetings.add(mapMeeting(m, participantStatus));
    }
    return meetings;
  }
}
