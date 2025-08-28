import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';


import 'package:file_picker/file_picker.dart';

class DocumentEditorPage extends StatefulWidget {
  final int documentId;
  final String title;
  final String content;
  const DocumentEditorPage({
    super.key,
    required this.documentId,
    required this.title,
    required this.content,
  });

  @override
  State<DocumentEditorPage> createState() => _DocumentEditorPageState();
}

class _DocumentEditorPageState extends State<DocumentEditorPage> {
  final HtmlEditorController controller = HtmlEditorController();
  bool _isEditorVisible = true;
  Future<void> _saveDocument() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    final htmlContent = await controller.getText();

    final url = Uri.parse('https://10.0.2.2:7128/api/documents/${widget.documentId}');
    final body = jsonEncode({
      "title": widget.title,
      "content": htmlContent,
      "template": "",
      "fileUrl": "",
      "visibility": "MAIN",
    });

    try {
      final res = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Document saved successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Lỗi lưu: ${res.statusCode} - ${res.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Exception: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('📝 ${widget.title}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveDocument,
            tooltip: 'Lưu tài liệu',
          ),
        ],
      ),
      body: HtmlEditor(
        controller: controller,
        htmlEditorOptions: HtmlEditorOptions(
          initialText: widget.content,
          hint: 'Nhập nội dung HTML ở đây...',
        ),
        htmlToolbarOptions: HtmlToolbarOptions(
          toolbarPosition: ToolbarPosition.aboveEditor, //by default
          toolbarType: ToolbarType.nativeScrollable, //by default
          onButtonPressed:
              (ButtonType type, bool? status, Function? updateStatus) {
            print(
                "button '${type.name}' pressed, the current selected status is $status");
            return true;
          },
          onDropdownChanged: (DropdownType type, dynamic changed,
              Function(dynamic)? updateSelectedItem) {
            print(
                "dropdown '${type.name}' changed to $changed");
            return true;
          },
          mediaLinkInsertInterceptor:
              (String url, InsertFileType type) {
            print(url);
            return true;
          },
          mediaUploadInterceptor:
              (PlatformFile file, InsertFileType type) async {
            print(file.name); //filename
            print(file.size); //size in bytes
            print(file.extension); //file extension (eg jpeg or mp4)
            return true;
          },
        ),
        otherOptions: const OtherOptions(height: 900),
      ),
    );
  }
}
