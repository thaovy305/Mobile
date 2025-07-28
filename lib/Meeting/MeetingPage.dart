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
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _refreshMeetings(); // Gọi lại khi mở lại trang
//   }

//   void _refreshMeetings() {
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
//     List<Meeting> meetings = [];

//     for (var jsonMeeting in meetingsJson) {
//       int meetingId = jsonMeeting['id'];
//       String participantStatus = 'Not Registered';

//       try {
//         final participantRes = await http.get(
//           UriHelper.build('/meeting-participants/meeting/$meetingId'),
//         );

//         if (participantRes.statusCode == 200) {
//           final List<dynamic> participants = json.decode(participantRes.body);
//           final participant = participants.firstWhere(
//             (p) => p['accountId'] == accountId,
//             orElse: () => null,
//           );

//           if (participant != null) {
//             participantStatus = participant['status'] ?? 'Unknown';
//           }
//         }
//       } catch (_) {
//         participantStatus = 'Unknown';
//       }

//       meetings.add(Meeting.fromJson(jsonMeeting, participantStatus));
//     }

//     return meetings;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('My Meeting Schedule')),
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

// class _MeetingPageState extends State<MeetingPage> with WidgetsBindingObserver {
//   late Future<List<Meeting>> _futureMeetings;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this); // 👀 theo dõi lifecycle
//     _futureMeetings = _loadMeetings(); // Tải dữ liệu ban đầu
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       // Khi quay lại app, reload dữ liệu
//       _refreshMeetings();
//     }
//   }

//   void _refreshMeetings() {
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
//     List<Meeting> meetings = [];

//     for (var jsonMeeting in meetingsJson) {
//       int meetingId = jsonMeeting['id'];
//       String participantStatus = 'Not Registered';

//       try {
//         final participantRes = await http.get(
//           UriHelper.build('/meeting-participants/meeting/$meetingId'),
//         );

//         if (participantRes.statusCode == 200) {
//           final List<dynamic> participants = json.decode(participantRes.body);
//           final participant = participants.firstWhere(
//             (p) => p['accountId'] == accountId,
//             orElse: () => null,
//           );

//           if (participant != null) {
//             participantStatus = participant['status'] ?? 'Unknown';
//           }
//         }
//       } catch (_) {
//         participantStatus = 'Unknown';
//       }

//       meetings.add(Meeting.fromJson(jsonMeeting, participantStatus));
//     }

//     return meetings;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Meeting Schedule')),
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
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/MeetingModel.dart';
import '../Meeting/WeeklyMeetingCalendar.dart';
import '../Helper/UriHelper.dart';

class MeetingPage extends StatefulWidget {
  @override
  State<MeetingPage> createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage> {
  late Future<List<Meeting>> _futureMeetings;

  @override
  void initState() {
    super.initState();
    _loadAndSetMeetings();
  }

  void _loadAndSetMeetings() {
    setState(() {
      _futureMeetings = _loadMeetings();
    });
  }

  Future<List<Meeting>> _loadMeetings() async {
    final prefs = await SharedPreferences.getInstance();
    final accountId = prefs.getInt('accountId') ?? 2;

    final meetingRes = await http.get(
      UriHelper.build('/meetings/account/$accountId/schedule'),
    );

    if (meetingRes.statusCode != 200) {
      throw Exception('Failed to load meetings');
    }

    final List<dynamic> meetingsJson = json.decode(meetingRes.body);
    List<Meeting> meetings = [];

    for (var jsonMeeting in meetingsJson) {
      int meetingId = jsonMeeting['id'];
      String participantStatus = 'Not Registered';

      try {
        final participantRes = await http.get(
          UriHelper.build('/meeting-participants/meeting/$meetingId'),
        );

        if (participantRes.statusCode == 200) {
          final List<dynamic> participants = json.decode(participantRes.body);
          final participant = participants.firstWhere(
            (p) => p['accountId'] == accountId,
            orElse: () => null,
          );

          if (participant != null) {
            participantStatus = participant['status'] ?? 'Unknown';
          }
        }
      } catch (_) {
        participantStatus = 'Unknown';
      }

      meetings.add(Meeting.fromJson(jsonMeeting, participantStatus));
    }

    return meetings;
  }

  // 🎯 Gọi hàm này khi push sang trang tạo mới
  Future<void> _navigateAndReload(Widget page) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
    _loadAndSetMeetings(); // ⬅️ Tải lại dữ liệu sau khi trở lại
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting Schedule'),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadAndSetMeetings),
        ],
      ),
      body: FutureBuilder<List<Meeting>>(
        future: _futureMeetings,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));

          final meetings = snapshot.data!;
          return WeeklyMeetingCalendar(meetings: meetings);
        },
      ),
    );
  }
}
