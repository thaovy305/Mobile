// import 'package:flutter/material.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:intl/intl.dart';
// import '../Models/MeetingModel.dart';

// class WeeklyMeetingCalendar extends StatefulWidget {
//   final List<Meeting> meetings;
//   WeeklyMeetingCalendar({required this.meetings});

//   @override
//   State<WeeklyMeetingCalendar> createState() => _WeeklyMeetingCalendarState();
// }

// class _WeeklyMeetingCalendarState extends State<WeeklyMeetingCalendar> {
//   DateTime _focusedDay = DateTime.now();

//   List<DateTime> _getWeekDays(DateTime focusedDay) {
//     final startOfWeek = focusedDay.subtract(
//       Duration(days: focusedDay.weekday - 1),
//     );
//     return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
//   }

//   List<Meeting> _getMeetingsForDay(DateTime day) {
//     return widget.meetings.where((meeting) {
//         // Ẩn meeting nếu đã qua và status vẫn là 'Active'
//         if (meeting.startTime.isBefore(DateTime.now()) &&
//             meeting.participantStatus == 'Active') {
//           return false;
//         }
//         return isSameDay(meeting.startTime, day);
//       }).toList()
//       ..sort((a, b) => a.startTime.compareTo(b.startTime));
//   }

//   Color _getStatusColor(String status) {
//     switch (status) {
//       case 'Present':
//         return Colors.green;
//       case 'Absent':
//         return Colors.red;
//       case 'Active':
//       default:
//         return Colors.grey;
//     }
//   }

//   Widget buildWeekView(List<Meeting> meetings, DateTime weekFocusDay) {
//     final weekDays = _getWeekDays(weekFocusDay);

//     return ListView.builder(
//       itemCount: weekDays.length,
//       itemBuilder: (context, index) {
//         final day = weekDays[index];
//         final dayMeetings = _getMeetingsForDay(day);

//         return Container(
//           margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.1),
//                 blurRadius: 6,
//                 offset: Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 '${DateFormat.E().format(day)}\n${DateFormat.yMMMd().format(day)}',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 8),
//               if (dayMeetings.isEmpty)
//                 const Text('No meetings', style: TextStyle(color: Colors.grey))
//               else
//                 ...dayMeetings.map(
//                   (meeting) => GestureDetector(
//                     child: Container(
//                       margin: const EdgeInsets.only(bottom: 10),
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: Colors.blue[50],
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             meeting.meetingTopic,
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             '${DateFormat.Hm().format(meeting.startTime)} - ${DateFormat.Hm().format(meeting.endTime)}',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey[800],
//                             ),
//                           ),
//                           Row(
//                             children: [
//                               CircleAvatar(
//                                 radius: 4,
//                                 backgroundColor: _getStatusColor(
//                                   meeting.participantStatus,
//                                 ),
//                               ),
//                               const SizedBox(width: 4),
//                               Text(
//                                 meeting.participantStatus,
//                                 style: TextStyle(fontSize: 11),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   DateTime _selectedDay = DateTime.now();

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         // Calendar hiển thị theo tuần
//         TableCalendar(
//           focusedDay: _focusedDay,
//           firstDay: DateTime(2020),
//           lastDay: DateTime(2030),
//           calendarFormat: CalendarFormat.week,
//           headerStyle: HeaderStyle(formatButtonVisible: false),
//           onPageChanged: (focusedDay) {
//             setState(() {
//               _focusedDay = focusedDay;
//             });
//           },
//           calendarStyle: CalendarStyle(
//             todayDecoration: BoxDecoration(
//               color: Colors.blue,
//               shape: BoxShape.circle,
//             ),
//             selectedDecoration: BoxDecoration(
//               color: Colors.orange,
//               shape: BoxShape.circle,
//             ),
//           ),
//           selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
//           onDaySelected: (selectedDay, focusedDay) {
//             setState(() {
//               _selectedDay = selectedDay;
//               _focusedDay = focusedDay;
//             });
//           },
//         ),

//         // Nút "Today"
//         Align(
//           alignment: Alignment.centerRight,
//           child: TextButton(
//             onPressed: () {
//               setState(() {
//                 _focusedDay = DateTime.now();
//                 _selectedDay = DateTime.now();
//               });
//             },
//             child: const Text("Today"),
//           ),
//         ),

//         // Khoảng cách
//         const SizedBox(height: 8),

//         // 👉 Legend (giải thích màu trạng thái)
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8.0),
//           child: Wrap(
//             spacing: 16,
//             children: [
//               _buildLegend(Colors.green, 'Present'),
//               _buildLegend(Colors.grey, 'Upcoming'),
//               _buildLegend(Colors.red, 'Absent'),
//             ],
//           ),
//         ),

//         const Divider(),

//         // 👉 Hiển thị danh sách cuộc họp theo tuần
//         Expanded(child: buildWeekView(widget.meetings, _focusedDay)),
//       ],
//     );
//   }

//   Widget _buildLegend(Color color, String label) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         CircleAvatar(radius: 6, backgroundColor: color),
//         const SizedBox(width: 4),
//         Text(label),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart'; // để sử dụng Clipboard
import '../Models/MeetingModel.dart';

class WeeklyMeetingCalendar extends StatefulWidget {
  final List<Meeting> meetings;
  WeeklyMeetingCalendar({required this.meetings});

  @override
  State<WeeklyMeetingCalendar> createState() => _WeeklyMeetingCalendarState();
}

class _WeeklyMeetingCalendarState extends State<WeeklyMeetingCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  final ScrollController _scrollController = ScrollController();

  List<DateTime> _getWeekDays(DateTime focusedDay) {
    final startOfWeek = focusedDay.subtract(
      Duration(days: focusedDay.weekday - 1),
    );
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  List<Meeting> _getMeetingsForDay(DateTime day) {
    return widget.meetings.where((meeting) {
        if (meeting.startTime.isBefore(DateTime.now()) &&
            meeting.participantStatus == 'Active') {
          return false;
        }
        return isSameDay(meeting.startTime, day);
      }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Present':
        return Colors.green;
      case 'Absent':
        return Colors.red;
      case 'Active':
      default:
        return Colors.grey;
    }
  }

  void _scrollToDay(DateTime day) {
    final index = day.weekday - 1;
    final itemHeight = 140.0;
    _scrollController.animateTo(
      index * itemHeight,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _copyMeetingLink(String link) {
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Copied meeting link to clipboard')));
  }

  Widget buildWeekView(List<Meeting> meetings, DateTime weekFocusDay) {
    final weekDays = _getWeekDays(weekFocusDay);

    return ListView.builder(
      controller: _scrollController,
      itemCount: weekDays.length,
      itemBuilder: (context, index) {
        final day = weekDays[index];
        final dayMeetings = _getMeetingsForDay(day);
        final isToday = isSameDay(day, DateTime.now());

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isToday ? Colors.yellow[100] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${DateFormat.E().format(day)}\n${DateFormat.yMMMd().format(day)}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (dayMeetings.isEmpty)
                const Text('No meetings', style: TextStyle(color: Colors.grey))
              else
                ...dayMeetings.map(
                  (meeting) => GestureDetector(
                    onTap: () => _copyMeetingLink(meeting.meetingUrl),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meeting.meetingTopic,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${DateFormat.Hm().format(meeting.startTime)} - ${DateFormat.Hm().format(meeting.endTime)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[800],
                            ),
                          ),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 4,
                                backgroundColor: _getStatusColor(
                                  meeting.participantStatus,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                meeting.participantStatus,
                                style: TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          focusedDay: _focusedDay,
          firstDay: DateTime(2020),
          lastDay: DateTime(2030),
          calendarFormat: CalendarFormat.week,
          headerStyle: HeaderStyle(formatButtonVisible: false),
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            Future.delayed(Duration(milliseconds: 300), () {
              _scrollToDay(selectedDay);
            });
          },
          onPageChanged: (focusedDay) {
            setState(() {
              _focusedDay = focusedDay;
            });
          },
        ),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
              Future.delayed(Duration(milliseconds: 300), () {
                _scrollToDay(DateTime.now());
              });
            },
            child: const Text("Today"),
          ),
        ),

        const SizedBox(height: 8),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Wrap(
            spacing: 16,
            children: [
              _buildLegend(Colors.green, 'Present'),
              _buildLegend(Colors.grey, 'Upcoming'),
              _buildLegend(Colors.red, 'Absent'),
            ],
          ),
        ),

        const Divider(),

        Expanded(child: buildWeekView(widget.meetings, _focusedDay)),
      ],
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(radius: 6, backgroundColor: color),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}
