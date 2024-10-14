
import 'package:flutter/material.dart';
import 'package:gazehub/service/api.dart';

class GitHubApiScreen extends StatefulWidget {
  @override
  _GitHubApiScreenState createState() => _GitHubApiScreenState();
}

class _GitHubApiScreenState extends State<GitHubApiScreen> {
  final GitHubService _gitHubService = GitHubService();
  final TextEditingController _usernameController = TextEditingController();
  String _output = "";
  bool _isLoading = false;

  // Function to fetch user data by username
  void _fetchUserByUsername(String username) async {
    setState(() {
      _isLoading = true;
      _output = "Fetching user data...";
    });

    try {
      final userData = await _gitHubService.fetchUserByUsername(username);
      setState(() {
        _output = userData.toString();
      });
    } catch (e) {
      setState(() {
        _output = 'Error: $e';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GitHub User Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Enter GitHub Username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                final username = _usernameController.text.trim();
                if (username.isNotEmpty) {
                  _fetchUserByUsername(username);
                }
              },
              child: Text('Search User'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Text(
                        _output,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
