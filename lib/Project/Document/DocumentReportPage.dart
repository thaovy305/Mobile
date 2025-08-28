import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Model không thay đổi
class SharedDocument {
  final int id;
  final String title;
  final String content;

  SharedDocument({
    required this.id,
    required this.title,
    required this.content,
  });

  factory SharedDocument.fromJson(Map<String, dynamic> json) {
    return SharedDocument(
      id: json['id'],
      title: json['title'] ?? 'No Title',
      content: json['content'] ?? '',
    );
  }
}

// ✨ THAY ĐỔI 1: Thêm projectId vào widget
class DocumentReportPage extends StatefulWidget {
  final int projectId;

  const DocumentReportPage({
    super.key,
    required this.projectId,
  });

  @override
  State<DocumentReportPage> createState() => _DocumentReportPageState();
}

class _DocumentReportPageState extends State<DocumentReportPage> {
  late Future<List<SharedDocument>> _sharedDocumentsFuture;

  @override
  void initState() {
    super.initState();
    _sharedDocumentsFuture = _fetchSharedDocuments();
  }

  Future<List<SharedDocument>> _fetchSharedDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';

    // ✨ THAY ĐỔI 2: Xây dựng URL động với projectId
    final url = Uri.parse(
        'https://10.0.2.2:7128/api/documents/shared-to-me/project/${widget.projectId}');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['isSuccess'] == true && data['data'] != null) {
          final List<dynamic> documentsJson = data['data'];
          return documentsJson
              .map((json) => SharedDocument.fromJson(json))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load documents');
        }
      } else {
        throw Exception('Failed to load documents: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error fetching documents: $e')),
        );
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Cập nhật tiêu đề để rõ ràng hơn
        title: const Text('📊 Project Reports'),
      ),
      body: FutureBuilder<List<SharedDocument>>(
        future: _sharedDocumentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No documents shared for this project.'));
          }

          final documents = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final doc = documents[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                child: ListTile(
                  leading: const Icon(Icons.article, color: Colors.blue),
                  title: Text(doc.title),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DocumentReportViewerPage(
                          title: doc.title,
                          content: doc.content,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Trang DocumentReportViewerPage không cần thay đổi
class DocumentReportViewerPage extends StatefulWidget {
  final String title;
  final String content;

  const DocumentReportViewerPage({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  State<DocumentReportViewerPage> createState() =>
      _DocumentReportViewerPageState();
}

class _DocumentReportViewerPageState extends State<DocumentReportViewerPage> {
  final HtmlEditorController controller = HtmlEditorController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('📄 ${widget.title}')),
      body: HtmlEditor(
        controller: controller,
        htmlEditorOptions: HtmlEditorOptions(
          initialText: widget.content,
          // dùng readOnly/disabled của plugin để khóa việc chỉnh sửa
          // (plugin chấp nhận 'disabled: true' hoặc 'readOnly: true' tùy version)
          disabled: true, // hoặc readOnly: true
          // autoAdjustHeight: false, // (tùy nhu cầu)
        ),
        // htmlToolbarOptions: const HtmlToolbarOptions(
        //   defaultToolbarButtons: [], // ẩn toolbar nếu muốn
        //   toolbarPosition: ToolbarPosition.aboveEditor,
        // ),
        otherOptions: const OtherOptions(height: 900),
      ),
    );
  }
}
