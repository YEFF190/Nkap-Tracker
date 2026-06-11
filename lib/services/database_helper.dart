import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction.dart' as tx;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('nkap_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_transactions (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        provider TEXT NOT NULL,
        isIncome INTEGER NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE imported_sms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sms_id TEXT UNIQUE NOT NULL
      )
    ''');
  }

  Future<void> insertTransaction(tx.Transaction t) async {
    final db = await database;
    await db.insert(
      'user_transactions',
      {
        'id': t.id,
        'title': t.title,
        'amount': t.amount,
        'category': t.category,
        'provider': t.provider,
        'isIncome': t.isIncome ? 1 : 0,
        'date': t.date.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> isSmsImported(String smsId) async {
    final db = await database;
    final result = await db.query(
      'imported_sms',
      where: 'sms_id = ?',
      whereArgs: [smsId],
    );
    return result.isNotEmpty;
  }

  Future<void> markSmsImported(String smsId) async {
    final db = await database;
    await db.insert(
      'imported_sms',
      {'sms_id': smsId},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<tx.Transaction>> getAllTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_transactions',
      orderBy: 'date DESC',
    );
    return maps.map((map) => tx.Transaction(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      category: map['category'],
      provider: map['provider'],
      isIncome: map['isIncome'] == 1,
      date: DateTime.parse(map['date']),
    )).toList();
  }

  Future<List<tx.Transaction>> getTransactionsByCategory(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_transactions',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'date DESC',
    );
    return maps.map((map) => tx.Transaction(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      category: map['category'],
      provider: map['provider'],
      isIncome: map['isIncome'] == 1,
      date: DateTime.parse(map['date']),
    )).toList();
  }

  Future<List<tx.Transaction>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_transactions',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    return maps.map((map) => tx.Transaction(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      category: map['category'],
      provider: map['provider'],
      isIncome: map['isIncome'] == 1,
      date: DateTime.parse(map['date']),
    )).toList();
  }

  Future<List<tx.Transaction>> getTransactionsByProvider(String provider) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_transactions',
      where: 'provider = ?',
      whereArgs: [provider],
      orderBy: 'date DESC',
    );
    return maps.map((map) => tx.Transaction(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      category: map['category'],
      provider: map['provider'],
      isIncome: map['isIncome'] == 1,
      date: DateTime.parse(map['date']),
    )).toList();
  }

  Future<void> deleteTransaction(String id) async {
    final db = await database;
    await db.delete(
      'user_transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllTransactions() async {
    final db = await database;
    await db.delete('user_transactions');
  }

  Future<double> getTotalIncome() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM user_transactions WHERE isIncome = 1',
    );
    return (result.first['total'] as double?) ?? 0.0;
  }

  Future<double> getTotalExpenses() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM user_transactions WHERE isIncome = 0',
    );
    return (result.first['total'] as double?) ?? 0.0;
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}