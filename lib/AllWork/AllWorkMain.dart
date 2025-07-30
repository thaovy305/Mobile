import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../Helper/UriHelper.dart';
import '../Login/LoginPage.dart';
import '../Models/Account.dart';
import 'WorkItemList.dart';
import 'WorkItemDetailed.dart';

// Define enum at file scope
enum ViewType { list, detailed }

class AllWorkMain extends StatefulWidget {
  const AllWorkMain({super.key});

  @override
  State<AllWorkMain> createState() => _AllWorkMainState();
}

class _AllWorkMainState extends State<AllWorkMain> {
  // Initial selected view
  ViewType _selectedView = ViewType.list;
  Account? account;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _checkPreferences().then((_) => fetchAccount());
  }

  Future<void> _checkPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';
    final token = prefs.getString('accessToken') ?? '';

    if (email.isEmpty || token.isEmpty) {
      setState(() {
        errorMessage = 'Email or token not found in preferences';
        isLoading = false;
      });
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
            (route) => false,
      );
    }
  }

  Future<void> fetchAccount() async {
    print("Starting fetchAccount");
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email') ?? '';
      final token = prefs.getString('accessToken') ?? '';
      if (email.isEmpty) {
        setState(() {
          errorMessage = 'Email not found in preferences';
          isLoading = false;
        });
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginPage()),
              (route) => false,
        );
        return;
      }

      final uri = UriHelper.build('/account/$email');

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
        print("Decoded JSON: $jsonBody");
        if (jsonBody['isSuccess'] == true) {
          final accountData = jsonBody['data'];
          if (accountData is Map<String, dynamic>) {
            setState(() {
              account = Account.fromJson(accountData);
              isLoading = false;
            });
          } else {
            setState(() {
              errorMessage = 'Invalid account data format: $accountData';
              isLoading = false;
            });
          }
        } else {
          setState(() {
            errorMessage = jsonBody['message'] ?? 'Failed to load account';
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
      print("Fetch account error: $e");
    }
  }

  // Widget to display based on the selected view
  Widget _getCurrentView() {
    switch (_selectedView) {
      case ViewType.list:
        return const WorkItemList();
      case ViewType.detailed:
        return const WorkItemDetailed();
      default:
        return const WorkItemList();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F6F8),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F6F8),
        body: Center(
          child: Text(
            errorMessage!,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade300,
              child: account?.picture != null
                  ? ClipOval(
                child: Image.network(
                  account!.picture!,
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text(
                      'DH',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              )
                  : const Text(
                'DH',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                "All Work",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search),
              color: Colors.grey,
              onPressed: () {
                // Add search functionality here
              },
            ),
            IconButton(
              icon: const Icon(Icons.add),
              color: Colors.grey,
              onPressed: () {
                // Add add functionality here
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // SegmentedButton centered at the top
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SegmentedButton<ViewType>(
              segments: const <ButtonSegment<ViewType>>[
                ButtonSegment<ViewType>(
                  value: ViewType.list,
                  label: Text('List'),
                ),
                ButtonSegment<ViewType>(
                  value: ViewType.detailed,
                  label: Text('Detailed'),
                ),
              ],
              selected: {_selectedView},
              onSelectionChanged: (Set<ViewType> newSelection) {
                setState(() {
                  _selectedView = newSelection.first;
                });
              },
              style: ButtonStyle(
                padding: const MaterialStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0)),
                // Text color for selected and unselected states
                foregroundColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return Colors.blue;
                  }
                  return Colors.grey;
                }),
                // Background color for selected and unselected states
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return Colors.blue[100];
                  }
                  return Colors.grey[200];
                }),
                // Border color for all states
                side: MaterialStateProperty.all(
                  const BorderSide(color: Colors.grey, width: 1.0),
                ),
              ),
            ),
          ),
          // Expanded to take remaining space and display the selected view
          Expanded(
            child: _getCurrentView(),
          ),
        ],
      ),
    );
  }
}