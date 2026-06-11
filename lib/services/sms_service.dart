import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';

class SmsService {
  static final SmsQuery _query = SmsQuery();

  static final List<Map<String, dynamic>> _patterns = [
    {
      'pattern': RegExp(
        r'received\s+([\d,]+)\s*FCFA',
        caseSensitive: false,
      ),
      'provider': 'MTN',
      'isIncome': true,
      'category': 'Income',
    },
    {
      'pattern': RegExp(
        r'sent\s+([\d,]+)\s*FCFA',
        caseSensitive: false,
      ),
      'provider': 'MTN',
      'isIncome': false,
      'category': 'Transfer',
    },
    {
      'pattern': RegExp(
        r'payment of\s+([\d,]+)\s*FCFA',
        caseSensitive: false,
      ),
      'provider': 'MTN',
      'isIncome': false,
      'category': 'Bills',
    },
    {
      'pattern': RegExp(
        r'recu\s+([\d,]+)\s*F',
        caseSensitive: false,
      ),
      'provider': 'Orange',
      'isIncome': true,
      'category': 'Income',
    },
    {
      'pattern': RegExp(
        r'envoye\s+([\d,]+)\s*F',
        caseSensitive: false,
      ),
      'provider': 'Orange',
      'isIncome': false,
      'category': 'Transfer',
    },
    {
      'pattern': RegExp(
        r'paiement de\s+([\d,]+)\s*F',
        caseSensitive: false,
      ),
      'provider': 'Orange',
      'isIncome': false,
      'category': 'Bills',
    },
  ];

  // Request SMS permission
  static Future<bool> requestPermission() async {
    final status = await Permission.sms.request();
    return status.isGranted;
  }

  // Parse SMS and return Transaction if it matches
  static Transaction? parseSms(SmsMessage message) {
    final body = message.body ?? '';
    final sender = message.sender ?? '';

    // Only process MTN or Orange messages
    final isMTN = sender.toLowerCase().contains('mtn') ||
        body.toLowerCase().contains('mtn') ||
        body.toLowerCase().contains('momo');
    final isOrange = sender.toLowerCase().contains('orange') ||
        body.toLowerCase().contains('orange money');

    if (!isMTN && !isOrange) return null;

    for (final pattern in _patterns) {
      final match = (pattern['pattern'] as RegExp).firstMatch(body);
      if (match != null) {
        final amountStr = match.group(1)!.replaceAll(',', '');
        final amount = double.tryParse(amountStr);
        if (amount == null) continue;

        // Override provider based on actual sender
        String provider = pattern['provider'] as String;
        if (isOrange) provider = 'Orange';
        if (isMTN) provider = 'MTN';

        return Transaction(
          id: const Uuid().v4(),
          title: _extractTitle(body, pattern['isIncome'] as bool),
          amount: amount,
          category: pattern['category'] as String,
          provider: provider,
          isIncome: pattern['isIncome'] as bool,
          date: message.date ?? DateTime.now(),
        );
      }
    }
    return null;
  }

  static String _extractTitle(String message, bool isIncome) {
    if (isIncome) {
      final fromMatch = RegExp(
        r'from\s+([A-Za-z\s]+)',
        caseSensitive: false,
      ).firstMatch(message);
      if (fromMatch != null) {
        return 'Received from ${fromMatch.group(1)!.trim()}';
      }
      return 'Money Received';
    } else {
      final toMatch = RegExp(
        r'to\s+([A-Za-z\s]+)',
        caseSensitive: false,
      ).firstMatch(message);
      if (toMatch != null) {
        return 'Sent to ${toMatch.group(1)!.trim()}';
      }
      return 'Money Sent';
    }
  }

  // Read existing MoMo SMS from inbox
  static Future<List<Transaction>> readExistingSms() async {
    final List<Transaction> transactions = [];
    try {
      final messages = await _query.querySms(
        kinds: [SmsQueryKind.inbox],
      );

      for (final message in messages) {
        final transaction = parseSms(message);
        if (transaction != null) {
          transactions.add(transaction);
        }
      }
    } catch (e) {
      print('Error reading SMS: $e');
    }
    return transactions;
  }
}