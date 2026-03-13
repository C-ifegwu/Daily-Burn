import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../providers/budget_provider.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  const TransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.categoryColors[transaction.category] ?? AppTheme.primary;
    final icon = AppTheme.categoryIcons[transaction.category] ?? Icons.receipt_long_rounded;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.note, style: AppTheme.titleMedium.copyWith(fontSize: 14)),
                Text(transaction.category, style: AppTheme.bodyMedium.copyWith(fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('-\$${transaction.amount.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.dangerRed)),
              Text(DateFormat('h:mm a').format(transaction.dateTime), style: AppTheme.labelSmall.copyWith(fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
