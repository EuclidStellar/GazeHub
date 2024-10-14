import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

class StarredRepoScreen extends StatefulWidget {
  final String starredUrl;

  const StarredRepoScreen({required this.starredUrl, Key? key}) : super(key: key);

  @override
  _StarredRepoScreenState createState() => _StarredRepoScreenState();
}

class _StarredRepoScreenState extends State<StarredRepoScreen> {
  late Future<List<StarredRepo>> starredRepos;

  @override
  void initState() {
    super.initState();
    starredRepos = fetchStarredRepos();
  }

  Future<List<StarredRepo>> fetchStarredRepos() async {
    final response = await http.get(Uri.parse(widget.starredUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => StarredRepo.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load starred repositories');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: Colors.white,
        title: const Text('Starred Repositories'),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<List<StarredRepo>>(
        future: starredRepos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              color: Colors.black,
              backgroundColor: Colors.white,
              
            ));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No starred repositories found.'));
          } else {
            return ListView.builder(

              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final repo = snapshot.data![index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(repo.ownerAvatarUrl),
                  ),
                  title: Text(repo.fullName , style: const TextStyle(color: Colors.white , fontWeight: FontWeight.bold),),
                  subtitle: Text(repo.description , style: const TextStyle(
                    color: Colors.white ,
                    fontSize: 12,
                  ),),
                  trailing: Text(repo.language , style: const TextStyle(
                    color: Colors.amber
                  ),),
                  onTap: () {
                    // Handle starred repo tap, e.g., open in a web browser
                    launchUrl(Uri.parse(repo.htmlUrl));
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

class StarredRepo {
  final String id;
  final String name;
  final String fullName;
  final String description;
  final String htmlUrl;
  final String ownerLogin;
  final String ownerAvatarUrl;
  final String language;

  StarredRepo({
    required this.id,
    required this.name,
    required this.fullName,
    required this.description,
    required this.htmlUrl,
    required this.ownerLogin,
    required this.ownerAvatarUrl,
    required this.language,
  });

  factory StarredRepo.fromJson(Map<String, dynamic> json) {
    return StarredRepo(
      id: json['id'].toString(),
      name: json['name'],
      fullName: json['full_name'],
      description: json['description'] ?? 'No description available',
      htmlUrl: json['html_url'],
      ownerLogin: json['owner']['login'],
      ownerAvatarUrl: json['owner']['avatar_url'],
      language: json['language'] ?? 'N/A',
    );
  }
}
