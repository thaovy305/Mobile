import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Models/Sprint.dart';
import '../../Helper/UriHelper.dart';

class CompleteSprintBottomSheet extends StatefulWidget {
  final int sprintId;
  final String sprintName;
  final String projectKey;
  final int projectId;
  final int workItem;
  final int workItemCompleted;
  final int workItemOpen;
  final Future<void> Function() onTaskUpdated;

  const CompleteSprintBottomSheet({
    super.key,
    required this.sprintId,
    required this.sprintName,
    required this.projectKey,
    required this.projectId,
    required this.workItem,
    required this.workItemCompleted,
    required this.workItemOpen,
    required this.onTaskUpdated,
  });

  @override
  State<CompleteSprintBottomSheet> createState() => _CompleteSprintBottomSheetState();
}

class _CompleteSprintBottomSheetState extends State<CompleteSprintBottomSheet> {
  bool _isLoading = false;
  bool _isConfirming = false;
  String? _selectedTarget;
  List<Sprint> _sprints = [];
  Sprint? _currentSprint;
  String? _sprintsError;
  String? _sprintError;

  @override
  void initState() {
    super.initState();

    if (widget.projectId > 0) {
      _fetchSprints();
    }
    _fetchCurrentSprint();
  }

  Future<bool> validateCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';
    final token = prefs.getString('accessToken') ?? '';
    if (email.isEmpty || token.isEmpty) {
      setState(() {
        _sprintsError = 'Credentials not found in preferences';
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credentials not found in preferences')),
      );
      return false;
    }
    return true;
  }

  Future<void> _fetchSprints() async {
    setState(() {
      _isLoading = true;
      _sprintsError = null;
    });
    try {
      if (!await validateCredentials()) return;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';
      final uri = UriHelper.build('/sprint/by-project-id?projectId=${widget.projectId}');

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
        if (jsonBody['isSuccess'] == true && jsonBody['data'] is List) {
          final sprints = (jsonBody['data'] as List).map((s) => Sprint.fromJson(s)).toList();
          setState(() {
            _sprints = sprints.where((s) => s.id != widget.sprintId && s.status != 'COMPLETED').toList();
            if (_sprints.isNotEmpty && _selectedTarget == null) {
              _selectedTarget = _sprints[0].id.toString();
            } else if (_sprints.isEmpty && _selectedTarget == null) {
              _selectedTarget = 'new_sprint';
            }
          });
        } else {
          setState(() {
            _sprintsError = jsonBody['message'] ?? 'Failed to load sprints';
          });
        }
      } else {
        setState(() {
          _sprintsError = 'Server error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _sprintsError = 'Network error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchCurrentSprint() async {
    setState(() {
      _isLoading = true;
      _sprintError = null;
    });
    try {
      if (!await validateCredentials()) return;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';
      final uri = UriHelper.build('/sprint/${widget.sprintId}');

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
          setState(() {
            _currentSprint = Sprint.fromJson(jsonBody['data']);
          });
        } else {
          setState(() {
            _sprintError = jsonBody['message'] ?? 'Failed to load sprint details';
          });
        }
      } else {
        setState(() {
          _sprintError = 'Server error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _sprintError = 'Network error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _moveTasks(String type, int sprintNewId) async {
    try {
      if (!await validateCredentials()) return;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';
      final uri = UriHelper.build('/sprint/move-tasks');
      final body = jsonEncode({
        'sprintOldId': widget.sprintId,
        'sprintNewId': sprintNewId,
        'type': type,
      });

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
        body: body,
      );

      if (response.statusCode != 200) {
        final jsonBody = json.decode(response.body);
        throw Exception(jsonBody['message'] ?? 'Failed to move tasks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to move tasks: $e');
    }
  }

  Future<void> _updateSprintStatus() async {
    try {
      if (!await validateCredentials()) return;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';
      final uri = UriHelper.build('/sprint/${widget.sprintId}/status');

      final response = await http.patch(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
        body: '"COMPLETED"',
      );

      if (response.statusCode != 200) {
        final jsonBody = json.decode(response.body);
        throw Exception(jsonBody['message'] ?? 'Failed to update sprint status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update sprint status: $e');
    }
  }

  Future<void> _handleConfirmMove() async {
    if (_selectedTarget == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a target sprint or option')),
      );
      return;
    }
    if (_currentSprint?.status == 'COMPLETED') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This sprint is already completed')),
      );
      return;
    }

    final targetName = _selectedTarget == 'new_sprint'
        ? 'a new sprint'
        : _selectedTarget == 'backlog'
        ? 'the backlog'
        : _sprints.firstWhere((s) => s.id.toString() == _selectedTarget!).name;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Complete Sprint'),
        content: Text(
          'Are you sure you want to complete sprint ${widget.sprintId} and move its ${widget.workItem} work item(s) to $targetName? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isConfirming = true;
        _sprintsError = null;
        _sprintError = null;
      });
      try {
        String type;
        int sprintNewId = 0;
        if (_selectedTarget == 'new_sprint') {
          type = 'NEW_SPRINT';
        } else if (_selectedTarget == 'backlog') {
          type = 'BACKLOG';
        } else {
          type = 'CHANGE';
          sprintNewId = int.parse(_selectedTarget!);
        }

        await _moveTasks(type, sprintNewId);
        await _updateSprintStatus();
        await widget.onTaskUpdated();
        if (mounted) Navigator.pop(context);
      } catch (e) {

        setState(() {
          _sprintError = 'Failed to complete sprint: $e';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to complete sprint: $e')),
        );
      } finally {
        setState(() {
          _isConfirming = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isValidProjectId = widget.projectId > 0;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Error messages
          if (_sprintsError != null || _sprintError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _sprintsError ?? _sprintError ?? 'Unknown error',
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          // Image
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: Image.network(
              'https://res.cloudinary.com/didnsp4p0/image/upload/v1753250008/ChatGPT_Image_12_50_58_23_thg_7__2025-removebg-preview_t3c6sw.png',
              width: 80,
              height: 80,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, size: 50),
            ),
          ),
          // Content
          Text(
            'Complete ${widget.sprintName}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 6),
          Text(
            'This sprint contains ${widget.workItemCompleted} completed work item(s) and ${widget.workItemOpen} open work item(s).',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '• Completed work items include everything in the last column on the board, Done.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                '• Open work items include everything from any other column on the board.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Dropdown
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Open work items to',
              border: OutlineInputBorder(),
            ),
            value: _selectedTarget,
            items: [
              if (_sprints.isEmpty)
                const DropdownMenuItem(
                  value: '',
                  enabled: false,
                  child: Text('No active or future sprints available'),
                ),
              ..._sprints.map((sprintData) => DropdownMenuItem(
                value: sprintData.id.toString(),
                child: Text(sprintData.name ?? 'Unnamed Sprint'),
              )),
              const DropdownMenuItem(value: 'new_sprint', child: Text('New Sprint')),
              const DropdownMenuItem(value: 'backlog', child: Text('Backlog')),
            ],
            onChanged: _isConfirming || _isLoading || !isValidProjectId || _currentSprint?.status == 'COMPLETED'
                ? null
                : (value) {
              setState(() {
                _selectedTarget = value;
              });
            },
            hint: Text(
              _isLoading
                  ? 'Loading sprints...'
                  : !isValidProjectId
                  ? 'Invalid project ID'
                  : _currentSprint?.status == 'COMPLETED'
                  ? 'Sprint already completed'
                  : 'Select an option',
            ),
          ),
          const SizedBox(height: 16),
          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _isConfirming ? null : () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isConfirming || _isLoading || !isValidProjectId || _selectedTarget == null || _currentSprint?.status == 'COMPLETED'
                    ? null
                    : _handleConfirmMove,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                ),
                child: _isConfirming
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : const Text('Complete Sprint'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}