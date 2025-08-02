import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Helper/UriHelper.dart';
import 'RiskPage.dart';

class RiskDetailPage extends StatefulWidget {
  final RiskItem risk;

  const RiskDetailPage({super.key, required this.risk});

  @override
  State<RiskDetailPage> createState() => _RiskDetailPageState();
}

class _RiskDetailPageState extends State<RiskDetailPage> {
  late String selectedStatus;
  late String selectedType;
  late Future<List<DynamicCategory>> riskTypesFuture;
  List<RiskSolutionItem> riskSolutions = [];
  bool isRiskSolutionLoading = true;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.risk.status;
    selectedType = widget.risk.type;
    riskTypesFuture = fetchRiskTypes();
    fetchRiskSolution();
  }

  Future<void> updateStatus(String newStatus) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';

    final int riskId = widget.risk.id;
    final url = UriHelper.build('/risk/$riskId/status');

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(newStatus),
      );

      if (response.statusCode == 200) {
        setState(() {
          selectedStatus = newStatus;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã cập nhật trạng thái thành $newStatus')),
        );
      } else {
        throw Exception('Failed to update status');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cập nhật thất bại')));
      print('Error updating status: $e');
    }
  }

  Future<List<DynamicCategory>> fetchRiskTypes() async {
    String categoryGroup = 'risk_type';
    final url = UriHelper.build(
      '/dynamiccategory/by-category-group?categoryGroup=$categoryGroup',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['data'] as List)
          .map((item) => DynamicCategory.fromJson(item))
          .toList();
    } else {
      throw Exception('Failed to load risk types');
    }
  }

  Future<void> updateRiskType(int riskId, String newType) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';

    final url = UriHelper.build('/risk/$riskId/type');
    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(newType),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update risk type');
    }
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "Không rõ";
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return "Không hợp lệ";
    }
  }

  Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget buildStatusDropdown() {
    return DropdownButton<String>(
      value: selectedStatus,
      onChanged: (value) {
        if (value != null) updateStatus(value);
      },
      underline: Container(),
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(8),
      items:
          ['OPEN', 'MITIGATED', 'CLOSED'].map((status) {
            return DropdownMenuItem<String>(
              value: status,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColors[status]?.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColors[status],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Map<String, Color> statusColors = {
    'OPEN': Colors.blue,
    'MITIGATED': Colors.green,
    'CLOSED': Colors.grey,
  };

  Widget buildInfoRowWithAvatar(
    String label,
    String? fullName,
    String? username,
    String? pictureUrl,
  ) {
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
            backgroundImage:
                pictureUrl != null && pictureUrl.isNotEmpty
                    ? NetworkImage(pictureUrl)
                    : null,
            child:
                (pictureUrl == null || pictureUrl.isEmpty)
                    ? const Icon(Icons.person, size: 18)
                    : null,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(fullName ?? username ?? 'Not assigned')),
        ],
      ),
    );
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

  Future<void> fetchRiskSolution() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';

    final uri = UriHelper.build('/risksolution/by-risk/${widget.risk.id}');
    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded['data'];
        if (data != null && data is List) {
          setState(() {
            riskSolutions =
                data.map((item) => RiskSolutionItem.fromJson(item)).toList();
            isRiskSolutionLoading = false;
          });
        } else {
          setState(() {
            isRiskSolutionLoading = false;
          });
        }
      } else {
        setState(() {
          isRiskSolutionLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isRiskSolutionLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String createdBy =
        widget.risk.creatorFullName ?? widget.risk.creatorUserName ?? 'Unknown';
    final String responsible =
        widget.risk.responsibleFullName ??
        widget.risk.responsibleUserName ??
        'Not assigned';
    final String dueDate = formatDate(widget.risk.dueDate);
    final String createdAt = formatDate(widget.risk.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.risk.title),
        backgroundColor: Colors.redAccent,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.grey[50],
        child: SingleChildScrollView(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(bottom: 24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [Chip(label: Text(widget.risk.riskKey))],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Status: ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      buildStatusDropdown(),
                    ],
                  ),
                  FutureBuilder<List<DynamicCategory>>(
                    future: riskTypesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return const Text("Failed to load risk type");
                      } else {
                        final types = snapshot.data!;
                        return DropdownButton<String>(
                          value: selectedType,
                          onChanged: (newType) async {
                            if (newType != null && newType != selectedType) {
                              try {
                                await updateRiskType(widget.risk.id, newType);
                                setState(() {
                                  selectedType = newType;
                                });
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Failed to update type'),
                                  ),
                                );
                              }
                            }
                          },
                          items:
                              types
                                  .map(
                                    (type) => DropdownMenuItem(
                                      value: type.name,
                                      child: Text(type.label),
                                    ),
                                  )
                                  .toList(),
                        );
                      }
                    },
                  ),

                  const Divider(height: 32),
                  buildInfoRowWithAvatar(
                    "Created by",
                    widget.risk.creatorFullName,
                    widget.risk.creatorUserName,
                    widget.risk.creatorPicture,
                  ),
                  buildInfoRowWithAvatar(
                    "Responsible",
                    widget.risk.responsibleFullName,
                    widget.risk.responsibleUserName,
                    widget.risk.responsiblePicture,
                  ),
                  buildInfoRow("Due date", dueDate),
                  buildInfoRow("Created at", createdAt),

                  const SizedBox(height: 24),
                  const Text(
                    "Description",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.risk.description.isNotEmpty
                        ? widget.risk.description
                        : "No description provided.",
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    "Scope",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.risk.riskScope.isNotEmpty
                        ? widget.risk.riskScope
                        : "No information.",
                  ),

                  const SizedBox(height: 24),
                  buildLevelLabel("Probability", widget.risk.probability),
                  buildLevelLabel("Impact Level", widget.risk.impactLevel),
                  buildLevelLabel("Severity Level", widget.risk.severityLevel),

                  if (isRiskSolutionLoading)
                    const CircularProgressIndicator()
                  else if (riskSolutions.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        const Text(
                          "Mitigation Plan",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ...riskSolutions
                            .map(
                              (solution) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  solution.mitigationPlan?.isNotEmpty == true
                                      ? solution.mitigationPlan!
                                      : "Not provided",
                                ),
                              ),
                            )
                            .toList(),

                        const SizedBox(height: 24),
                        const Text(
                          "Contingency Plan",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ...riskSolutions
                            .map(
                              (solution) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  solution.contingencyPlan?.isNotEmpty == true
                                      ? solution.contingencyPlan!
                                      : "Not provided",
                                ),
                              ),
                            )
                            .toList(),
                      ],
                    )
                  else
                    const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ),
      ),
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
      id: json['id'],
      name: json['name'],
      label: json['label'],
    );
  }
}

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
      id: json['id'],
      riskId: json['riskId'],
      mitigationPlan: json['mitigationPlan'],
      contingencyPlan: json['contingencyPlan'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
