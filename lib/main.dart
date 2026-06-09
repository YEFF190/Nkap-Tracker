import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_navigation.dart';
import 'screens/pin_screen.dart';

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
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkPin();
  }

  Future<void> _checkPin() async {
    final prefs = await SharedPreferences.getInstance();
    final String? pin = prefs.getString('pin');

    if (!mounted) return;

    if (pin == null) {
      // No PIN set — go to setup
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PinScreen(
            isSetup: true,
            onSuccess: () async {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainNavigation(),
                ),
              );
            },
          ),
        ),
      );
    } else {
      // PIN exists — ask for it
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PinScreen(
            isSetup: false,
            correctPin: pin,
            onSuccess: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainNavigation(),
                ),
              );
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF2D2D2D),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'N',
              style: TextStyle(
                color: Colors.white,
                fontSize: 60,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Nkap Tracker',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}