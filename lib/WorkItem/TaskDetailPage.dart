import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
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
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    fetchTaskDetail();
    fetchSubtasks();
    loadTaskAssignments();
  }

  Future<bool> validateCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';
    final token = prefs.getString('accessToken') ?? '';
    if (email.isEmpty || token.isEmpty) {
      setState(() {
        _errorMessage = 'Credentials not found in preferences';
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credentials not found in preferences')),
      );
      return false;
    }
    return true;
  }

  Future<void> loadTaskAssignments() async {
    try {
      final assignments = await fetchTaskAssignments();
      setState(() {
        taskAssignments = assignments;
      });
    } catch (e) {

      setState(() {
        _errorMessage = 'Error loading task assignments: $e';
      });
    }
  }

  Future<void> fetchSubtasks() async {
    try {
      if (!await validateCredentials()) return;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';
      final uri = UriHelper.build('/subtask/by-task/${widget.taskId}');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
      );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        if (jsonBody['isSuccess'] == true && jsonBody['data'] != null) {
          final List data = jsonBody['data'];
          setState(() {
            subtasks = data.map((json) => Subtask.fromJson(json)).toList();
            _errorMessage = null;
          });
        } else {
          showError(jsonBody['message'] ?? 'No subtask data');
        }
      } else {
        showError('There are no subtask in this task');
      }
    } catch (e) {
      showError('Network error: $e');
    }
  }

  Future<void> fetchTaskDetail() async {
    try {
      if (!await validateCredentials()) return;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';
      final uri = UriHelper.build('/task/${widget.taskId}');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
      );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        if (jsonBody['isSuccess'] == true) {
          setState(() {
            task = Task.fromJson(jsonBody['data']);
            isLoading = false;
            _errorMessage = null;
          });

          if (task?.epicId != null && task!.epicId!.isNotEmpty) {
            await fetchEpicData(task!.epicId!);
          }
        } else {
          showError(jsonBody['message'] ?? 'Task not found');
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
      if (!await validateCredentials()) return;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';
      final uri = UriHelper.build('/epic/$epicId');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
      );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        if (jsonBody['isSuccess'] == true) {
          setState(() {
            epic = Epic.fromJson(jsonBody['data']);
            _errorMessage = null;
          });
        } else {

          setState(() {
            _errorMessage = jsonBody['message'] ?? 'Failed to load epic';
          });
        }
      } else {

        setState(() {
          _errorMessage = 'Server error: ${response.statusCode}';
        });
      }
    } catch (e) {

      setState(() {
        _errorMessage = 'Network error: $e';
      });
    }
  }

  void showError(String message) {
    setState(() {
      isLoading = false;
      _errorMessage = message;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _fetchTaskFiles() async {
    setState(() {
      _isLoadingAttachments = true;
      _errorMessage = null;
    });
    try {
      if (!await validateCredentials()) return;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';
      final uri = UriHelper.build('/taskfile/by-task/${widget.taskId}');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['isSuccess']) {
          final List<TaskFile> files =
          (jsonData['data'] as List).map((e) => TaskFile.fromJson(e)).toList();
          setState(() {
            _taskFiles = files;
            _errorMessage = null;
          });
        } else {
          setState(() {
            _errorMessage = jsonData['message'] ?? 'Failed to load task files';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Server error: ${response.statusCode}';
        });
      }
    } catch (e) {

      setState(() {
        _errorMessage = 'Network error: $e';
      });
    } finally {
      setState(() {
        _isLoadingAttachments = false;
      });
    }
  }

  Future<void> _uploadFile() async {
    setState(() {
      _isLoadingAttachments = true;
      _errorMessage = null;
    });
    try {
      if (!await validateCredentials()) return;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';
      final accountId = prefs.getInt('accountId');

      if (accountId == null) {
        setState(() {
          _errorMessage = 'AccountId not found';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AccountId not found')),
        );
        return;
      }

      final source = await showModalBottomSheet<ImageSource?>(
        context: context,
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: const Text('Choose a File'),
              onTap: () => Navigator.pop(context, null),
            ),
          ],
        ),
      );

      PlatformFile? file;
      String? fileName;

      if (source != null) {
        final ImagePicker _picker = ImagePicker();
        final XFile? image = await _picker.pickImage(source: source);
        if (image == null) {

          setState(() {
            _errorMessage = 'No image selected';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No image selected')),
          );
          return;
        }
        file = PlatformFile(
          name: image.name,
          path: image.path,
          size: await image.length(),
        );
        fileName = image.name;
      } else {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.any,
          allowMultiple: false,
          withData: true,
        );
        if (result == null || result.files.isEmpty) {

          setState(() {
            _errorMessage = 'No file selected';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No file selected')),
          );
          return;
        }
        file = result.files.first;
        fileName = file.name;
      }

      if (file.path == null && file.bytes == null) {

        setState(() {
          _errorMessage = 'Selected file has no valid path or data';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Selected file has no valid path or data')),
        );
        return;
      }

      final uri = UriHelper.build('/taskfile/upload');

      var request = http.MultipartRequest('POST', uri);

      request.headers['Content-Type'] = 'multipart/form-data';
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = '*/*';

      request.fields['taskId'] = widget.taskId;
      request.fields['title'] = fileName;
      request.fields['createdBy'] = accountId.toString();


      if (file.path != null) {

        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            file.path!,
            filename: fileName,
          ),
        );
      } else if (file.bytes != null) {

        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            file.bytes!,
            filename: fileName,
          ),
        );
      }


      var response = await request.send();
      var responseBody = await response.stream.bytesToString();


      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(responseBody);
        if (jsonResponse['isSuccess'] == true ||
            (jsonResponse['urlFile'] != null && jsonResponse['status'] == 'UPLOADED')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File uploaded successfully')),
          );
          await _fetchTaskFiles();
        } else {
          setState(() {
            _errorMessage = jsonResponse['message'] ?? 'Upload failed';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: ${jsonResponse['message'] ?? 'Unknown error'}')),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Upload failed: ${response.reasonPhrase}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {

      setState(() {
        _errorMessage = 'Error uploading file: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading file: $e')),
      );
    } finally {
      setState(() {
        _isLoadingAttachments = false;
      });
    }
  }

  Future<void> updateTaskStatus(String newStatus) async {
    try {
      if (!await validateCredentials()) return;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';
      final createdBy = prefs.getInt('accountId');

      if (createdBy == null) {
        setState(() {
          _errorMessage = 'AccountId not found';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AccountId not found')),
        );
        return;
      }

      final uri = UriHelper.build('/task/${widget.taskId}/status');
      final payload = {'status': newStatus, 'createdBy': createdBy};


      final response = await http.patch(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
        body: jsonEncode(payload),
      );


      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        if (jsonBody['isSuccess'] == true) {
          setState(() {
            task!.status = newStatus;
            _errorMessage = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Update status successfully')),
          );
        } else {
          setState(() {
            _errorMessage = jsonBody['message'] ?? 'Update failed';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Update failed: ${jsonBody['message'] ?? 'Unknown error'}')),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Server error: ${response.statusCode}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: ${response.statusCode}')),
        );
      }
    } catch (e) {

      setState(() {
        _errorMessage = 'Error updating task status: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating task status: $e')),
      );
    }
  }

  Future<void> createSubtask(BuildContext context, String taskId, String title) async {
    try {
      if (!await validateCredentials()) return;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';
      final accountId = prefs.getInt('accountId');

      if (accountId == null) {
        setState(() {
          _errorMessage = 'AccountId not found';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AccountId not found')),
        );
        return;
      }

      final uri = UriHelper.build('/subtask/create2');
      final payload = Subtask(taskId: taskId, title: title, createdBy: accountId).toJson();


      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _isCreatingSubtask = false;
          _subtaskController.clear();
          _errorMessage = null;
        });
        await fetchSubtasks();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subtask created successfully')),
        );
      } else {
        final jsonBody = json.decode(response.body);
        setState(() {
          _errorMessage = jsonBody['message'] ?? 'Failed to create subtask';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Create failed: ${jsonBody['message'] ?? 'Unknown error'}')),
        );
      }
    } catch (e) {

      setState(() {
        _errorMessage = 'Error creating subtask: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating subtask: $e')),
      );
    }
  }

  Future<List<TaskAssignment>> fetchTaskAssignments() async {
    try {
      if (!await validateCredentials()) {
        throw Exception('Credentials not found');
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';
      final uri = UriHelper.build('/task/${widget.taskId}/taskassignment');


      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['isSuccess'] == true) {
          final List<dynamic> data = jsonResponse['data'];
          return data.map((e) => TaskAssignment.fromJson(e)).toList();
        } else {
          throw Exception(jsonResponse['message'] ?? 'Failed to load task assignments');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {

      throw Exception('Error fetching task assignments: $e');
    }
  }

  Future<void> _updateIssueType(String newType) async {
    try {
      if (!await validateCredentials()) return;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';
      final accountId = prefs.getInt('accountId');

      if (accountId == null) {
        setState(() {
          _errorMessage = 'AccountId not found';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AccountId not found')),
        );
        return;
      }

      final uri = UriHelper.build('/task/${task!.id}/type');
      final payload = {'type': newType.toUpperCase(), 'createdBy': accountId};

      final response = await http.patch(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
        body: jsonEncode(payload),
      );


      if (response.statusCode == 200) {
        final parsed  = json.decode(response.body);
        if (parsed ['isSuccess'] == true) {
          setState(() {
            task!.type = parsed ['data']['type'];
            _errorMessage = null;
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Issue type updated successfully')),
          );
        } else {
          setState(() {
            _errorMessage = parsed ['message'] ?? 'Update failed';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Update failed: ${parsed ['message'] ?? 'Unknown error'}')),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Server error: ${response.statusCode}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: ${response.statusCode}')),
        );
      }
    } catch (e) {

      setState(() {
        _errorMessage = 'Error updating issue type: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating issue type: $e')),
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
            'Select a status',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildStatusOption('TO_DO', Colors.grey, context),
          const Divider(),
          _buildStatusOption('IN_PROGRESS', Color(0xFF5BA6E3), context),
          const Divider(),
          _buildStatusOption('DONE', Color(0xFF78CC7F), context),
        ],
      ),
    );
  }

  Widget _buildStatusOption(String status, Color color, BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
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
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
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

  Widget _buildIssueTypeSheet(BuildContext context) {
    final types = ['Task', 'Bug', 'Story'];
    final descriptions = [
      'Tasks track small, distinct pieces of work.',
      'Bugs track problems or errors.',
      'Stories track functionality or features expressed as user goals.',
    ];
    final icons = [
      'assets/type_task.svg',
      'assets/type_bug.svg',
      'assets/type_story.svg',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Issue Type',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(types.length, (index) {
            final selected = task!.type.toLowerCase() == types[index].toLowerCase();
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? Colors.blue : Colors.grey.shade300,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                leading: SvgPicture.asset(icons[index], width: 24, height: 24),
                title: Text(
                  types[index],
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(descriptions[index]),
                trailing: selected ? const Icon(Icons.check, color: Colors.blue) : null,
                onTap: () {
                  if (!selected) {
                    _updateIssueType(types[index]);
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  final GlobalKey _subtaskKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

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

  Widget buildDetailRow(String title, String value) {
    if (title == 'Issue Type') {
      String iconPath = getIssueTypeIconPath(value);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$title: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            SvgPicture.asset(iconPath, width: 18, height: 18),
            const SizedBox(width: 6),
            Text(value),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Text(
              '$title: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Flexible(child: Text(value)),
          ],
        ),
      );
    }
  }

  String getIssueTypeIconPath(String type) {
    switch (type.toLowerCase()) {
      case 'task':
        return 'assets/type_task.svg';
      case 'bug':
        return 'assets/type_bug.svg';
      case 'story':
        return 'assets/type_story.svg';
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
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Task not found${_errorMessage != null ? ': $_errorMessage' : ''}',
                  style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    _errorMessage = null;
                  });
                  fetchTaskDetail();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
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
                Scrollable.ensureVisible(
                  _subtaskKey.currentContext!,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
                setState(() {
                  _isSubtaskExpanded = true;
                  _isCreatingSubtask = true;
                });
              } else if (value == 'attachment') {
                _uploadFile();
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
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    task!.title ?? 'No title',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  children: (taskAssignments).map((assignment) {
                    final hasImage =
                        assignment.accountPicture != null && assignment.accountPicture!.isNotEmpty;
                    final firstLetter =
                        assignment.accountFullname?.split(' ').last.characters.first ?? 'U';

                    return Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: CircleAvatar(
                        radius: 15,
                        backgroundImage: hasImage ? NetworkImage(assignment.accountPicture!) : null,
                        backgroundColor: Colors.blue[100],
                        child: !hasImage
                            ? Text(
                          firstLetter,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
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
                task!.status ?? '',
                style: const TextStyle(color: Colors.black),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _statusColor(task!.status ?? 'TO_DO'),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
            const SizedBox(height: 16),
            buildCard(
              title: 'Description',
              child: Text(
                task!.description ?? 'Add a description...',
                style: const TextStyle(color: Colors.black),
              ),
            ),
            buildCard(
              title: 'Attachments',
              badgeCount: _taskFiles.length,
              onTap: () async {
                setState(() {
                  _isAttachmentsExpanded = !_isAttachmentsExpanded;
                });
                if (_isAttachmentsExpanded && _taskFiles.isEmpty) {
                  await _fetchTaskFiles();
                }
              },
              child: _isAttachmentsExpanded
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    onPressed: _uploadFile,
                    icon: const Icon(Icons.add),
                    label: const Text('Add attachment'),
                  ),
                ],
              )
                  : const SizedBox.shrink(),
            ),
            buildCard(
              title: 'Parent Work Item',
              onTap: () {},
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
                          Text(
                            epic?.name ?? 'None',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            task?.epicId ?? '',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (epic != null && epic!.status.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(epic!.status),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          epic!.status,
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
                  Container(
                    key: _subtaskKey,
                    child: buildCard(
                      title: 'Subtask List',
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
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Progress: $done/$total done',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              );
                            },
                          ),
                          _isSubtaskExpanded
                              ? Column(
                            children: [
                              ...subtasks.map(
                                    (subtask) => ListTile(
                                  dense: true,
                                  visualDensity: VisualDensity.compact,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  leading: SvgPicture.asset(
                                    'assets/type_subtask.svg',
                                    width: 18,
                                    height: 18,
                                  ),
                                  title: Text(
                                    subtask.title ?? '',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    subtask.id ?? '',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
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
                                        builder: (_) => SubtaskDetailPage(
                                          subtaskId: subtask.id ?? '',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 8),
                              _isCreatingSubtask
                                  ? Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/type_subtask.svg',
                                    width: 18,
                                    height: 18,
                                  ),
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
                                        } catch (e) {

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
                                label: const Text('Create subtask'),
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
              title: 'Assignee',
              child: Column(
                children: taskAssignments.map((assignment) {
                  return ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 2,
                      horizontal: 0,
                    ),
                    visualDensity: const VisualDensity(
                      horizontal: 0,
                      vertical: -4,
                    ),
                    leading: CircleAvatar(
                      radius: 13,
                      backgroundImage: assignment.accountPicture != null &&
                          assignment.accountPicture!.isNotEmpty
                          ? NetworkImage(assignment.accountPicture!)
                          : null,
                      backgroundColor: Colors.blue[100],
                      child: (assignment.accountPicture == null || assignment.accountPicture!.isEmpty)
                          ? Text(
                        (assignment.accountFullname?.split(' ').last.characters.first ?? 'U'),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
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
            buildCard(
              title: 'Details',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        builder: (bottomSheetContext) => _buildIssueTypeSheet(bottomSheetContext),
                      );
                    },
                    child: buildDetailRow('Issue Type', task!.type),
                  ),
                  buildDetailRow(
                    'Start Date',
                    task?.plannedStartDate?.toIso8601String().split('T').first ?? 'None',
                  ),
                  buildDetailRow(
                    'End Date',
                    task?.plannedEndDate?.toIso8601String().split('T').first ?? 'None',
                  ),
                  buildDetailRow('Sprint', task?.sprintName ?? 'None'),
                ],
              ),
            ),
            buildCard(
              title: 'Reporter',
              child: ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 2,
                  horizontal: 0,
                ),
                visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                leading: CircleAvatar(
                  radius: 13,
                  backgroundImage:
                  task!.reporterPicture != null && task!.reporterPicture!.isNotEmpty
                      ? NetworkImage(task!.reporterPicture!)
                      : null,
                  backgroundColor: Colors.blue[100],
                  child: (task!.reporterPicture == null || task!.reporterPicture!.isEmpty)
                      ? Text(
                    (task!.reporterName?.split(' ').last.characters.first ?? 'U'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
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
}