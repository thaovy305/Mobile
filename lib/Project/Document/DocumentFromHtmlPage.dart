import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';

class DocumentFromHtmlPage extends StatefulWidget {
  const DocumentFromHtmlPage({super.key});

  @override
  State<DocumentFromHtmlPage> createState() => _DocumentFromHtmlPageState();
}

class _DocumentFromHtmlPageState extends State<DocumentFromHtmlPage> {
  late QuillController _controller;

  @override
  void initState() {
    super.initState();

    const html = '''<h1>📊 Project Plan with Timeline</h1>
    <h2>📅 Project Overview</h2>
    <p>This project aims to develop a human resource management system (HRMS) for small and medium-sized enterprises (SMEs) to streamline HR processes and improve efficiency.</p>
    <h2>🚀 Next Steps</h2>
    <ul>
      <li>Finalize the project plan and obtain stakeholder approval.</li>
      <li>Assemble the project team.</li>
      <li>Procure necessary resources and tools.</li>
      <li>Kick off Phase 1: Requirements Gathering and Planning.</li>
    </ul>'''; // 👉 Rút gọn không dùng <table> vì Quill không hỗ trợ

    final converter = HtmlToDelta();
    final delta = converter.convert(html, transformTableAsEmbed: false);
    final document = Document.fromDelta(delta);

    _controller = QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📝 Quill HTML Preview')),
      body: Column(
        children: [
          QuillSimpleToolbar(controller: _controller),
          Expanded(
            child: QuillEditor.basic(
              controller: _controller,
              //readOnly: false,
            ),
          ),
        ],
      ),
    );
  }
}
