import 'package:flutter/material.dart';
import 'package:gazehub/screens/followers.dart';
import 'package:gazehub/screens/following.dart';
import 'package:gazehub/screens/organisation.dart';
import 'package:gazehub/screens/repo.dart';
import 'package:gazehub/screens/starred_repo.dart';
import 'package:gazehub/service/api.dart';
import 'package:url_launcher/url_launcher.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final GitHubService _gitHubService = GitHubService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

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

  // Fetch user data from GitHub API
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

  // Widget to display user info
  Widget _buildUserInfo() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    }

    if (_userData == null) {
      return const Center(
        child: Text(
          'Failed to load user data.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar and Username
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(_userData!['avatar_url']),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userData!['name'] ?? 'No Name',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${_userData!['login']}',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Bio and Blog
            if (_userData!['bio'] != null) ...[
              const Text(
                'Bio',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _userData!['bio'],
                style: TextStyle(fontSize: 16, color: Colors.grey[400]),
              ),
            ],

            // Company and Location

            const SizedBox(height: 20),

            // Repositories, Followers, Following
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard('Repos', _userData!['public_repos'].toString(),
                    () {
                  _navigateToScreen('repos');
                }),
                _buildStatCard('Followers', _userData!['followers'].toString(),
                    () {
                  _navigateToScreen('followers');
                }),
                _buildStatCard('Following', _userData!['following'].toString(),
                    () {
                  _navigateToScreen('following');
                }),
              ],
            ),

            const SizedBox(height: 20),
            if (_userData!['company'] != null ||
                _userData!['location'] != null ||
                _userData!['organizations_url'] != null)
              Row(
                children: [
                  if (_userData!['company'] != null)
                    _buildInfoCard('Company', _userData!['company']),
                  const SizedBox(width: 10),
                  if (_userData!['location'] != null)
                    _buildInfoCard('Location', _userData!['location']),
                  const SizedBox(width: 10),
                  if (_userData!['organizations_url'] != null)
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => OrganizationScreen(
                                    organizationsUrl:
                                        _userData!['organizations_url'])),
                          );
                        },
                        child: _buildInfoCard('Organizations', "View")),
                ],
              ),
            const SizedBox(height: 20),
            GestureDetector(
                onTap: () {
                  _navigateToScreen('starred');
                },
                child: _buildInfoCard('Starred Repos', 'View')),
            // HTML URL (GitHub Profile Link)
            TextButton(
              onPressed: () {
                final url = _userData!['html_url'];
                _launchURL(Uri.parse(url));
              },
              child: const Text(
                'Visit GitHub Profile',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to create stat cards (e.g., repos, followers, following)
  Widget _buildStatCard(String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[400],
            ),
          )
        ],
      ),
    );
  }

  // Helper widget to create info cards (e.g., company, location)
  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  // Navigation based on stat card selection
  void _navigateToScreen(String type) {
    switch (type) {
      case 'repos':
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ReposScreen(reposUrl: _userData!['repos_url'])),
        );
        break;
      case 'followers':
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  FollowerScreen(followersUrl: _userData!['followers_url'])),
        );
        break;
      case 'following':
        String followingUrl = _userData!['following_url'].split('{')[0];
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  FollowingScreen(followingUrl: followingUrl)),
        );
      case 'starred':
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => StarredRepoScreen(
                  starredUrl: _userData!['starred_url'].split('{')[0])),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _buildUserInfo(),
    );
  }
}
