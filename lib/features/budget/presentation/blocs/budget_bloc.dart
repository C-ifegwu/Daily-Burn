import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/models/transaction_model.dart';
import '../../data/repositories/budget_repository.dart';

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

abstract class BudgetEvent {
  const BudgetEvent();
}

class LoadTransactionsEvent extends BudgetEvent {
  const LoadTransactionsEvent();
}

class AddExpenseEvent extends BudgetEvent {
  final TransactionModel transaction;

  const AddExpenseEvent(this.transaction);
}

class UpdateExpenseEvent extends BudgetEvent {
  final TransactionModel transaction;

  const UpdateExpenseEvent(this.transaction);
}

class DeleteExpenseEvent extends BudgetEvent {
  final String transactionId;

  const DeleteExpenseEvent(this.transactionId);
}

abstract class BudgetState {
  const BudgetState();
}

class BudgetInitial extends BudgetState {
  const BudgetInitial();
}

class BudgetLoading extends BudgetState {
  const BudgetLoading();
}

class BudgetLoaded extends BudgetState {
  final List<TransactionModel> transactions;

  const BudgetLoaded(this.transactions);
}

class BudgetSuccess extends BudgetState {
  const BudgetSuccess();
}

class BudgetFailure extends BudgetState {
  final String message;

  const BudgetFailure(this.message);
}

class BudgetBloc extends ChangeNotifier {
  final BudgetRepository _repository;

  final StreamController<BudgetEvent> _eventController =
      StreamController<BudgetEvent>();
  final StreamController<BudgetState> _stateController =
      StreamController<BudgetState>.broadcast();

  StreamSubscription<List<TransactionModel>>? _transactionsSubscription;
  double _monthlyTotal = 1250.0;
  DateTime _startDate = DateTime.now();
  bool _isSetup = false;
  final List<Transaction> _transactions = [];
  BudgetState _state = const BudgetInitial();

  BudgetBloc({BudgetRepository? repository})
      : _repository = repository ?? BudgetRepository() {
    _eventController.stream.listen(_handleEvent);
    add(const LoadTransactionsEvent());
  }

  Stream<BudgetState> get stream => _stateController.stream;

  BudgetState get state => _state;
  double get monthlyTotal => _monthlyTotal;
  DateTime get startDate => _startDate;
  bool get isSetup => _isSetup;
  List<Transaction> get transactions => List.unmodifiable(_transactions);

  int get totalDaysInPeriod {
    final end = DateTime(_startDate.year, _startDate.month + 1, _startDate.day);
    return end.difference(_startDate).inDays.clamp(1, 366);
  }

  int get daysLeft {
    final now = DateTime.now();
    final end = DateTime(_startDate.year, _startDate.month + 1, _startDate.day);
    return end.difference(now).inDays.clamp(0, 366);
  }

  double get dailyLimit {
    if (totalDaysInPeriod == 0) return 0;
    return _monthlyTotal / totalDaysInPeriod;
  }

  double get adjustedDailyLimit {
    if (daysLeft == 0) return 0;
    return monthlyRemaining / daysLeft;
  }

  double get totalSpentThisMonth {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    return _transactions
        .where((t) => t.dateTime.isAfter(monthStart))
        .fold(0.0, (s, t) => s + t.amount);
  }

  double get monthlyRemaining =>
      (_monthlyTotal - totalSpentThisMonth).clamp(0, double.infinity);

  double get todaySpent {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _transactions
        .where((t) => t.dateTime.isAfter(today))
        .fold(0.0, (s, t) => s + t.amount);
  }

  double get todayRemaining =>
      (adjustedDailyLimit - todaySpent).clamp(0, double.infinity);

  double get todaySpentPct => adjustedDailyLimit > 0
      ? (todaySpent / adjustedDailyLimit).clamp(0.0, 1.0)
      : 0.0;

  double get monthlySpentPct => _monthlyTotal > 0
      ? (totalSpentThisMonth / _monthlyTotal).clamp(0.0, 1.0)
      : 0.0;

  bool get isOverspentToday => todaySpent > adjustedDailyLimit;

  List<Transaction> get todayTransactions {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _transactions.where((t) => t.dateTime.isAfter(today)).toList();
  }

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

  void add(BudgetEvent event) {
    if (!_eventController.isClosed) {
      _eventController.add(event);
    }
  }

  Future<void> _handleEvent(BudgetEvent event) async {
    if (event is LoadTransactionsEvent) {
      await _loadTransactions();
      return;
    }
    if (event is AddExpenseEvent) {
      await _addExpense(event);
      return;
    }
    if (event is UpdateExpenseEvent) {
      await _updateExpense(event);
      return;
    }
    if (event is DeleteExpenseEvent) {
      await _deleteExpense(event);
    }
  }

  Future<void> _loadTransactions() async {
    _emit(const BudgetLoading());

    await _transactionsSubscription?.cancel();
    _transactionsSubscription = _repository.getTransactions().listen(
          (transactions) {
            _transactions
              ..clear()
              ..addAll(transactions.map(_fromModel));
            _emit(BudgetLoaded(transactions));
            notifyListeners();
          },
          onError: (Object error) => _emit(BudgetFailure(error.toString())),
        );
  }

  Future<void> _addExpense(AddExpenseEvent event) async {
    _emit(const BudgetLoading());
    try {
      await _repository.addTransaction(event.transaction);
      _emit(const BudgetSuccess());
    } catch (error) {
      _emit(BudgetFailure(error.toString()));
    }
  }

  Future<void> _updateExpense(UpdateExpenseEvent event) async {
    _emit(const BudgetLoading());
    try {
      await _repository.updateTransaction(event.transaction);
      _emit(const BudgetSuccess());
    } catch (error) {
      _emit(BudgetFailure(error.toString()));
    }
  }

  Future<void> _deleteExpense(DeleteExpenseEvent event) async {
    _emit(const BudgetLoading());
    try {
      await _repository.deleteTransaction(event.transactionId);
      _emit(const BudgetSuccess());
    } catch (error) {
      _emit(BudgetFailure(error.toString()));
    }
  }

  void setupBudget({required double monthlyTotal, required DateTime startDate}) {
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

    add(AddExpenseEvent(_toModel(tx)));
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();

    add(DeleteExpenseEvent(id));
  }

  Future<void> editTransaction(
    String id, {
    double? amount,
    String? note,
    String? category,
  }) async {
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

    add(UpdateExpenseEvent(_toModel(updated)));
  }

  void setMonthlyTotal(double total) {
    _monthlyTotal = total;
    notifyListeners();
  }

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

  int get currentStreak {
    int streak = 0;
    final now = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final day = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: i));
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

  int get projectedDaysLeft {
    final history = dailySpendHistory(7);
    final nonZero = history.where((d) => d > 0);
    if (nonZero.isEmpty) return daysLeft;
    final avgDaily = nonZero.reduce((a, b) => a + b) / nonZero.length;
    if (avgDaily <= 0) return daysLeft;
    return (monthlyRemaining / avgDaily).floor();
  }

  double get avgDailySpend {
    final history = dailySpendHistory(7);
    final nonZero = history.where((d) => d > 0).toList();
    if (nonZero.isEmpty) return 0;
    return nonZero.reduce((a, b) => a + b) / nonZero.length;
  }

  String get topCategory {
    final cat = spendingByCategory;
    if (cat.isEmpty) return 'None';
    return cat.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

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

  void _emit(BudgetState state) {
    _state = state;
    if (!_stateController.isClosed) {
      _stateController.add(state);
    }
  }

  Future<void> close() async {
    await _transactionsSubscription?.cancel();
    await _eventController.close();
    await _stateController.close();
  }

  @override
  void dispose() {
    close();
    super.dispose();
  }
}
