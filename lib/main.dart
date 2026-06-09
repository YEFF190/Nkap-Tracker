import 'package:flutter/material.dart';
import 'main_navigation.dart';

void main() {
  runApp(const NkapTrackerApp());
}

class NkapTrackerApp extends StatelessWidget {
  const NkapTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nkap Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D2D2D),
        ),
        useMaterial3: true,
      ),
      home: const MainNavigation(),
    );
  }
}