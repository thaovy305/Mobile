import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'Backlog/BacklogMainPage.dart';
import 'Dashboard/Dashboard.dart';
import 'KanbanBoard/KanbanBoardMain.dart';
import 'Risk/RiskPage.dart';
import 'Document/DocumentPage.dart';
import 'Document/DocumentReportPage.dart';

class ProjectOverviewPage extends StatefulWidget {
  final String projectName;
  final String projectKey;
  final int? projectId; // <-- cho phép null

  const ProjectOverviewPage({
    super.key,
    required this.projectName,
    required this.projectKey,
    this.projectId, // <-- không bắt buộc
  });

  @override
  State<ProjectOverviewPage> createState() => _ProjectOverviewPageState();
}

class _ProjectOverviewPageState extends State<ProjectOverviewPage> {
  bool _isClient = false;

  // giữ 1 future để không fetch lại mỗi lần build
  late Future<int> _resolvedProjectId;

  // Tabs cơ bản (không gồm Documents/Reports, vì phần đó ta chèn động)
  final List<String> _baseTabs = const [
    "Backlog",
    "Board",
    "Dashboard",
    "Risk",
    "Summary",
    "Calendar",
    // slot Documents | Reports sẽ chèn ở đây
    "Timeline",
    "Reports",
  ];

  List<String> get _tabs {
    final tabs = List<String>.from(_baseTabs);
    final insertIndex = 6; // sau "Calendar"
    tabs.insert(insertIndex, _isClient ? "Reports (Client)" : "Documents");
    return tabs;
  }

  @override
  void initState() {
    super.initState();
    _loadRole();
    _resolvedProjectId = _resolveProjectId(); // <-- tính projectId 1 lần
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = (prefs.getString('userRole') ?? '').toUpperCase();
    setState(() => _isClient = role == 'CLIENT');
  }

  /// Lấy projectId theo thứ tự ưu tiên:
  /// 1) Nếu widget.projectId đã có -> dùng luôn
  /// 2) Nếu cache trong SharedPreferences theo key -> dùng cache
  /// 3) Gọi API /api/projects/by-key/{projectKey} -> lấy id, rồi lưu cache
  Future<int> _resolveProjectId() async {
    if (widget.projectId != null) return widget.projectId!;

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'projectId:${widget.projectKey}';

    final cached = prefs.getInt(cacheKey);
    if (cached != null) return cached;

    // gọi API
    final token = prefs.getString('accessToken') ?? '';
    final url = Uri.parse(
        'https://10.0.2.2:7128/api/project/by-project-key?projectKey=${widget.projectKey}');

    final res = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (res.statusCode != 200) {
      throw Exception('Get project by key failed: ${res.statusCode}');
    }

    final body = json.decode(res.body);
    if (body['isSuccess'] != true || body['data'] == null) {
      throw Exception(body['message'] ?? 'Invalid response for project by key');
    }

    final id = body['data']['id'] as int;
    await prefs.setInt(cacheKey, id);
    return id;
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _tabs;

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: true,
          title: Text(
            widget.projectName,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48.0),
            child: TabBar(
              isScrollable: true,
              indicatorColor: Colors.blue,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              padding: EdgeInsets.zero,
              labelPadding: const EdgeInsets.symmetric(horizontal: 12),
              tabs: tabs.map((t) => Tab(text: t)).toList(),
            ),
          ),
        ),
        body: TabBarView(
          children: tabs.map<Widget>((tab) {
            if (tab == "Backlog")   return BacklogMainPage(projectKey: widget.projectKey);
            if (tab == "Dashboard") return DashboardPage(projectKey: widget.projectKey);
            if (tab == "Board")     return KanbanBoardMain(projectKey: widget.projectKey);
            if (tab == "Risk")      return RiskPage(projectKey: widget.projectKey);

            if (tab == "Documents") {
              return DocumentPage(projectKey: widget.projectKey);
            }

            if (tab == "Reports (Client)") {
              // chờ resolve projectId rồi truyền vào DocumentReportPage
              return FutureBuilder<int>(
                future: _resolvedProjectId,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Center(child: Text('Error: ${snap.error}'));
                  }
                  final projectId = snap.data!;
                  return DocumentReportPage(projectId: projectId);
                },
              );
            }

            return Center(
              child: Text('Page: $tab', style: const TextStyle(fontSize: 18)),
            );
          }).toList(),
        ),
      ),
    );
  }
}
