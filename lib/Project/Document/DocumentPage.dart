import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'DocumentEditorPage.dart';
import '../../Helper/UriHelper.dart';
// LIST WIDGET (reusable & easier to manage)
class DocumentListView extends StatelessWidget {
  final List<dynamic> documents;
  final String emptyListMessage;
  final Future<void> Function() onRefresh;
  final Future<void> Function()? onSilentRefresh; // optional silent refresh callback
  final String tabType;

  const DocumentListView({
    super.key,
    required this.documents,
    required this.emptyListMessage,
    required this.onRefresh,
    this.onSilentRefresh,
    required this.tabType,
  });

  Future<Map<String, dynamic>?> fetchDocumentDetail(int docId, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    final url = UriHelper.build('/documents/$docId');
    try {
      final res = await http.get(url, headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
      });
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final data = body['data'];
        if (data is Map<String, dynamic>) return data;
      }
    } catch (e) {
      print("❌ Error fetching detail: $e");
    }
    return null;
  }

  Color _getTabColor(String type) {
    switch (type) {
      case 'MAIN':
        return Colors.blue;
      case 'PRIVATE':
        return Colors.deepPurple;
      default:
        return Colors.grey;
    }
  }

  IconData _getTabIcon(String type) {
    switch (type) {
      case 'MAIN':
        return Icons.inventory_2_rounded;
      case 'PRIVATE':
        return Icons.lock_rounded;
      default:
        return Icons.description_rounded;
    }
  }

  // Delete API
  Future<bool> _deleteDocument(int docId, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    final url = UriHelper.build('/documents/$docId');

    try {
      final res = await http.delete(url, headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
      });

      if (res.statusCode == 200) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Deleted successfully"),
              backgroundColor: Colors.green[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
        return true;
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to delete document (HTTP ${res.statusCode})"),
              backgroundColor: Colors.red[400],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
        return false;
      }
    } catch (e) {
      print("❌ Error deleting document: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Network error while deleting document"),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
      return false;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays} day(s) ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour(s) ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute(s) ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _getTabColor(tabType).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getTabIcon(tabType),
                size: 64,
                color: _getTabColor(tabType).withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              emptyListMessage,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to create a new document',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: _getTabColor(tabType),
      child: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: documents.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        // Swipe to delete
        itemBuilder: (context, index) {
          final doc = documents[index];
          return Dismissible(
            key: ValueKey(doc['id']),
            direction: DismissDirection.endToStart,
            background: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.red[400],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.delete_forever_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Delete',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            confirmDismiss: (direction) async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: const Text('Confirm delete'),
                    content: Text(
                      'Are you sure you want to permanently delete "${doc['title'] ?? 'Untitled'}"?',
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(foregroundColor: Colors.red[400]),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  );
                },
              );

              if (confirmed != true) {
                return false;
              }

              final success = await _deleteDocument(doc['id'], context);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Deleted "${doc['title'] ?? 'Untitled'}"'),
                    backgroundColor: Colors.green[600],
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
                onRefresh(); // reload list
              }

              return success;
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    final detail = await fetchDocumentDetail(doc['id'], context);
                    if (detail != null && context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DocumentEditorPage(
                            documentId: detail['id'],
                            title: detail['title'] ?? 'Untitled',
                            content: detail['content'] ?? '',
                          ),
                        ),
                      ).then((_) {
                        if (onSilentRefresh != null) {
                          onSilentRefresh!();
                        } else {
                          onRefresh();
                        }
                      });
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("Unable to load document details"),
                          backgroundColor: Colors.red[400],
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getTabColor(tabType).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getTabIcon(tabType),
                            color: _getTabColor(tabType),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doc['title'] ?? 'Untitled',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 14,
                                    color: Colors.grey[500],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Updated: ${_formatDate(doc['updatedAt'])}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// MAIN PAGE (refreshed & simplified)
class DocumentPage extends StatefulWidget {
  final String projectKey;

  const DocumentPage({super.key, required this.projectKey});

  @override
  State<DocumentPage> createState() => _DocumentPageState();
}

class _DocumentPageState extends State<DocumentPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? _projectId;

  List<dynamic> _allDocuments = [];
  List<dynamic> _mainDocuments = [];
  List<dynamic> _privateDocuments = [];

  bool _isLoading = true;

  final List<Map<String, dynamic>> _tabs = const [
    {
      'icon': Icons.inventory_2_rounded,
      'text': 'MAIN',
      'color': Colors.blue,
    },
    {
      'icon': Icons.lock_rounded,
      'text': 'PRIVATE',
      'color': Colors.deepPurple,
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _initializeData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    final id = await _getProjectIdFromKey(widget.projectKey);
    if (id != null) {
      setState(() => _projectId = id);
      await _fetchAndFilterDocuments();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchAndFilterDocuments({bool showLoading = true}) async {
    if (_projectId == null) return;

    if (showLoading) setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    final url = UriHelper.build('/documents/project/$_projectId');

    try {
      final res = await http.get(url, headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
      });

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final data = body['data'];

        if (data is! List) {
          throw Exception('Invalid API format: "data" is not a List');
        }

        final List<Map<String, dynamic>> newDocuments = data
            .where((e) => e is Map<String, dynamic>)
            .cast<Map<String, dynamic>>()
            .toList();

        // Sort by updatedAt (desc)
        newDocuments.sort((a, b) {
          final ua = a['updatedAt']?.toString();
          final ub = b['updatedAt']?.toString();
          if (ua == null && ub == null) return 0;
          if (ua == null) return 1;
          if (ub == null) return -1;
          DateTime? da, db;
          try {
            da = DateTime.parse(ua);
          } catch (_) {}
          try {
            db = DateTime.parse(ub);
          } catch (_) {}
          if (da == null && db == null) return 0;
          if (da == null) return 1;
          if (db == null) return -1;
          return db.compareTo(da);
        });

        setState(() {
          _allDocuments = newDocuments;
          _mainDocuments = _allDocuments.where((doc) => doc['visibility'] == 'MAIN').toList();
          _privateDocuments = _allDocuments.where((doc) => doc['visibility'] == 'PRIVATE').toList();
        });
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Unable to load documents list (HTTP ${res.statusCode})"),
              backgroundColor: Colors.red[400],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Unable to load documents list"),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (showLoading) setState(() => _isLoading = false);
    }
  }

  void _showCreateDocumentDialog() {
    String title = '';
    final String type = ['MAIN', 'PRIVATE'][_tabController.index];
    final currentTab = _tabs[_tabController.index];

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (currentTab['color'] as Color).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    currentTab['icon'] as IconData,
                    size: 32,
                    color: currentTab['color'] as Color,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Create $type document',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Enter document title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: currentTab['color'] as Color),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) => title = value,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (title.isNotEmpty) {
                            Navigator.pop(context);
                            _createDocument(title, type);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: currentTab['color'] as Color,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Create',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<int?> _getProjectIdFromKey(String projectKey) async {
    final url = UriHelper.build('/project/by-project-key?projectKey=$projectKey');
    try {
      final res = await http.get(url, headers: {'accept': '*/*'});
      if (res.statusCode == 200) return jsonDecode(res.body)['data']['id'];
    } catch (e) {
      print('Connection error: $e');
    }
    return null;
  }

  Future<void> _createDocument(String title, String type) async {
    if (_projectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Error: Invalid Project ID."),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    final url = UriHelper.build('/documents/create');
    final bodyData = {
      "projectId": _projectId,
      "title": title,
      "visibility": type,
      "content": ""
    };

    try {
      final response = await http.post(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      }, body: jsonEncode(bodyData));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final data = responseData['data'];
        final int documentId = data['id'];

        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DocumentEditorPage(
                documentId: documentId,
                title: title,
                content: "",
              ),
            ),
          ).then((_) => _fetchAndFilterDocuments(showLoading: false));
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Unable to create document"),
              backgroundColor: Colors.red[400],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Network error while creating document"),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              tabs: _tabs
                  .map((tab) => Tab(
                icon: Icon(
                  tab['icon'] as IconData,
                  size: 20,
                ),
                text: tab['text'] as String,
              ))
                  .toList(),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : TabBarView(
        controller: _tabController,
        children: [
          DocumentListView(
            documents: _mainDocuments,
            emptyListMessage: 'No MAIN documents yet',
            onRefresh: _fetchAndFilterDocuments,
            tabType: 'MAIN',
          ),
          DocumentListView(
            documents: _privateDocuments,
            emptyListMessage: 'No PRIVATE documents yet',
            onRefresh: _fetchAndFilterDocuments,
            tabType: 'PRIVATE',
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _tabs[_tabController.index]['color'] as Color,
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -5,
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _showCreateDocumentDialog,
          backgroundColor: _tabs[_tabController.index]['color'] as Color,
          foregroundColor: Colors.white,
          elevation: 0,
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            'New Document',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
