import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_navigation.dart';
import 'screens/pin_screen.dart';
import 'screens/login_screen.dart';

// GlobalKey allows us to navigate from ANYWHERE in the app
// even from settings which is deep inside the widget tree
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const NkapTrackerApp());
}

class NkapTrackerApp extends StatelessWidget {
  const NkapTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nkap Tracker',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey, // ← register the global key
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D2D2D),
        ),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Color(0xFF0A1628),
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFFF0A500)),
              ),
            );
          }
          if (snapshot.data == null) return const LoginScreen();
          return const SplashScreen();
        },
      ),
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
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    final String? pin = prefs.getString('pin');
    final bool pinEnabled = prefs.getBool('pin_enabled') ?? false;

    if (!mounted) return;

    if (pin == null || !pinEnabled) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigation()),
      );
    } else {
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
      backgroundColor: Color(0xFF0A1628),
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
              style: TextStyle(color: Colors.white70, fontSize: 20),
            ),
            SizedBox(height: 30),
            CircularProgressIndicator(color: Color(0xFFF0A500)),
          ],
        ),
      ),
    );
  }
}