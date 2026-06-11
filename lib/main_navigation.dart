import 'package:flutter/material.dart';
import 'models/transaction.dart';
import 'screens/home_screen.dart';
import 'screens/history_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/settings_screen.dart';
import 'services/database_helper.dart';
import 'services/sms_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final transactions = await DatabaseHelper.instance.getAllTransactions();
  setState(() {
    _transactions = transactions; // Will be empty on fresh install 
    _isLoading = false;
  });
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