class Transaction {
  final String id;
  final String title;
  final double amount;
  final String category;
  final String provider;
  final bool isIncome;
  final DateTime date;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.provider,
    required this.isIncome,
    required this.date,
  });
}