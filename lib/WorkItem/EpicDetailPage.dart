import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Helper/UriHelper.dart';
import '../models/epic.dart'; // nếu có UriHelper

class EpicDetailPage extends StatefulWidget {
  final String epicId;

  const EpicDetailPage({Key? key, required this.epicId}) : super(key: key);

  @override
  State<EpicDetailPage> createState() => _EpicDetailPageState();
}

class _EpicDetailPageState extends State<EpicDetailPage> {
  Epic? epicData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEpicDetail();
  }

  Future<void> fetchEpicDetail() async {
    try {
      final uri = UriHelper.build('/epic/${widget.epicId}'); // hoặc dùng Uri.parse trực tiếp
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);

        if (jsonBody['isSuccess'] == true) {
          setState(() {
            epicData = Epic.fromJson(jsonBody['data']);
            isLoading = false;
          });
        } else {
          showError(jsonBody['message'] ?? 'Không tìm thấy Epic');
        }
      } else {
        showError('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      showError('Lỗi mạng: $e');
    }
  }

  void showError(String message) {
    setState(() {
      isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (epicData == null) {
      return const Center(child: Text('Không tìm thấy Epic'));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Epic Detail ${epicData!.id}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildDetailRow('Tên', epicData!.name),
            buildDetailRow('Mô tả', epicData!.description),
            buildDetailRow('Bắt đầu', epicData!.startDate.toIso8601String()),
            buildDetailRow('Kết thúc', epicData!.endDate.toIso8601String()),
            buildDetailRow('Trạng thái', epicData!.status),
            const SizedBox(height: 16),
            const Text('Người tạo', style: TextStyle(fontWeight: FontWeight.bold)),
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(epicData!.reporterPicture),
              ),
              title: Text(epicData!.reporterFullname),
            ),
            const Text('Người giao việc', style: TextStyle(fontWeight: FontWeight.bold)),
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(epicData!.assignedByPicture),
              ),
              title: Text(epicData!.assignedByFullname),
            ),
            const Text('Sprint liên quan', style: TextStyle(fontWeight: FontWeight.bold)),
            buildDetailRow('Tên Sprint', epicData!.sprintName),
            buildDetailRow('Goal', epicData!.sprintGoal),
          ],
        ),
      ),
    );
  }
}
