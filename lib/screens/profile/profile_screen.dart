// Profile screen — refactored for new light theme + monthly budget model.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../providers/budget_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final budget = context.watch<BudgetProvider>();
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(backgroundColor: AppTheme.background, title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.border)),
              child: Row(
                children: [
                  Container(
                    width: 60, height: 60,
                    decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppTheme.primaryLight, AppTheme.primaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight), shape: BoxShape.circle),
                    child: Center(child: Text('A', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white))),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Alex', style: AppTheme.titleMedium.copyWith(fontSize: 18)),
                      Text('Monthly Budget: \$${budget.monthlyTotal.toStringAsFixed(0)}', style: AppTheme.bodyMedium.copyWith(fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _Row('Start Date', DateFormat('MMM d, y').format(budget.startDate)),
            _Row('Daily Limit', '\$${budget.adjustedDailyLimit.toStringAsFixed(2)}/day'),
            _Row('Days Left', '${budget.daysLeft} days'),
            _Row('Monthly Remaining', '\$${budget.monthlyRemaining.toStringAsFixed(2)}'),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/input-budget'),
                child: const Text('Edit Budget'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.border)),
      child: Row(
        children: [
          Text(label, style: AppTheme.bodyMedium),
          const Spacer(),
          Text(value, style: AppTheme.titleMedium.copyWith(fontSize: 14)),
        ],
      ),
    );
  }
}
