import 'dart:async';

import 'package:flutter/foundation.dart';

import '../features/budget/data/models/transaction_model.dart';
import '../features/budget/data/repositories/budget_repository.dart';

class Transaction {
  final String id;
  final String category;
  final double amount;
  final String note;
  final DateTime dateTime;

  Transaction({
    required this.id,
    required this.category,
    required this.amount,
    required this.note,
    required this.dateTime,
  });
}

class BudgetProvider extends ChangeNotifier {
  final BudgetRepository _repository;
  StreamSubscription<List<TransactionModel>>? _transactionsSubscription;

  BudgetProvider({BudgetRepository? repository})
      : _repository = repository ?? BudgetRepository() {
    _transactionsSubscription = _repository.getTransactions().listen((items) {
      _transactions
        ..clear()
        ..addAll(items.map(_fromModel));
      notifyListeners();
    });
  }

  // ── Monthly Budget Settings ───────────────────────────────────
  double _monthlyTotal = 1250.0;
  DateTime _startDate = DateTime.now();
  bool _isSetup = false;

  // ── Transactions ──────────────────────────────────────────────
  final List<Transaction> _transactions = [];

  // ── Getters ───────────────────────────────────────────────────
  double get monthlyTotal => _monthlyTotal;
  DateTime get startDate => _startDate;
  bool get isSetup => _isSetup;
  List<Transaction> get transactions => List.unmodifiable(_transactions);

  // Days from start to end of month
  int get totalDaysInPeriod {
    final end = DateTime(_startDate.year, _startDate.month + 1, _startDate.day);
    return end.difference(_startDate).inDays.clamp(1, 366);
  }

  // Days left in period
  int get daysLeft {
    final now = DateTime.now();
    final end = DateTime(_startDate.year, _startDate.month + 1, _startDate.day);
    return end.difference(now).inDays.clamp(0, 366);
  }

  // Daily burn limit
  double get dailyLimit {
    if (totalDaysInPeriod == 0) return 0;
    return _monthlyTotal / totalDaysInPeriod;
  }

  // Adjusted daily limit based on remaining balance
  double get adjustedDailyLimit {
    if (daysLeft == 0) return 0;
    return monthlyRemaining / daysLeft;
  }

  // Total spent this month
  double get totalSpentThisMonth {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    return _transactions
        .where((t) => t.dateTime.isAfter(monthStart))
        .fold(0.0, (s, t) => s + t.amount);
  }

  // Monthly remaining
  double get monthlyRemaining =>
      (_monthlyTotal - totalSpentThisMonth).clamp(0, double.infinity);

  // Today's spending
  double get todaySpent {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _transactions
        .where((t) => t.dateTime.isAfter(today))
        .fold(0.0, (s, t) => s + t.amount);
  }

  // Today's remaining (safe to spend today)
  double get todayRemaining =>
      (adjustedDailyLimit - todaySpent).clamp(0, double.infinity);

  // Percentage of today's limit spent
  double get todaySpentPct => adjustedDailyLimit > 0
      ? (todaySpent / adjustedDailyLimit).clamp(0.0, 1.0)
      : 0.0;

  // Percentage of monthly limit spent
  double get monthlySpentPct => _monthlyTotal > 0
      ? (totalSpentThisMonth / _monthlyTotal).clamp(0.0, 1.0)
      : 0.0;

  // Is overspent today
  bool get isOverspentToday => todaySpent > adjustedDailyLimit;

  // Today's transactions
  List<Transaction> get todayTransactions {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _transactions.where((t) => t.dateTime.isAfter(today)).toList();
  }

  // Spending by category (this month)
  Map<String, double> get spendingByCategory {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final result = <String, double>{};
    for (final t
        in _transactions.where((t) => t.dateTime.isAfter(monthStart))) {
      result[t.category] = (result[t.category] ?? 0) + t.amount;
    }
    return result;
  }

  // ── Actions ───────────────────────────────────────────────────
  void setupBudget(
      {required double monthlyTotal, required DateTime startDate}) {
    _monthlyTotal = monthlyTotal;
    _startDate = startDate;
    _isSetup = true;
    notifyListeners();
  }

  Future<void> addTransaction(Transaction t) async {
    final tx = t.id.isEmpty
        ? Transaction(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            category: t.category,
            amount: t.amount,
            note: t.note,
            dateTime: t.dateTime,
          )
        : t;

    _transactions.insert(0, tx);
    notifyListeners();
    await _repository.addTransaction(_toModel(tx));
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
    await _repository.deleteTransaction(id);
  }

  Future<void> editTransaction(String id,
      {double? amount, String? note, String? category}) async {
    final idx = _transactions.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    final old = _transactions[idx];
    final updated = Transaction(
      id: old.id,
      category: category ?? old.category,
      amount: amount ?? old.amount,
      note: note ?? old.note,
      dateTime: old.dateTime,
    );
    _transactions[idx] = updated;
    notifyListeners();
    await _repository.updateTransaction(_toModel(updated));
  }

  void setMonthlyTotal(double total) {
    _monthlyTotal = total;
    notifyListeners();
  }

  // ── Analytics helpers ─────────────────────────────────────────
  /// Spend per day for the last [days] days, oldest first.
  List<double> dailySpendHistory(int days) {
    final now = DateTime.now();
    return List.generate(days, (i) {
      final day = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: days - 1 - i));
      final next = day.add(const Duration(days: 1));
      return _transactions
          .where((t) => t.dateTime.isAfter(day) && t.dateTime.isBefore(next))
          .fold(0.0, (s, t) => s + t.amount);
    });
  }

  /// Days in a row where daily spend <= adjustedDailyLimit.
  int get currentStreak {
    int streak = 0;
    final now = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final day =
          DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final next = day.add(const Duration(days: 1));
      final daySpend = _transactions
          .where((t) => t.dateTime.isAfter(day) && t.dateTime.isBefore(next))
          .fold(0.0, (s, t) => s + t.amount);
      if (daySpend <= dailyLimit && daySpend >= 0) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  /// Projected days until budget runs out at current spend rate.
  int get projectedDaysLeft {
    final history = dailySpendHistory(7);
    final nonZero = history.where((d) => d > 0);
    if (nonZero.isEmpty) return daysLeft;
    final avgDaily = nonZero.reduce((a, b) => a + b) / nonZero.length;
    if (avgDaily <= 0) return daysLeft;
    return (monthlyRemaining / avgDaily).floor();
  }

  /// Average daily spend over past 7 days.
  double get avgDailySpend {
    final history = dailySpendHistory(7);
    final nonZero = history.where((d) => d > 0).toList();
    if (nonZero.isEmpty) return 0;
    return nonZero.reduce((a, b) => a + b) / nonZero.length;
  }

  /// Top spending category this month.
  String get topCategory {
    final cat = spendingByCategory;
    if (cat.isEmpty) return 'None';
    return cat.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Most recent transaction.
  Transaction? get latestTransaction =>
      _transactions.isEmpty ? null : _transactions.first;

  Transaction _fromModel(TransactionModel model) {
    return Transaction(
      id: model.id,
      category: model.category,
      amount: model.amount,
      note: model.note,
      dateTime: model.date,
    );
  }

  TransactionModel _toModel(Transaction transaction) {
    return TransactionModel(
      id: transaction.id,
      title: transaction.note,
      amount: transaction.amount,
      date: transaction.dateTime,
      category: transaction.category,
      note: transaction.note,
    );
  }

  @override
  void dispose() {
    _transactionsSubscription?.cancel();
    super.dispose();
  }
}
