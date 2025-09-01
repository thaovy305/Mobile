import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Models/Sprint.dart';
import '../../Helper/UriHelper.dart';

class StartSprintBottomSheet extends StatefulWidget {
  final int sprintId;
  final Sprint sprint;
  final int workItemCount;
  final String projectKey;
  final DateTime initialStartDate;
  final DateTime initialEndDate;
  final Future<void> Function() onTaskUpdated;

  const StartSprintBottomSheet({
    super.key,
    required this.sprintId,
    required this.sprint,
    required this.workItemCount,
    required this.projectKey,
    required this.initialStartDate,
    required this.initialEndDate,
    required this.onTaskUpdated,
  });

  @override
  State<StartSprintBottomSheet> createState() => _StartSprintBottomSheetState();
}

class _StartSprintBottomSheetState extends State<StartSprintBottomSheet> {
  late DateTime _startDate;
  late DateTime _endDate;
  String sprintName = '';
  String sprintGoal = '';
  String selectedDuration = '1 week';
  final List<String> durations = ['1 week', '2 weeks', '3 weeks'];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    sprintName = widget.sprint.name ?? '';
  }

  Future<bool> validateCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';
    final token = prefs.getString('accessToken') ?? '';
    if (email.isEmpty || token.isEmpty) {
      setState(() {
        _errorMessage = 'Credentials not found in preferences';
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credentials not found in preferences')),
      );
      return false;
    }
    return true;
  }

  Future<void> updateSprint(int sprintId, String name, String goal, DateTime startDate, DateTime endDate) async {
    try {
      if (!await validateCredentials()) return;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';
      final uri = UriHelper.build('/sprint/$sprintId');
      final formattedStartDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(startDate.toUtc());
      final formattedEndDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(endDate.toUtc());
      final body = jsonEncode({
        'projectId': widget.sprint.projectId,
        'name': name,
        'goal': goal.isEmpty ? null : goal,
        'startDate': formattedStartDate,
        'endDate': formattedEndDate,
        'plannedStartDate': formattedStartDate,
        'plannedEndDate': formattedEndDate,
        'status': 'ACTIVE',
      });


      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
        body: body,
      );


      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        if (jsonBody['isSuccess'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sprint updated successfully')),
          );
        } else {
          setState(() {
            _errorMessage = jsonBody['message'] ?? 'Failed to update sprint';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update sprint: ${jsonBody['message']}')),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Server error: ${response.statusCode}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error occurred or sprint not found')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          // Adjust end date based on selected duration
          if (selectedDuration == '1 week') {
            _endDate = _startDate.add(const Duration(days: 7));
          } else if (selectedDuration == '2 weeks') {
            _endDate = _startDate.add(const Duration(days: 14));
          } else if (selectedDuration == '3 weeks') {
            _endDate = _startDate.add(const Duration(days: 21));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _handleConfirm() async {
    if (_startDate.isAfter(_endDate)) {
      setState(() {
        _errorMessage = 'Start date must be before end date';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Start date must be before end date')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await updateSprint(widget.sprintId, sprintName, sprintGoal, _startDate, _endDate);
      await widget.onTaskUpdated();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('h a E, dd MMM, yyyy', 'en_US');

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle drag indicator
          Container(
            height: 5,
            width: 40,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Error message display
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),

          // Header with button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Start Sprint',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: _isLoading ? null : _handleConfirm,
                child: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text(
                  'Start Sprint',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),

          // Sprint name input
          TextField(
            decoration: const InputDecoration(
              labelText: 'Sprint Name',
              border: OutlineInputBorder(),
              counterText: '',
            ),
            maxLength: 30,
            onChanged: (value) => sprintName = value,
            controller: TextEditingController(text: sprintName),
          ),
          const SizedBox(height: 12),

          // Duration dropdown
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Sprint Duration',
              border: OutlineInputBorder(),
            ),
            value: selectedDuration,
            items: durations
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedDuration = value;
                  // Adjust end date when duration changes
                  if (selectedDuration == '1 week') {
                    _endDate = _startDate.add(const Duration(days: 7));
                  } else if (selectedDuration == '2 weeks') {
                    _endDate = _startDate.add(const Duration(days: 14));
                  } else if (selectedDuration == '3 weeks') {
                    _endDate = _startDate.add(const Duration(days: 21));
                  }
                });
              }
            },
          ),
          const SizedBox(height: 12),

          // Start date
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Start Date'),
            trailing: TextButton(
              onPressed: () => _selectDate(context, true),
              child: Text(dateFormat.format(_startDate)),
            ),
          ),

          // End date
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('End Date'),
            trailing: TextButton(
              onPressed: () => _selectDate(context, false),
              child: Text(dateFormat.format(_endDate)),
            ),
          ),
          const SizedBox(height: 12),

          // Sprint goal input
          TextField(
            decoration: const InputDecoration(
              labelText: 'Sprint Goal',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => sprintGoal = value,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}