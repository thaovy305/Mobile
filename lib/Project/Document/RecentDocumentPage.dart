// import 'dart:convert';
// import 'dart:io'; // Import để xử lý lỗi certificate
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'DocumentEditorPage.dart';
//
// // Class để bỏ qua kiểm tra certificate (CHỈ DÙNG CHO DEVELOPMENT)
// // Bạn nên có một giải pháp certificate hợp lệ cho môi trường production.
// class MyHttpOverrides extends HttpOverrides {
//   @override
//   HttpClient createHttpClient(SecurityContext? context) {
//     return super.createHttpClient(context)
//       ..badCertificateCallback =
//           (X509Certificate cert, String host, int port) => true;
//   }
// }
//
// class RecentDocumentPage extends StatefulWidget {
//   final int projectId;
//
//   const RecentDocumentPage({super.key, required this.projectId});
//
//   @override
//   State<RecentDocumentPage> createState() => _RecentDocumentPageState();
// }
//
// class _RecentDocumentPageState extends State<RecentDocumentPage> {
//   List<dynamic> documents = [];
//   bool isLoading = true;
//   String errorMessage = '';
//
//   @override
//   void initState() {
//     super.initState();
//     // Dòng này cần thiết khi làm việc với API local dùng self-signed certificate
//     HttpOverrides.global = MyHttpOverrides();
//     fetchDocuments();
//   }
//
//   Future<void> fetchDocuments() async {
//     setState(() {
//       isLoading = true;
//       errorMessage = '';
//     });
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('accessToken') ?? '';
//
//       // URL cho API local
//       final url = Uri.parse(
//           'https://10.0.2.2:7128/api/documents/project/${widget.projectId}');
//
//       final res = await http.get(url, headers: {
//         'accept': 'text/plain',
//         'Authorization': 'Bearer $token',
//       });
//
//       if (res.statusCode == 200) {
//         final data = jsonDecode(res.body);
//         setState(() {
//           documents = data;
//         });
//       } else {
//         throw Exception("Lỗi server: ${res.statusCode}");
//       }
//     } catch (e) {
//       setState(() {
//         // Cung cấp thông điệp lỗi rõ ràng hơn
//         errorMessage = "Không thể tải dữ liệu. Vui lòng kiểm tra kết nối và thử lại.\nChi tiết: $e";
//       });
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }
//
//   Future<Map<String, dynamic>?> fetchDocumentDetail(int docId) async {
//     // ... (Giữ nguyên logic của bạn)
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('accessToken') ?? '';
//
//     final url = Uri.parse('https://10.0.2.2:7128/api/documents/$docId');
//
//     try {
//       final res = await http.get(url, headers: {
//         'accept': 'text/plain',
//         'Authorization': 'Bearer $token',
//       });
//
//       if (res.statusCode == 200) {
//         return jsonDecode(res.body);
//       } else {
//         print("❌ Lỗi server khi lấy chi tiết: ${res.statusCode}");
//       }
//     } catch (e) {
//       print("❌ Lỗi kết nối khi lấy chi tiết: $e");
//     }
//     return null;
//   }
//
//   // =======================================================================
//   // PHẦN GIAO DIỆN ĐÃ ĐƯỢC NÂNG CẤP
//   // =======================================================================
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('📄 Tài liệu gần đây'),
//         backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
//       ),
//       body: buildBody(),
//       // Thêm nút refresh để tải lại dữ liệu khi có lỗi
//       floatingActionButton: FloatingActionButton(
//         onPressed: fetchDocuments,
//         child: const Icon(Icons.refresh),
//       ),
//     );
//   }
//
//   Widget buildBody() {
//     if (isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }
//
//     if (errorMessage.isNotEmpty) {
//       return Center(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Text(
//             errorMessage,
//             textAlign: TextAlign.center,
//             style: TextStyle(color: Colors.red[700], fontSize: 16),
//           ),
//         ),
//       );
//     }
//
//     if (documents.isEmpty) {
//       return const Center(
//         child: Text(
//           'Không có tài liệu nào.',
//           style: TextStyle(fontSize: 18, color: Colors.grey),
//         ),
//       );
//     }
//
//     return ListView.builder(
//       // Thêm padding cho cả danh sách
//       padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
//       itemCount: documents.length,
//       itemBuilder: (context, index) {
//         final doc = documents[index];
//         final visibility = doc['visibility'] ?? '---';
//         final isPublic = visibility == 'Public';
//
//         return Card(
//           // Thêm độ nổi và bo góc cho Card
//           elevation: 3,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           margin: const EdgeInsets.symmetric(vertical: 6.0),
//           child: InkWell(
//             // InkWell để có hiệu ứng khi nhấn
//             borderRadius: BorderRadius.circular(12),
//             onTap: () async {
//               final detail = await fetchDocumentDetail(doc['id']);
//               if (detail != null && context.mounted) {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => DocumentEditorPage(
//                       documentId: detail['id'],
//                       title: detail['title'] ?? 'Untitled',
//                       content: detail['content'] ?? '',
//                     ),
//                   ),
//                 );
//               } else if (context.mounted) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                       content: Text("Không thể tải chi tiết tài liệu")),
//                 );
//               }
//             },
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Row(
//                 children: [
//                   // Icon đầu dòng
//                   Icon(
//                     Icons.article_outlined,
//                     color: Theme.of(context).primaryColor,
//                     size: 40,
//                   ),
//                   const SizedBox(width: 16),
//                   // Dùng Expanded để text tự động xuống dòng nếu quá dài
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Tiêu đề
//                         Text(
//                           doc['title'] ?? 'Không có tiêu đề',
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 17,
//                           ),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         const SizedBox(height: 6),
//                         // Thông tin phụ (visibility)
//                         Row(
//                           children: [
//                             Icon(
//                               isPublic ? Icons.public : Icons.lock_outline,
//                               size: 14,
//                               color: Colors.grey[600],
//                             ),
//                             const SizedBox(width: 4),
//                             Text(
//                               "Trạng thái: $visibility",
//                               style: TextStyle(
//                                 color: Colors.grey[600],
//                                 fontSize: 13,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   // Icon mũi tên ở cuối
//                   const Icon(Icons.chevron_right, color: Colors.grey),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }