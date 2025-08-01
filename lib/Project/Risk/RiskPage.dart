import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../Helper/UriHelper.dart';
import 'RiskDetailPage.dart';

class RiskItem {
  final int id;
  final String riskKey;
  final int createdBy;
  final String? creatorFullName;
  final String? creatorUserName;
  final String? creatorPicture;
  final int responsibleId;
  final String? responsibleFullName;
  final String? responsibleUserName;
  final String? responsiblePicture;
  final int projectId;
  final String? taskId;
  final String? taskTitle;
  final String riskScope;
  final String title;
  final String description;
  late final String status;
  late final String type;
  final String generatedBy;
  final String probability;
  final String impactLevel;
  final String severityLevel;
  final bool isApproved;
  final String dueDate;
  final String createdAt;
  final String updatedAt;

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
    required this.dueDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RiskItem.fromJson(Map<String, dynamic> json) {
    return RiskItem(
      id: json['id'],
      riskKey: json['riskKey'],
      createdBy: json['createdBy'],
      creatorFullName: json['creatorFullName'],
      creatorUserName: json['creatorUserName'],
      creatorPicture: json['creatorPicture'],
      responsibleId: json['responsibleId'],
      responsibleFullName: json['responsibleFullName'],
      responsibleUserName: json['responsibleUserName'],
      responsiblePicture: json['responsiblePicture'],
      projectId: json['projectId'],
      taskId: json['taskId'],
      taskTitle: json['taskTitle'],
      riskScope: json['riskScope'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      type: json['type'],
      generatedBy: json['generatedBy'],
      probability: json['probability'],
      impactLevel: json['impactLevel'],
      severityLevel: json['severityLevel'],
      isApproved: json['isApproved'],
      dueDate: json['dueDate'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
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
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    fetchRisks();
  }

  Future<void> fetchRisks() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';

    final uri = UriHelper.build('/risk/by-project-key?projectKey=${widget.projectKey}');
    try {
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List<dynamic> data = decoded['data'];

        setState(() {
          risks = data.map((e) => RiskItem.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (isError || risks.isEmpty) {
      return const Center(child: Text("Không tải được danh sách rủi ro"));
    }

    return ListView.builder(
      itemCount: risks.length,
      itemBuilder: (context, index) {
        final risk = risks[index];
        return ListTile(
          leading: const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
          title: Text(risk.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('Severity Level: ${risk.severityLevel}'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          // onTap: () {
          //   Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (_) => RiskDetailPage(risk: risk),
          //     ),
          //   );
          // },
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RiskDetailPage(risk: risk),
              ),
            ).then((_) {
              fetchRisks();
            });
          },

        );
      },
    );
  }
}
