import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../Helper/UriHelper.dart';
import 'RiskDetailPage.dart';

class RiskItem {
  int id;
  String riskKey;
  int createdBy;
  String? creatorFullName;
  String? creatorUserName;
  String? creatorPicture;
  int? responsibleId;
  String? responsibleFullName;
  String? responsibleUserName;
  String? responsiblePicture;
  int projectId;
  String? taskId;
  String? taskTitle;
  String riskScope;
  String title;
  String description;
  String status;
  String type;
  String generatedBy;
  String probability;
  String impactLevel;
  String severityLevel;
  bool isApproved;
  String? dueDate; // Made nullable to handle null from API
  String createdAt;
  String updatedAt;

  RiskItem({
    required this.id,
    required this.riskKey,
    required this.createdBy,
    this.creatorFullName,
    this.creatorUserName,
    this.creatorPicture,
    required this.responsibleId,
    this.responsibleFullName,
    this.responsibleUserName,
    this.responsiblePicture,
    required this.projectId,
    this.taskId,
    this.taskTitle,
    required this.riskScope,
    required this.title,
    required this.description,
    required this.status,
    required this.type,
    required this.generatedBy,
    required this.probability,
    required this.impactLevel,
    required this.severityLevel,
    required this.isApproved,
    this.dueDate, // Made nullable
    required this.createdAt,
    required this.updatedAt,
  });

  factory RiskItem.fromJson(Map<String, dynamic> json) {
    return RiskItem(
      id: json['id'] ?? 0,
      riskKey: json['riskKey'] ?? '',
      createdBy: json['createdBy'] ?? 0,
      creatorFullName: json['creatorFullName'],
      creatorUserName: json['creatorUserName'],
      creatorPicture: json['creatorPicture'],
      responsibleId: json['responsibleId'] ?? 0,
      responsibleFullName: json['responsibleFullName'],
      responsibleUserName: json['responsibleUserName'],
      responsiblePicture: json['responsiblePicture'],
      projectId: json['projectId'] ?? 0,
      taskId: json['taskId'],
      taskTitle: json['taskTitle'],
      riskScope: json['riskScope'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      type: json['type'] ?? '',
      generatedBy: json['generatedBy'] ?? '',
      probability: json['probability'] ?? '',
      impactLevel: json['impactLevel'] ?? '',
      severityLevel: json['severityLevel'] ?? '',
      isApproved: json['isApproved'] ?? false,
      dueDate: json['dueDate'], // Nullable, no default needed
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class DynamicCategory {
  final int id;
  final String name;
  final String label;

  DynamicCategory({required this.id, required this.name, required this.label});

  factory DynamicCategory.fromJson(Map<String, dynamic> json) {
    return DynamicCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      label: json['label'] ?? '',
    );
  }
}

class RiskPage extends StatefulWidget {
  final String projectKey;

  const RiskPage({super.key, required this.projectKey});

  @override
  State<RiskPage> createState() => _RiskPageState();
}

class _RiskPageState extends State<RiskPage> {
  List<RiskItem> risks = [];
  List<DynamicCategory> scopeTypes = [];
  bool isLoading = true;
  bool isError = false;
  String errorMessage = '';

  String scopeFilter = 'ALL';
  String dueDateFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    fetchRisks();
    fetchScopeTypes();
  }

  Future<void> fetchRisks() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    if (token.isEmpty) {
      setState(() {
        isError = true;
        isLoading = false;
        errorMessage = 'Không tìm thấy access token';
      });
      print('Error: No access token found');
      return;
    }

    final uri = UriHelper.build('/risk/by-project-key?projectKey=${widget.projectKey}');
    print('Fetching risks from: $uri with projectKey: ${widget.projectKey}');
    try {
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List<dynamic>? data = decoded['data'];

        if (data == null || data.isEmpty) {
          setState(() {
            isError = true;
            isLoading = false;
            errorMessage = 'Không có rủi ro nào cho dự án này';
          });
          print('Error: No risks found in response data');
          return;
        }

        setState(() {
          risks = data.map((e) => RiskItem.fromJson(e)).toList();
          isLoading = false;
          isError = false;
        });
      } else {
        setState(() {
          isError = true;
          isLoading = false;
          errorMessage = 'Lỗi máy chủ: ${response.statusCode}';
        });
        print('Error: Server returned status ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isError = true;
        isLoading = false;
        errorMessage = 'Lỗi kết nối hoặc dữ liệu: $e';
      });
      print('Error fetching risks: $e');
    }
  }

  Future<void> fetchScopeTypes() async {
    final uri = UriHelper.build('/dynamiccategory/by-category-group?categoryGroup=risk_scope');
    print('Fetching scope types from: $uri');
    try {
      final response = await http.get(uri);
      print('Scope types response status: ${response.statusCode}');
      print('Scope types response body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List<dynamic> data = decoded['data'];
        setState(() {
          scopeTypes = data.map((e) => DynamicCategory.fromJson(e)).toList();
        });
      } else {
        print('Error: Failed to fetch scope types, status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching scope types: $e');
    }
  }

  List<RiskItem> getFilteredRisks() {
    final today = DateTime.now();
    return risks
        .where((risk) {
      final isScopeMatch = scopeFilter == 'ALL' ||
          (scopeFilter == 'TASK' && risk.riskScope != 'PROJECT') ||
          (scopeFilter == 'PROJECT' && risk.riskScope == 'PROJECT');
      final dueDateStr = risk.dueDate?.split('T')[0] ?? '';
      final isDueDateMatch = dueDateFilter == 'ALL' ||
          (dueDateFilter == 'ACTIVE' &&
              dueDateStr.isNotEmpty &&
              (DateTime.tryParse(dueDateStr)?.isAfter(today.subtract(const Duration(days: 1))) == true ||
                  !risk.status.toUpperCase().contains('CLOSED')));
      return isScopeMatch && isDueDateMatch;
    })
        .toList()
      ..sort((a, b) {
        final aDueDate = a.dueDate != null && a.dueDate!.isNotEmpty
            ? DateTime.tryParse(a.dueDate!)?.millisecondsSinceEpoch ?? double.infinity
            : double.infinity;
        final bDueDate = b.dueDate != null && b.dueDate!.isNotEmpty
            ? DateTime.tryParse(b.dueDate!)?.millisecondsSinceEpoch ?? double.infinity
            : double.infinity;
        final aIsClosed = a.status.toUpperCase().contains('CLOSED');
        final bIsClosed = b.status.toUpperCase().contains('CLOSED');
        if (aIsClosed && !bIsClosed) return 1;
        if (!aIsClosed && bIsClosed) return -1;
        return aDueDate.compareTo(bDueDate);
      });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (isError || risks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(errorMessage.isNotEmpty ? errorMessage : 'Không tải được danh sách rủi ro'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  isError = false;
                  errorMessage = '';
                });
                fetchRisks();
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    final filteredRisks = getFilteredRisks();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: scopeFilter,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        scopeFilter = value;
                      });
                    }
                  },
                  items: [
                    const DropdownMenuItem(value: 'ALL', child: Text('All Scopes')),
                    ...scopeTypes.map((scope) => DropdownMenuItem(
                      value: scope.name,
                      child: Text(scope.label),
                    )),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: dueDateFilter,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        dueDateFilter = value;
                      });
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: 'ALL', child: Text('All Due Dates')),
                    DropdownMenuItem(value: 'ACTIVE', child: Text('Active Due Dates')),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredRisks.length,
            itemBuilder: (context, index) {
              final risk = filteredRisks[index];
              return ListTile(
                leading: const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                title: Text(risk.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Severity: ${risk.severityLevel}'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RiskDetailPage(risk: risk, projectKey: widget.projectKey),
                    ),
                  ).then((_) {
                    fetchRisks();
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }
}