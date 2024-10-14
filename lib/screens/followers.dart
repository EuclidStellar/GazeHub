import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

class FollowerScreen extends StatefulWidget {
  final String followersUrl;

  const FollowerScreen({required this.followersUrl, Key? key}) : super(key: key);

  @override
  _FollowerScreenState createState() => _FollowerScreenState();
}

class _FollowerScreenState extends State<FollowerScreen> {
  late Future<List<Follower>> followers;

  @override
  void initState() {
    super.initState();
    followers = fetchFollowers();
  }

  Future<List<Follower>> fetchFollowers() async {
    final response = await http.get(Uri.parse(widget.followersUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Follower.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load followers');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Followers'),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<List<Follower>>(
        future: followers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding:  EdgeInsets.all(128.0),
              child: Center(child: LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                color: Colors.black,
                backgroundColor: Colors.white,
              
              )),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No followers found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final follower = snapshot.data![index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(follower.avatarUrl),
                  ),
                  title: Text(follower.login , style: const TextStyle(color: Colors.white , fontSize: 18 , fontWeight: FontWeight.bold)),
                  subtitle: Text(follower.htmlUrl , style: const TextStyle(color: Colors.white)),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Handle follower profile tap
                    launchUrl(Uri.parse(follower.htmlUrl));
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

class Follower {
  final String login;
  final String avatarUrl;
  final String htmlUrl;

  Follower({
    required this.login,
    required this.avatarUrl,
    required this.htmlUrl,
  });

  factory Follower.fromJson(Map<String, dynamic> json) {
    return Follower(
      login: json['login'],
      avatarUrl: json['avatar_url'],
      htmlUrl: json['html_url'],
      
    );
  }
}


