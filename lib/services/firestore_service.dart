import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction.dart' as tx;

class FirestoreService {
  // Singleton — same pattern as your DatabaseHelper
  static final FirestoreService instance = FirestoreService._init();
  FirestoreService._init();

  // Get the current logged in user's ID
  // This is how we know WHOSE transactions to save/load
  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  // Reference to THIS user's transactions collection in Firestore
  // Path: users/{userId}/transactions
  CollectionReference? get _transactionsRef {
    if (_userId == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('transactions');
  }

  // SAVE a transaction to Firestore
  Future<void> insertTransaction(tx.Transaction t) async {
    if (_transactionsRef == null) return;
    await _transactionsRef!.doc(t.id).set({
      'id': t.id,
      'title': t.title,
      'amount': t.amount,
      'category': t.category,
      'provider': t.provider,
      'isIncome': t.isIncome,
      'date': t.date.toIso8601String(),
    });
  }

  // GET all transactions from Firestore
  Future<List<tx.Transaction>> getAllTransactions() async {
    if (_transactionsRef == null) return [];
    final snapshot = await _transactionsRef!
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return tx.Transaction(
        id: data['id'],
        title: data['title'],
        amount: data['amount'],
        category: data['category'],
        provider: data['provider'],
        isIncome: data['isIncome'],
        date: DateTime.parse(data['date']),
      );
    }).toList();
  }

  // LISTEN to transactions in real time
  // This is the MAGIC of Firestore — data updates automatically
  // on ALL devices when someone adds a transaction!
  Stream<List<tx.Transaction>> transactionsStream() {
    if (_transactionsRef == null) return Stream.value([]);
    return _transactionsRef!
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return tx.Transaction(
                id: data['id'],
                title: data['title'],
                amount: data['amount'],
                category: data['category'],
                provider: data['provider'],
                isIncome: data['isIncome'],
                date: DateTime.parse(data['date']),
              );
            }).toList());
  }

  // DELETE a transaction from Firestore
  Future<void> deleteTransaction(String id) async {
    if (_transactionsRef == null) return;
    await _transactionsRef!.doc(id).delete();
  }

  // DELETE all transactions
  Future<void> deleteAllTransactions() async {
    if (_transactionsRef == null) return;
    final snapshot = await _transactionsRef!.get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // SYNC — copy all local transactions to Firestore
  // Useful when user logs in for the first time on a new device
  Future<void> syncLocalToFirestore(List<tx.Transaction> localTransactions) async {
    for (final transaction in localTransactions) {
      await insertTransaction(transaction);
    }
  }
}