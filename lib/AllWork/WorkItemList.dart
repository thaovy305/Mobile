import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../Helper/UriHelper.dart';
import '../Models/WorkItem.dart';
import 'WorkItemCardList.dart';
import '../WorkItem/EpicDetailPage.dart';
import '../WorkItem/SubtaskDetailPage.dart';
import '../WorkItem/TaskDetailPage.dart';

class WorkItemList extends StatefulWidget {
  const WorkItemList({super.key});

  @override
  State<WorkItemList> createState() => _WorkItemListState();
}

class _WorkItemListState extends State<WorkItemList> {
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

  Future<void> _refreshWorkItems() async {
    if (accountId != 0) {
      await fetchWorkItems(accountId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? Center(child: Text(errorMessage!))
            : workItems.isEmpty
            ? const Center(child: Text('No work items found'))
            : Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0), // loại bỏ khoảng cách dọc
              color: Colors.transparent,
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(1),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 12.0),
                        child: Text(
                          'Issue',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 12.0),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.start,
                          crossAxisAlignment:
                          CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Key',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const Spacer(),
                            PopupMenuButton<String>(
                              onSelected: (String value) {
                                setState(() {
                                  if (value == 'sort_status') {
                                    workItems.sort((a, b) =>
                                        a.status
                                            .compareTo(b.status));
                                  } else if (value == 'sort_date') {
                                    workItems.sort((a, b) => b
                                        .createdAt
                                        .compareTo(a.createdAt));
                                  }
                                });
                              },
                              itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                                const PopupMenuItem<String>(
                                  value: 'sort_status',
                                  child: Text('Sort by Status'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'sort_date',
                                  child: Text('Sort by Date'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Work items list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 0, top: 0), // Removed top padding
                itemCount: workItems.length,
                itemBuilder: (context, index) {
                  final item = workItems[index];
                  return WorkItemCardList(
                    id: item.key,
                    title: item.summary,
                    status: item.status,
                    type: item.type,
                    onTap: () {
                      Widget detailPage;
                      switch (item.type) {
                        case 'TASK':
                          detailPage =
                              TaskDetailPage(taskId: item.key);
                          break;
                        case 'EPIC':
                          detailPage =
                              EpicDetailPage(epicId: item.key);
                          break;
                        case 'SUBTASK':
                        case 'SUBSTACK':
                          detailPage = SubtaskDetailPage(
                              subtaskId: item.key);
                          break;
                        default:
                          detailPage =
                              TaskDetailPage(taskId: item.key);
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => detailPage),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}