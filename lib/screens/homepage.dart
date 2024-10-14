import 'package:flutter/material.dart';
import 'package:gazehub/screens/Profile.dart';
import 'package:gazehub/screens/explore.dart';
import 'package:gazehub/screens/icecream.dart';
import 'package:gazehub/service/api.dart';
import 'package:url_launcher/url_launcher.dart';

class GitHubCloneHomePage extends StatefulWidget {
  @override
  _GitHubCloneHomePageState createState() => _GitHubCloneHomePageState();
}

class _GitHubCloneHomePageState extends State<GitHubCloneHomePage> {
  final GitHubService _gitHubService = GitHubService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    Profile(),
    ExploreScreen(),
    ProfileSearchScreen()
  ];

  Future<void> _launchURL(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    try {
      final userData = await _gitHubService.fetchCurrentUser();
      setState(() {
        _userData = userData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'GazeHub',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: _screens[_selectedIndex],  // Display the selected screen
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.icecream),
            label: 'Ice Cream',
          ),
        ],
      ),
    );
  }
}


