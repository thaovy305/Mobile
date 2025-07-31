import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../Helper/UriHelper.dart';
import '../Models/NotificationModel.dart';
import '../Models/RecipientNotification.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'EpicDetailPage.dart';
import 'SubtaskDetailPage.dart';
import 'TaskDetailPage.dart';

class NotificationPage extends StatefulWidget {
  final Function(int)? onUnreadCountChanged;
  const NotificationPage({Key? key, this.onUnreadCountChanged}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<RecipientNotification> _recipientNotifications = [];
  bool _isLoading = true;
  int _accountId = 0;
  List<NotificationModel> _notifications = [];
  int currentIndex = 4;

  @override
  void initState() {
    super.initState();
    _loadAccountAndFetchNotifications();
  }

  Future<void> _loadAccountAndFetchNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    _accountId = prefs.getInt('accountId') ?? 0;
    await _fetchRecipientNotifications();
    await _fetchNotifications();
  }

  Future<void> _fetchRecipientNotifications() async {
    final url = UriHelper.build('/recipientnotification/account/$_accountId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final data = decoded['data'] as List;
      setState(() {
        _recipientNotifications =
            data.map((json) => RecipientNotification.fromJson(json)).toList();
      });
      final unread = _recipientNotifications.where((n) => !n.isRead).length;
      if (widget.onUnreadCountChanged != null) {
        widget.onUnreadCountChanged!(unread);
      }
    } else {
      print('Failed to load recipient notifications');
    }
  }

  Future<void> _fetchNotifications() async {
    final url = UriHelper.build('/notification');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final data = decoded['data'] as List;
      setState(() {
        _notifications =
            data.map((json) => NotificationModel.fromJson(json)).toList();
        _isLoading = false;
      });
    } else {
      print('Failed to load notifications');
    }
  }

  NotificationModel? _findNotificationById(int id) {
    return _notifications.firstWhere(
          (n) => n.id == id,
      orElse: () => NotificationModel(
        id: id,
        createdBy: 0,
        createdByName: "Unknown",
        type: "",
        priority: "",
        message: "",
        relatedEntityType: "",
        relatedEntityId: 0,
        createdAt: DateTime.now(),
        isRead: false,
      ),
    );
  }

  Future<void> _markAsRead(int notificationId) async {
    final url = UriHelper.build(
        '/recipientnotification/mark-as-read?accountId=$_accountId&notificationId=$notificationId');
    final response = await http.put(url);
    if (response.statusCode == 200) {
      await _fetchRecipientNotifications();
      setState(() {});
    } else {
      print('Failed to mark as read');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _recipientNotifications.length,
        itemBuilder: (context, index) {
          final recipient = _recipientNotifications[index];
          final noti = _findNotificationById(recipient.notificationId);

          final message = recipient.notificationMessage;
          final taskMatch = RegExp(r'task (\w+-\d+)', caseSensitive: false)
              .firstMatch(message);
          final subtaskMatch =
          RegExp(r'subtask (\w+-\d+)', caseSensitive: false)
              .firstMatch(message);
          final epicMatch = RegExp(r'epic (\w+-\d+)', caseSensitive: false)
              .firstMatch(message);

          final isRead = recipient.isRead;
          final textStyle = TextStyle(
            fontWeight:
            isRead ? FontWeight.normal : FontWeight.bold,
            color: isRead ? Colors.grey[700] : Colors.black,
          );

          return ListTile(
            onTap: () async {
              if (!isRead) {
                await _markAsRead(recipient.notificationId);
              }

              if (subtaskMatch != null) {
                final subtaskId = subtaskMatch.group(1)!;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SubtaskDetailPage(subtaskId: subtaskId),
                  ),
                );
              } else if (taskMatch != null) {
                final taskId = taskMatch.group(1)!;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TaskDetailPage(taskId: taskId),
                  ),
                );
              } else if (epicMatch != null) {
                final epicId = epicMatch.group(1)!;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EpicDetailPage(epicId: epicId),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed'),
                  ),
                );
              }
            },
            leading: Icon(
              isRead
                  ? Icons.notifications_none
                  : Icons.notifications_active,
              color: isRead ? Colors.grey : Colors.blue,
            ),
            title: Text(
              noti?.createdByName ?? 'Unknown',
              style: textStyle,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipient.notificationMessage,
                  style: textStyle,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm')
                      .format(recipient.createdAt),
                  style: TextStyle(
                      color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
