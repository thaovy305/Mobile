import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Helper/UriHelper.dart';
import '../Models/Subtask.dart';
import '../Models/SubtaskFile.dart';
import '../Models/Task.dart';
import 'EditDescriptionPage.dart';
import 'SubtaskCommentSection.dart';

class SubtaskDetailPage extends StatefulWidget {
  final String subtaskId;

  const SubtaskDetailPage({super.key, required this.subtaskId});

  @override
  State<SubtaskDetailPage> createState() => _SubtaskDetailPageState();
}

class _SubtaskDetailPageState extends State<SubtaskDetailPage> {
  Subtask? subtask;
  bool isLoading = true;
  Task? task;
  bool _isAttachmentsExpanded = false;
  List<SubtaskFile> _subtaskFiles = [];
  bool _isLoadingAttachments = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    loadData();
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

  Future<void> loadData() async {
    await fetchSubtaskDetail();
    if (subtask != null && subtask!.taskId != null) {
      await fetchTaskDetail(subtask!.taskId!);
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchTaskDetail(String taskId) async {
    try {
      if (!await validateCredentials()) return;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';
      final uri = UriHelper.build('/task/$taskId');


      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['isSuccess'] == true) {
          setState(() {
            task = Task.fromJson(data['data']);
            _errorMessage = null;
          });
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'Failed to load task';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load task: ${data['message'] ?? 'Unknown error'}')),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Server error: ${response.statusCode}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response.statusCode}')),
        );
      }
    } catch (e) {

      setState(() {
        _errorMessage = 'Network error: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
  }

  Future<void> fetchSubtaskDetail() async {
    try {
      if (!await validateCredentials()) return;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';
      final uri = UriHelper.build('/subtask/${widget.subtaskId}');


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
            subtask = Subtask.fromJson(jsonBody['data']);
            isLoading = false;
            _errorMessage = null;
          });
        } else {
          showError(jsonBody['message'] ?? 'Subtask not found');
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
      _errorMessage = message;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> fetchSubtaskFiles() async {
    setState(() {
      _isLoadingAttachments = true;
      _errorMessage = null;
    });
    try {
      if (!await validateCredentials()) return;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';
      final uri = UriHelper.build('/subtaskfile/by-subtask/${widget.subtaskId}');

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
          final List<SubtaskFile> files =
          (jsonData['data'] as List).map((e) => SubtaskFile.fromJson(e)).toList();
          setState(() {
            _subtaskFiles = files;
            _errorMessage = null;
          });
        } else {
          setState(() {
            _errorMessage = jsonData['message'] ?? 'Failed to load subtask files';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load subtask files: ${jsonData['message'] ?? 'Unknown error'}')),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Server error: ${response.statusCode}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response.statusCode}')),
        );
      }
    } catch (e) {

      setState(() {
        _errorMessage = 'Network error: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
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

      final uri = UriHelper.build('/subtaskfile/upload');

      var request = http.MultipartRequest('POST', uri);

      request.headers['Content-Type'] = 'multipart/form-data';
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = '*/*';

      request.fields['subtaskId'] = widget.subtaskId;
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
          await fetchSubtaskFiles();
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

  Future<void> updateSubtaskStatus(String newStatus) async {
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

      final uri = UriHelper.build('/subtask/${widget.subtaskId}/status');
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
            subtask!.status = newStatus;
            _errorMessage = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Status updated successfully')),
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
        _errorMessage = 'Error updating subtask status: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating subtask status: $e')),
      );
    }
  }

  Future<void> updateSubtask({
    int? assignedBy,
    String? title,
    String? description,
    String? priority,
    DateTime? startDate,
    DateTime? endDate,
    int? reporterId,
    int? createdBy,
  }) async {
    try {
      if (!await validateCredentials()) return;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';
      final accountId = prefs.getInt('accountId');

      if (accountId == null || subtask == null) {
        setState(() {
          _errorMessage = 'Missing account or subtask info';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Missing account or subtask info')),
        );
        return;
      }

      final uri = UriHelper.build('/subtask/${widget.subtaskId}');
      final payload = {
        'assignedBy': assignedBy ?? subtask!.assignedBy,
        'priority': priority ?? subtask!.priority,
        'title': title ?? subtask!.title,
        'description': description ?? subtask!.description,
        'startDate': (startDate ?? subtask!.startDate)?.toIso8601String(),
        'endDate': (endDate ?? subtask!.endDate)?.toIso8601String(),
        'reporterId': reporterId ?? subtask!.reporterId,
        'createdBy': accountId,
      };


      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
        body: jsonEncode(payload),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['isSuccess']) {
        setState(() {
          _errorMessage = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subtask updated successfully')),
        );
        await fetchSubtaskDetail();
      } else {
        setState(() {
          _errorMessage = data['message'] ?? 'Failed to update subtask';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update subtask: ${data['message'] ?? response.statusCode}'),
          ),
        );
      }
    } catch (e) {

      setState(() {
        _errorMessage = 'Error updating subtask: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating subtask: $e')),
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
        updateSubtaskStatus(status);
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
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status.replaceAll('_', ' '),
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
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

  String _getTaskTypeIcon(String type) {
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

  final List<String> priorityOptions = [
    'HIGHEST',
    'HIGH',
    'MEDIUM',
    'LOW',
    'LOWEST',
  ];

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (subtask == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Subtask not found${_errorMessage != null ? ': $_errorMessage' : ''}',
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    _errorMessage = null;
                  });
                  loadData();
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
            SvgPicture.asset('assets/type_subtask.svg', width: 20, height: 20),
            const SizedBox(width: 8),
            Text(
              subtask!.id ?? '',
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
                    subtask!.title ?? 'No title',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 18,
                  backgroundImage: subtask!.assignedByPicture != null &&
                      subtask!.assignedByPicture!.isNotEmpty
                      ? NetworkImage(subtask!.assignedByPicture!)
                      : null,
                  backgroundColor: Colors.blue[100],
                  child: subtask!.assignedByPicture == null || subtask!.assignedByPicture!.isEmpty
                      ? Text(
                    (subtask!.assignedByName?.split(' ').last.characters.first ?? 'U'),
                    style: const TextStyle(color: Colors.black),
                  )
                      : null,
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
                subtask!.status ?? '',
                style: const TextStyle(color: Colors.black),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _statusColor(subtask!.status ?? 'TO_DO'),
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
              child: GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditDescriptionPage(
                        initialDescription: subtask!.description,
                      ),
                    ),
                  );
                  if (result != null && result != subtask!.description) {
                    await updateSubtask(description: result);
                    setState(() {
                      subtask = subtask!.copyWith(description: result);
                      _errorMessage = null;
                    });
                  }
                },
                child: Text(
                  subtask!.description?.isNotEmpty == true ? subtask!.description! : 'Add a description...',
                  style: TextStyle(
                    color: subtask!.description?.isNotEmpty == true ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),
            buildCard(
              title: 'Attachments',
              badgeCount: _subtaskFiles.length,
              onTap: () async {
                setState(() {
                  _isAttachmentsExpanded = !_isAttachmentsExpanded;
                });
                if (_isAttachmentsExpanded && _subtaskFiles.isEmpty) {
                  await fetchSubtaskFiles();
                }
              },
              child: _isAttachmentsExpanded
                  ? _isLoadingAttachments
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ..._subtaskFiles.map(
                        (file) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
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
                    SvgPicture.asset(
                      _getTaskTypeIcon(task?.type ?? 'TASK'),
                      width: 20,
                      height: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (task != null)
                            Text(
                              task!.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          Text(
                            subtask!.taskId ?? '',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor(subtask!.status ?? ''),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        subtask!.status ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            buildCard(
              title: 'Assignee',
              child: ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 2,
                  horizontal: 0,
                ),
                visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                leading: CircleAvatar(
                  radius: 13,
                  backgroundImage: subtask!.assignedByPicture != null &&
                      subtask!.assignedByPicture!.isNotEmpty
                      ? NetworkImage(subtask!.assignedByPicture!)
                      : null,
                  backgroundColor: Colors.blue[100],
                  child: (subtask!.assignedByPicture == null || subtask!.assignedByPicture!.isEmpty)
                      ? Text(
                    (subtask!.assignedByName?.split(' ').last.characters.first ?? 'U'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  )
                      : null,
                ),
                title: Text(
                  subtask?.assignedByName ?? 'Unassigned',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            buildCard(
              title: 'Details',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildDetailRow(
                    'Priority',
                    subtask?.priority ?? 'None',
                    onTap: () async {
                      final selected = await showDialog<String>(
                        context: context,
                        builder: (BuildContext context) {
                          String? tempPriority = subtask?.priority;
                          return AlertDialog(
                            title: const Text('Edit Priority'),
                            content: StatefulBuilder(
                              builder: (context, setState) {
                                return DropdownButton<String>(
                                  value: tempPriority,
                                  isExpanded: true,
                                  items: priorityOptions.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      tempPriority = newValue;
                                    });
                                  },
                                );
                              },
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, null),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, tempPriority),
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                      if (selected != null && selected != subtask?.priority) {
                        await updateSubtask(priority: selected);
                      }
                    },
                  ),
                  buildDetailRow(
                    'Start Date',
                    subtask?.startDate?.toIso8601String().split('T').first ?? 'None',
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: subtask?.startDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        locale: const Locale('vi', 'VN'),
                      );
                      if (picked != null) {
                        final pickedWithHour = DateTime(picked.year, picked.month, picked.day, 12);
                        final pickedUtc = pickedWithHour.toUtc();
                        await updateSubtask(
                          startDate: pickedUtc,
                          endDate: subtask!.endDate,
                        );
                        setState(() {
                          subtask = subtask!.copyWith(startDate: pickedUtc);
                          _errorMessage = null;
                        });
                      }
                    },
                  ),
                  buildDetailRow(
                    'End Date',
                    subtask?.endDate?.toIso8601String().split('T').first ?? 'None',
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: subtask?.endDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        locale: const Locale('vi', 'VN'),
                      );
                      if (picked != null) {
                        final pickedWithHour = DateTime(picked.year, picked.month, picked.day, 12);
                        final pickedUtc = pickedWithHour.toUtc();
                        await updateSubtask(endDate: pickedUtc);
                        setState(() {
                          subtask = subtask!.copyWith(endDate: pickedUtc);
                          _errorMessage = null;
                        });
                      }
                    },
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
                  backgroundImage: subtask!.reporterPicture != null &&
                      subtask!.reporterPicture!.isNotEmpty
                      ? NetworkImage(subtask!.reporterPicture!)
                      : null,
                  backgroundColor: Colors.blue[100],
                  child: (subtask!.reporterPicture == null || subtask!.reporterPicture!.isEmpty)
                      ? Text(
                    (subtask!.reporterName?.split(' ').last.characters.first ?? 'U'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  )
                      : null,
                ),
                title: Text(
                  subtask!.reporterName ?? 'Unassigned',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            SubtaskCommentSection(subtaskId: subtask?.id ?? ''),
          ],
        ),
      ),
    );
  }

  Widget buildDetailRow(String title, String value, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$title: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Text(value, style: const TextStyle(color: Colors.black87)),
            ),
            const SizedBox(width: 15),
          ],
        ),
      ),
    );
  }
}