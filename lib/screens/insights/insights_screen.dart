import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_theme.dart';
import '../../providers/budget_provider.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetProvider>(
      builder: (context, budget, _) {
        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            backgroundColor: AppTheme.background,
            automaticallyImplyLeading: false,
            title: const Text('Insights'),
            bottom: TabBar(
              controller: _tabCtrl,
              labelColor: AppTheme.primary,
              unselectedLabelColor: AppTheme.textSecondary,
              indicatorColor: AppTheme.primary,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
              tabs: const [Tab(text: 'Overview'), Tab(text: 'Categories')],
            ),
          ),
          body: TabBarView(
            controller: _tabCtrl,
            children: [
              _OverviewTab(budget: budget),
              _CategoryTab(budget: budget),
            ],
          ),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// OVERVIEW TAB
// ──────────────────────────────────────────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  final BudgetProvider budget;
  const _OverviewTab({required this.budget});

  @override
  Widget build(BuildContext context) {
    final spentPct = budget.monthlySpentPct;
    final stateColor = AppTheme.budgetColor(spentPct);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Summary cards ────────────────────────────────────────
          Row(
            children: [
              Expanded(child: _SummaryCard(label: 'Spent', value: '\$${budget.totalSpentThisMonth.toStringAsFixed(2)}', color: AppTheme.dangerRed, icon: Icons.arrow_upward_rounded)),
              const SizedBox(width: 12),
              Expanded(child: _SummaryCard(label: 'Remaining', value: '\$${budget.monthlyRemaining.toStringAsFixed(2)}', color: AppTheme.safeGreen, icon: Icons.savings_rounded)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _SummaryCard(label: 'Daily Burn', value: '\$${budget.adjustedDailyLimit.toStringAsFixed(2)}', color: AppTheme.primary, icon: Icons.local_fire_department_rounded)),
              const SizedBox(width: 12),
              Expanded(child: _SummaryCard(label: 'Days Left', value: '${budget.daysLeft} days', color: AppTheme.warningYellow, icon: Icons.calendar_today_rounded)),
            ],
          ),
          const SizedBox(height: 28),

          // ── Monthly progress ─────────────────────────────────────
          Text('Monthly Progress', style: AppTheme.titleMedium),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('\$${budget.totalSpentThisMonth.toStringAsFixed(2)}', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: stateColor, letterSpacing: -1.5)),
                        Text('of \$${budget.monthlyTotal.toStringAsFixed(2)}', style: AppTheme.bodyMedium.copyWith(fontSize: 13)),
                      ],
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: spentPct,
                            strokeWidth: 8,
                            backgroundColor: stateColor.withAlpha(30),
                            valueColor: AlwaysStoppedAnimation(stateColor),
                            strokeCap: StrokeCap.round,
                          ),
                          Text(
                            '${(spentPct * 100).toStringAsFixed(0)}%',
                            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: stateColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: spentPct,
                    backgroundColor: AppTheme.border,
                    valueColor: AlwaysStoppedAnimation(stateColor),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('\$0', style: AppTheme.labelSmall),
                    Text('\$${budget.monthlyTotal.toStringAsFixed(0)}', style: AppTheme.labelSmall),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ── Spending bar chart (last 7 days) ─────────────────────
          Text('Daily Spending — Last 7 Days', style: AppTheme.titleMedium),
          const SizedBox(height: 16),
          Container(
            height: 200,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.border),
            ),
            child: _SpendingBarChart(budget: budget),
          ),
          const SizedBox(height: 28),

          // ── Daily limit vs. actual ────────────────────────────────
          Text('Limit vs. Actual', style: AppTheme.titleMedium),
          const SizedBox(height: 8),
          _LimitRow(label: 'Original daily limit', value: budget.dailyLimit),
          const SizedBox(height: 8),
          _LimitRow(label: 'Adjusted daily limit', value: budget.adjustedDailyLimit, isAdjusted: true),
          const SizedBox(height: 8),
          _LimitRow(label: 'Spent today', value: budget.todaySpent, isSpend: true),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _SummaryCard({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const Spacer(),
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: color, letterSpacing: -0.8)),
          const SizedBox(height: 2),
          Text(label, style: AppTheme.labelSmall.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}

class _LimitRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isAdjusted;
  final bool isSpend;
  const _LimitRow({required this.label, required this.value, this.isAdjusted = false, this.isSpend = false});

  @override
  Widget build(BuildContext context) {
    final color = isSpend ? AppTheme.dangerRed : isAdjusted ? AppTheme.warningYellow : AppTheme.safeGreen;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Text(label, style: AppTheme.bodyMedium),
          const Spacer(),
          Text('\$${value.toStringAsFixed(2)}', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

class _SpendingBarChart extends StatelessWidget {
  final BudgetProvider budget;
  const _SpendingBarChart({required this.budget});

  List<double> get _dailyTotals {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i));
      final nextDay = day.add(const Duration(days: 1));
      return budget.transactions
          .where((t) => t.dateTime.isAfter(day) && t.dateTime.isBefore(nextDay))
          .fold(0.0, (s, t) => s + t.amount);
    });
  }

  @override
  Widget build(BuildContext context) {
    final totals = _dailyTotals;
    final maxY = (totals.reduce((a, b) => a > b ? a : b) * 1.3).clamp(10.0, double.infinity);
    final limit = budget.adjustedDailyLimit;
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final dayIdx = (now.weekday - 1 - (6 - value.toInt())) % 7;
                final label = days[dayIdx.clamp(0, 6)];
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(label, style: AppTheme.labelSmall.copyWith(fontSize: 10)),
                );
              },
              reservedSize: 24,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text(
                '\$${value.toStringAsFixed(0)}',
                style: AppTheme.labelSmall.copyWith(fontSize: 9),
              ),
              reservedSize: 36,
              interval: maxY / 3,
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(color: AppTheme.border, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: limit,
              color: AppTheme.dangerRed.withAlpha(120),
              strokeWidth: 1.5,
              dashArray: [6, 4],
              label: HorizontalLineLabel(
                show: true,
                labelResolver: (_) => 'limit',
                style: GoogleFonts.inter(fontSize: 9, color: AppTheme.dangerRed, fontWeight: FontWeight.w600),
                alignment: Alignment.topRight,
              ),
            ),
          ],
        ),
        barGroups: List.generate(7, (i) {
          final spent = totals[i];
          final isOver = spent > limit;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: spent == 0 ? 0.5 : spent,
                color: isOver ? AppTheme.dangerRed : spent > limit * 0.7 ? AppTheme.warningYellow : AppTheme.primary,
                width: 16,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// CATEGORY TAB
// ──────────────────────────────────────────────────────────────────────────────
class _CategoryTab extends StatelessWidget {
  final BudgetProvider budget;
  const _CategoryTab({required this.budget});

  @override
  Widget build(BuildContext context) {
    final cat = budget.spendingByCategory;
    final total = cat.values.fold(0.0, (s, v) => s + v);

    if (cat.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📊', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text('No data yet', style: AppTheme.headlineMedium),
            const SizedBox(height: 6),
            Text('Add some expenses to see your breakdown.', style: AppTheme.bodyMedium),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Pie chart ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              children: [
                Text('This Month\'s Breakdown', style: AppTheme.titleMedium),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 52,
                      sections: cat.entries.map((e) {
                        final color = AppTheme.categoryColors[e.key] ?? AppTheme.primary;
                        final pct = total > 0 ? e.value / total : 0.0;
                        return PieChartSectionData(
                          value: e.value,
                          color: color,
                          title: '${(pct * 100).toStringAsFixed(0)}%',
                          radius: 60,
                          titleStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Legend
                Wrap(
                  spacing: 16,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: cat.entries.map((e) {
                    final color = AppTheme.categoryColors[e.key] ?? AppTheme.primary;
                    final emoji = AppTheme.categoryEmojis[e.key] ?? '💰';
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text('$emoji ${e.key}', style: AppTheme.bodyMedium.copyWith(fontSize: 12)),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Category breakdown rows ───────────────────────────────
          Text('Category Details', style: AppTheme.titleMedium),
          const SizedBox(height: 12),
          ...cat.entries.map((e) {
            final color = AppTheme.categoryColors[e.key] ?? AppTheme.primary;
            final emoji = AppTheme.categoryEmojis[e.key] ?? '💰';
            final pct = total > 0 ? e.value / total : 0.0;
            final txCount = budget.transactions.where((t) => t.category == e.key).length;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(12)),
                        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.key, style: AppTheme.titleMedium),
                            Text('$txCount transaction${txCount == 1 ? '' : 's'}', style: AppTheme.bodyMedium.copyWith(fontSize: 12)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('\$${e.value.toStringAsFixed(2)}', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: color, letterSpacing: -0.5)),
                          Text('${(pct * 100).toStringAsFixed(0)}% of total', style: AppTheme.labelSmall.copyWith(fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: color.withAlpha(20),
                      valueColor: AlwaysStoppedAnimation(color),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
