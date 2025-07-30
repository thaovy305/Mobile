import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../Helper/UriHelper.dart';
import '../Models/WorkItem.dart';
import 'WorkItemCardDetailed.dart';
import '../WorkItem/EpicDetailPage.dart';
import '../WorkItem/SubtaskDetailPage.dart';
import '../WorkItem/TaskDetailPage.dart';

class WorkItemDetailed extends StatefulWidget {
  const WorkItemDetailed({super.key});

  @override
  State<WorkItemDetailed> createState() => _WorkItemDetailedState();
}

class _WorkItemDetailedState extends State<WorkItemDetailed> {
  List<WorkItem> workItems = [];
  bool isLoading = true;
  String? errorMessage;
  int accountId = 0;

  @override
  void initState() {
    super.initState();
    _loadAccountId();
  }

  Future<void> _loadAccountId() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';
    setState(() {
      accountId = prefs.getInt('accountId') ?? 0;
      isLoading = email.isNotEmpty;
    });
    if (email.isNotEmpty && accountId != 0) {
      await fetchWorkItems(accountId);
    } else {
      setState(() {
        isLoading = false;
        errorMessage = 'No account ID found or user not logged in';
      });
    }
  }

  Future<void> fetchWorkItems(int accountId) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final uri = UriHelper.build('/account/$accountId/workitem');
      print('Fetching work items from: $uri');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
      );
      print('Response status: ${response.statusCode}, body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        print('Parsed JSON: $jsonBody');
        if (jsonBody['isSuccess'] == true) {
          final data = jsonBody['data'] as Map<String, dynamic>;
          final workItemsJson = data['workItems'] as List<dynamic>?;
          setState(() {
            workItems = workItemsJson != null
                ? workItemsJson.map((itemJson) {
              print('Parsing work item: $itemJson');
              return WorkItem.fromJson(itemJson);
            }).toList()
                : [];
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = jsonBody['message'] ?? 'Failed to load work items';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Server error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('Error: $e\nStackTrace: $stackTrace');
      setState(() {
        errorMessage = 'Network error: $e';
        isLoading = false;
      });
    }
  }

  // Group work items by time period
  Map<String, List<WorkItem>> groupWorkItemsByTimePeriod() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfMonth = DateTime(now.year, now.month, 1);
    final thisWeek = <WorkItem>[];
    final thisMonth = <WorkItem>[];
    final previousMonths = <WorkItem>[];

    for (var item in workItems) {
      final createdAt = DateTime.parse(item.createdAt);
      if (createdAt.isAfter(startOfWeek) || createdAt.isAtSameMomentAs(startOfWeek)) {
        thisWeek.add(item);
      } else if (createdAt.isAfter(startOfMonth) ||
          createdAt.isAtSameMomentAs(startOfMonth)) {
        thisMonth.add(item);
      } else {
        previousMonths.add(item);
      }
    }

    return {
      'This Week': thisWeek,
      'This Month': thisMonth,
      'Previous Months': previousMonths,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        body: Center(child: Text(errorMessage!)),
      );
    }

    if (workItems.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No work items found')),
      );
    }

    final groupedItems = groupWorkItemsByTimePeriod();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          children: [
            // This Week Section
            if (groupedItems['This Week']!.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Text(
                  'This Week',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ),
              ...groupedItems['This Week']!.map((item) => WorkItemCardDetailed(
                id: item.key,
                title: item.summary.isEmpty ? 'No summary' : item.summary,
                status: item.status.isEmpty ? 'Unknown' : item.status,
                type: item.type.isEmpty ? 'Unknown' : item.type,
                onTap: () {
                  Widget detailPage;
                  switch (item.type.isEmpty ? 'TASK' : item.type) {
                    case 'TASK':
                      detailPage = TaskDetailPage(taskId: item.key);
                      break;
                    case 'EPIC':
                      detailPage = EpicDetailPage(epicId: item.key);
                      break;
                    case 'SUBTASK':
                    case 'SUBSTACK':
                      detailPage = SubtaskDetailPage(subtaskId: item.key);
                      break;
                    default:
                      detailPage = TaskDetailPage(taskId: item.key);
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => detailPage),
                  );
                },
              )),
            ],
            // This Month Section
            if (groupedItems['This Month']!.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Text(
                  'This Month',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ),
              ...groupedItems['This Month']!.map((item) => WorkItemCardDetailed(
                id: item.key,
                title: item.summary.isEmpty ? 'No summary' : item.summary,
                status: item.status.isEmpty ? 'Unknown' : item.status,
                type: item.type.isEmpty ? 'Unknown' : item.type,
                onTap: () {
                  Widget detailPage;
                  switch (item.type.isEmpty ? 'TASK' : item.type) {
                    case 'TASK':
                      detailPage = TaskDetailPage(taskId: item.key);
                      break;
                    case 'EPIC':
                      detailPage = EpicDetailPage(epicId: item.key);
                      break;
                    case 'SUBTASK':
                    case 'SUBSTACK':
                      detailPage = SubtaskDetailPage(subtaskId: item.key);
                      break;
                    default:
                      detailPage = TaskDetailPage(taskId: item.key);
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => detailPage),
                  );
                },
              )),
            ],
            // Previous Months Section
            if (groupedItems['Previous Months']!.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Text(
                  'Previous Months',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ),
              ...groupedItems['Previous Months']!.map((item) => WorkItemCardDetailed(
                id: item.key,
                title: item.summary.isEmpty ? 'No summary' : item.summary,
                status: item.status.isEmpty ? 'Unknown' : item.status,
                type: item.type.isEmpty ? 'Unknown' : item.type,
                onTap: () {
                  Widget detailPage;
                  switch (item.type.isEmpty ? 'TASK' : item.type) {
                    case 'TASK':
                      detailPage = TaskDetailPage(taskId: item.key);
                      break;
                    case 'EPIC':
                      detailPage = EpicDetailPage(epicId: item.key);
                      break;
                    case 'SUBTASK':
                    case 'SUBSTACK':
                      detailPage = SubtaskDetailPage(subtaskId: item.key);
                      break;
                    default:
                      detailPage = TaskDetailPage(taskId: item.key);
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => detailPage),
                  );
                },
              )),
            ],
          ],
        ),
      ),
    );
  }
}