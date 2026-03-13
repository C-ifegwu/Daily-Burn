import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_theme.dart';
import '../../providers/budget_provider.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  static const _tips = [
    ('🍜', 'Campus Canteen', 'Avg spend: \$4.50 — Save vs off-campus'),
    ('🚶', 'Walk Route A', '20 min walk saves \$3 bus fare — 5x / wk'),
    ('📚', 'Library Cafe', 'Coffee at \$2.00 — Half of Starbucks'),
    ('🏪', 'Checkers Express', 'Groceries ~\$25/week vs eating out \$70+'),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetProvider>(
      builder: (ctx, budget, _) {
        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            backgroundColor: AppTheme.background,
            title: const Text('Budget Map'),
            automaticallyImplyLeading: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Monthly burn chart
                const SizedBox(height: 8),
                Text('Monthly Spending', style: AppTheme.titleMedium),
                const SizedBox(height: 4),
                Text('Category breakdown this month', style: AppTheme.bodyMedium.copyWith(fontSize: 12)),
                const SizedBox(height: 16),
                _buildPieChart(budget),
                const SizedBox(height: 28),
                // Spending places map replacer
                Text('Smart Spots Near You 📍', style: AppTheme.titleMedium),
                const SizedBox(height: 4),
                Text('Budget-friendly places on your usual routes', style: AppTheme.bodyMedium.copyWith(fontSize: 12)),
                const SizedBox(height: 16),
                ..._tips.map(
                  (t) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(
                      children: [
                        Text(t.$1, style: const TextStyle(fontSize: 32)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.$2, style: AppTheme.titleMedium.copyWith(fontSize: 14)),
                              const SizedBox(height: 3),
                              Text(t.$3, style: AppTheme.bodyMedium.copyWith(fontSize: 12, height: 1.4)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPieChart(BudgetProvider budget) {
    final cat = budget.spendingByCategory;
    final total = cat.values.fold(0.0, (s, v) => s + v);
    if (total == 0) {
      return Container(
        height: 180,
        decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
        child: Center(child: Text('No data yet', style: AppTheme.bodyMedium)),
      );
    }

    final colors = [AppTheme.catFood, AppTheme.catTransport, AppTheme.catFun, AppTheme.catMisc];
    final sections = cat.entries.toList().asMap().entries.map((entry) {
      final i = entry.key % colors.length;
      final e = entry.value;
      return PieChartSectionData(
        value: e.value,
        color: colors[i],
        title: '${(e.value / total * 100).toStringAsFixed(0)}%',
        radius: 70,
        titleStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: PieChart(PieChartData(sections: sections, sectionsSpace: 2, centerSpaceRadius: 40)),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: cat.entries.toList().asMap().entries.map((entry) {
              final i = entry.key % colors.length;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: colors[i], shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(entry.value.key, style: AppTheme.bodyMedium.copyWith(fontSize: 12)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
