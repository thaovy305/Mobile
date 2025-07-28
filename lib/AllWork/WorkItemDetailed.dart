import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../Helper/UriHelper.dart';
import '../Models/WorkItem.dart';
import '../Models/Account.dart';
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
          final workItemsJson = data['workItems'] as List<dynamic>?; // Allow null
          setState(() {
            workItems = workItemsJson != null
                ? workItemsJson.map((itemJson) {
              print('Parsing work item: $itemJson');
              return WorkItem.fromJson(itemJson);
            }).toList()
                : []; // Default to empty list if null
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Work Item Detailed List'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : workItems.isEmpty
          ? const Center(child: Text('No work items found'))
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: workItems.length,
        itemBuilder: (context, index) {
          final item = workItems[index];
          return WorkItemCardDetailed(
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
          );
        },
      ),
    );
  }
}