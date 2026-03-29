import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/budget_provider.dart';
import '../../widgets/daily_burn_button.dart';

class SpendingBlockedScreen extends StatelessWidget {
  const SpendingBlockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final budget = context.read<BudgetProvider>();
    final daysLeft = budget.daysLeft;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F6),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    48,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.dangerRed.withAlpha(20),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppTheme.dangerRed.withAlpha(60), width: 2),
                    ),
                    child: const Icon(Icons.block_rounded,
                        color: AppTheme.dangerRed, size: 56),
                  ),
                  const SizedBox(height: 32),
                  Text('Budget Exhausted',
                      style: AppTheme.headlineMedium,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 14),
                  Text(
                    'You\'ve hit your monthly limit of \$${budget.monthlyTotal.toStringAsFixed(0)}.\nYour budget resets in $daysLeft day${daysLeft == 1 ? '' : 's'}.',
                    style:
                        AppTheme.bodyMedium.copyWith(fontSize: 15, height: 1.7),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.dangerRed.withAlpha(12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppTheme.dangerRed.withAlpha(40), width: 1),
                    ),
                    child: Column(
                      children: [
                        Text('You spent', style: AppTheme.bodyMedium),
                        const SizedBox(height: 8),
                        Text(
                            '\$${budget.totalSpentThisMonth.toStringAsFixed(2)}',
                            style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.dangerRed,
                                letterSpacing: -2,
                                height: 1.0)),
                        Text(
                            'of your \$${budget.monthlyTotal.toStringAsFixed(0)} monthly budget',
                            style: AppTheme.bodyMedium.copyWith(fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  DailyBurnButton(
                      label: 'Go Home',
                      onTap: () => Navigator.pushNamedAndRemoveUntil(
                          context, '/home', (_) => false)),
                  const SizedBox(height: 12),
                  DailyBurnButton(
                      label: 'Adjust Budget',
                      onTap: () =>
                          Navigator.pushNamed(context, '/input-budget'),
                      isPrimary: false),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
