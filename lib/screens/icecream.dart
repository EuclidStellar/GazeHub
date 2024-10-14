

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileSearchScreen extends StatefulWidget {
  @override
  _ProfileSearchScreenState createState() => _ProfileSearchScreenState();
}

class _ProfileSearchScreenState extends State<ProfileSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> recentSearches = [];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  void _loadRecentSearches() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      recentSearches = prefs.getStringList('recentSearches') ?? [];
    });
  }

  void _saveRecentSearch(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      if (!recentSearches.contains(username)) {
        recentSearches.insert(0, username);
        if (recentSearches.length > 5) {
          recentSearches.removeLast();
        }
      } else {
        recentSearches.remove(username);
        recentSearches.insert(0, username);
      }
    });
    await prefs.setStringList('recentSearches', recentSearches);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,  // Black background
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Search GitHub username',
                  hintStyle: TextStyle(color: Colors.white70),
                  prefixIcon: Icon(Icons.search, color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[800],  // Grey background for input
                ),
                style: TextStyle(color: Colors.white),
                onSubmitted: (value) => _searchProfile(value),
              ),
            ),
            Expanded(
              child: recentSearches.isEmpty
                  ? Center(child: Text('No recent searches', style: TextStyle(color: Colors.white)))
                  : ListView.builder(
                      itemCount: recentSearches.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                                'https://api.github.com/users/${recentSearches[index]}/avatar'),
                            onBackgroundImageError: (_, __) => Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(recentSearches[index], style: TextStyle(color: Colors.white)),
                          onTap: () => _searchProfile(recentSearches[index]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _searchProfile(String username) {
    _saveRecentSearch(username);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(username: username),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  final String username;

  ProfileScreen({required this.username});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<Map<String, dynamic>> userData;
  late Future<List<dynamic>> followers;
  late Future<List<dynamic>> following;
  late Future<List<dynamic>> repos;
  late Future<List<dynamic>> starred;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    userData = fetchUserData(widget.username);
    followers = fetchFollowers(widget.username);
    following = fetchFollowing(widget.username);
    repos = fetchRepos(widget.username);
    starred = fetchStarred(widget.username);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> fetchUserData(String username) async {
    final response = await http.get(Uri.parse('https://api.github.com/users/$username'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user data');
    }
  }

  Future<List<dynamic>> fetchFollowers(String username) async {
    final response = await http.get(Uri.parse('https://api.github.com/users/$username/followers'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load followers');
    }
  }

  Future<List<dynamic>> fetchFollowing(String username) async {
    final response = await http.get(Uri.parse('https://api.github.com/users/$username/following'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load following');
    }
  }

  Future<List<dynamic>> fetchRepos(String username) async {
    final response = await http.get(Uri.parse('https://api.github.com/users/$username/repos'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load repos');
    }
  }

  Future<List<dynamic>> fetchStarred(String username) async {
    final response = await http.get(Uri.parse('https://api.github.com/users/$username/starred'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load starred repos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,  // Black background
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              backgroundColor: Colors.black,
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(widget.username, style: TextStyle(color: Colors.white)),
                background: FutureBuilder<Map<String, dynamic>>(
                  future: userData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
                    } else {
                      final user = snapshot.data!;
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            user['avatar_url'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[800],
                                child: Icon(Icons.person, color: Colors.white, size: 100),
                              );
                            },
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  tabs: [
                    Tab(icon: Icon(Icons.person, color: Colors.white), text: "Profile"),
                    Tab(icon: Icon(Icons.people, color: Colors.white), text: "Network"),
                    Tab(icon: Icon(Icons.code, color: Colors.white), text: "Repos"),
                    Tab(icon: Icon(Icons.star, color: Colors.white), text: "Starred"),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildProfileTab(),
            _buildNetworkTab(),
            _buildReposTab(),
            _buildStarredTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: userData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
        } else {
          final user = snapshot.data!;
          return ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              _buildInfoTile(Icons.person, 'Name', user['name'] ?? 'N/A'),
              _buildInfoTile(Icons.info, 'Bio', user['bio'] ?? 'N/A'),
              _buildInfoTile(Icons.link, 'Blog', user['blog'] ?? 'N/A'),
              _buildInfoTile(Icons.location_on, 'Location', user['location'] ?? 'N/A'),
            ],
          );
        }
      },
    );
  }

  Widget _buildNetworkTab() {
    return Column(
      children: [
        Expanded(
          child: _buildFollowersTab(),
        ),
        Expanded(
          child: _buildFollowingTab(),
        ),
      ],
    );
  }

  Widget _buildFollowersTab() {
    return FutureBuilder<List<dynamic>>(
      future: followers,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
        } else {
          final followers = snapshot.data!;
          return ListView.builder(
            itemCount: followers.length,
            itemBuilder: (context, index) {
              final follower = followers[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(follower['avatar_url']),
                  onBackgroundImageError: (_, __) => Icon(Icons.person, color: Colors.white),
                ),
                title: Text(follower['login'], style: TextStyle(color: Colors.white)),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildFollowingTab() {
    return FutureBuilder<List<dynamic>>(
      future: following,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
        } else {
          final following = snapshot.data!;
          return ListView.builder(
            itemCount: following.length,
            itemBuilder: (context, index) {
              final followee = following[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(followee['avatar_url']),
                  onBackgroundImageError: (_, __) => Icon(Icons.person, color: Colors.white),
                ),
                title: Text(followee['login'], style: TextStyle(color: Colors.white)),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildReposTab() {
    return FutureBuilder<List<dynamic>>(
      future: repos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
        } else {
          final repos = snapshot.data!;
          return ListView.builder(
            itemCount: repos.length,
            itemBuilder: (context, index) {
              final repo = repos[index];
              return ListTile(
                leading: Icon(Icons.book, color: Colors.white),
                title: Text(repo['name'], style: TextStyle(color: Colors.white)),
                subtitle: Text(repo['description'] ?? 'No description', style: TextStyle(color: Colors.grey)),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildStarredTab() {
    return FutureBuilder<List<dynamic>>(
      future: starred,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
        } else {
          final starred = snapshot.data!;
          return ListView.builder(
            itemCount: starred.length,
            itemBuilder: (context, index) {
              final repo = starred[index];
              return ListTile(
                leading: Icon(Icons.star, color: Colors.white),
                title: Text(repo['name'], style: TextStyle(color: Colors.white)),
                subtitle: Text(repo['description'] ?? 'No description', style: TextStyle(color: Colors.grey)),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: TextStyle(color: Colors.white)),
      subtitle: Text(value, style: TextStyle(color: Colors.grey[300])),
      tileColor: Colors.grey.withOpacity(0.2),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.black,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
