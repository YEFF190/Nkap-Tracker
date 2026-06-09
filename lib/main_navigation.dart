import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'models/transaction.dart';
import 'screens/home_screen.dart';
import 'screens/history_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/settings_screen.dart';

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
  }

  // Load transactions from local storage
  Future<void> _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('transactions');
    if (data != null) {
      final List<dynamic> jsonList = jsonDecode(data);
      setState(() {
        _transactions = jsonList.map((json) => Transaction(
          id: json['id'],
          title: json['title'],
          amount: json['amount'].toDouble(),
          category: json['category'],
          provider: json['provider'],
          isIncome: json['isIncome'],
          date: DateTime.parse(json['date']),
        )).toList();
      });
    } else {
      // Default sample transactions for first launch
      setState(() {
        _transactions = [
          Transaction(
            id: '1',
            title: 'Salary',
            amount: 150000,
            category: 'Income',
            provider: 'MTN',
            isIncome: true,
            date: DateTime.now(),
          ),
          Transaction(
            id: '2',
            title: 'Food',
            amount: 5000,
            category: 'Food',
            provider: 'Orange',
            isIncome: false,
            date: DateTime.now(),
          ),
          Transaction(
            id: '3',
            title: 'Transport',
            amount: 500,
            category: 'Transport',
            provider: 'MTN',
            isIncome: false,
            date: DateTime.now(),
          ),
        ];
      });
    }
    setState(() => _isLoading = false);
  }

  // Save transactions to local storage
  Future<void> _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList = _transactions.map((t) => {
      'id': t.id,
      'title': t.title,
      'amount': t.amount,
      'category': t.category,
      'provider': t.provider,
      'isIncome': t.isIncome,
      'date': t.date.toIso8601String(),
    }).toList();
    await prefs.setString('transactions', jsonEncode(jsonList));
  }

  void _addTransaction(Transaction t) {
    setState(() {
      _transactions.insert(0, t);
    });
    _saveTransactions();
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