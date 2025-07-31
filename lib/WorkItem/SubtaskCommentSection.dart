import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Helper/UriHelper.dart';
import '../Models/ActivityLog.dart';
import '../Models/SubtaskComment.dart';

class SubtaskCommentSection extends StatefulWidget {
  final String subtaskId;

  const SubtaskCommentSection({super.key, required this.subtaskId});

  @override
  State<SubtaskCommentSection> createState() => _SubtaskCommentSectionState();
}

class _SubtaskCommentSectionState extends State<SubtaskCommentSection> {
  String selectedActivity = 'Comments';
  List<SubtaskComment> comments = [];
  List<String> activities = ['Comments', 'History'];
  int? currentUserId;
  String commentInput = '';
  int? editingCommentId;
  TextEditingController editController = TextEditingController();
  bool isOldestFirst = true;
  List<ActivityLog> activityLogs = [];

  @override
  void initState() {
    super.initState();
    fetchComments();
    fetchCurrentUserId();
    fetchActivityLogs();
  }

  Future<void> fetchComments() async {
    final url = UriHelper.build('/subtaskcomment/by-subtask/${widget.subtaskId}');
    final response = await http.get(url, headers: {'accept': '*/*'});

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonMap = jsonDecode(response.body);
      final List<dynamic> dataList = jsonMap['data'];

      setState(() {
        if (dataList.isEmpty) {
          print('No comment');
          comments = [];
        } else {
          comments = dataList.map((e) => SubtaskComment.fromJson(e)).toList();
          comments.sort((a, b) {
            final aDate = DateTime.parse(a.createdAt);
            final bDate = DateTime.parse(b.createdAt);
            return isOldestFirst
                ? aDate.compareTo(bDate)
                : bDate.compareTo(aDate);
          });
        }
      });
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Failed to fetch comment: ${response.statusCode}'),
      //   ),
      // );
    }
  }

  Future<void> _createCommentSubtask(String content) async {
    final prefs = await SharedPreferences.getInstance();
    final createdBy = prefs.getInt('accountId');

    if (createdBy == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('AccountId not found')));
      return;
    }

    final url = UriHelper.build('/subtaskcomment');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'accept': '*/*'},
      body: jsonEncode({
        "subtaskId": widget.subtaskId,
        "accountId": createdBy,
        "content": content,
        "createdBy": createdBy,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      commentInput = '';
      print("Created successfully");
      await fetchComments();
      await fetchActivityLogs();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Comment failed: ${response.statusCode}'),
        ),
      );
    }
  }

  Future<void> deleteComment(int commentId, int createdBy) async {
    final uri = UriHelper.build('/subtaskcomment/$commentId');
    final response = await http.delete(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'createdBy': createdBy}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['isSuccess'] == true) {
        print("Delete successfully");
        await fetchComments();
        await fetchActivityLogs();
      } else {
        print("Delete failed: ${json['message']}");
      }
    } else {
      print("Error: ${response.statusCode}");
    }
  }

  Future<void> updateComment(int commentId, String updatedContent) async {
    final prefs = await SharedPreferences.getInstance();
    final accountId = prefs.getInt('accountId');
    if (accountId == null) return;

    final comment = comments.firstWhere(
          (c) => c.id == commentId,
    );

    final response = await http.put(
      UriHelper.build('/subtaskcomment/$commentId'),
      headers: {'Content-Type': 'application/json', 'accept': '*/*'},
      body: jsonEncode({
        "subtaskId": comment.subtaskId,
        "accountId": accountId,
        "content": updatedContent,
        "createdBy": accountId,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Updated comment')));
      await fetchComments();
      await fetchActivityLogs();

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Updated error: ${response.statusCode}')),
      );
    }
  }

  Future<void> fetchActivityLogs() async {
    final uri = UriHelper.build('/activitylog/subtask/${widget.subtaskId}');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> data = jsonData['data'];
        setState(() {
          activityLogs = data.map((e) => ActivityLog.fromJson(e)).toList();
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('API error: $e');
    }
  }

  Future<void> fetchCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getInt('accountId');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            PopupMenuButton<String>(
              initialValue: selectedActivity,
              onSelected: (value) {
                setState(() {
                  selectedActivity = value;
                });
              },
              itemBuilder:
                  (context) =>
                  activities
                      .map(
                        (e) => PopupMenuItem<String>(
                      value: e,
                      child: Row(
                        children: [
                          if (selectedActivity == e)
                            Icon(Icons.check, size: 16),
                          if (selectedActivity == e) SizedBox(width: 8),
                          Text(e),
                        ],
                      ),
                    ),
                  )
                      .toList(),
              child: Row(
                children: [
                  Text(
                    selectedActivity,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  isOldestFirst = !isOldestFirst;
                  comments.sort((a, b) {
                    final aDate = DateTime.parse(a.createdAt);
                    final bDate = DateTime.parse(b.createdAt);
                    return isOldestFirst
                        ? aDate.compareTo(bDate)
                        : bDate.compareTo(aDate);
                  });
                  activityLogs.sort((a, b) {
                    final aDate = DateTime.parse(a.createdAt);
                    final bDate = DateTime.parse(b.createdAt);
                    return isOldestFirst
                        ? aDate.compareTo(bDate)
                        : bDate.compareTo(aDate);
                  });
                });
              },
              child: Text(isOldestFirst ? "Oldest first" : "Newest first"),
            ),
          ],
        ),
        const SizedBox(height: 4),

        if (selectedActivity == 'Comments') ...[
          Column(
            children:
            comments.map((comment) {
              final isEditing = editingCommentId == comment.id;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.white,
                elevation: 1,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundImage:
                    comment.accountPicture.isNotEmpty
                        ? NetworkImage(comment.accountPicture)
                        : null,
                    child:
                    comment.accountPicture.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            comment.accountName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            formatDateTime(comment.createdAt),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            textAlign:
                            TextAlign
                                .right,
                          ),
                        ],
                      ),
                      if (isEditing)
                        Column(
                          children: [
                            TextField(
                              controller: editController,
                              maxLines: null,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Edit comment',
                              ),
                            ),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    await updateComment(
                                      comment.id,
                                      editController.text,
                                    );
                                    setState(() {
                                      editingCommentId = null;
                                    });
                                    await fetchComments();
                                    await fetchActivityLogs();
                                  },
                                  child: const Text("Save"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      editingCommentId = null;
                                    });
                                  },
                                  child: const Text("Cancel"),
                                ),
                              ],
                            ),
                          ],
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              comment.content,
                              style: const TextStyle(color: Colors.black),
                            ),
                            const SizedBox(height: 4),
                            if (comment.accountId == currentUserId)
                              Row(
                                children: [
                                  TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        editingCommentId = comment.id;
                                        editController.text =
                                            comment.content;
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.edit,
                                      size: 13,
                                      color: Colors.black54,
                                    ),
                                    label: const Text(
                                      "Edit",
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 13,
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(50, 20),
                                      tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  TextButton.icon(
                                    onPressed: () async {
                                      final confirm = await showDialog<
                                          bool
                                      >(
                                        context: context,
                                        builder:
                                            (ctx) => AlertDialog(
                                          title: const Text(
                                            "Delete confirm",
                                          ),
                                          content: const Text(
                                            "Are you sure delete comment?",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(
                                                ctx,
                                                false,
                                              ),
                                              child: const Text("Cancel"),
                                            ),
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(
                                                ctx,
                                                true,
                                              ),
                                              child: const Text("Delete"),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        await deleteComment(
                                          comment.id,
                                          currentUserId!,
                                        );
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                      size: 13,
                                      color: Colors.black54,
                                    ),
                                    label: const Text(
                                      "Delete",
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 13,
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(60, 20),
                                      tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ] else if (selectedActivity == 'History') ...[
          if (activityLogs.isNotEmpty) ...[
            Column(
              children: activityLogs.map((log) {
                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text(
                      log.createdByName ?? 'None',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(log.message ?? ''),
                        const SizedBox(height: 4),
                        Text(
                          formatDateTime(log.createdAt),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ] else ...[
            const Center(child: Text('No activity logs found.')),
          ],
        ],

        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (value) => commentInput = value,
                decoration: const InputDecoration(
                  hintText: "Comment...",
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () async {
                if (commentInput.trim().isEmpty) return;
                await _createCommentSubtask(commentInput);
                setState(() {
                  commentInput = '';
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  String formatDateTime(String createdAt) {
    final dt =
    DateTime.parse(createdAt).toLocal();
    final date =
        "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
    final time =
        "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";

    return "$date\n$time";
  }
}
