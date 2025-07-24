import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../Helper/UriHelper.dart'; // Đảm bảo import UriHelper nếu dùng
import '../Login/LoginPage.dart';
import '../WorkItem/TaskDetailPage.dart';
import '../WorkItem/EpicDetailPage.dart';
import '../WorkItem/SubtaskDetailPage.dart';
import 'BottomNavBar.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _username = 'User';
  int _accountId = 0;
  String _accessToken = '';
  String? _picture;
  String? _fullName = '';
  bool _isLoading = false; // Thêm trạng thái loading

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? ''; // Lấy email từ SharedPreferences
    setState(() {
      _username = prefs.getString('username') ?? 'User';
      _accessToken = prefs.getString('accessToken') ?? '';
      _accountId = prefs.getInt('accountId') ?? 0;
      _isLoading = email.isNotEmpty; // Bắt đầu loading nếu có email
    });
    if (email.isNotEmpty) {
      await _fetchAccountData(email); // Fetch dữ liệu tài khoản nếu có email
    } else {
      setState(() {
        _isLoading = false; // Tắt loading nếu không có email
      });
    }
  }

  Future<void> _fetchAccountData(String email) async {
    try {
      final uri = UriHelper.build('/account/$email');
      print("Fetching account with URI: $uri"); // Log URL
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
          'Accept': '*/*',
        },
      );

      print("Response status: ${response.statusCode}"); // Log status
      print("Response body: ${response.body}"); // Log body

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        if (jsonBody['isSuccess'] == true) {
          final accountData = jsonBody['data'] as Map<String, dynamic>;
          setState(() {
            _picture = accountData['picture'] as String?;
            _fullName = accountData['fullName'] as String?; // Cập nhật _fullName
            _isLoading = false; // Tắt loading khi fetch thành công
          });
        } else {
          setState(() {
            _isLoading = false; // Tắt loading nếu isSuccess là false
          });
          print("API success is false: ${jsonBody['message']}");
        }
      } else {
        setState(() {
          _isLoading = false; // Tắt loading nếu status không phải 200
        });
        print("API error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      setState(() {
        _isLoading = false; // Tắt loading nếu có lỗi
      });
      print("Error fetching account data: $e");
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('accessToken');
    await prefs.remove('email');

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: _picture != null ? Colors.transparent : Colors.blue,
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2) // Loading khi fetch
                  : (_picture != null
                  ? ClipOval(
                child: Image.network(
                  _picture!,
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.person, color: Colors.white);
                  },
                ),
              )
                  : Icon(Icons.person, color: Colors.white)),
            ),
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_fullName ?? _username, style: TextStyle(fontSize: 12)),
            ),
            Spacer(),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') _logout();
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'logout', child: Text('Logout')),
              ],
              icon: Icon(Icons.more_vert, color: Colors.black),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello ${_fullName ?? _username} 👋',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.symmetric(vertical: 0),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Quick access',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Text('Edit',
                    style: TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.assignment, size: 36, color: Colors.orange),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Personalize this space',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text(
                          'Add your most important stuff here, for fast access.',
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                        ),
                        SizedBox(height: 4),
                        Text('Add items',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Text('Project List',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 16),
            _buildRecentItemWithWidgetIcon(
              SvgPicture.asset(
                'assets/type_task.svg',
                width: 24,
                height: 24,
              ),
              'Edit flower product',
              'FLOWER-7',
              null,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskDetailPage(taskId: 'FLOWER-7'),
                  ),
                );
              },
            ),
            _buildRecentItemWithWidgetIcon(
              SvgPicture.asset(
                'assets/type_epic.svg',
                width: 24,
                height: 24,
              ),
              'Edit flower product',
              'FLOWER-1',
              null,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EpicDetailPage(epicId: 'FLOWER-1'),
                  ),
                );
              },
            ),
            _buildRecentItemWithWidgetIcon(
              SvgPicture.asset(
                'assets/type_subtask.svg',
                width: 24,
                height: 24,
              ),
              'Edit flower product',
              'FLOWER-19',
              null,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubtaskDetailPage(subtaskId: 'FLOWER-19'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        username: _fullName ?? _username, // Sử dụng _fullName cho BottomNavBar
        currentIndex: 0,
      ),
    );
  }

  Widget _buildRecentSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[600])),
        SizedBox(height: 8),
        ...items,
      ],
    );
  }

  Widget _buildRecentItemWithWidgetIcon(
      Widget iconWidget, String title, String subtitle,
      [String? color, VoidCallback? onTap]) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: iconWidget,
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                Text(subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            )
          ],
        ),
      ),
    );
  }

  Color _getColor(String? color) {
    switch (color) {
      case 'pink':
        return Colors.pinkAccent;
      default:
        return Colors.blue;
    }
  }
}