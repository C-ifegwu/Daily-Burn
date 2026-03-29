import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/budget_provider.dart';

class ExpenseSuccessScreen extends StatefulWidget {
  final String category;
  final double amount;
  const ExpenseSuccessScreen(
      {super.key, required this.category, required this.amount});

  @override
  State<ExpenseSuccessScreen> createState() => _ExpenseSuccessScreenState();
}

class _ExpenseSuccessScreenState extends State<ExpenseSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _scale = Tween(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final budget = context.watch<BudgetProvider>();
    final isOverspent = budget.isOverspentToday;
    final catColor =
        AppTheme.categoryColors[widget.category] ?? AppTheme.primary;
    final catEmoji = AppTheme.categoryEmojis[widget.category] ?? '💰';

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // ── Check animation ─────────────────────────────────
              FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _scale,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.safeGreen.withAlpha(20),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppTheme.safeGreen.withAlpha(60),
                          width: 2),
                    ),
                    child: const Center(
                      child: Icon(Icons.check_rounded, color: AppTheme.safeGreen, size: 60),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
                  Text('Expense Recorded!', style: AppTheme.headlineMedium),
                  const SizedBox(height: 6),
                  Text('Great job tracking your spending.',
                      style: AppTheme.bodyMedium),
                  const SizedBox(height: 36),
                  // ── Summary card ─────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: catColor.withAlpha(12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: catColor.withAlpha(50)),
                    ),
                    child: Column(
                      children: [
                        Text('$catEmoji ${widget.category}',
                            style: AppTheme.titleMedium),
                        const SizedBox(height: 12),
                        Text(
                          '\$${widget.amount.toStringAsFixed(2)}',
                          style: GoogleFonts.inter(
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            color: catColor,
                            letterSpacing: -2,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Divider(color: catColor.withAlpha(40)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _SummaryRow(
                                label: 'Remaining today',
                                value:
                                    '\$${budget.todayRemaining.toStringAsFixed(2)}'),
                            _SummaryRow(
                                label: 'Monthly left',
                                value:
                                    '\$${budget.monthlyRemaining.toStringAsFixed(2)}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                  // ── Overspend warning if needed ──────────────────────
                  if (isOverspent)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.dangerRed.withAlpha(15),
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: AppTheme.dangerRed.withAlpha(50)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: AppTheme.dangerRed, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'You\'ve exceeded today\'s limit. Your daily limit will be adjusted.',
                              style: AppTheme.bodyMedium.copyWith(
                                  fontSize: 13, color: AppTheme.dangerRed),
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.safeGreen),
                      onPressed: () {
                        if (isOverspent) {
                          Navigator.pushReplacementNamed(
                              context, '/adjustment');
                        } else {
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/home', (_) => false);
                        }
                      },
                      child: Text(
                          isOverspent ? 'See Adjustment' : 'Back to Dashboard',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context, '/home', (_) => false),
                    child: Text('Skip',
                        style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary)),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTheme.labelSmall.copyWith(fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: AppTheme.titleMedium.copyWith(fontSize: 15)),
      ],
    );
  }
}
