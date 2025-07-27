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
  Map<String, bool> isLoadingPerStatus = {}; // Thêm trạng thái loading cho từng cột
  String? errorMessage;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85); // Hiển thị 85% cột
    _fetchInitialData();
    _pageController.addListener(_onPageChanged); // Lắng nghe thay đổi trang
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      isLoadingPerStatus.clear();
      taskStatuses = [];
      tasksByStatus.clear();
      errorMessage = null;
    });
    await _fetchDataForStatus(null); // Lấy dữ liệu ban đầu cho tất cả cột
  }

  Future<void> _fetchDataForStatus(String? statusName) async {
    if (statusName != null) {
      setState(() {
        isLoadingPerStatus[statusName] = true;
      });
    }
    try {
      final sprintUri = UriHelper.build('/sprint/active-with-tasks/${widget.projectKey}');
      print('Fetching active sprint: $sprintUri');
      final sprintResponse = await http.get(sprintUri, headers: {'Accept': '*/*'});
      print('Sprint response: ${sprintResponse.statusCode}, body: ${sprintResponse.body}');
      if (sprintResponse.statusCode != 200 || json.decode(sprintResponse.body)['isSuccess'] != true) {
        setState(() {
          errorMessage = 'No active sprint found';
          if (statusName != null) isLoadingPerStatus[statusName] = false;
        });
        return;
      }
      final sprintData = json.decode(sprintResponse.body)['data'];
      final sprintId = sprintData['id'] as int?;

      if (sprintId == null) {
        setState(() {
          errorMessage = 'No active sprint found';
          if (statusName != null) isLoadingPerStatus[statusName] = false;
        });
        return;
      }

      final statusUri = UriHelper.build('/dynamiccategory/by-category-group?categoryGroup=task_status');
      print('Fetching task statuses: $statusUri');
      final statusResponse = await http.get(statusUri, headers: {'Accept': '*/*'});
      print('Status response: ${statusResponse.statusCode}, body: ${statusResponse.body}');
      if (statusResponse.statusCode != 200 || json.decode(statusResponse.body)['isSuccess'] != true) {
        throw Exception('Failed to load task statuses');
      }
      final statusData = json.decode(statusResponse.body)['data'] as List;

      Map<String, List<Task>> tasksByStatusTemp = {};
      for (var status in statusData) {
        final statusName = status['name'].toString();
        if (statusName != null && (statusName == statusName || statusName == null)) {
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
        if (statusName != null) isLoadingPerStatus[statusName] = false;
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
        await _fetchDataForStatus(newStatus); // Cập nhật chỉ cột mới
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
    if (taskStatuses.isEmpty && errorMessage == null) {
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
              onPressed: _fetchInitialData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
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