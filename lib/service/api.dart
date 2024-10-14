import 'dart:convert';
import 'package:gazehub/data/access.dart';
import 'package:http/http.dart' as http;

class GitHubService {
  final String baseUrl = 'https://api.github.com';
  final String accessToken = AccessToken().token;

Future<List<dynamic>> _fetchList(Uri url) async {
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',  // Include the token here
        'Accept': 'application/vnd.github.v3+json',  // Ensure using GitHub API v3
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Please check your token.');
    } else {
      throw Exception('Failed to load data from ${url.toString()}');
    }
  }

  // Fetches the list of users that the current user is following

Future<Map<String, dynamic>> fetchUserByUsername(String username) async {
    final url = Uri.parse('$baseUrl/users/$username');
    return await _fetchData(url);
  }

  // Helper method for making a request and parsing data
  Future<Map<String, dynamic>> _fetchData(Uri url) async {
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',  // Include the token here
        'Accept': 'application/vnd.github.v3+json',  // Ensure using GitHub API v3
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('User not found.');
    } else {
      throw Exception('Failed to load data from ${url.toString()}');
    }
  }



  // Fetches current user data
  Future<Map<String, dynamic>> fetchCurrentUser() async {
    final url = Uri.parse('https://api.github.com/user');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/vnd.github.v3+json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user data');
    }
  }
}
