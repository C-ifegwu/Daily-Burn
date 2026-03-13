import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

// Legacy widget kept for compatibility — new flow uses AddExpenseScreen category cards
class DailyBurnButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool isDestructive;

  const DailyBurnButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isPrimary = true,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = isPrimary ? AppTheme.primary : AppTheme.surfaceVariant;
    if (isDestructive) bg = AppTheme.dangerRed;
    final Color fg = isPrimary || isDestructive ? Colors.white : AppTheme.textPrimary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: fg),
          ),
        ),
      ),
    );
  }
}
