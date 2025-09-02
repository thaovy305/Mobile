// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../Models/MeetingModel.dart';
// import '../Meeting/WeeklyMeetingCalendar.dart';
// import '../Helper/UriHelper.dart';

// class MeetingPage extends StatefulWidget {
//   @override
//   State<MeetingPage> createState() => _MeetingPageState();
// }

// class _MeetingPageState extends State<MeetingPage> {
//   late Future<List<Meeting>> _futureMeetings;

//   @override
//   void initState() {
//     super.initState();
//     _loadAndSetMeetings();
//   }

//   void _loadAndSetMeetings() {
//     setState(() {
//       _futureMeetings = _loadMeetings();
//     });
//   }

//   Future<List<Meeting>> _loadMeetings() async {
//     final prefs = await SharedPreferences.getInstance();
//     final accountId = prefs.getInt('accountId') ?? 2;

//     final meetingRes = await http.get(
//       UriHelper.build('/meetings/account/$accountId/schedule'),
//     );

//     if (meetingRes.statusCode != 200) {
//       throw Exception('Failed to load meetings');
//     }

//     final List<dynamic> meetingsJson = json.decode(meetingRes.body);

//     final meetings = await Future.wait(
//       meetingsJson.map((jsonMeeting) async {
//         int meetingId = jsonMeeting['id'];
//         String participantStatus = 'Not Registered';

//         try {
//           final participantRes = await http.get(
//             UriHelper.build('/meeting-participants/meeting/$meetingId'),
//           );

//           if (participantRes.statusCode == 200) {
//             final List<dynamic> participants = json.decode(participantRes.body);
//             final participant = participants.firstWhere(
//               (p) => p['accountId'] == accountId,
//               orElse: () => null,
//             );

//             if (participant != null) {
//               participantStatus = participant['status'] ?? 'Unknown';
//             }
//           }
//         } catch (_) {
//           participantStatus = 'Unknown';
//         }

//         return Meeting.fromJson(jsonMeeting, participantStatus);
//       }),
//     );

//     return meetings;
//   }

//   Future<void> _navigateAndReload(Widget page) async {
//     await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => page),
//     );
//     _loadAndSetMeetings();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Meeting Schedule'),
//         actions: [
//           IconButton(icon: Icon(Icons.refresh), onPressed: _loadAndSetMeetings),
//         ],
//       ),
//       body: FutureBuilder<List<Meeting>>(
//         future: _futureMeetings,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting)
//             return const Center(child: CircularProgressIndicator());
//           if (snapshot.hasError)
//             return Center(child: Text('Error: ${snapshot.error}'));

//           final meetings = snapshot.data!;
//           return WeeklyMeetingCalendar(meetings: meetings);
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/MeetingModel.dart';
import '../Meeting/WeeklyMeetingCalendar.dart';
import '../Meeting/MeetingService.dart';

class MeetingPage extends StatefulWidget {
  const MeetingPage({super.key});

  @override
  State<MeetingPage> createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage> {
  late Future<List<Meeting>> _futureMeetings;

  @override
  void initState() {
    super.initState();
    _reloadMeetings();
  }

  Future<void> _reloadMeetings() async {
    setState(() {
      _futureMeetings = _loadMeetings();
    });
  }

  Future<List<Meeting>> _loadMeetings() async {
    final prefs = await SharedPreferences.getInstance();
    final accountId = prefs.getInt('accountId') ?? 2;

    final list = await fetchMeetings(accountId);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return list.where((m) {
      final ms = (m.status ?? '').toUpperCase();
      if (ms == 'CANCELLED') return false;

      final end = m.endTime;
      final meetingDay = DateTime(end.year, end.month, end.day);
      final isActiveOutdated = (ms == 'ACTIVE') && meetingDay.isBefore(today);
      return !isActiveOutdated;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reloadMeetings,
            tooltip: 'Reload',
          ),
        ],
      ),
      body: FutureBuilder<List<Meeting>>(
        future: _futureMeetings,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          final meetings = snapshot.data ?? [];
          if (meetings.isEmpty) {
            return const Center(child: Text('No meetings found'));
          }
          return WeeklyMeetingCalendar(meetings: meetings);
        },
      ),
    );
  }
}
