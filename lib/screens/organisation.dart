import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class OrganizationScreen extends StatefulWidget {
  final String organizationsUrl;

  const OrganizationScreen({required this.organizationsUrl, Key? key}) : super(key: key);

  @override
  _OrganizationScreenState createState() => _OrganizationScreenState();
}

class _OrganizationScreenState extends State<OrganizationScreen> {
  late Future<List<Organization>> organizations;

  @override
  void initState() {
    super.initState();
    organizations = fetchOrganizations();
  }

  Future<List<Organization>> fetchOrganizations() async {
    final response = await http.get(Uri.parse(widget.organizationsUrl));
    
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Organization.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load organizations');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organizations'),
        centerTitle: true ,
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<List<Organization>>(
        future: organizations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              backgroundColor: Colors.white,
            ));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No organizations found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final organization = snapshot.data![index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(organization.avatarUrl),
                  ),
                  title: Text(
                    organization.login,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    organization.description,
                    style: const TextStyle(color: Colors.white60),
                  ),
                  onTap: () {
                    launchUrl(Uri.parse(organization.htmlUrl));
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

class Organization {
  final String login;
  final String avatarUrl;
  final String description;
  final String htmlUrl;

  Organization({
    required this.login,
    required this.avatarUrl,
    required this.description,
    required this.htmlUrl,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      login: json['login'],
      htmlUrl: json['url'],
      avatarUrl: json['avatar_url'],
      description: json['description'] ?? 'No description available', // Handle null description
    );
  }
}
