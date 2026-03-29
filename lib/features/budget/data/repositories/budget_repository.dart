import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/transaction_model.dart';

class BudgetRepository {
  final FirebaseFirestore _db;

  BudgetRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  Future<void> addTransaction(TransactionModel transaction) async {
    await _db
        .collection('transactions')
        .doc(transaction.id)
        .set(transaction.toMap());
  }

  Stream<List<TransactionModel>> getTransactions() {
    return _db
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await _db
        .collection('transactions')
        .doc(transaction.id)
        .update(transaction.toMap());
  }

  Future<void> deleteTransaction(String id) async {
    await _db.collection('transactions').doc(id).delete();
  }
}
