import 'package:flutter/material.dart';
import 'package:gazehub/screens/homepage.dart';
import 'package:gazehub/screens/search_user.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.grey,
        useMaterial3: true,
        
        // Set default scaffold background color to black
        scaffoldBackgroundColor: Colors.black,
        
        // Set text color to white by default
        textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme.apply(
                bodyColor: Colors.white,    // Text color set to white
                displayColor: Colors.white, // Headings text color to white
              ),
        ),
        
        // Button theme to use grey color
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Colors.grey, // Button text color to white
          ),
        ),
        
        // Apply visual density for adaptive platforms
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      title: 'GazeHub',
      debugShowCheckedModeBanner: false,
      home: GitHubCloneHomePage(),
    );
  }
}
