import 'package:flutter/material.dart';
import '../models/transaction.dart';

class HistoryScreen extends StatefulWidget {
  final List<Transaction> transactions;
  const HistoryScreen({super.key, required this.transactions});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  static const Color primaryDark = Color(0xFF0A1628);
  static const Color primaryBlue = Color(0xFF1A3A5C);
  static const Color accentBlue = Color(0xFF2D6A9F);

  String _filter = 'All';
  String _searchQuery = '';

  List<Transaction> get filteredTransactions {
    return widget.transactions.where((t) {
      final matchesFilter = _filter == 'All'
          ? true
          : _filter == 'Income'
              ? t.isIncome
              : !t.isIncome;
      final matchesSearch =
          t.title.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food': return Icons.restaurant;
      case 'transport': return Icons.directions_bus;
      case 'income': return Icons.account_balance_wallet;
      case 'bills': return Icons.receipt_long;
      case 'school': return Icons.school;
      case 'transfer': return Icons.swap_horiz;
      default: return Icons.attach_money;
    }
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K';
    return amount.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: Column(
        children: [
          // Header
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primaryDark, primaryBlue, accentBlue],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  children: [
          const Text(
  'Transaction History',
  style: TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 20,
  ),
),
                    const SizedBox(height: 16),
                    // Search bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: TextField(
                        onChanged: (val) =>
                            setState(() => _searchQuery = val),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search transactions...',
                          hintStyle:
                              const TextStyle(color: Colors.white54),
                          prefixIcon: const Icon(Icons.search,
                              color: Colors.white54),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Filter tabs
                    Row(
                      children: ['All', 'Income', 'Expense'].map((f) {
                        final isSelected = _filter == f;
                        return GestureDetector(
                          onTap: () => setState(() => _filter = f),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              f,
                              style: TextStyle(
                                color: isSelected
                                    ? primaryDark
                                    : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Count
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredTransactions.length} transactions',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: filteredTransactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long,
                            size: 60,
                            color: Colors.grey.withOpacity(0.4)),
                        const SizedBox(height: 16),
                        const Text(
                          'No transactions found',
                          style: TextStyle(
                              color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final t = filteredTransactions[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: t.isIncome
                                    ? const Color(0xFF00C48C)
                                        .withOpacity(0.1)
                                    : const Color(0xFFFF6B6B)
                                        .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                _getCategoryIcon(t.category),
                                color: t.isIncome
                                    ? const Color(0xFF00C48C)
                                    : const Color(0xFFFF6B6B),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: primaryDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2),
                                        decoration: BoxDecoration(
                                          color: t.provider == 'MTN'
                                              ? const Color(0xFFFFCC00)
                                                  .withOpacity(0.2)
                                              : const Color(0xFFFF6600)
                                                  .withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          t.provider,
                                          style: TextStyle(
                                            color: t.provider == 'MTN'
                                                ? const Color(0xFFB8860B)
                                                : const Color(0xFFFF6600),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${t.date.day}/${t.date.month}/${t.date.year}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${t.isIncome ? '+' : '-'}${_formatAmount(t.amount)}',
                                  style: TextStyle(
                                    color: t.isIncome
                                        ? const Color(0xFF00C48C)
                                        : const Color(0xFFFF6B6B),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const Text(
                                  'FCFA',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}