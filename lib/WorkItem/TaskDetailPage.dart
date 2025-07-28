import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Helper/UriHelper.dart';
import '../Models/Epic.dart';
import '../Models/Subtask.dart';
import '../Models/Task.dart';

import '../Models/TaskAssignment.dart';
import '../Models/TaskFile.dart';
import 'CommentSection.dart';
import 'SubtaskDetailPage.dart';


class TaskDetailPage extends StatefulWidget {
  final String taskId;

  const TaskDetailPage({super.key, required this.taskId});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPage();

}

class _TaskDetailPage extends State<TaskDetailPage> {
  Task? task;
  bool isLoading = true;
  Subtask? subtask;
  bool _isAttachmentsExpanded = false;
  List<TaskFile> _taskFiles = [];
  bool _isLoadingAttachments = false;
  List<Subtask> subtasks = [];
  bool _isSubtaskExpanded = false;
  List<TaskAssignment> taskAssignments = [];
  Epic? epic;
  bool _isCreatingSubtask = false;
  TextEditingController _subtaskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchTaskDetail();
    fetchSubtasks();
    loadTaskAssignments();
  }

  Future<void> loadTaskAssignments() async {
    try {
      final assignments = await fetchTaskAssignments();
      setState(() {
        taskAssignments = assignments;
      });
    } catch (e) {
      print("Error loading task assignments: $e");
    }
  }

  Future<void> fetchSubtasks() async {
    try {
      final uri = UriHelper.build('/subtask/by-task/${widget.taskId}');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        print("Subtask response: $jsonBody"); // ✅ debug

        if (jsonBody['isSuccess'] == true && jsonBody['data'] != null) {
          final List data = jsonBody['data'];

          setState(() {
            subtasks = data.map((json) => Subtask.fromJson(json)).toList();
          });
        } else {
          showError("No subtask data");
        }
      } else {
        showError("Failed to fetch subtasks: ${response.statusCode}");
      }
    } catch (e) {
      showError("Error fetching subtasks: $e");
    }
  }

  Future<void> fetchTaskDetail() async {
    try {
      final uri = UriHelper.build('/task/${widget.taskId}');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        if (jsonBody['isSuccess'] == true) {
          setState(() {
            task = Task.fromJson(jsonBody['data']);
            isLoading = false;
          });

          // ✅ Sau khi task đã load xong, mới fetch epic
          if (task?.epicId != null && task!.epicId!.isNotEmpty) {
            await fetchEpicData(task!.epicId!);
          }
        } else {
          showError(jsonBody['message'] ?? 'task not found');
        }
      } else {
        showError('Server error: ${response.statusCode}');
      }
    } catch (e) {
      showError('Network error: $e');
    }
  }

  Future<void> fetchEpicData(String epicId) async {
    try {
      final response = await http.get(
        UriHelper.build('/epic/$epicId'),
        headers: {'accept': '*/*'},
      );

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        setState(() {
          epic = Epic.fromJson(jsonBody['data']); // chú ý: phải lấy `data`
        });
      } else {
        print('Lỗi khi fetch Epic: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi: $e');
    }
  }

  void showError(String message) {
    setState(() => isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _fetchTaskFiles() async {
    setState(() {
      _isLoadingAttachments = true;
    });
    try {
      final response = await http.get(
        UriHelper.build('/taskfile/by-task/${widget.taskId}'),
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['isSuccess']) {
          final List<TaskFile> files =
          (jsonData['data'] as List)
              .map((e) => TaskFile.fromJson(e))
              .toList();
          setState(() {
            _taskFiles = files;
          });
        }
      }
    } catch (e) {
      print("Failed to load attachments: $e");
    } finally {
      setState(() {
        _isLoadingAttachments = false;
      });
    }
  }

  Future<void> updateTaskStatus(String newStatus) async {
    final prefs = await SharedPreferences.getInstance();
    final createdBy = prefs.getInt('accountId');

    if (createdBy == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AccountId not found')),
      );
      return;
    }

    final uri = UriHelper.build('/task/${widget.taskId}/status');

    final payload = {
      "status": newStatus,
      "createdBy": createdBy,
    };

    try {
      final response = await http.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        setState(() {
          task!.status = newStatus;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Update status successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Widget _buildStatusSelectorSheet(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Select a status",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildStatusOption("TO_DO", Colors.grey, context),
          const Divider(),
          _buildStatusOption("IN_PROGRESS", Color(0xFF5BA6E3), context),
          const Divider(),
          _buildStatusOption("DONE", Color(0xFF78CC7F), context),
        ],
      ),
    );
  }

  Widget _buildStatusOption(String status, Color color, BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop(); // Đóng bottom sheet
        updateTaskStatus(status);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                status.replaceAll('_', ' '),
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'DONE':
        return Color(0xFF78CC7F);
      case 'IN_PROGRESS':
        return Color(0xFF5BA6E3);
      case 'TO_DO':
      default:
        return Colors.grey;
    }
  }

  Future<void> createSubtask(BuildContext context, String taskId, String title) async {
    final prefs = await SharedPreferences.getInstance();
    final accountId = prefs.getInt('accountId');

    if (accountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy AccountId')),
      );
      return;
    }

    final url = UriHelper.build('/subtask/create2');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'accept': '*/*',
      },
      body: jsonEncode(
        Subtask(taskId: taskId, title: title, createdBy: accountId).toJson(),
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Created successfully');
    } else {
      print('Create failed: ${response.body}');
      throw Exception('Failed to create subtask');
    }
  }

  final GlobalKey _subtaskKey = GlobalKey(); // đặt ngoài build
  final ScrollController _scrollController = ScrollController(); // để cuộn

  Widget buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
  );

  Widget buildCard({
    required String title,
    required Widget child,
    int? badgeCount,
    VoidCallback? onTap,
  }) {
    return Card(
      color: Colors.white,
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (badgeCount != null)
                    Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('$badgeCount'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              child,
            ],
          ),
        ),
      ),
    );
  }


  Future<List<TaskAssignment>> fetchTaskAssignments() async {
    final response = await http.get(
      UriHelper.build('/task/${widget.taskId}/taskassignment'),
      headers: {'accept': '*/*'},
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final List<dynamic> data = jsonResponse['data'];
      return data.map((e) => TaskAssignment.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load task assignments');
    }
  }

  String _getTaskTypeAsset(String type) {
    switch (type.toUpperCase()) {
      case 'BUG':
        return 'assets/type_bug.svg';
      case 'STORY':
        return 'assets/type_story.svg';
      case 'TASK':
      default:
        return 'assets/type_task.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (task == null) {
      return const Scaffold(body: Center(child: Text('Task not found')));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: Row(
          children: [
            SvgPicture.asset(
              _getTaskTypeAsset(task!.type),
              width: 20,
              height: 20,
            ),
            const SizedBox(width: 8),
            Text(
              task!.id,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'subtask') {
                // Cuộn đến Subtask section
                Scrollable.ensureVisible(
                  _subtaskKey.currentContext!,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
                setState(() {
                  _isSubtaskExpanded = true;
                  _isCreatingSubtask = true; // mở ô nhập luôn nếu muốn
                });
              } else if (value == 'attachment') {
                // Xử lý tạo attachment tại đây
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'subtask',
                child: Text('Create subtask'),
              ),
              const PopupMenuItem<String>(
                value: 'attachment',
                child: Text('Create attachment'),
              ),
            ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title task
                Expanded(
                  child: Text(
                    task!.title ?? "No title",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(width: 8),

                // Danh sách assignees (CircleAvatar)
                Row(
                  children: (taskAssignments ?? []).map((assignment) {
                    final hasImage = assignment.accountPicture != null && assignment.accountPicture!.isNotEmpty;
                    final firstLetter = assignment.accountFullname?.split(' ').last.characters.first ?? 'U';

                    return Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: CircleAvatar(
                        radius: 15,
                        backgroundImage: hasImage ? NetworkImage(assignment.accountPicture!) : null,
                        backgroundColor: Colors.blue[100],
                        child: !hasImage
                            ? Text(
                          firstLetter,
                          style: const TextStyle(color: Colors.black),
                        )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),

            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  builder: (context) => _buildStatusSelectorSheet(context),
                );
              },
              icon: const Icon(Icons.arrow_drop_down),
              label: Text(
                task!.status ?? '' ,
                style: const TextStyle(color: Colors.black),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _statusColor(task!.status ?? 'TO_DO'),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),

            const SizedBox(height: 16),

            buildCard(
              title: "Description",
              child: Text(
                task!.description ?? "Add a description...",
                style: const TextStyle(color: Colors.black),
              ),
            ),

            buildCard(
              title: "Attachments",
              badgeCount: _taskFiles.length,
              onTap: () async {
                setState(() {
                  _isAttachmentsExpanded = !_isAttachmentsExpanded;
                });
                if (_isAttachmentsExpanded && _taskFiles.isEmpty) {
                  await _fetchTaskFiles(); // Gọi API khi mở ra
                }
              },
              child:
              _isAttachmentsExpanded
                  ? _isLoadingAttachments
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ..._taskFiles.map(
                        (file) => Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          launchUrl(Uri.parse(file.urlFile));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.insert_drive_file,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      file.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      // Thêm chức năng upload
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Add attachment"),
                  ),
                ],
              )
                  : const SizedBox.shrink(),
            ),

            buildCard(
              title: "Parent Work Item",
              onTap: () {

              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (epic != null)
                            Text(
                              epic!.name ?? 'None',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          Text(
                            task!.epicId ?? '',
                            style: const TextStyle(color: Colors.black, fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(epic?.status ?? ''),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        epic?.status ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),

    SingleChildScrollView(
    controller: _scrollController,
    child: Column(
    children: [
    // ... các phần khác
    Container(
    key: _subtaskKey, // GẮN key ở đây
    child:buildCard(
              title: "Subtask List",
              badgeCount: subtasks.length,
              onTap: () {
                setState(() {
                  _isSubtaskExpanded = !_isSubtaskExpanded;
                });
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Builder(
                    builder: (_) {
                      final total = subtasks.length;
                      if (total == 0) return const SizedBox();

                      final done = subtasks.where((s) => s.status == 'DONE').length;
                      final inProgress = subtasks.where((s) => s.status == 'IN_PROGRESS').length;
                      final toDo = total - done - inProgress;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    flex: done,
                                    child: Container(
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF78CC7F),
                                        //borderRadius: const BorderRadius.horizontal(left: Radius.circular(4)),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: inProgress,
                                    child: Container(
                                      height: 8,
                                      color: const Color(0xFF5BA6E3),
                                    ),
                                  ),
                                  Expanded(
                                    flex: toDo,
                                    child: Container(
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        //borderRadius: const BorderRadius.horizontal(right: Radius.circular(4), left: Radius.circular(4)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Progress: $done/$total done",
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                          ),

                          const SizedBox(height: 8),
                        ],
                      );
                    },
                  ),

                  // Subtask List (expandable)
                  _isSubtaskExpanded
                      ? Column(
                    children: [
                      ...subtasks.map(
                            (subtask) => ListTile(
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          contentPadding: const EdgeInsets.symmetric(vertical: 4),
                          leading: SvgPicture.asset('assets/type_subtask.svg', width: 18, height: 18),
                          title: Text(subtask.title ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                          subtitle: Text(subtask.id?? '', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _statusColor(subtask.status ?? ''),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              subtask.status ?? '',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SubtaskDetailPage(subtaskId: subtask.id ?? ''),
                                  ),
                                );
                              },
                            ),
                      ),
                      const SizedBox(height: 8),

                      _isCreatingSubtask
                          ? Row(
                        children: [
                          SvgPicture.asset('assets/type_subtask.svg', width: 18, height: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _subtaskController,
                              decoration: const InputDecoration(
                                hintText: 'Add a subtask',
                                border: InputBorder.none,
                              ),
                              onSubmitted: (value) async {
                                try {
                                  await createSubtask(context, widget.taskId, value);
                                  setState(() {
                                    _isCreatingSubtask = false;
                                    _subtaskController.clear();
                                    fetchSubtasks(); // nếu có function load lại subtasks
                                  });
                                } catch (e) {
                                  print('Lỗi tạo subtask: $e');
                                }
                              },

                            ),
                          ),
                        ],
                      )
                          : OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _isCreatingSubtask = true;
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text("Create subtask"),
                      ),
                    ],
                  )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
    ),
    ],
    ),
    ),

            buildCard(
              title: "Assignee",
              child: Column(
                children: taskAssignments.map((assignment) {
                  return ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
                    visualDensity: const VisualDensity(horizontal: 0, vertical: -4), // giảm khoảng cách dòng
                    leading: CircleAvatar(
                      radius: 13,
                      backgroundImage: assignment.accountPicture != null && assignment.accountPicture!.isNotEmpty
                          ? NetworkImage(assignment.accountPicture!)
                          : null,
                      backgroundColor: Colors.blue[100],
                      child: (assignment.accountPicture == null || assignment.accountPicture!.isEmpty)
                          ? Text(
                        (assignment.accountFullname?.split(' ').last.characters.first ?? 'U'),
                        style: const TextStyle(fontSize: 12, color: Colors.black),
                      )
                          : null,
                    ),
                    title: Text(
                      assignment.accountFullname ?? 'Unassigned',
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Details
            buildCard(
              title: "Details",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildDetailRow(
                    "Start Date",
                    task!.plannedStartDate?.toIso8601String().split("T").first ?? 'None',
                  ),
                  buildDetailRow(
                    "End Date",
                    task!.plannedEndDate?.toIso8601String().split("T").first ?? 'None',
                  ),
                  buildDetailRow(
                    "Sprint",
                    task!.sprintName ?? 'None',
                  ),
                ],
              ),
            ),
            buildCard(
              title: "Reporter",
              child: ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
                visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                leading: CircleAvatar(
                  radius: 13,
                  backgroundImage: task!.reporterPicture != null && task!.reporterPicture!.isNotEmpty
                      ? NetworkImage(task!.reporterPicture!)
                      : null,
                  backgroundColor: Colors.blue[100],
                  child: (task!.reporterPicture == null || task!.reporterPicture!.isEmpty)
                      ? Text(
                    (task!.reporterName?.split(' ').last.characters.first ?? 'U'),
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                  )
                      : null,
                ),
                title: Text(
                  task!.reporterName ?? 'Unassigned',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            CommentSection(taskId: task!.id ?? ''),
          ],
        ),
      ),
    );
  }
  Widget buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
