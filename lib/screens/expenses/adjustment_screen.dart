import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/budget_provider.dart';

class AdjustmentScreen extends StatelessWidget {
  const AdjustmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final budget = context.watch<BudgetProvider>();
    final oldLimit = budget.dailyLimit;
    final newLimit = budget.adjustedDailyLimit;
    final overspend = budget.todaySpent - oldLimit;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Spacer(),
              // ── Flag icon ────────────────────────────────────────
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppTheme.warningYellow.withAlpha(30),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.warningYellow.withAlpha(80), width: 2),
                ),
                child: const Center(child: Text('⚠️', style: TextStyle(fontSize: 40))),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.warningYellow.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Adjustment Flagged',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.warningYellow),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'New Daily Limit:\n\$${newLimit.toStringAsFixed(2)}',
                style: AppTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'We noticed you went slightly over your monthly fitness and nutrition goal track, so we\'ve adjusted today\'s value to keep you on track.',
                style: AppTheme.bodyMedium.copyWith(height: 1.6),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              // ── Breakdown card ───────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('How we calculated this', style: AppTheme.titleMedium),
                    const SizedBox(height: 16),
                    _CalcRow(
                      label: 'Yesterday\'s Overspend',
                      value: '\$${overspend > 0 ? overspend.toStringAsFixed(2) : '0.00'}',
                      color: AppTheme.dangerRed,
                    ),
                    const SizedBox(height: 8),
                    _CalcRow(label: 'Monthly Remaining', value: '\$${budget.monthlyRemaining.toStringAsFixed(2)}', color: AppTheme.textPrimary),
                    const SizedBox(height: 8),
                    _CalcRow(label: 'Days Left in Month', value: '${budget.daysLeft} days', color: AppTheme.textPrimary),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('New Daily Limit', style: AppTheme.titleMedium),
                        Text(
                          '\$${newLimit.toStringAsFixed(2)}/day',
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: -0.5),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false),
                  child: const Text('Go to Dashboard', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    side: const BorderSide(color: AppTheme.border),
                  ),
                  child: Text('Input My Budget', style: AppTheme.titleMedium.copyWith(fontSize: 15, color: AppTheme.textPrimary)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalcRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _CalcRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTheme.bodyMedium),
        Text(value, style: AppTheme.titleMedium.copyWith(color: color, fontSize: 14)),
      ],
    );
  }
}
