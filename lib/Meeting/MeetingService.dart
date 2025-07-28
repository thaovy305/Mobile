import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Helper/UriHelper.dart';
import '../Models/MeetingModel.dart';

Future<List<Meeting>> fetchMeetings(int accountId) async {
  final scheduleRes = await http.get(
    UriHelper.build('/meetings/account/$accountId/schedule'),
  );

  final participantRes = await http.get(
    UriHelper.build('/meeting-participants/$accountId'),
  );

  if (scheduleRes.statusCode == 200 && participantRes.statusCode == 200) {
    final scheduleJson = jsonDecode(scheduleRes.body);
    final participantJson = jsonDecode(participantRes.body);

    final List<dynamic> scheduleList =
        scheduleJson is List
            ? scheduleJson
            : (scheduleJson['data'] ?? []) as List<dynamic>;

    final List<dynamic> participantList =
        participantJson is List
            ? participantJson
            : (participantJson['data'] ?? []) as List<dynamic>;

    return scheduleList.where((m) => m['status'] != 'CANCELLED').map((meeting) {
      final matchedParticipant = participantList.firstWhere(
        (p) => p['meetingId'] == meeting['id'],
        orElse: () => {'status': 'Active'},
      );

      return Meeting.fromJson(meeting, matchedParticipant['status']);
    }).toList();
  } else {
    throw Exception('Failed to fetch data');
  }
}
