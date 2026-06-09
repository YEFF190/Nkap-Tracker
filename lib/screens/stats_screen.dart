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

  final List<Color> _chartColors = [
    const Color(0xFF2D2D2D),
    Colors.red,
    Colors.orange,
    Colors.blue,
    Colors.purple,
    Colors.teal,
  ];

  @override
  Widget build(BuildContext context) {
    final categories = expensesByCategory;
    final total = totalExpenses;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text(
          'Statistics',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['This Month', 'Last Month', 'All Time']
                    .map((period) {
                  final isSelected = _selectedPeriod == period;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedPeriod = period),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF2D2D2D)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        period,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // Income vs Expenses summary cards
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
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
                            color: const Color(0xFF2D2D2D).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.arrow_downward,
                              color: Color(0xFF2D2D2D), size: 18),
                        ),
                        const SizedBox(height: 10),
                        const Text('Total Income',
                            style: TextStyle(
                                color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          '${totalIncome.toStringAsFixed(0)} FCFA',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
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
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.arrow_upward,
                              color: Colors.red, size: 18),
                        ),
                        const SizedBox(height: 10),
                        const Text('Total Expenses',
                            style: TextStyle(
                                color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          '${totalExpenses.toStringAsFixed(0)} FCFA',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Pie chart
            if (categories.isNotEmpty) ...[
              const Text(
                'Expenses by Category',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
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
                              title: '${percentage.toStringAsFixed(0)}%',
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
                          sectionsSpace: 2,
                          centerSpaceRadius: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Legend
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
                              '${cat.key} (${cat.value.toStringAsFixed(0)} FCFA)',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ] else
              const Center(
                child: Column(
                  children: [
                    SizedBox(height: 40),
                    Icon(Icons.bar_chart, size: 60, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      'No expense data yet',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Bar chart - Income vs Expenses
            const Text(
              'Income vs Expenses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
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
                            color: const Color(0xFF2D2D2D),
                            width: 40,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 1,
                        barRods: [
                          BarChartRodData(
                            toY: totalExpenses,
                            color: Colors.red,
                            width: 40,
                            borderRadius: BorderRadius.circular(6),
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
                                return const Text('Income',
                                    style: TextStyle(fontSize: 12));
                              case 1:
                                return const Text('Expenses',
                                    style: TextStyle(fontSize: 12));
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
    );
  }
}