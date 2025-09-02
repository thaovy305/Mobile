import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Helper/UriHelper.dart';
import '../../Models/Task.dart';
import 'KanbanColumn.dart';

class KanbanBoardMain extends StatefulWidget {
  final String projectKey;

  const KanbanBoardMain({super.key, required this.projectKey});

  @override
  State<KanbanBoardMain> createState() => _KanbanBoardMainState();
}

class _KanbanBoardMainState extends State<KanbanBoardMain> {
  int? activeSprintId;
  List<Map<String, dynamic>> taskStatuses = [];
  Map<String, List<Task>> tasksByStatus = {};
  Map<String, bool> isLoadingPerStatus = {};
  String? errorMessage;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _fetchInitialData();
    _pageController.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  Future<bool> validateCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';
    final token = prefs.getString('accessToken') ?? '';
    if (email.isEmpty || token.isEmpty) {
      setState(() {
        errorMessage = 'Credentials not found in preferences';
        isLoadingPerStatus.clear();
        taskStatuses = [];
        tasksByStatus = {};
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credentials not found in preferences')),
      );
      return false;
    }
    return true;
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      isLoadingPerStatus.clear();
      taskStatuses = [];
      tasksByStatus.clear();
      errorMessage = null;
    });
    await _fetchDataForStatus(null);
  }

  Future<void> _fetchDataForStatus(String? statusName) async {
    if (statusName != null) {
      setState(() {
        isLoadingPerStatus[statusName] = true;
      });
    }
    try {
      if (!await validateCredentials()) return;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';
      final sprintUri = UriHelper.build('/sprint/active-with-tasks/${widget.projectKey}');

      final sprintResponse = await http.get(
        sprintUri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
      );

      if (sprintResponse.statusCode != 200 || json.decode(sprintResponse.body)['isSuccess'] != true) {
        setState(() {
          errorMessage = 'No active sprint found';
          taskStatuses = [];
          tasksByStatus = {};
          if (statusName != null) isLoadingPerStatus[statusName] = false;
        });
        return;
      }

      final sprintData = json.decode(sprintResponse.body)['data'];
      final sprintId = sprintData['id'] as int?;

      if (sprintId == null) {
        setState(() {
          errorMessage = 'No active sprint found';
          taskStatuses = [];
          tasksByStatus = {};
          if (statusName != null) isLoadingPerStatus[statusName] = false;
        });
        return;
      }

      final statusUri = UriHelper.build('/dynamiccategory/by-category-group?categoryGroup=task_status');

      final statusResponse = await http.get(
        statusUri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
      );

      if (statusResponse.statusCode != 200 || json.decode(statusResponse.body)['isSuccess'] != true) {
        setState(() {
          errorMessage = 'Failed to load task statuses';
          taskStatuses = [];
          tasksByStatus = {};
          if (statusName != null) isLoadingPerStatus[statusName] = false;
        });
        return;
      }

      final statusData = json.decode(statusResponse.body)['data'] as List;

      Map<String, List<Task>> tasksByStatusTemp = {};
      for (var status in statusData) {
        final statusNameLoop = status['name'].toString();
        if (statusNameLoop != null && (statusName == statusNameLoop || statusName == null)) {
          final taskUri = UriHelper.build('/task/by-sprint-id/$sprintId/task-status?taskStatus=$statusNameLoop');

          final taskResponse = await http.get(
            taskUri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
              'Accept': '*/*',
            },
          );

          if (taskResponse.statusCode == 200 && json.decode(taskResponse.body)['isSuccess'] == true) {
            final tasksData = json.decode(taskResponse.body)['data'] as List;
            tasksByStatusTemp[statusNameLoop] = tasksData.map((task) => Task.fromJson(task)).toList();
          } else {
            tasksByStatusTemp[statusNameLoop] = [];
          }
        }
      }

      setState(() {
        activeSprintId = sprintId;
        taskStatuses = statusData.cast<Map<String, dynamic>>();
        tasksByStatus = tasksByStatusTemp;
        if (statusName != null) isLoadingPerStatus[statusName] = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        taskStatuses = [];
        tasksByStatus = {};
        if (statusName != null) isLoadingPerStatus[statusName] = false;
      });
    }
  }

  Future<void> _updateTaskStatus(String taskId, String newStatus) async {
    try {
      if (!await validateCredentials()) return;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';
      final userId = prefs.getInt('userId') ?? 1;
      final uri = UriHelper.build('/task/$taskId/status');

      final response = await http.patch(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
        body: json.encode({
          'status': newStatus,
          'createdBy': userId,
        }),
      );

      if (response.statusCode == 200 && json.decode(response.body)['isSuccess'] == true) {
        await _fetchDataForStatus(newStatus);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update task status: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating task status: $e')),
      );
    }
  }

  void _autoScrollToNextPage(DragTargetDetails<String> details) {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final localPosition = details.offset.dx;
    final screenWidth = MediaQuery.of(context).size.width;
    final visibleWidth = screenWidth * 0.85;
    final currentOffset = _pageController.offset;
    const scrollSpeed = 100.0;

    if (localPosition > visibleWidth * 0.9 && currentOffset < (taskStatuses.length - 1) * visibleWidth) {
      _pageController.jumpTo(currentOffset + scrollSpeed);
    } else if (localPosition < visibleWidth * 0.1 && currentOffset > 0) {
      _pageController.jumpTo(currentOffset - scrollSpeed);
    }
  }

  void _onPageChanged() {
    final currentPage = (_pageController.page ?? 0).round();
    if (currentPage >= 0 && currentPage < taskStatuses.length) {
      final statusName = taskStatuses[currentPage]['name'].toString();
      if (!tasksByStatus.containsKey(statusName)) {
        _fetchDataForStatus(statusName);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              errorMessage == 'No active sprint found'
                  ? 'No active sprint found.\nPlease start a new sprint.'
                  : 'Error: $errorMessage',
              style: const TextStyle(color: Colors.black38, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchInitialData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (taskStatuses.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final columns = taskStatuses.map((status) {
      final statusName = status['name'].toString();
      return KanbanColumn(
        title: status['label'].toString().toUpperCase(),
        statusName: statusName,
        tasks: tasksByStatus[statusName] ?? [],
        onTaskDropped: _updateTaskStatus,
        onDragUpdate: _autoScrollToNextPage,
        isLoading: isLoadingPerStatus[statusName] ?? false,
      );
    }).toList();

    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.horizontal,
      itemCount: columns.length,
      itemBuilder: (context, index) => columns[index],
    );
  }
}