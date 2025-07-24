import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../Helper/UriHelper.dart';
import '../Login/LoginPage.dart';
import '../Models/Project.dart';
import '../BottomNavBar.dart';

class ProjectListByAccountPage extends StatefulWidget {
  final String username;

  const ProjectListByAccountPage({Key? key, required this.username}) : super(key: key);

  @override
  State<ProjectListByAccountPage> createState() => _ProjectListByAccountPageState();
}

class _ProjectListByAccountPageState extends State<ProjectListByAccountPage> {
  List<Project> projects = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchProjects();
  }

  Future<void> fetchProjects() async {
    setState(() {
      isLoading = true;
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
        },
      );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        if (jsonBody['isSuccess'] == true) {
          final data = jsonBody['data'];
          if (data is List) {
            setState(() {
              projects = data
                  .map((projectJson) {
                try {
                  if (projectJson is Map<String, dynamic>) {
                    return Project.fromJson(projectJson);
                  } else {
                    print('Invalid project JSON: $projectJson');
                    return null;
                  }
                } catch (e) {
                  print('Error parsing project: $projectJson, Error: $e');
                  return null;
                }
              })
                  .where((project) => project != null)
                  .cast<Project>()
                  .toList();
              isLoading = false;
            });
          } else {
            setState(() {
              errorMessage = 'Invalid data format: data is not a list';
              isLoading = false;
            });
          }
        } else {
          setState(() {
            errorMessage = jsonBody['message'] ?? 'Failed to load projects';
            isLoading = false;
          });
        }
      } else if (response.statusCode == 401) {
        setState(() {
          errorMessage = 'Unauthorized: Please log in again';
          isLoading = false;
        });
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginPage()),
              (route) => false,
        );
      } else {
        setState(() {
          errorMessage = 'Server error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Network error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Projects for ${widget.username}'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.red)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final project = projects[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: project.iconUrl != null
                  ? (project.iconUrl!.toLowerCase().endsWith('.svg')
                  ? SvgPicture.network(
                project.iconUrl!,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                placeholderBuilder: (context) =>
                const Icon(Icons.image_not_supported, size: 40),
              )
                  : Image.network(
                project.iconUrl!,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.image_not_supported, size: 40);
                },
              ))
                  : const Icon(Icons.image_not_supported, size: 40),
              title: Text(
                project.projectName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                'Key: ${project.projectKey}\nStatus: ${project.projectStatus}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              onTap: () {
                // Add navigation or action for project tap
              },
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        username: widget.username,
        currentIndex: 1,
      ),
    );
  }
}