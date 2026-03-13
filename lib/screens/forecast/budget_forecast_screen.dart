import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_theme.dart';
import '../../providers/budget_provider.dart';

class BudgetForecastScreen extends StatelessWidget {
  const BudgetForecastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetProvider>(
      builder: (context, budget, _) {
        final avg = budget.avgDailySpend;
        final projected = budget.projectedDaysLeft;
        final daysLeft = budget.daysLeft;
        final remaining = budget.monthlyRemaining;
        final limit = budget.adjustedDailyLimit;
        final isOnTrack = projected >= daysLeft;
        final statusColor = isOnTrack ? AppTheme.safeGreen : AppTheme.dangerRed;

        // Build 30-day forecast: actual (past) + projected (future)
        final history = budget.dailySpendHistory(7);
        final forecastSpots = <FlSpot>[];
        // past 7 days actual
        for (int i = 0; i < 7; i++) {
          forecastSpots.add(FlSpot(i.toDouble(), history[i]));
        }
        // next 7 days projected at avg rate
        for (int i = 1; i <= 7; i++) {
          forecastSpots.add(FlSpot((7 + i).toDouble(), avg));
        }

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            backgroundColor: AppTheme.background,
            title: const Text('Budget Forecast'),
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
                // ── Status hero ────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(15),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: statusColor.withAlpha(60), width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Text(isOnTrack ? '✅' : '⚠️', style: const TextStyle(fontSize: 44)),
                      const SizedBox(height: 12),
                      Text(
                        isOnTrack ? 'On Track!' : 'Overspending Risk',
                        style: AppTheme.headlineMedium.copyWith(color: statusColor),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isOnTrack
                            ? 'At your current rate, your budget will last ${projected} days — covering the ${daysLeft} remaining.'
                            : 'At your current rate, your budget will run out in ~$projected days. You have $daysLeft days to go.',
                        style: AppTheme.bodyMedium.copyWith(height: 1.6),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Key numbers ────────────────────────────────────
                Row(
                  children: [
                    Expanded(child: _ForecastStat(label: 'Remaining', value: '\$${remaining.toStringAsFixed(2)}', sub: 'this month', color: statusColor)),
                    const SizedBox(width: 12),
                    Expanded(child: _ForecastStat(label: 'Avg/Day', value: '\$${avg.toStringAsFixed(2)}', sub: 'last 7 days', color: AppTheme.primary)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _ForecastStat(label: 'Daily Limit', value: '\$${limit.toStringAsFixed(2)}', sub: 'adjusted', color: AppTheme.safeGreen)),
                    const SizedBox(width: 12),
                    Expanded(child: _ForecastStat(label: 'Budget Lasts', value: '~$projected days', sub: 'at current pace', color: isOnTrack ? AppTheme.safeGreen : AppTheme.dangerRed)),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Forecast chart ─────────────────────────────────
                Text('Spend Forecast (14 Days)', style: AppTheme.titleMedium),
                const SizedBox(height: 8),
                Text('Solid = actual · Dashed = projected', style: AppTheme.bodyMedium.copyWith(fontSize: 11)),
                const SizedBox(height: 12),
                Container(
                  height: 200,
                  padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: LineChart(
                    LineChartData(
                      minY: 0,
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
                            interval: 2,
                            getTitlesWidget: (v, _) {
                              final i = v.toInt();
                              if (i < 7) return Text('D-${7 - i}', style: AppTheme.labelSmall.copyWith(fontSize: 9));
                              return Text('+${i - 6}', style: AppTheme.labelSmall.copyWith(fontSize: 9, color: AppTheme.primary));
                            },
                            reservedSize: 20,
                          ),
                        ),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      extraLinesData: ExtraLinesData(
                        horizontalLines: [
                          HorizontalLine(
                            y: limit,
                            color: AppTheme.dangerRed.withAlpha(100),
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
                      lineBarsData: [
                        // Actual (past 7)
                        LineChartBarData(
                          spots: forecastSpots.sublist(0, 7),
                          isCurved: true,
                          color: AppTheme.primary,
                          barWidth: 2.5,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(show: true, color: AppTheme.primary.withAlpha(20)),
                        ),
                        // Projected (next 7)
                        LineChartBarData(
                          spots: forecastSpots.sublist(6),
                          isCurved: false,
                          color: AppTheme.primary.withAlpha(120),
                          barWidth: 2,
                          dashArray: [6, 4],
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(show: true, color: AppTheme.primary.withAlpha(10)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Advice card ────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Text('💡', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Text('What you can do', style: AppTheme.titleMedium),
                      ]),
                      const SizedBox(height: 12),
                      ...(isOnTrack
                          ? [
                              'You\'re spending \$${avg.toStringAsFixed(2)}/day — below your \$${limit.toStringAsFixed(2)} limit.',
                              'Keep this pace and you\'ll save \$${((limit - avg) * daysLeft).toStringAsFixed(2)} by month end.',
                              'Consider moving savings to your Goals screen.',
                            ]
                          : [
                              'Reduce daily spend by \$${(avg - limit).toStringAsFixed(2)} to stay on track.',
                              'Your top category this month is ${budget.topCategory} — start there.',
                              'Try 2 no-spend days this week to recover \$${(avg * 2).toStringAsFixed(2)}.',
                            ])
                          .map((tip) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle)),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(child: Text(tip, style: AppTheme.bodyMedium.copyWith(fontSize: 13, height: 1.5))),
                                ],
                              ),
                            )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ForecastStat extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color color;
  const _ForecastStat({required this.label, required this.value, required this.sub, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTheme.labelSmall.copyWith(fontSize: 11)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: color, letterSpacing: -0.8)),
          Text(sub, style: AppTheme.labelSmall.copyWith(fontSize: 10)),
        ],
      ),
    );
  }
}
