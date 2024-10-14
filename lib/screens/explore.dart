

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class ExploreScreen extends StatefulWidget {
  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<String> randomIssues = [
    'Shouldn\'t need an end date for a sprint',
    'Add a feature to support dark mode',
    'Improve the performance of the search function',
    'Fix memory leaks in the application',
    'Refactor the codebase to follow best practices',
    'Update the documentation for API endpoints',
    'Add more tests for the main application',
    'Implement error handling for API calls',
    'Support more formats in file upload feature',
    'Integrate analytics for user engagement tracking',
    'Create a tutorial for new users',
    'Improve accessibility features',
    'Add pagination to the issue list',
    'Optimize images for better load times',
    'Implement notifications for new issues',
    'Add keyboard shortcuts for better navigation',
    'Create a feedback form for users',
    'Improve UI responsiveness on mobile',
    'Integrate third-party authentication',
    'Update dependencies to the latest versions'
  ];

  List<Map<String, dynamic>> beginnerIssues = [];
  String searchUser = '';
  Map<String, dynamic>? userData;
  List<Map<String, dynamic>> fetchedIssues = []; // Store fetched issues
  final GlobalKey<AnimatedListState> _animatedListKey = GlobalKey<AnimatedListState>();
  int _currentIndex = 0; // To keep track of the current index
  late Timer _timer;

  final String _baseUrl = 'https://api.github.com';

  @override
  void initState() {
    super.initState();
    _fetchBeginnerIssues();
    _startRandomIssueChange();
  }

  void _startRandomIssueChange() {
    // ignore: prefer_const_constructors
    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      setState(() {
        randomIssues.shuffle();
        _fetchIssueData(randomIssues.first); // Fetch data for the first random issue
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _fetchBeginnerIssues() async {
    try {
      final issues = await fetchGoodFirstIssues();
      setState(() {
        beginnerIssues = issues;
      });
    } catch (e) {
      print('Failed to fetch beginner issues: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchGoodFirstIssues() async {
    final response = await http.get(Uri.parse('$_baseUrl/search/issues?q=label:"good first issue"&sort=comments&order=desc'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return List<Map<String, dynamic>>.from(jsonResponse['items']);
    } else {
      throw Exception('Failed to load good first issues');
    }
  }

  Future<Map<String, dynamic>> fetchUser(String username) async {
    final response = await http.get(Uri.parse('$_baseUrl/users/$username'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<void> _fetchIssueData(String issueTitle) async {
    final response = await http.get(Uri.parse('$_baseUrl/search/issues?q=$issueTitle'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      List<Map<String, dynamic>> issues = List<Map<String, dynamic>>.from(jsonResponse['items']);
      setState(() {
        fetchedIssues.addAll(issues);
        for (var issue in issues) {
          _animatedListKey.currentState?.insertItem(_currentIndex++);
        }
      });
    } else {
      print('Failed to fetch issue data for "$issueTitle": ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              cursorColor: Colors.white,
              decoration: InputDecoration(
        
                hintText: 'Search GitHub Users by ID',
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
              ),
              style: const TextStyle(color: Colors.white),
              onSubmitted: (value) {
                _searchUser(value);
              },
            ),
            const SizedBox(height: 20),

            // Display User Information
            if (userData != null) _buildUserCard(userData!),
            const SizedBox(height: 20),

            // Fetched Random Issues Section
            const Text(
              'Fetched Random Issues',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Container(
              height: 200, // Increased height for better visibility
              child: AnimatedList(
                key: _animatedListKey,
                scrollDirection: Axis.horizontal,
                initialItemCount: fetchedIssues.length,
                itemBuilder: (context, index, animation) {
                  return _buildAnimatedIssueCard(fetchedIssues[index], animation);
                },
              ),
            ),
            const SizedBox(height: 20),

            // Good First Issues Section
            const Text(
              'Good First Issues',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            if (beginnerIssues.isEmpty)
              const Center(child: CircularProgressIndicator(color: Colors.white))
            else
              Container(
                height: 400, // Set a fixed height for the ListView
                child: ListView.builder(
                  itemCount: beginnerIssues.length,
                  itemBuilder: (context, index) {
                    return _buildIssueCard(beginnerIssues[index]);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Widget to create user cards
  Widget _buildUserCard(Map<String, dynamic> user) {
    return Card(
      color: Colors.grey[800],
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(user['avatar_url']),
        ),
        title: Text(user['login'], style: const TextStyle(color: Colors.white)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${user['name'] ?? 'N/A'}', style: TextStyle(color: Colors.grey[400])),
            Text('Followers: ${user['followers']}', style: TextStyle(color: Colors.grey[400])),
            Text('Public Repos: ${user['public_repos']}', style: TextStyle(color: Colors.grey[400])),
          ],
        ),
        onTap: () {
          launchUrl(Uri.parse(user['html_url']));
        },
      ),
    );
  }

  // Widget to create animated issue cards
  Widget _buildAnimatedIssueCard(Map<String, dynamic> issue, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1.0, 0.0), // Start from the left
        end: Offset.zero,
      ).animate(animation),
      child: Container(
        width: 200, // Set a fixed width for better layout
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Card(
          color: Colors.grey[800],
          child: ListTile(
            title: Text(issue['title'], style: const TextStyle(color: Colors.white)),
            subtitle: Text('Repo: ${issue['repository_url'] ?? "N/A"}', style: TextStyle(color: Colors.grey[400])),
            onTap: () {
              launchUrl(Uri.parse(issue['html_url']));
            },
          ),
        ),
      ),
    );
  }

  // Widget to create issue cards
  Widget _buildIssueCard(Map<String, dynamic> issue) {
    return Card(
      color: Colors.grey[800],
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        title: Text(issue['title'], style: const TextStyle(color: Colors.white)),
        subtitle: Text('Repo: ${issue['repository_url'] ?? "N/A"}', style: TextStyle(color: Colors.grey[400])),
        onTap: () {
          launchUrl(Uri.parse(issue['html_url']));
        },
      ),
    );
  }

  // Function to search for users
  void _searchUser(String userId) async {
    try {
      final user = await fetchUser(userId);
      setState(() {
        userData = user;
      });
    } catch (e) {
      print('Error fetching user: $e');
    }
  }
}
