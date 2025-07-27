import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
  bool isLoading = true;
  String? errorMessage;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85); // Hiển thị 85% cột
    _fetchData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      // Lấy sprint active
      final sprintUri = UriHelper.build('/sprint/active-with-tasks/${widget.projectKey}');
      print('Fetching active sprint: $sprintUri');
      final sprintResponse = await http.get(sprintUri, headers: {'Accept': '*/*'});
      print('Sprint response: ${sprintResponse.statusCode}, body: ${sprintResponse.body}');
      if (sprintResponse.statusCode != 200 || json.decode(sprintResponse.body)['isSuccess'] != true) {
        setState(() {
          errorMessage = 'No active sprint found';
          isLoading = false;
        });
        return;
      }
      final sprintData = json.decode(sprintResponse.body)['data'];
      final sprintId = sprintData['id'] as int?;

      if (sprintId == null) {
        setState(() {
          errorMessage = 'No active sprint found';
          isLoading = false;
        });
        return;
      }

      // Lấy danh sách trạng thái task
      final statusUri = UriHelper.build('/dynamiccategory/by-category-group?categoryGroup=task_status');
      print('Fetching task statuses: $statusUri');
      final statusResponse = await http.get(statusUri, headers: {'Accept': '*/*'});
      print('Status response: ${statusResponse.statusCode}, body: ${statusResponse.body}');
      if (statusResponse.statusCode != 200 || json.decode(statusResponse.body)['isSuccess'] != true) {
        throw Exception('Failed to load task statuses');
      }
      final statusData = json.decode(statusResponse.body)['data'] as List;

      // Lấy task cho từng trạng thái
      Map<String, List<Task>> tasksByStatusTemp = {};
      for (var status in statusData) {
        final statusName = status['name'].toString();
        final taskUri = UriHelper.build('/task/by-sprint-id/$sprintId/task-status?taskStatus=$statusName');
        print('Fetching tasks for status $statusName: $taskUri');
        final taskResponse = await http.get(taskUri, headers: {'Accept': '*/*'});
        print('Task response for $statusName: ${taskResponse.statusCode}, data: ${taskResponse.body}');
        if (taskResponse.statusCode == 200 && json.decode(taskResponse.body)['isSuccess'] == true) {
          final tasksData = json.decode(taskResponse.body)['data'] as List;
          tasksByStatusTemp[statusName] = tasksData.map((task) => Task.fromJson(task)).toList();
        } else {
          tasksByStatusTemp[statusName] = [];
        }
      }

      setState(() {
        activeSprintId = sprintId;
        taskStatuses = statusData.cast<Map<String, dynamic>>();
        tasksByStatus = tasksByStatusTemp;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _updateTaskStatus(String taskId, String newStatus) async {
    try {
      final uri = UriHelper.build('/task/$taskId/status');
      print('Updating task $taskId to status $newStatus: $uri');
      final response = await http.patch(
        uri,
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'status': newStatus,
          'createdBy': 1, // Giả sử user ID là 1, thay bằng user ID thực tế nếu có
        }),
      );
      print('Update task response: ${response.statusCode}, body: ${response.body}');
      if (response.statusCode == 200 && json.decode(response.body)['isSuccess'] == true) {
        // Làm mới toàn bộ dữ liệu sau khi cập nhật
        await _fetchData();
      } else {
        print('Failed to update task status: ${response.body}');
      }
    } catch (e) {
      print('Error updating task status: $e');
    }
  }

  void _autoScrollToNextPage(DragTargetDetails<String> details) {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final localPosition = details.offset.dx; // Tọa độ cục bộ trong DragTarget
    final screenWidth = MediaQuery.of(context).size.width;
    final visibleWidth = screenWidth * 0.85; // Chiều rộng hiển thị của cột
    final currentOffset = _pageController.offset; // Vị trí hiện tại của PageView
    const scrollSpeed = 100.0; // Tốc độ cuộn (pixel)

    print('Local position: $localPosition, screenWidth: $screenWidth, currentOffset: $currentOffset');

    // Cuộn sang phải nếu gần viền phải
    if (localPosition > visibleWidth * 0.9 && currentOffset < (taskStatuses.length - 1) * visibleWidth) {
      _pageController.jumpTo(currentOffset + scrollSpeed);
    }
    // Cuộn sang trái nếu gần viền trái
    else if (localPosition < visibleWidth * 0.1 && currentOffset > 0) {
      _pageController.jumpTo(currentOffset - scrollSpeed);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $errorMessage', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final columns = taskStatuses.map((status) => KanbanColumn(
      title: status['label'].toString().toUpperCase(),
      statusName: status['name'].toString(),
      tasks: tasksByStatus[status['name']] ?? [],
      onTaskDropped: _updateTaskStatus,
      onDragUpdate: _autoScrollToNextPage,
    )).toList();

    if (columns.isEmpty) {
      return const Center(child: Text('No task statuses available'));
    }

    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.horizontal,
      itemCount: columns.length,
      itemBuilder: (context, index) => columns[index],
    );
  }
}