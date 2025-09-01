import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../../Helper/UriHelper.dart';
import 'RiskPage.dart';

class RiskSolutionItem {
  final int id;
  final int riskId;
  final String? mitigationPlan;
  final String? contingencyPlan;
  final String createdAt;
  final String updatedAt;

  RiskSolutionItem({
    required this.id,
    required this.riskId,
    this.mitigationPlan,
    this.contingencyPlan,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RiskSolutionItem.fromJson(Map<String, dynamic> json) {
    return RiskSolutionItem(
      id: json['id'] ?? 0,
      riskId: json['riskId'] ?? 0,
      mitigationPlan: json['mitigationPlan'],
      contingencyPlan: json['contingencyPlan'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class RiskFileItem {
  final int id;
  final int riskId;
  final String fileName;
  final String fileUrl;
  final String uploadedAt;

  RiskFileItem({
    required this.id,
    required this.riskId,
    required this.fileName,
    required this.fileUrl,
    required this.uploadedAt,
  });

  factory RiskFileItem.fromJson(Map<String, dynamic> json) {
    return RiskFileItem(
      id: json['id'] ?? 0,
      riskId: json['riskId'] ?? 0,
      fileName: json['fileName'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      uploadedAt: json['uploadedAt'] ?? '',
    );
  }
}

class RiskCommentItem {
  final int id;
  final int riskId;
  final int accountId;
  final String? accountFullName;
  final String? accountUserName;
  final String? accountPicture;
  final String comment;
  final String createdAt;

  RiskCommentItem({
    required this.id,
    required this.riskId,
    required this.accountId,
    this.accountFullName,
    this.accountUserName,
    this.accountPicture,
    required this.comment,
    required this.createdAt,
  });

  factory RiskCommentItem.fromJson(Map<String, dynamic> json) {
    return RiskCommentItem(
      id: json['id'] ?? 0,
      riskId: json['riskId'] ?? 0,
      accountId: json['accountId'] ?? 0,
      accountFullName: json['accountFullName'],
      accountUserName: json['accountUserName'],
      accountPicture: json['accountPicture'],
      comment: json['comment'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}

class ActivityLogItem {
  final int id;
  final int createdBy;
  final String? createdByName;
  final String message;
  final String createdAt;

  ActivityLogItem({
    required this.id,
    required this.createdBy,
    this.createdByName,
    required this.message,
    required this.createdAt,
  });

  factory ActivityLogItem.fromJson(Map<String, dynamic> json) {
    return ActivityLogItem(
      id: json['id'] ?? 0,
      createdBy: json['createdBy'] ?? 0,
      createdByName: json['createdByName'],
      message: json['message'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}

class Assignee {
  final int id;
  final String? fullName;
  final String userName;
  final String? picture;

  Assignee({
    required this.id,
    this.fullName,
    required this.userName,
    this.picture,
  });

  factory Assignee.fromJson(Map<String, dynamic> json) {
    return Assignee(
      id: json['accountId'] ?? 0,
      fullName: json['fullName'],
      userName: json['username'] ?? '',
      picture: json['picture'],
    );
  }
}

class RiskDetailPage extends StatefulWidget {
  final RiskItem risk;
  final String projectKey;

  const RiskDetailPage({super.key, required this.risk, required this.projectKey});

  @override
  State<RiskDetailPage> createState() => _RiskDetailPageState();
}

class _RiskDetailPageState extends State<RiskDetailPage> {
  late RiskItem editableRisk;
  late Future<List<DynamicCategory>> riskTypesFuture;
  late Future<List<DynamicCategory>> impactCategoriesFuture;
  late Future<List<DynamicCategory>> probabilityCategoriesFuture;
  late Future<List<Assignee>> assigneesFuture;
  List<RiskSolutionItem> riskSolutions = [];
  List<RiskFileItem> riskFiles = [];
  List<RiskCommentItem> riskComments = [];
  List<ActivityLogItem> activityLogs = [];
  bool isRiskSolutionLoading = true;
  bool isRiskFilesLoading = true;
  bool isRiskCommentsLoading = true;
  bool isActivityLogsLoading = true;
  String newMitigation = '';
  String newContingency = '';
  String newComment = '';
  int? editIndexMitigation;
  String editTextMitigation = '';
  int? editIndexContingency;
  String editTextContingency = '';
  int? editingCommentId;
  String editedCommentContent = '';
  int? currentAccountId;
  int? hoveredFileId;

  @override
  void initState() {
    super.initState();
    editableRisk = widget.risk;
    riskTypesFuture = fetchRiskTypes();
    impactCategoriesFuture = fetchCategories('risk_impact_level');
    probabilityCategoriesFuture = fetchCategories('risk_probability_level');
    assigneesFuture = fetchAssignees();
    fetchRiskSolution();
    fetchRiskFiles();
    fetchRiskComments();
    fetchActivityLogs();
    fetchCurrentAccountId();
  }

  Future<void> fetchCurrentAccountId() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      final user = json.decode(userJson);
      setState(() {
        currentAccountId = user['id'] ?? (prefs.getInt('accountId') ?? 0); // Fallback to accountId
      });
    } else {
      final accountId = prefs.getInt('accountId');
      setState(() {
        currentAccountId = accountId ?? 0; // Fallback nếu userJson null
      });
    }
  }

  Future<List<DynamicCategory>> fetchRiskTypes() async {
    return fetchCategories('risk_type');
  }

  Future<List<DynamicCategory>> fetchCategories(String categoryGroup) async {
    final url = UriHelper.build('/dynamiccategory/by-category-group?categoryGroup=$categoryGroup');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
        'Accept': '*/*',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> categories = data['data'];
      final seenNames = <String>{};
      final uniqueCategories = categories.where((item) {
        final name = item['name'] as String? ?? '';
        if (seenNames.contains(name)) return false;
        seenNames.add(name);
        return true;
      }).toList();
      return uniqueCategories.map((item) => DynamicCategory.fromJson(item)).toList();
    }
    throw Exception('Failed to load $categoryGroup');
  }

  // Future<List<Assignee>> fetchAssignees() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString('accessToken') ?? '';
  //   final projectResponse = await http.get(
  //     UriHelper.build('/project/by-key?projectKey=${widget.projectKey}'),
  //     headers: {'Authorization': 'Bearer $token'},
  //   );
  //   if (projectResponse.statusCode != 200) throw Exception('Failed to load project');
  //   final projectData = json.decode(projectResponse.body);
  //   final projectId = projectData['data']['id'];
  //
  //   final response = await http.get(
  //     UriHelper.build('/project/$projectId/projectmember/with-positions'),
  //     headers: {'Authorization': 'Bearer $token'},
  //   );
  //   if (response.statusCode == 200) {
  //     final data = json.decode(response.body);
  //     return (data['data'] as List)
  //         .map((m) => Assignee.fromJson(m))
  //         .toList();
  //   }
  //   throw Exception('Failed to load assignees');
  // }

  Future<List<Assignee>> fetchAssignees() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    final projectResponse = await http.get(
      UriHelper.build('/project/view-by-key?projectKey=${widget.projectKey}'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (projectResponse.statusCode != 200) throw Exception('Failed to load project');
    final projectData = json.decode(projectResponse.body);
    final projectId = projectData['data']['id'];

    final response = await http.get(
      UriHelper.build('/project/$projectId/projectmember/with-positions'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['isSuccess'] == true && data['data'] != null) {
        final members = data['data'] as List? ?? [];
        return members.map((m) => Assignee.fromJson(m)).toList();
      }
      return [];
    }
    throw Exception('Failed to load assignees: ${response.statusCode}');
  }

  Future<void> fetchRiskSolution() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    final uri = UriHelper.build('/risksolution/by-risk/${widget.risk.id}');
    try {
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded['data'];
        setState(() {
          riskSolutions = data != null
              ? (data as List).map((item) => RiskSolutionItem.fromJson(item)).toList()
              : [];
          isRiskSolutionLoading = false;
        });
      } else {
        setState(() {
          isRiskSolutionLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isRiskSolutionLoading = false;
      });
      print('Error fetching risk solutions: $e');
    }
  }

  Future<void> fetchRiskFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    final uri = UriHelper.build('/riskfile/by-risk/${widget.risk.id}');
    try {
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded['data'];
        setState(() {
          riskFiles = data != null
              ? (data as List).map((item) => RiskFileItem.fromJson(item)).toList()
              : [];
          isRiskFilesLoading = false;
        });
      } else {
        setState(() {
          isRiskFilesLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isRiskFilesLoading = false;
      });
      print('Error fetching risk files: $e');
    }
  }

  Future<void> fetchRiskComments() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    final uri = UriHelper.build('/riskcomment/by-risk/${widget.risk.id}');
    try {
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded['data'];
        setState(() {
          riskComments = data != null
              ? (data as List).map((item) => RiskCommentItem.fromJson(item)).toList()
              : [];
          isRiskCommentsLoading = false;
        });
      } else {
        setState(() {
          isRiskCommentsLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isRiskCommentsLoading = false;
      });
      print('Error fetching risk comments: $e');
    }
  }

  Future<void> fetchActivityLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    final uri = UriHelper.build('/activitylog/risk/${widget.risk.riskKey}');
    try {
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded['data'];
        setState(() {
          activityLogs = data != null
              ? (data as List).map((item) => ActivityLogItem.fromJson(item)).toList()
              : [];
          isActivityLogsLoading = false;
        });
      } else {
        setState(() {
          isActivityLogsLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isActivityLogsLoading = false;
      });
      print('Error fetching activity logs: $e');
    }
  }

  Future<void> updateRiskField(String endpoint, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    final url = UriHelper.build('/risk/${widget.risk.id}/$endpoint?createdBy=$currentAccountId');
    try {
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(value),
      );
      if (response.statusCode == 200) {
        final updatedData = json.decode(response.body)['data'];
        setState(() {
          if (endpoint == 'title') editableRisk.title = updatedData['title'] ?? editableRisk.title;
          if (endpoint == 'status') editableRisk.status = updatedData['status'] ?? editableRisk.status;
          if (endpoint == 'type') editableRisk.type = updatedData['type'] ?? editableRisk.type;
          if (endpoint == 'responsible') {
            editableRisk.responsibleId = updatedData['responsibleId'] ?? editableRisk.responsibleId;
            editableRisk.responsibleFullName = updatedData['responsibleFullName'];
            editableRisk.responsibleUserName = updatedData['responsibleUserName'];
            editableRisk.responsiblePicture = updatedData['responsiblePicture'];
          }
          if (endpoint == 'dueDate') editableRisk.dueDate = updatedData['dueDate'];
          if (endpoint == 'description') editableRisk.description = updatedData['description'] ?? editableRisk.description;
          if (endpoint == 'impactLevel') {
            editableRisk.impactLevel = updatedData['impactLevel'] ?? editableRisk.impactLevel;
            editableRisk.severityLevel = updatedData['severityLevel'] ?? editableRisk.severityLevel;
          }
          if (endpoint == 'probability') {
            editableRisk.probability = updatedData['probability'] ?? editableRisk.probability;
            editableRisk.severityLevel = updatedData['severityLevel'] ?? editableRisk.severityLevel;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully updated $endpoint')),
        );
        await fetchActivityLogs(); // Gọi lại activity logs sau khi cập nhật
      } else {
        throw Exception('Failed to update $endpoint: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update $endpoint')),
      );
      print('Error updating $endpoint: $e');
    }
  }

  Future<void> createRiskSolution({String? mitigationPlan, String? contingencyPlan}) async {
    if ((mitigationPlan?.trim().isEmpty ?? true) && (contingencyPlan?.trim().isEmpty ?? true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mitigation or contingency plan cannot be empty')),
      );
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    final url = UriHelper.build('/risksolution');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'riskId': widget.risk.id,
          'mitigationPlan': mitigationPlan,
          'contingencyPlan': contingencyPlan,
          'createdBy': currentAccountId,
        }),
      );
      if (response.statusCode == 200) {
        await fetchRiskSolution();
        await fetchActivityLogs();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully added ${mitigationPlan != null ? 'mitigation' : 'contingency'} plan')),
        );
      } else {
        throw Exception('Failed to create risk solution: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add plan')),
      );
      print('Error creating risk solution: $e');
    }
  }

  Future<void> updateRiskSolution(int id, {String? mitigationPlan, String? contingencyPlan}) async {
    if ((mitigationPlan?.trim().isEmpty ?? true) && (contingencyPlan?.trim().isEmpty ?? true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plan cannot be empty')),
      );
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    final url = UriHelper.build('/risksolution/$id/${mitigationPlan != null ? 'mitigation' : 'contingency'}');
    try {
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(mitigationPlan ?? contingencyPlan),
      );
      if (response.statusCode == 200) {
        await fetchRiskSolution();
        await fetchActivityLogs();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully updated ${mitigationPlan != null ? 'mitigation' : 'contingency'} plan')),
        );
      } else {
        throw Exception('Failed to update risk solution: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update plan')),
      );
      print('Error updating risk solution: $e');
    }
  }

  Future<void> deleteRiskSolution(int id, String type) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    final url = UriHelper.build('/risksolution/$id/$type');
    try {
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        await fetchRiskSolution();
        await fetchActivityLogs();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully deleted $type plan')),
        );
      } else {
        throw Exception('Failed to delete $type: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete plan')),
      );
      print('Error deleting $type: $e');
    }
  }

  // Future<void> uploadRiskFile(PlatformFile file) async {
  //   if (file.size > 10 * 1024 * 1024) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('File size exceeds 10MB limit')),
  //     );
  //     return;
  //   }
  //   if (currentAccountId == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Account ID not found, please login again')),
  //     );
  //     return;
  //   }
  //
  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString('accessToken') ?? '';
  //   final url = UriHelper.build('/riskfile/upload');
  //   try {
  //     final request = http.MultipartRequest('POST', url)
  //       ..headers['Authorization'] = 'Bearer $token'
  //       ..fields['riskId'] = widget.risk.id.toString()
  //       ..fields['fileName'] = file.name
  //       ..fields['uploadedBy'] = currentAccountId.toString()
  //       ..files.add(http.MultipartFile.fromBytes('file', file.bytes!, filename: file.name));
  //     final response = await request.send();
  //     if (response.statusCode == 200) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Successfully uploaded file ${file.name}')),
  //       );
  //       await fetchRiskFiles();
  //       await fetchActivityLogs();
  //     } else {
  //       throw Exception('Failed to upload file: ${response.statusCode} - ${await response.stream.bytesToString()}');
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Failed to upload file')),
  //     );
  //     print('Error uploading file: $e');
  //   }
  // }

  Future<void> uploadRiskFile() async {
    // Show dialog to choose between camera, gallery, or file picker
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
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(source: source);
        if (image == null) {
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
        // Use file_picker for other files
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.any,
          allowMultiple: false,
          withData: true,
        );
        if (result == null || result.files.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No file selected')),
          );
          return;
        }
        file = result.files.first;
        fileName = file.name;
      }

      // Check file size (10MB limit)
      if (file.size > 10 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File size exceeds 10MB limit')),
        );
        return;
      }

      // Get accountId from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';
      final accountId = currentAccountId ?? prefs.getInt('accountId');

      if (accountId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account ID not found, please login again')),
        );
        return;
      }

      // Prepare the multipart request
      final url = UriHelper.build('/riskfile/upload');
      var request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $token'
        ..headers['accept'] = '*/*'
        ..headers['Content-Type'] = 'multipart/form-data'
        ..fields['riskId'] = widget.risk.id.toString()
        ..fields['fileName'] = fileName
        ..fields['uploadedBy'] = accountId.toString();

      // Add the file
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Selected file has no valid path or data')),
        );
        return;
      }

      // Send the request
      setState(() {
        isRiskFilesLoading = true;
      });

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      print('Response status: ${response.statusCode}');
      print('Response body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(responseBody);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Successfully uploaded file $fileName')),
          );
          await fetchRiskFiles();
          await fetchActivityLogs();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading file: $e')),
      );
      print('Error uploading file: $e');
    } finally {
      setState(() {
        isRiskFilesLoading = false;
      });
    }
  }

  Future<void> deleteRiskFile(int id, int currentAccountId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    final url = UriHelper.build('/riskfile/$id?createdBy=$currentAccountId');
    try {
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully deleted file')),
        );
        await fetchRiskFiles();
        await fetchActivityLogs();
      } else {
        throw Exception('Failed to delete file: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete file')),
      );
      print('Error deleting file: $e');
    }
  }

  // Future<void> createRiskComment(String comment) async {
  //   if (comment.trim().isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Comment cannot be empty')),
  //     );
  //     return;
  //   }
  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString('accessToken') ?? '';
  //   final url = UriHelper.build('/riskcomment');
  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Content-Type': 'application/json',
  //       },
  //       body: jsonEncode({
  //         'riskId': widget.risk.id,
  //         'accountId': currentAccountId,
  //         'comment': comment,
  //       }),
  //     );
  //     if (response.statusCode == 200) {
  //       await fetchRiskComments();
  //       await fetchActivityLogs();
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Successfully added comment')),
  //       );
  //     } else {
  //       throw Exception('Failed to create comment: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Failed to add comment')),
  //     );
  //     print('Error creating comment: $e');
  //   }
  // }

  Future<void> createRiskComment(String comment) async {
    if (comment.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment cannot be empty')),
      );
      return;
    }
    if (currentAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account ID not found, please login again')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    final url = UriHelper.build('/riskcomment');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'riskId': widget.risk.id,
          'accountId': currentAccountId,
          'comment': comment,
        }),
      );
      if (response.statusCode == 201) {
        await fetchRiskComments();
        await fetchActivityLogs();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully added comment')),
        );
      } else {
        throw Exception('Failed to create comment: ${response.statusCode} - ${json.decode(response.body)['message'] ?? ''}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add comment')),
      );
      print('Error creating comment: $e');
    }
  }

  Future<void> updateRiskComment(int id, String comment) async {
    if (comment.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment cannot be empty')),
      );
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    final url = UriHelper.build('/riskcomment/$id');
    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'riskId': widget.risk.id,
          'accountId': currentAccountId,
          'comment': comment,
        }),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully updated comment')),
        );
        await fetchRiskComments();
        await fetchActivityLogs();
      } else {
        throw Exception('Failed to update comment: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update comment')),
      );
      print('Error updating comment: $e');
    }
  }

  Future<void> deleteRiskComment(int id, int currentAccountId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    final url = UriHelper.build('/riskcomment/$id?createdBy=$currentAccountId');
    try {
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully deleted comment')),
        );
        await fetchRiskComments();
        await fetchActivityLogs();
      } else {
        throw Exception('Failed to delete comment: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete comment')),
      );
      print('Error deleting comment: $e');
    }
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "Unknown";
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return "Invalid";
    }
  }

  Color getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case "low":
        return Colors.green;
      case "medium":
        return Colors.orange;
      case "high":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget buildInfoRowWithAvatar(String label, String? fullName, String? username, String? pictureUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          CircleAvatar(
            radius: 18,
            backgroundImage: pictureUrl != null && pictureUrl.isNotEmpty ? NetworkImage(pictureUrl) : null,
            child: pictureUrl == null || pictureUrl.isEmpty ? const Icon(Icons.person, size: 18) : null,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(fullName ?? username ?? 'Not assigned')),
        ],
      ),
    );
  }

  Widget buildLevelLabel(String title, String value) {
    final displayValue = value.isNotEmpty ? value : "Unknown";
    final color = getLevelColor(displayValue);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            displayValue,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final String createdBy = editableRisk.creatorFullName ?? editableRisk.creatorUserName ?? 'Unknown';
    final String responsible = editableRisk.responsibleFullName ?? editableRisk.responsibleUserName ?? 'Not assigned';
    final String dueDate = formatDate(editableRisk.dueDate);
    final String createdAt = formatDate(editableRisk.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: Text(editableRisk.title),
        backgroundColor: Colors.redAccent,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.grey[50],
        child: SingleChildScrollView(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.only(bottom: 24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [Chip(label: Text(editableRisk.riskKey))],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: TextEditingController(text: editableRisk.title),
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() => editableRisk.title = value),
                    onSubmitted: (value) => updateRiskField('title', value),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text("Status: ", style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: editableRisk.status,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => editableRisk.status = value);
                              updateRiskField('status', value);
                            }
                          },
                          items: ['OPEN', 'MITIGATED', 'CLOSED'].map((status) {
                            return DropdownMenuItem<String>(
                              value: status,
                              child: Text(status),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<List<DynamicCategory>>(
                    future: riskTypesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return const Text("Failed to load risk types");
                      }
                      final types = snapshot.data!;
                      return Row(
                        children: [
                          const Text("Type: ", style: TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: editableRisk.type,
                              onChanged: (value) {
                                if (value != null && value != editableRisk.type) {
                                  setState(() => editableRisk.type = value);
                                  updateRiskField('type', value);
                                }
                              },
                              items: types.map((type) => DropdownMenuItem(
                                value: type.name,
                                child: Text(type.label),
                              )).toList(),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // FutureBuilder<List<Assignee>>(
                  //   future: assigneesFuture,
                  //   builder: (context, snapshot) {
                  //     if (snapshot.connectionState == ConnectionState.waiting) {
                  //       return const CircularProgressIndicator();
                  //     } else if (snapshot.hasError) {
                  //       return const Text("Failed to load assignees");
                  //     }
                  //     final assignees = snapshot.data!;
                  //     return Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         const Text(
                  //           "Assignee",
                  //           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  //         ),
                  //         const SizedBox(height: 6),
                  //         DropdownButton<int>(
                  //           isExpanded: true,
                  //           value: editableRisk.responsibleId,
                  //           onChanged: (value) async {
                  //             if (value != null) {
                  //               final selected = assignees.firstWhere(
                  //                     (a) => a.id == value,
                  //                 orElse: () => Assignee(id: 0, fullName: null, userName: 'Not assigned', picture: null),
                  //               );
                  //               setState(() {
                  //                 editableRisk.responsibleId = value;
                  //                 editableRisk.responsibleFullName = selected.fullName;
                  //                 editableRisk.responsibleUserName = selected.userName;
                  //                 editableRisk.responsiblePicture = selected.picture;
                  //               });
                  //               await updateRiskField('responsible-id', value);
                  //             } else {
                  //               setState(() {
                  //                 editableRisk.responsibleId = null;
                  //                 editableRisk.responsibleFullName = null;
                  //                 editableRisk.responsibleUserName = null;
                  //                 editableRisk.responsiblePicture = null;
                  //               });
                  //               await updateRiskField('responsible-id', null);
                  //             }
                  //           },
                  //           items: [
                  //             const DropdownMenuItem(value: null, child: Text('No Assignee')),
                  //             ...assignees.map((user) => DropdownMenuItem(
                  //               value: user.id,
                  //               child: Text(user.fullName ?? user.userName),
                  //             )),
                  //           ],
                  //           // decoration: const InputDecoration(
                  //           //   border: OutlineInputBorder(),
                  //           //   hintText: 'Select assignee',
                  //           // ),
                  //         ),
                  //       ],
                  //     );
                  //   },
                  // ),
                  FutureBuilder<List<Assignee>>(
                    future: assigneesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Column(
                          children: [
                            Text("Failed to load assignees: ${snapshot.error}"),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  assigneesFuture = fetchAssignees(); // Retry fetching assignees
                                });
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        );
                      }
                      final assignees = snapshot.data!;
                      // Ensure responsibleId is valid: if it's 0 or not in assignees, set to null
                      final validResponsibleId = editableRisk.responsibleId == 0 ||
                          !assignees.any((a) => a.id == editableRisk.responsibleId)
                          ? null
                          : editableRisk.responsibleId;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Assignee",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 6),
                          DropdownButton<int?>(
                            isExpanded: true,
                            value: validResponsibleId,
                            onChanged: (value) async {
                              final selected = value != null
                                  ? assignees.firstWhere(
                                    (a) => a.id == value,
                                orElse: () => Assignee(
                                    id: 0, fullName: null, userName: 'Not assigned', picture: null),
                              )
                                  : Assignee(
                                  id: 0, fullName: null, userName: 'Not assigned', picture: null);
                              setState(() {
                                editableRisk.responsibleId = value;
                                editableRisk.responsibleFullName = selected.fullName;
                                editableRisk.responsibleUserName = selected.userName;
                                editableRisk.responsiblePicture = selected.picture;
                              });
                              await updateRiskField('responsible-id', value);
                            },
                            items: [
                              const DropdownMenuItem(value: null, child: Text('No Assignee')),
                              ...assignees.map((user) => DropdownMenuItem(
                                value: user.id,
                                child: Text(user.fullName ?? user.userName),
                              )),
                            ],
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text("Due Date: ", style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(
                        child: TextFormField(
                          initialValue: editableRisk.dueDate?.split('T')[0] ?? '',
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Select date',
                          ),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              final newDate = DateFormat('yyyy-MM-dd').format(date) + 'T00:00:00Z';
                              setState(() => editableRisk.dueDate = newDate);
                              updateRiskField('duedate', newDate);
                            }
                          },
                          readOnly: true,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  buildInfoRowWithAvatar(
                    "Created By",
                    editableRisk.creatorFullName,
                    editableRisk.creatorUserName,
                    editableRisk.creatorPicture,
                  ),
                  buildInfoRow("Created At", createdAt),
                  const SizedBox(height: 24),
                  const Text(
                    "Description",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: TextEditingController(text: editableRisk.description),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter description',
                    ),
                    maxLines: 4,
                    onChanged: (value) => setState(() => editableRisk.description = value),
                    onSubmitted: (value) => updateRiskField('description', value),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Scope",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(editableRisk.riskScope.isNotEmpty ? editableRisk.riskScope : "No information"),
                  const SizedBox(height: 24),
                  FutureBuilder<List<DynamicCategory>>(
                    future: impactCategoriesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return const Text("Failed to load impact levels");
                      }
                      final categories = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Impact Level",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 6),
                          ...categories.map((category) => RadioListTile<String>(
                            title: Text(category.label),
                            value: category.name,
                            groupValue: editableRisk.impactLevel,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => editableRisk.impactLevel = value);
                                updateRiskField('impact-level', value);
                              }
                            },
                          )),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  FutureBuilder<List<DynamicCategory>>(
                    future: probabilityCategoriesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return const Text("Failed to load probabilities");
                      }
                      final categories = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Probability",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 6),
                          ...categories.map((category) => RadioListTile<String>(
                            title: Text(category.label),
                            value: category.name,
                            groupValue: editableRisk.probability,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => editableRisk.probability = value);
                                updateRiskField('probability', value);
                              }
                            },
                          )),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  buildLevelLabel("Severity Level", editableRisk.severityLevel),
                  const SizedBox(height: 24),
                  if (isRiskSolutionLoading)
                    const CircularProgressIndicator()
                  else if (riskSolutions.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Mitigation Plan",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        ...riskSolutions.asMap().entries.map((entry) {
                          final index = entry.key;
                          final solution = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: editIndexMitigation == index
                                      ? TextField(
                                    controller: TextEditingController(text: editTextMitigation),
                                    onChanged: (value) => editTextMitigation = value,
                                    onSubmitted: (value) {
                                      updateRiskSolution(solution.id, mitigationPlan: value);
                                      setState(() => editIndexMitigation = null);
                                    },
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: 'Enter mitigation plan',
                                    ),
                                  )
                                      : Text(
                                    solution.mitigationPlan?.isNotEmpty == true
                                        ? solution.mitigationPlan!
                                        : "None",
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(editIndexMitigation == index ? Icons.check : Icons.edit),
                                  onPressed: () {
                                    if (editIndexMitigation == index) {
                                      updateRiskSolution(solution.id, mitigationPlan: editTextMitigation);
                                      setState(() => editIndexMitigation = null);
                                    } else {
                                      setState(() {
                                        editIndexMitigation = index;
                                        editTextMitigation = solution.mitigationPlan ?? '';
                                      });
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => deleteRiskSolution(solution.id, 'mitigation'),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        TextField(
                          decoration: const InputDecoration(
                            hintText: 'Add mitigation plan',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) => newMitigation = value,
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              createRiskSolution(mitigationPlan: value.trim());
                              setState(() => newMitigation = '');
                            }
                          },
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "Contingency Plan",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        ...riskSolutions.asMap().entries.map((entry) {
                          final index = entry.key;
                          final solution = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: editIndexContingency == index
                                      ? TextField(
                                    controller: TextEditingController(text: editTextContingency),
                                    onChanged: (value) => editTextContingency = value,
                                    onSubmitted: (value) {
                                      updateRiskSolution(solution.id, contingencyPlan: value);
                                      setState(() => editIndexContingency = null);
                                    },
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: 'Enter contingency plan',
                                    ),
                                  )
                                      : Text(
                                    solution.contingencyPlan?.isNotEmpty == true
                                        ? solution.contingencyPlan!
                                        : "None",
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(editIndexContingency == index ? Icons.check : Icons.edit),
                                  onPressed: () {
                                    if (editIndexContingency == index) {
                                      updateRiskSolution(solution.id, contingencyPlan: editTextContingency);
                                      setState(() => editIndexContingency = null);
                                    } else {
                                      setState(() {
                                        editIndexContingency = index;
                                        editTextContingency = solution.contingencyPlan ?? '';
                                      });
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => deleteRiskSolution(solution.id, 'contingency'),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        TextField(
                          decoration: const InputDecoration(
                            hintText: 'Add contingency plan',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) => newContingency = value,
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              createRiskSolution(contingencyPlan: value.trim());
                              setState(() => newContingency = '');
                            }
                          },
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),
                  const Text(
                    "Attachments",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  if (isRiskFilesLoading)
                    const CircularProgressIndicator()
                  else if (riskFiles.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: riskFiles.map((file) {
                        return Container(
                          width: 100,
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Opening files is not supported in the app')),
                                ),
                                child: file.fileUrl.contains(RegExp(r'\.(jpg|jpeg|png|gif)$', caseSensitive: false))
                                    ? Image.network(file.fileUrl, height: 80, fit: BoxFit.cover)
                                    : Container(
                                  height: 80,
                                  color: Colors.grey[200],
                                  child: Center(
                                    child: Text(
                                      file.fileName.length > 10 ? '${file.fileName.substring(0, 10)}...' : file.fileName,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              Text(file.fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text(formatDate(file.uploadedAt), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteRiskFile(file.id, currentAccountId!),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    )
                  else
                    const Text("No attachments"),
                  // ElevatedButton(
                  //   onPressed: () async {
                  //     final result = await FilePicker.platform.pickFiles();
                  //     if (result != null && result.files.isNotEmpty) {
                  //       await uploadRiskFile(result.files.first);
                  //     }
                  //   },
                  //   child: const Text('Upload File'),
                  // ),
                  ElevatedButton(
                    onPressed: uploadRiskFile, // Updated to call the new function
                    child: const Text('Upload File'),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Comments",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  if (isRiskCommentsLoading)
                    const CircularProgressIndicator()
                  else if (riskComments.isNotEmpty)
                    Column(
                      children: riskComments.reversed.map((comment) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundImage: comment.accountPicture != null && comment.accountPicture!.isNotEmpty
                                    ? NetworkImage(comment.accountPicture!)
                                    : null,
                                child: comment.accountPicture == null || comment.accountPicture!.isEmpty
                                    ? const Icon(Icons.person, size: 18)
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          comment.accountFullName ?? comment.accountUserName ?? 'User #${comment.accountId}',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          formatDate(comment.createdAt),
                                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    editingCommentId == comment.id
                                        ? Column(
                                      children: [
                                        TextField(
                                          controller: TextEditingController(text: editedCommentContent),
                                          onChanged: (value) => editedCommentContent = value,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            hintText: 'Edit comment',
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                updateRiskComment(comment.id, editedCommentContent);
                                                setState(() => editingCommentId = null);
                                              },
                                              child: const Text('Save', style: TextStyle(color: Colors.green)),
                                            ),
                                            TextButton(
                                              onPressed: () => setState(() => editingCommentId = null),
                                              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                        : Text(comment.comment),
                                    if (comment.accountId == currentAccountId && editingCommentId != comment.id)
                                      Row(
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                editingCommentId = comment.id;
                                                editedCommentContent = comment.comment;
                                              });
                                            },
                                            child: const Text('Edit', style: TextStyle(color: Colors.blue)),
                                          ),
                                          TextButton(
                                            onPressed: () => deleteRiskComment(comment.id, currentAccountId!),
                                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    )
                  else
                    const Text("No comments"),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Add comment',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => newComment = value,
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        createRiskComment(value.trim());
                        setState(() => newComment = '');
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Activity Log",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  if (isActivityLogsLoading)
                    const CircularProgressIndicator()
                  else if (activityLogs.isNotEmpty)
                    Column(
                      children: activityLogs.map((log) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    log.createdByName ?? 'User #${log.createdBy}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    formatDate(log.createdAt),
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(log.message),
                            ],
                          ),
                        );
                      }).toList(),
                    )
                  else
                    const Text("No activity logs"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}