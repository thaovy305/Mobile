import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// Chuyển đổi một chuỗi HTML thành đối tượng Document của Quill.
Future<Document> htmlToDelta(String html) async {
  // Tạo một WebView chạy nền để thực thi JavaScript
  final HeadlessInAppWebView headlessWebView = HeadlessInAppWebView(
    initialUrlRequest: URLRequest(url: WebUri('about:blank')),
    onWebViewCreated: (controller) async {
      // Tải nội dung file JS
      final jsContent = await rootBundle.loadString('assets/js/quill_converter.js');
      await controller.evaluateJavascript(source: jsContent);
    },
  );

  try {
    await headlessWebView.run();

    // Gọi hàm 'convertHtmlToDelta' từ file JS với chuỗi HTML
    final result = await headlessWebView.webViewController.callAsyncJavaScript(
      functionBody: 'return convertHtmlToDelta(${jsonEncode(html)});',
    );

    // Xử lý kết quả trả về (là một chuỗi JSON của Delta)
    if (result?.value != null) {
      final decodedJson = jsonDecode(result!.value);
      return Document.fromJson(decodedJson['ops']);
    }
  } catch (e) {
    debugPrint('Lỗi chuyển đổi HTML sang Delta: $e');
  } finally {
    // Luôn hủy webview sau khi dùng xong
    await headlessWebView.dispose();
  }

  // Trả về một document trống nếu có lỗi
  return Document();
}