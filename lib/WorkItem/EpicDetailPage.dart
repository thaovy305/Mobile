import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import '../Helper/UriHelper.dart';
import '../Models/EpicFile.dart';
import '../Models/Task.dart';
import '../models/epic.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'EpicCommentSection.dart';
import 'TaskDetailPage.dart';

class EpicDetailPage extends StatefulWidget {
  final String epicId;

  const EpicDetailPage({Key? key, required this.epicId}) : super(key: key);

  @override
  State<EpicDetailPage> createState() => _EpicDetailPageState();
}

class _EpicDetailPageState extends State<EpicDetailPage> {
  Epic? epicData;
  bool isLoading = true;
  bool _isAttachmentsExpanded = false;
  List<EpicFile> _epicFiles = [];
  bool _isLoadingAttachments = false;
  List<Task> _tasks = [];
  bool _isTaskExpanded = false;

  @override
  void initState() {
    super.initState();
    fetchEpicDetail();
    _fetchEpicFiles();
    loadTasks();
  }

  void loadTasks() async {
    try {
      final fetched = await fetchTasksByEpicId('${widget.epicId}');
      setState(() {
        _tasks = fetched;
      });
    } catch (e) {
      print("Error loading tasks: $e");
    }
  }

  Future<void> fetchEpicDetail() async {
    try {
      final uri = UriHelper.build('/epic/${widget.epicId}');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);

        if (jsonBody['isSuccess'] == true) {
          setState(() {
            epicData = Epic.fromJson(jsonBody['data']);
            isLoading = false;
          });
        } else {
          showError(jsonBody['message'] ?? 'Epic not found');
        }
      } else {
        showError('Server error: ${response.statusCode}');
      }
    } catch (e) {
      showError('Network error: $e');
    }
  }

  void showError(String message) {
    setState(() {
      isLoading = false;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> updateEpicStatus(String newStatus) async {
    final prefs = await SharedPreferences.getInstance();
    final createdBy = prefs.getInt('accountId');

    if (createdBy == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('AccountId not found')));
      return;
    }

    final uri = UriHelper.build('/epic/${widget.epicId}/status');

    final payload = {"status": newStatus, "createdBy": createdBy};

    try {
      final response = await http.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        setState(() {
          epicData!.status = newStatus;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
        Navigator.of(context).pop();
        updateEpicStatus(status);
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
      default:
        return Colors.grey;
    }
  }

  Future<void> _fetchEpicFiles() async {
    setState(() {
      _isLoadingAttachments = true;
    });
    try {
      final response = await http.get(
        UriHelper.build('/epicfile/by-epic/${widget.epicId}'),
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['isSuccess']) {
          final List<EpicFile> files =
              (jsonData['data'] as List)
                  .map((e) => EpicFile.fromJson(e))
                  .toList();
          setState(() {
            _epicFiles = files;
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

  Future<void> _uploadFile() async {
    // Show dialog to choose between camera and file picker
    final source = await showModalBottomSheet<ImageSource>(
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
            onTap: () => Navigator.pop(context, null), // Use file picker
          ),
        ],
      ),
    );

    try {
      PlatformFile? file;
      String? fileName;

      if (source != null) {
        // Use image_picker for camera or gallery
        final ImagePicker _picker = ImagePicker();
        final XFile? photo = await _picker.pickImage(source: source);
        if (photo == null) {
          print('No photo selected');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No photo selected')),
          );
          return;
        }
        file = PlatformFile(
          name: photo.name,
          path: photo.path,
          size: await photo.length(),
        );
        fileName = photo.name;
      } else {
        // Use file_picker for other files
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.any,
          allowMultiple: false,
          withData: true,
        );
        if (result == null || result.files.isEmpty) {
          print('No file selected');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No file selected')),
          );
          return;
        }
        file = result.files.first;
        fileName = file.name;
      }

      if (file.path == null && file.bytes == null) {
        print('Error: Both file.path and file.bytes are null');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Selected file has no valid path or data')),
        );
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final accountId = prefs.getInt('accountId');
      print('Account ID: $accountId');

      if (accountId == null) {
        print('Error: accountId not found in SharedPreferences');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AccountId not found')),
        );
        return;
      }

      final uri = UriHelper.build('/epicfile/upload');
      print('API URL: $uri');
      var request = http.MultipartRequest('POST', uri);

      request.headers['accept'] = '*/*';
      request.headers['Content-Type'] = 'multipart/form-data';

      final token = prefs.getString('accessToken');
      if (token != null) {
        print('Adding Bearer token to headers');
        request.headers['Authorization'] = 'Bearer $token';
      } else {
        print('Warning: No access token found in SharedPreferences');
      }

      // Add form fields
      request.fields['epicId'] = widget.epicId;
      request.fields['title'] = fileName;
      request.fields['createdBy'] = accountId.toString();
      print('Form fields: ${request.fields}');

      // Add the file
      if (file.path != null) {
        print('Using file.path to upload');
        request.files.add(
          await http.MultipartFile.fromPath(
            'urlFile',
            file.path!,
            filename: fileName,
          ),
        );
      } else if (file.bytes != null) {
        print('Using file.bytes to upload');
        request.files.add(
          http.MultipartFile.fromBytes(
            'urlFile',
            file.bytes!,
            filename: fileName,
          ),
        );
      }

      // Send the request
      setState(() {
        _isLoadingAttachments = true;
      });
      print('Sending multipart request...');

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      print('Response status: ${response.statusCode}');
      print('Response body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(responseBody);
        print('Parsed JSON response: $jsonResponse');

        if (jsonResponse['isSuccess'] == true ||
            (jsonResponse['urlFile'] != null && jsonResponse['status'] == 'UPLOADED')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File uploaded successfully')),
          );
          await _fetchEpicFiles();
        } else {
          print('Upload reported as failed: ${jsonResponse['message'] ?? 'Unknown error'}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: ${jsonResponse['message'] ?? 'Unknown error'}')),
          );
        }
      } else {
        print('Upload failed with status: ${response.statusCode}, reason: ${response.reasonPhrase}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      print('Error uploading file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading file: $e')),
      );
    } finally {
      setState(() {
        _isLoadingAttachments = false;
      });
    }
  }

  Future<List<Task>> fetchTasksByEpicId(String epicId) async {
    final response = await http.get(
      UriHelper.build('/task/by-epic-id?epicId=${widget.epicId}'),
      headers: {'accept': '*/*'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final List<dynamic> data = jsonResponse['data'];
      return data.map((e) => Task.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

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
        // 👈 Bắt sự kiện nhấn
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

  String getTypeIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'task':
        return 'assets/type_task.svg';
      case 'bug':
        return 'assets/type_bug.svg';
      case 'story':
        return 'assets/type_story.svg';
      default:
        return 'assets/type_task.svg'; // fallback
    }
  }

  void _showCreateTaskSheet(BuildContext context) {
    String title = '';
    String selectedType = 'Task';

    final types = ['Task', 'Bug', 'Story'];
    final icons = [
      'assets/type_task.svg',
      'assets/type_bug.svg',
      'assets/type_story.svg',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 16,
          right: 16,
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Create Task', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              TextField(
                decoration: const InputDecoration(labelText: 'Title'),
                onChanged: (val) => title = val,
              ),
              const SizedBox(height: 16),

              const Text('Issue Type', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              ...List.generate(types.length, (index) {
                final type = types[index];
                final selected = selectedType == type;
                return InkWell(
                  onTap: () {
                    setModalState(() {
                      selectedType = type;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: selected ? Colors.blue : Colors.grey.shade300),
                    ),
                    child: ListTile(
                      leading: SvgPicture.asset(icons[index], width: 24, height: 24),
                      title: Text(type),
                      trailing: selected ? const Icon(Icons.check, color: Colors.blue) : null,
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _createTask(title, selectedType, context),
                  child: const Text('Create Task'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createTask(
    String title,
    String type,
    BuildContext context,
  ) async {
    if (title.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Title cannot be empty")));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final accountId = prefs.getInt('accountId');
    final projectId = epicData?.projectId;
    final epicId = epicData?.id;
    final sprintId = epicData?.sprintId;
    final now = DateTime.now().toIso8601String();
    print('accountId: $accountId, projectId: $projectId, epicId: $epicId, sprintId: $sprintId');

    final payload = {
      "reporterId": accountId,
      "projectId": projectId,
      "epicId": epicId,
      "sprintId": sprintId,
      "type": type.toUpperCase(),
      "title": title,
      "createdBy": accountId,
      "dependencies": [],
    };

    try {
      final response = await http.post(
        UriHelper.build('/task'),
        headers: {'Content-Type': 'application/json', 'Accept': '*/*'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body);
        if (json['isSuccess']) {
          final newTask = Task.fromJson(json['data']);
          setState(() {
            _tasks.insert(0, newTask);
          });
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Task created successfully")),
          );
        } else {
          throw Exception(json['message']);
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to create task: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (epicData == null) {
      return const Scaffold(body: Center(child: Text('Epic not found')));
    }

    return Scaffold(
      backgroundColor: Color(0xFFF5F6F8),
      appBar: AppBar(
        title: Row(
          children: [
            SvgPicture.asset('assets/type_epic.svg', width: 20, height: 20),
            const SizedBox(width: 8),
            Text(
              epicData!.id,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              epicData!.name,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
            const SizedBox(height: 8), // khoảng cách giữa name và dropdown
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
                epicData!.status,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _statusColor(epicData!.status),
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
            // Description Card
            buildCard(
              title: "Description",
              child: Text(
                epicData!.description.isNotEmpty
                    ? epicData!.description
                    : "Add a description...",
              ),
            ),

            // Attachments
            buildCard(
              title: "Attachments",
              badgeCount: _epicFiles.length,
              onTap: () async {
                setState(() {
                  _isAttachmentsExpanded = !_isAttachmentsExpanded;
                });
                if (_isAttachmentsExpanded && _epicFiles.isEmpty) {
                  await _fetchEpicFiles();
                }
              },
              child:
                  _isAttachmentsExpanded
                      ? _isLoadingAttachments
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ..._epicFiles.map(
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
                                onPressed: _uploadFile,
                                icon: const Icon(Icons.add),
                                label: const Text("Add attachment"),
                              ),
                            ],
                          )
                      : const SizedBox.shrink(),
            ),

            // Parent
            buildCard(title: "Parent work item", child: const Text("None")),

            buildCard(
              title: "Task Item",
              badgeCount: _tasks.length,
              onTap: () {
                setState(() {
                  _isTaskExpanded = !_isTaskExpanded;
                });
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress bar
                  Builder(
                    builder: (_) {
                      final total = _tasks.length;
                      if (total == 0) return const SizedBox();

                      final done =
                          _tasks.where((s) => s.status == 'DONE').length;
                      final inProgress =
                          _tasks.where((s) => s.status == 'IN_PROGRESS').length;
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
                                        //borderRadius: const BorderRadius.horizontal(right: Radius.circular(4)),
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

                  _isTaskExpanded
                      ? Column(
                        children: [
                          ..._tasks.map(
                            (task) => ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            TaskDetailPage(taskId: task.id),
                                  ),
                                );
                              },
                              dense: true,
                              visualDensity: VisualDensity.compact,
                              contentPadding: EdgeInsets.symmetric(vertical: 4),
                              leading: SvgPicture.asset(
                                getTypeIcon(task.type),
                                width: 18,
                                height: 18,
                              ),
                              title: Text(
                                task.title,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                task.id,
                                style: TextStyle(
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
                                  color: _statusColor(task.status ?? ''),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  task.status ?? "UNKNOWN",
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () => _showCreateTaskSheet(context),
                            icon: const Icon(Icons.add),
                            label: const Text("Create task"),
                          ),
                        ],
                      )
                      : const SizedBox.shrink(),
                ],
              ),
            ),

            buildCard(
              title: "Assignee",
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
                      (epicData!.assignedByPicture != null &&
                              epicData!.assignedByPicture!.isNotEmpty)
                          ? NetworkImage(epicData!.assignedByPicture!)
                          : null,
                  backgroundColor: Colors.blue[100],
                  child:
                      (epicData!.assignedByPicture == null ||
                              epicData!.assignedByPicture!.isEmpty)
                          ? Text(
                            (epicData!.assignedByFullname
                                    ?.split(' ')
                                    .last
                                    .characters
                                    .first ??
                                'U'),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          )
                          : null,
                ),
                title: Text(
                  epicData!.assignedByFullname ?? 'Unassigned',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),

            // Details card
            buildCard(
              title: "Details",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildDetailRow(
                    "Start Date",
                    epicData!.startDate.toIso8601String().split("T").first ??
                        'None',
                  ),
                  buildDetailRow(
                    "End Date",
                    epicData!.endDate.toIso8601String().split("T").first ??
                        'None',
                  ),
                  buildDetailRow("Sprint", epicData!.sprintName ?? 'None'),
                ],
              ),
            ),

            // Reporter
            buildCard(
              title: "Reporter",
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
                      (epicData!.reporterPicture != null &&
                              epicData!.reporterPicture!.isNotEmpty)
                          ? NetworkImage(epicData!.reporterPicture!)
                          : null,
                  backgroundColor: Colors.grey[300],
                  child:
                      (epicData!.reporterPicture == null ||
                              epicData!.reporterPicture!.isEmpty)
                          ? Text(
                            (epicData!.reporterFullname
                                    ?.split(' ')
                                    .last
                                    .characters
                                    .first ??
                                'U'),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          )
                          : null,
                ),
                title: Text(
                  epicData!.reporterFullname ?? 'Unassigned',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            EpicCommentSection(epicId: epicData?.id ?? ''),
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
