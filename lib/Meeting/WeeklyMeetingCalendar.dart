import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../Models/MeetingModel.dart';

class WeeklyMeetingCalendar extends StatefulWidget {
  final List<Meeting> meetings;

  WeeklyMeetingCalendar({required this.meetings});

  @override
  State<WeeklyMeetingCalendar> createState() => _WeeklyMeetingCalendarState();
}

class _WeeklyMeetingCalendarState extends State<WeeklyMeetingCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<Meeting> _getMeetingsForDay(DateTime day) {
    return widget.meetings.where((meeting) {
        return isSameDay(meeting.startTime, day);
      }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime)); // Sort by time
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

  String _getTimeSlotLabel(DateTime startTime) {
    final hour = startTime.hour;
    if (hour < 12) return 'Morning';
    if (hour < 18) return 'Afternoon';
    return 'Buổi tối';
  }

  @override
  Widget build(BuildContext context) {
    final meetingsToday = _getMeetingsForDay(_selectedDay ?? _focusedDay);

    return Column(
      children: [
        TableCalendar(
          focusedDay: _focusedDay,
          firstDay: DateTime(2020),
          lastDay: DateTime(2030),
          calendarFormat: CalendarFormat.week,
          selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
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
        ),

        // 👉 Chú thích trạng thái
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Wrap(
            spacing: 16,
            children: [
              _buildLegend(Colors.green, 'Present'),
              _buildLegend(Colors.grey, 'Upcomming'),
              _buildLegend(Colors.red, 'Absent'),
            ],
          ),
        ),

        const Divider(),

        // const Text(
        //   'List of meetings for the day',
        //   style: TextStyle(fontWeight: FontWeight.bold),
        // ),
        // const SizedBox(height: 8),
        Expanded(
          child:
              meetingsToday.isEmpty
                  ? const Center(child: Text('There are no meetings'))
                  : ListView.builder(
                    itemCount: meetingsToday.length,
                    itemBuilder: (context, index) {
                      final meeting = meetingsToday[index];
                      final timeSlot = _getTimeSlotLabel(meeting.startTime);

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getStatusColor(
                              meeting.participantStatus,
                            ),
                          ),
                          title: Text(meeting.meetingTopic),
                          subtitle: Text(
                            '$timeSlot | '
                            '${meeting.startTime.hour.toString().padLeft(2, '0')}:${meeting.startTime.minute.toString().padLeft(2, '0')} - '
                            '${meeting.endTime.hour.toString().padLeft(2, '0')}:${meeting.endTime.minute.toString().padLeft(2, '0')}',
                          ),
                        ),
                      );
                    },
                  ),
        ),
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
