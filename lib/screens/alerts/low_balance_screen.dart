import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../theme/app_theme.dart';
import '../../providers/budget_provider.dart';
import '../../widgets/daily_burn_button.dart';

class LowBalanceScreen extends StatelessWidget {
  const LowBalanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetProvider>(
      builder: (context, budget, _) {
        final pct = budget.todaySpentPct;
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
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close_rounded,
                                color: AppTheme.textSecondary),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.dangerRed.withAlpha(30),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: AppTheme.dangerRed.withAlpha(60),
                                  width: 1),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.warning_rounded,
                                    color: AppTheme.dangerRed, size: 14),
                                const SizedBox(width: 6),
                                Text('LOW BALANCE',
                                    style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.dangerRed,
                                        letterSpacing: 1.2)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      CircularPercentIndicator(
                        radius: 120,
                        lineWidth: 14,
                        percent: pct.clamp(0, 1),
                        backgroundColor: AppTheme.border,
                        progressColor: pct > 0.9
                            ? AppTheme.dangerRed
                            : AppTheme.warningYellow,
                        animation: true,
                        animationDuration: 1000,
                        center: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${(pct * 100).toStringAsFixed(0)}%',
                              style: GoogleFonts.inter(
                                  fontSize: 44,
                                  fontWeight: FontWeight.w800,
                                  color: pct > 0.9
                                      ? AppTheme.dangerRed
                                      : AppTheme.warningYellow,
                                  letterSpacing: -2),
                            ),
                            Text('spent', style: AppTheme.bodyMedium),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text('⚠️ Panic Mode',
                          style: AppTheme.headlineLarge,
                          textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      Text(
                        'You\'ve used ${(pct * 100).toStringAsFixed(0)}% of today\'s budget. Only \$${budget.todayRemaining.toStringAsFixed(2)} left.',
                        style: AppTheme.bodyMedium
                            .copyWith(fontSize: 15, height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(
                              child: _AlertStat(
                                  label: 'Spent',
                                  value:
                                      '\$${budget.totalSpentThisMonth.toStringAsFixed(2)}',
                                  color: AppTheme.dangerRed)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _AlertStat(
                                  label: 'Remaining',
                                  value:
                                      '\$${budget.monthlyRemaining.toStringAsFixed(2)}',
                                  color: AppTheme.warningYellow)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      DailyBurnButton(
                          label: 'I\'ll Be Careful',
                          onTap: () => Navigator.pop(context)),
                      const SizedBox(height: 12),
                      DailyBurnButton(
                          label: 'Adjust My Budget',
                          onTap: () => Navigator.pop(context),
                          isPrimary: false),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AlertStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _AlertStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(40), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTheme.bodyMedium.copyWith(fontSize: 12)),
          const SizedBox(height: 4),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: -0.8)),
        ],
      ),
    );
  }
}
