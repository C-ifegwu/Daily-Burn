import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../providers/budget_provider.dart';

class MonthlyReviewScreen extends StatelessWidget {
  const MonthlyReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetProvider>(
      builder: (context, budget, _) {
        final spentPct = budget.monthlySpentPct;
        final stateColor = AppTheme.budgetColor(spentPct);
        final cat = budget.spendingByCategory;
        final total = cat.values.fold(0.0, (s, v) => s + v);
        final history = budget.dailySpendHistory(30);
        final maxSpend = history.reduce((a, b) => a > b ? a : b);
        final now = DateTime.now();
        final monthName = DateFormat('MMMM yyyy').format(now);

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            backgroundColor: AppTheme.background,
            title: const Text('Monthly Review'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero card ──────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [stateColor, stateColor.withAlpha(200)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: stateColor.withAlpha(60), blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(monthName, style: GoogleFonts.inter(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 10),
                      Text(
                        '\$${budget.totalSpentThisMonth.toStringAsFixed(2)}',
                        style: GoogleFonts.inter(fontSize: 42, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -2, height: 1.0),
                      ),
                      Text('spent of \$${budget.monthlyTotal.toStringAsFixed(2)}', style: GoogleFonts.inter(fontSize: 14, color: Colors.white70)),
                      const SizedBox(height: 18),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: spentPct,
                          backgroundColor: Colors.white.withAlpha(40),
                          valueColor: const AlwaysStoppedAnimation(Colors.white),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('${(spentPct * 100).toStringAsFixed(0)}% of monthly budget used', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Quick stats ────────────────────────────────────
                Row(
                  children: [
                    Expanded(child: _StatChip(emoji: '📅', label: 'Days Left', value: '${budget.daysLeft}')),
                    const SizedBox(width: 10),
                    Expanded(child: _StatChip(emoji: '🎯', label: 'Daily avg', value: '\$${budget.avgDailySpend.toStringAsFixed(0)}')),
                    const SizedBox(width: 10),
                    Expanded(child: _StatChip(emoji: '🔥', label: 'Streak', value: '${budget.currentStreak}d')),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Verdict banner ─────────────────────────────────
                _VerdictBanner(budget: budget),
                const SizedBox(height: 24),

                // ── 30-day spend chart ─────────────────────────────
                Text('30-Day Spending', style: AppTheme.titleMedium),
                const SizedBox(height: 12),
                Container(
                  height: 160,
                  padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: maxSpend == 0
                      ? Center(child: Text('No spending data', style: AppTheme.bodyMedium))
                      : LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              getDrawingHorizontalLine: (_) => FlLine(color: AppTheme.border, strokeWidth: 1),
                            ),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 7,
                                  getTitlesWidget: (v, _) => Text('${v.toInt() + 1}', style: AppTheme.labelSmall.copyWith(fontSize: 9)),
                                  reservedSize: 18,
                                ),
                              ),
                              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: history.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                                isCurved: true,
                                color: stateColor,
                                barWidth: 2.5,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: stateColor.withAlpha(30),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 24),

                // ── Category breakdown ─────────────────────────────
                if (cat.isNotEmpty) ...[
                  Text('Spending by Category', style: AppTheme.titleMedium),
                  const SizedBox(height: 12),
                  ...() {
                    final sorted = cat.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
                    return sorted.map((e) {
                      final catColor = AppTheme.categoryColors[e.key] ?? AppTheme.primary;
                      final emoji = AppTheme.categoryEmojis[e.key] ?? '💰';
                      final pct = total > 0 ? e.value / total : 0.0;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(emoji, style: const TextStyle(fontSize: 20)),
                                const SizedBox(width: 10),
                                Text(e.key, style: AppTheme.titleMedium),
                                const Spacer(),
                                Text('\$${e.value.toStringAsFixed(2)}', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: catColor)),
                                const SizedBox(width: 8),
                                Text('${(pct * 100).toStringAsFixed(0)}%', style: AppTheme.labelSmall),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: pct,
                                backgroundColor: catColor.withAlpha(20),
                                valueColor: AlwaysStoppedAnimation(catColor),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList();
                  }(),
                ],
                const SizedBox(height: 24),

                // ── Top tip ────────────────────────────────────────
                _TipCard(budget: budget),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  const _StatChip({required this.emoji, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, letterSpacing: -0.5)),
          Text(label, style: AppTheme.labelSmall.copyWith(fontSize: 10)),
        ],
      ),
    );
  }
}

class _VerdictBanner extends StatelessWidget {
  final BudgetProvider budget;
  const _VerdictBanner({required this.budget});

  @override
  Widget build(BuildContext context) {
    final pct = budget.monthlySpentPct;
    String emoji;
    String title;
    String subtitle;
    Color color;

    if (pct < 0.5) {
      emoji = '🌟';
      title = 'You\'re crushing it!';
      subtitle = 'Under 50% spent with ${budget.daysLeft} days to go. Amazing discipline!';
      color = AppTheme.safeGreen;
    } else if (pct < 0.8) {
      emoji = '⚡';
      title = 'On track, stay focused';
      subtitle = 'You\'ve used ${(pct * 100).toStringAsFixed(0)}% this month. Watch the daily burn.';
      color = AppTheme.warningYellow;
    } else {
      emoji = '🚨';
      title = 'Budget under pressure';
      subtitle = 'Only \$${budget.monthlyRemaining.toStringAsFixed(2)} left. Consider reducing daily spend.';
      color = AppTheme.dangerRed;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.titleMedium.copyWith(color: color)),
                const SizedBox(height: 3),
                Text(subtitle, style: AppTheme.bodyMedium.copyWith(fontSize: 12, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final BudgetProvider budget;
  const _TipCard({required this.budget});

  @override
  Widget build(BuildContext context) {
    final top = budget.topCategory;
    final topEmoji = AppTheme.categoryEmojis[top] ?? '💡';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(topEmoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Top Spend: $top', style: AppTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Your biggest category this month is $top. Try setting a daily cap for it next month.',
                  style: AppTheme.bodyMedium.copyWith(fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
