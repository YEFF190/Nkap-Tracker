import 'package:flutter/material.dart';
import 'models/transaction.dart';
import 'screens/home_screen.dart';
import 'screens/history_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/settings_screen.dart';
import 'services/database_helper.dart';
import 'services/sms_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/firestore_service.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  List<Transaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _initSms();
  }

 Future<void> _loadTransactions() async {
  // Step 1 — Load local SQLite first (instant, no internet needed)
  final localTransactions = await DatabaseHelper.instance.getAllTransactions();
  setState(() {
    _transactions = localTransactions; // show immediately
    _isLoading = false;
  });

  // Step 2 — Then load from Firestore in background
  try {
    final cloudTransactions = await FirestoreService.instance.getAllTransactions();
    
    // Step 3 — Merge: combine both lists without duplicates
    // We use the transaction ID to detect duplicates
    final localIds = localTransactions.map((t) => t.id).toSet();
    final newFromCloud = cloudTransactions
        .where((t) => !localIds.contains(t.id))
        .toList();

    // Step 4 — Save cloud-only transactions to local SQLite too
    for (final t in newFromCloud) {
      await DatabaseHelper.instance.insertTransaction(t);
    }

    // Step 5 — Update screen with complete merged list
    if (newFromCloud.isNotEmpty) {
      final allTransactions = await DatabaseHelper.instance.getAllTransactions();
      setState(() {
        _transactions = allTransactions;
      });
    }
  } catch (e) {
    // No internet — local data already showing, no problem!
    debugPrint('Firestore unavailable: $e');
  }
}

  Future<void> _initSms() async {
  final prefs = await SharedPreferences.getInstance();
  final bool smsAlreadyImported = prefs.getBool('sms_imported') ?? false;
  
  if (smsAlreadyImported) return; // Don't import again!

  final bool granted = await SmsService.requestPermission();
  if (granted) {
    final existingSms = await SmsService.readExistingSms();
    for (final t in existingSms) {
      await DatabaseHelper.instance.insertTransaction(t);
    }
    if (existingSms.isNotEmpty) {
      _loadTransactions();
    }
    // Mark as imported so it never runs again
    await prefs.setBool('sms_imported', true);
  }
}

  Future<void> _addTransaction(Transaction t) async {
    await DatabaseHelper.instance.insertTransaction(t);
    setState(() {
      _transactions.insert(0, t);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
              SizedBox(height: 20),
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Loading your Nkap...',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }

    final screens = [
      HomeScreen(
        transactions: _transactions,
        onAddTransaction: _addTransaction,
      ),
      HistoryScreen(transactions: _transactions),
      StatsScreen(transactions: _transactions),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF2D2D2D),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.bold),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Stats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}