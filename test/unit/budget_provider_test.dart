import 'package:flutter_test/flutter_test.dart';
import 'package:daily_burn/providers/budget_provider.dart';

void main() {
  group('BudgetProvider - Initial State', () {
    
    test('Initial monthly total should be 1250.0', () {
      final provider = BudgetProvider();
      expect(provider.monthlyTotal, 1250.0);
    });
    
    test('isSetup should be false initially', () {
      final provider = BudgetProvider();
      expect(provider.isSetup, false);
    });
    
    test('Should have 8 sample transactions initially', () {
      final provider = BudgetProvider();
      expect(provider.transactions.length, 8);
    });
  });
  
  group('BudgetProvider - Transaction CRUD', () {
    
    test('Add transaction should increase transaction count', () {
      final provider = BudgetProvider();
      provider.setupBudget(monthlyTotal: 1000.0, startDate: DateTime.now());
      
      final initialCount = provider.transactions.length;
      
      provider.addTransaction(Transaction(
        id: 'test-99',
        category: 'Food',
        amount: 25.0,
        note: 'Test expense',
        dateTime: DateTime.now(),
      ));
      
      expect(provider.transactions.length, initialCount + 1);
    });
    
    test('Delete transaction should decrease transaction count', () {
      final provider = BudgetProvider();
      provider.setupBudget(monthlyTotal: 1000.0, startDate: DateTime.now());
      
      final initialCount = provider.transactions.length;
      final idToDelete = provider.transactions.first.id;
      
      provider.deleteTransaction(idToDelete);
      
      expect(provider.transactions.length, initialCount - 1);
    });
  });
  
  group('BudgetProvider - Calculations', () {
    
    test('dailyLimit calculates correctly', () {
      final provider = BudgetProvider();
      provider.setupBudget(monthlyTotal: 1000.0, startDate: DateTime(2024, 4, 1));
      
      final limit = provider.dailyLimit;
      
      // For 30-day month: 1000 / 30 = 33.33
      expect(limit, closeTo(33.33, 0.01));
    });
    
    test('monthlyRemaining should be non-negative', () {
      final provider = BudgetProvider();
      provider.setupBudget(monthlyTotal: 1000.0, startDate: DateTime.now());
      
      final remaining = provider.monthlyRemaining;
      
      expect(remaining >= 0, true);
    });
  });
  
  group('BudgetProvider - Analytics', () {
    
    test('topCategory returns a string', () {
      final provider = BudgetProvider();
      provider.setupBudget(monthlyTotal: 1000.0, startDate: DateTime.now());
      
      final top = provider.topCategory;
      
      expect(top, isA<String>());
      expect(top.isNotEmpty, true);
    });
    
    test('spendingByCategory returns a map', () {
      final provider = BudgetProvider();
      provider.setupBudget(monthlyTotal: 1000.0, startDate: DateTime.now());
      
      final categories = provider.spendingByCategory;
      
      expect(categories, isA<Map<String, double>>());
    });
  });
}