import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../providers/budget_provider.dart';
import '../../widgets/transaction_detail_sheet.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetProvider>(
      builder: (context, budget, _) {
        final grouped = _group(budget.transactions);
        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            backgroundColor: AppTheme.background,
            title: const Text('History'),
            automaticallyImplyLeading: false,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/monthly-review'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.primary.withAlpha(40)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.bar_chart_rounded, color: AppTheme.primary, size: 14),
                        const SizedBox(width: 4),
                        Text('Review', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primary)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: grouped.isEmpty
              ? _buildEmpty()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  itemCount: grouped.length,
                  itemBuilder: (ctx, i) {
                    final entry = grouped[i];
                    return _DaySection(label: entry.key, transactions: entry.value);
                  },
                ),
        );
      },
    );
  }

  List<MapEntry<String, List<Transaction>>> _group(List<Transaction> txns) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final map = <String, List<Transaction>>{};
    for (final t in txns) {
      final d = DateTime(t.dateTime.year, t.dateTime.month, t.dateTime.day);
      final String key;
      if (d == today) {
        key = 'Today';
      } else if (d == yesterday) {
        key = 'Yesterday';
      } else {
        key = DateFormat('MMMM d, y').format(d);
      }
      (map[key] ??= []).add(t);
    }
    return map.entries.toList();
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📭', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 20),
          Text('No transactions yet', style: AppTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('Add your first expense from the dashboard.', style: AppTheme.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.primary.withAlpha(40)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_rounded, color: AppTheme.primary, size: 18),
                const SizedBox(width: 8),
                Text('Tap + to add an expense', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  final String label;
  final List<Transaction> transactions;
  const _DaySection({required this.label, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final total = transactions.fold(0.0, (s, t) => s + t.amount);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
          child: Row(
            children: [
              Text(label, style: AppTheme.titleMedium.copyWith(fontSize: 13)),
              const Spacer(),
              Text(
                '-\$${total.toStringAsFixed(2)}',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.dangerRed),
              ),
            ],
          ),
        ),
        ...transactions.map((t) => _TxRow(t: t)),
      ],
    );
  }
}

class _TxRow extends StatelessWidget {
  final Transaction t;
  const _TxRow({required this.t});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.categoryColors[t.category] ?? AppTheme.primary;
    final emoji = AppTheme.categoryEmojis[t.category] ?? '💰';

    return GestureDetector(
      onTap: () => showTransactionDetail(context, t),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.note, style: AppTheme.titleMedium.copyWith(fontSize: 14)),
                  Text(t.category, style: AppTheme.bodyMedium.copyWith(fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('-\$${t.amount.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.dangerRed)),
                Text(DateFormat('h:mm a').format(t.dateTime), style: AppTheme.labelSmall.copyWith(fontSize: 11)),
              ],
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.textTertiary, size: 16),
          ],
        ),
      ),
    );
  }
}
