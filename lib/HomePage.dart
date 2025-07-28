import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../Helper/UriHelper.dart';
import '../Login/LoginPage.dart';
import 'Models/Project.dart';
import 'Models/WorkItem.dart';
import 'WorkItem/EpicDetailPage.dart';
import 'WorkItem/SubtaskDetailPage.dart';
import 'WorkItem/TaskDetailPage.dart';

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
  bool _isLoading = false;
  String? errorMessage;
  List<Project> projects = [];
  Project? _selectedProject;
  List<WorkItem> workItems = [];
  bool _isWorkItemsLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';
    setState(() {
      _username = prefs.getString('username') ?? 'User';
      _accessToken = prefs.getString('accessToken') ?? '';
      _accountId = prefs.getInt('accountId') ?? 0;
      _isLoading = email.isNotEmpty;
    });
    if (email.isNotEmpty) {
      await _fetchAccountData(email);
      await fetchProjects();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchProjects() async {
    setState(() {
      _isLoading = true;
      errorMessage = null;
    });

    try {
      final uri = UriHelper.build('/account/projects');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
      );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        if (jsonBody['isSuccess'] == true) {
          final data = jsonBody['data'];
          if (data is List) {
            setState(() {
              projects =
                  data
                      .map((projectJson) {
                        try {
                          if (projectJson is Map<String, dynamic>) {
                            return Project.fromJson(projectJson);
                          } else {
                            print('Invalid project JSON: $projectJson');
                            return null;
                          }
                        } catch (e) {
                          print('Parsing error: $e');
                          return null;
                        }
                      })
                      .whereType<Project>()
                      .toList();
              _selectedProject = projects.isNotEmpty ? projects.first : null;
              _isLoading = false;
            });
            if (_selectedProject != null) {
              await fetchWorkItems(_selectedProject!.projectId);
            }
          } else {
            setState(() {
              errorMessage = 'Invalid data format';
              _isLoading = false;
            });
          }
        } else {
          setState(() {
            errorMessage = jsonBody['message'] ?? 'Failed to fetch projects';
            _isLoading = false;
          });
        }
      } else if (response.statusCode == 401) {
        setState(() {
          errorMessage = 'Unauthorized. Please login again.';
          _isLoading = false;
        });
        await prefs.clear();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginPage()),
            (route) => false,
          );
        }
      } else {
        setState(() {
          errorMessage = 'Server error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Network error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> fetchWorkItems(int projectId) async {
    setState(() {
      _isWorkItemsLoading = true;
      errorMessage = null;
    });

    try {
      final uri = UriHelper.build('/project/$projectId/workitems',
      );
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
      );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        if (jsonBody['isSuccess'] == true) {
          final data = jsonBody['data'];
          if (data is List) {
            setState(() {
              workItems =
                  data
                      .map((itemJson) {
                        try {
                          if (itemJson is Map<String, dynamic>) {
                            return WorkItem.fromJson(itemJson);
                          } else {
                            print('Invalid work item JSON: $itemJson');
                            return null;
                          }
                        } catch (e) {
                          print(
                            'Error parsing work item: $itemJson, Error: $e',
                          );
                          return null;
                        }
                      })
                      .whereType<WorkItem>()
                      .toList();
              _isWorkItemsLoading = false;
            });
          } else {
            setState(() {
              errorMessage = 'Invalid work items data format';
              _isWorkItemsLoading = false;
            });
          }
        } else {
          setState(() {
            errorMessage = jsonBody['message'] ?? 'Failed to fetch work items';
            _isWorkItemsLoading = false;
          });
        }
      } else if (response.statusCode == 401) {
        setState(() {
          errorMessage = 'Unauthorized. Please login again.';
          _isWorkItemsLoading = false;
        });
        await prefs.clear();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginPage()),
            (route) => false,
          );
        }
      } else {
        setState(() {
          errorMessage = 'Server error: ${response.statusCode}';
          _isWorkItemsLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Network error: $e';
        _isWorkItemsLoading = false;
      });
    }
  }

  Future<void> _fetchAccountData(String email) async {
    try {
      final uri = UriHelper.build('/account/$email');
      print("Fetching account with URI: $uri");
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
          'Accept': '*/*',
        },
      );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        if (jsonBody['isSuccess'] == true) {
          final accountData = jsonBody['data'] as Map<String, dynamic>;
          setState(() {
            _picture = accountData['picture'] as String?;
            _fullName = accountData['fullName'] as String?;
            _isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'API success is false: ${jsonBody['message']}';
            _isLoading = false;
          });
          print("API success is false: ${jsonBody['message']}");
        }
      } else {
        setState(() {
          errorMessage = 'API error: ${response.statusCode}';
          _isLoading = false;
        });
        print("API error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching account data: $e';
        _isLoading = false;
      });
      print("Error fetching account data: $e");
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('accessToken');
    await prefs.remove('email');

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
    }
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
              backgroundColor:
                  _picture != null ? Colors.transparent : Colors.blue,
              child:
                  _isLoading
                      ? CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )
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
            Expanded(
              child: Container(
                height: 36,
                padding: EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Project>(
                    isExpanded: true,
                    value: _selectedProject,
                    hint: Text(
                      "Select project",
                      style: TextStyle(fontSize: 11),
                    ),
                    icon: Icon(Icons.arrow_drop_down, size: 16),
                    style: TextStyle(fontSize: 11, color: Colors.black),
                    dropdownColor: Colors.white,
                    itemHeight: 48,
                    items:
                        projects.map((project) {
                          return DropdownMenuItem<Project>(
                            value: project,
                            child: Row(
                              children: [
                                if (project.iconUrl != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child:
                                        project.iconUrl!.endsWith('.svg')
                                            ? SvgPicture.network(
                                              project.iconUrl!,
                                              width: 20,
                                              height: 20,
                                              placeholderBuilder:
                                                  (context) => Icon(
                                                    Icons.image,
                                                    size: 16,
                                                  ),
                                            )
                                            : Image.network(
                                              project.iconUrl!,
                                              width: 20,
                                              height: 20,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Icon(
                                                    Icons.image_not_supported,
                                                    size: 16,
                                                    color: Colors.grey,
                                                  ),
                                            ),
                                  )
                                else
                                  Icon(
                                    Icons.image,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    project.projectName ?? 'Unnamed',
                                    style: TextStyle(fontSize: 11),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                    onChanged: (Project? selected) {
                      setState(() {
                        _selectedProject = selected;
                      });
                      if (selected != null) {
                        fetchWorkItems(selected.projectId);
                      }
                    },
                  ),
                ),
              ),
            ),
            Spacer(),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') _logout();
              },
              itemBuilder:
                  (context) => [
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
            if (errorMessage != null)
              Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            Text(
              'Hello ${_fullName ?? _username} 👋',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
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
                Text(
                  'Quick access',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Edit',
                  style: TextStyle(color: Colors.blue, fontSize: 14),
                ),
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
                        Text(
                          'Personalize this space',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Add your most important stuff here, for fast access.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Add items',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Work Items',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16),
            _isWorkItemsLoading
                ? Center(child: CircularProgressIndicator())
                : workItems.isEmpty
                ? Text('No work items found')
                : Column(
                  children:
                      workItems.map((workItem) {
                        return _buildRecentItemWithWidgetIcon(
                          SvgPicture.asset(
                            _getIconForWorkItem(workItem),
                            width: 24,
                            height: 24,
                          ),
                          workItem.summary,
                          workItem.key,
                          null,
                          () {
                            if (workItem.type == 'EPIC') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          EpicDetailPage(epicId: workItem.key),
                                ),
                              );
                            } else if (workItem.type == 'TASK' ||
                                workItem.type == 'STORY' || workItem.type == 'BUG') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          TaskDetailPage(taskId: workItem.key),
                                ),
                              );
                            } else if (workItem.type == 'SUBTASK') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => SubtaskDetailPage(
                                        subtaskId: workItem.key,
                                      ),
                                ),
                              );
                            }
                          },
                        );
                      }).toList(),
                ),
          ],
        ),
      ),

    );
  }

  Widget _buildRecentItemWithWidgetIcon(
    Widget iconWidget,
    String title,
    String subtitle, [
    String? color,
    VoidCallback? onTap,
  ]) {
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
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              child: iconWidget,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getIconForWorkItem(WorkItem workItem) {
    switch (workItem.type) {
      case 'EPIC':
        return 'assets/type_epic.svg';
      case 'TASK':
        return 'assets/type_task.svg';
      case 'STORY':
        return 'assets/type_story.svg';
      case 'SUBTASK':
        return 'assets/type_subtask.svg';
      case 'BUG':
        return 'assets/type_bug.svg';
      default:
        return 'assets/type_task.svg';
    }
  }
}
