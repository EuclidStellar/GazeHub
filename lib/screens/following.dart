import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

class FollowingScreen extends StatefulWidget {
  final String followingUrl;

  const FollowingScreen({required this.followingUrl, Key? key}) : super(key: key);

  @override
  _FollowingScreenState createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  late Future<List<Following>> following;

  @override
  void initState() {
    super.initState();
    following = fetchFollowing();
  }

  Future<List<Following>> fetchFollowing() async {
    final response = await http.get(Uri.parse(widget.followingUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Following.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load following');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Following'),
        centerTitle: true,
        foregroundColor: Colors.white,

        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<List<Following>>(
        future: following,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Padding(
              padding: EdgeInsets.all(128.0),
              child: LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                backgroundColor: Colors.white,
                color: Colors.black,
              ),
            ));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No following found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final followingUser = snapshot.data![index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(followingUser.avatarUrl),
                  ),
                  title: Text(followingUser.login , style: const TextStyle(color: Colors.white , fontWeight: FontWeight.bold),),
                  subtitle: Text(followingUser.htmlUrl , style: const TextStyle(color: Colors.white)),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Handle following user profile tap
                    launchUrl(Uri.parse(followingUser.htmlUrl));
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

class Following {
  final String login;
  final String avatarUrl;
  final String htmlUrl;

  Following({
    required this.login,
    required this.avatarUrl,
    required this.htmlUrl,
  });

  factory Following.fromJson(Map<String, dynamic> json) {
    return Following(
      login: json['login'],
      avatarUrl: json['avatar_url'],
      htmlUrl: json['html_url'],
    );
  }
}
