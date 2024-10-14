import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

class ReposScreen extends StatefulWidget {
  final String reposUrl;

  const ReposScreen({required this.reposUrl, Key? key}) : super(key: key);

  @override
  _ReposScreenState createState() => _ReposScreenState();
}

class _ReposScreenState extends State<ReposScreen> {
  late Future<List<Repo>> repos;

  @override
  void initState() {
    super.initState();
    repos = fetchRepos();
  }

  Future<List<Repo>> fetchRepos() async {
    final response = await http.get(Uri.parse(widget.reposUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Repo.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load repositories');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Repositories'),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<List<Repo>>(
        future: repos,
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
            return const Center(child: Text('No repositories found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final repo = snapshot.data![index];
                return ListTile(
                  title: Text(repo.name , style: const TextStyle(color: Colors.white , fontSize: 18 , fontWeight: FontWeight.bold),),
                  subtitle: Text(repo.description ?? 'No description' , style: const TextStyle(color: Colors.white , fontSize: 12 , fontWeight: FontWeight.normal),),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Open the repository page on GitHub
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

class Repo {
  final String name;
  final String? description;
  final String htmlUrl;

  Repo({
    required this.name,
    this.description,
    required this.htmlUrl,
  });

  factory Repo.fromJson(Map<String, dynamic> json) {
    return Repo(
      name: json['name'],
      description: json['description'],
      htmlUrl: json['html_url'],
    );
  }
}
