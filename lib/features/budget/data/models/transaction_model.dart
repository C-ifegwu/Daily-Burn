import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final String note;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.note,
  });

  factory TransactionModel.fromMap(
      Map<String, dynamic> map, String documentId) {
    final dynamic rawDate = map['date'];

    DateTime parsedDate;
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is DateTime) {
      parsedDate = rawDate;
    } else {
      parsedDate = DateTime.now();
    }

    return TransactionModel(
      id: documentId,
      title: (map['title'] ?? map['note'] ?? '') as String,
      amount: ((map['amount'] ?? 0) as num).toDouble(),
      date: parsedDate,
      category: (map['category'] ?? 'Misc') as String,
      note: (map['note'] ?? map['title'] ?? '') as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'category': category,
      'note': note,
    };
  }
}
