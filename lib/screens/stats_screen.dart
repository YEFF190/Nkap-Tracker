import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction.dart';

class StatsScreen extends StatefulWidget {
  final List<Transaction> transactions;
  const StatsScreen({super.key, required this.transactions});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  static const Color primaryDark = Color(0xFF0A1628);
  static const Color primaryBlue = Color(0xFF1A3A5C);
  static const Color accentBlue = Color(0xFF2D6A9F);
  static const Color accentGold = Color(0xFFF0A500);

  String _selectedPeriod = 'This Month';

  Map<String, double> get expensesByCategory {
    final Map<String, double> result = {};
    for (var t in widget.transactions.where((t) => !t.isIncome)) {
      result[t.category] = (result[t.category] ?? 0) + t.amount;
    }
    return result;
  }

  double get totalIncome => widget.transactions
      .where((t) => t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpenses => widget.transactions
      .where((t) => !t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);

  double get savingsRate => totalIncome > 0
      ? ((totalIncome - totalExpenses) / totalIncome * 100)
      : 0;

  String _formatAmount(double amount) {
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K';
    return amount.toStringAsFixed(0);
  }

  final List<Color> _chartColors = [
    const Color(0xFF2D6A9F),
    const Color(0xFFFF6B6B),
    const Color(0xFFF0A500),
    const Color(0xFF00C48C),
    Colors.purple,
    Colors.teal,
  ];

  @override
  Widget build(BuildContext context) {
    final categories = expensesByCategory;
    final total = totalExpenses;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SingleChildScrollView(
        child: Column(
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
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                           onPressed: () => Navigator.canPop(context) ? Navigator.pop(context) : null,
                          ),
                          const Text(
                            'Statistics',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Period selector
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ['This Month', 'Last Month', 'All Time']
                              .map((period) {
                            final isSelected = _selectedPeriod == period;
                            return GestureDetector(
                              onTap: () => setState(
                                  () => _selectedPeriod = period),
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
                                  period,
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
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Summary cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          label: 'Total Income',
                          value: '${_formatAmount(totalIncome)} FCFA',
                          icon: Icons.arrow_downward_rounded,
                          color: const Color(0xFF00C48C),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          label: 'Total Expenses',
                          value: '${_formatAmount(totalExpenses)} FCFA',
                          icon: Icons.arrow_upward_rounded,
                          color: const Color(0xFFFF6B6B),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Savings rate card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [primaryDark, primaryBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Savings Rate',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${savingsRate.toStringAsFixed(1)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: accentGold.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.savings_outlined,
                            color: accentGold,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Pie chart
                  if (categories.isNotEmpty) ...[
                    _buildSectionTitle('Expenses by Category'),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 200,
                            child: PieChart(
                              PieChartData(
                                sections: categories.entries
                                    .toList()
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  final index = entry.key;
                                  final cat = entry.value;
                                  final percentage =
                                      (cat.value / total * 100);
                                  return PieChartSectionData(
                                    value: cat.value,
                                    title:
                                        '${percentage.toStringAsFixed(0)}%',
                                    color: _chartColors[
                                        index % _chartColors.length],
                                    radius: 80,
                                    titleStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  );
                                }).toList(),
                                sectionsSpace: 3,
                                centerSpaceRadius: 0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            children: categories.entries
                                .toList()
                                .asMap()
                                .entries
                                .map((entry) {
                              final index = entry.key;
                              final cat = entry.value;
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: _chartColors[
                                          index % _chartColors.length],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${cat.key} (${_formatAmount(cat.value)} FCFA)',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Bar chart
                  _buildSectionTitle('Income vs Expenses'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: totalIncome > totalExpenses
                              ? totalIncome * 1.2
                              : totalExpenses * 1.2,
                          barGroups: [
                            BarChartGroupData(
                              x: 0,
                              barRods: [
                                BarChartRodData(
                                  toY: totalIncome,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF00C48C),
                                      Color(0xFF00A376)
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                  width: 50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 1,
                              barRods: [
                                BarChartRodData(
                                  toY: totalExpenses,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFF6B6B),
                                      Color(0xFFFF4444)
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                  width: 50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ],
                            ),
                          ],
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  switch (value.toInt()) {
                                    case 0:
                                      return const Padding(
                                        padding: EdgeInsets.only(top: 8),
                                        child: Text('Income',
                                            style:
                                                TextStyle(fontSize: 12)),
                                      );
                                    case 1:
                                      return const Padding(
                                        padding: EdgeInsets.only(top: 8),
                                        child: Text('Expenses',
                                            style:
                                                TextStyle(fontSize: 12)),
                                      );
                                    default:
                                      return const Text('');
                                  }
                                },
                              ),
                            ),
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: primaryDark,
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}