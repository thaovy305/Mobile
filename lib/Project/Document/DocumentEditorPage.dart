// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_quill/flutter_quill.dart' hide Text;
// import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
//
// class DocumentEditorPage extends StatefulWidget {
//   final int documentId;
//   final String title;
//   final String content;
//   const DocumentEditorPage({
//     super.key,
//     required this.documentId,
//     required this.title,
//     required this.content,
//   });
//
//   @override
//   State<DocumentEditorPage> createState() => _DocumentEditorPageState();
// }
//
// class _DocumentEditorPageState extends State<DocumentEditorPage> {
//   late final QuillController _controller;
//   final FocusNode _focusNode = FocusNode();
//   final ScrollController _scrollController = ScrollController();
//
//   Document _initializeDocument() {
//     try {
//       final decodedJson = jsonDecode(widget.content);
//       if (decodedJson is List) {
//         // TH1: content là Quill Delta JSON
//         return Document.fromJson(decodedJson);
//       }
//     } catch (_) {
//       // Không phải JSON → giả định là HTML
//       try {
//         // final converter = HtmlToDeltaConverter();
//         // final delta = converter.convert(widget.content, transformTableAsEmbed: false);
//         var delta = HtmlToDelta().convert(widget.content, transformTableAsEmbed: false);
//         return Document.fromDelta(delta);
//       } catch (e) {
//         debugPrint('🔥 Lỗi convert HTML → Delta: $e');
//       }
//     }
//
//     // Nếu mọi cách đều fail, hiển thị plain text
//     return Document()..insert(0, widget.content);
//   }
//
//
//   @override
//   void initState() {
//     super.initState();
//     final document = _initializeDocument();
//     _controller = QuillController(
//       document: document,
//       selection: const TextSelection.collapsed(offset: 0),
//     );
//
//
//     // TODO: Load nội dung từ server nếu có
//     // _loadDocumentContent();
//   }
//
//   // Gọi API PUT để lưu nội dung
//   Future<void> _saveDocumentToServer() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('accessToken') ?? '';
//
//     final contentDelta = _controller.document.toDelta();
//     final contentJson = jsonEncode(contentDelta.toJson());
//
//     final url = Uri.parse(
//         'https://10.0.2.2:7128/api/documents/${widget.documentId}');
//
//     final bodyData = {
//       "title": widget.title,
//       "content": contentJson,
//       "template": "",
//       "fileUrl": "",
//       "visibility": "MAIN", // hoặc PRIVATE / SHAREABLE nếu cần
//     };
//
//     print("🟡 [SAVE] PUT to: $url");
//     print("🟡 [SAVE] Body: ${jsonEncode(bodyData)}");
//     print("🟡 [SAVE] Token: $token");
//
//     try {
//       final response = await http.put(
//         url,
//         headers: {
//           'accept': '*/*',
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode(bodyData),
//       );
//
//       print("🔴 [SAVE] Status code: ${response.statusCode}");
//       print("🔴 [SAVE] Response body: ${response.body}");
//
//       if (!mounted) return;
//
//       if (response.statusCode == 200) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('💾 Lưu tài liệu thành công')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               '❌ Lưu thất bại: ${response.statusCode}\n${response.body}',
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       print("🔥 [SAVE] Exception: $e");
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('❌ Lỗi khi lưu: $e')),
//       );
//     }
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     _focusNode.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Chỉnh sửa: ${widget.title}'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.save),
//             tooltip: 'Lưu tài liệu',
//             onPressed: _saveDocumentToServer,
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           QuillSimpleToolbar(
//             controller: _controller,
//             config: QuillSimpleToolbarConfig(
//               showClipboardPaste: true,
//               embedButtons: FlutterQuillEmbeds.toolbarButtons(),
//               showAlignmentButtons: true,
//               showDirection: true,
//               showFontFamily: true,
//               showFontSize: true,
//               showColorButton: true,
//               showListCheck: true,
//               multiRowsDisplay: true,
//             ),
//           ),
//           const Divider(height: 1),
//           Expanded(
//             child: QuillEditor(
//               controller: _controller,
//               focusNode: _focusNode,
//               scrollController: _scrollController,
//               config: QuillEditorConfig(
//                 placeholder: 'Nhập nội dung tài liệu...',
//                 padding: const EdgeInsets.all(16),
//                 embedBuilders: FlutterQuillEmbeds.editorBuilders(),
//                 expands: true,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
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
        title: Text('📝 Chỉnh sửa: ${widget.title}'),
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
