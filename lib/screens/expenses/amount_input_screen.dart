import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/budget_provider.dart';

class AmountInputScreen extends StatefulWidget {
  final String category;
  const AmountInputScreen({super.key, required this.category});

  @override
  State<AmountInputScreen> createState() => _AmountInputScreenState();
}

class _AmountInputScreenState extends State<AmountInputScreen> {
  String _amount = '0';

  void _append(String digit) {
    setState(() {
      if (_amount == '0' && digit != '.') {
        _amount = digit;
      } else if (digit == '.' && _amount.contains('.')) {
        return;
      } else {
        _amount += digit;
      }
    });
  }

  void _backspace() {
    setState(() {
      _amount = _amount.length > 1 ? _amount.substring(0, _amount.length - 1) : '0';
    });
  }

  double get _value => double.tryParse(_amount) ?? 0;

  Color get _catColor => AppTheme.categoryColors[widget.category] ?? AppTheme.primary;
  String get _catEmoji => AppTheme.categoryEmojis[widget.category] ?? '💰';

  @override
  Widget build(BuildContext context) {
    final budget = context.watch<BudgetProvider>();
    final willBeOver = budget.todaySpent + _value > budget.adjustedDailyLimit;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_catEmoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(widget.category),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // ── Amount display ─────────────────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _catColor.withAlpha(18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _catColor.withAlpha(60)),
              ),
              child: Column(
                children: [
                  Text(
                    'How much?',
                    style: AppTheme.bodyMedium.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text('\$', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w400, color: AppTheme.textSecondary)),
                      ),
                      Text(
                        _amount,
                        style: GoogleFonts.inter(
                          fontSize: 56,
                          fontWeight: FontWeight.w800,
                          color: _catColor,
                          letterSpacing: -3,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                  if (willBeOver && _value > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.dangerRed.withAlpha(20),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: AppTheme.dangerRed, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              'This will exceed today\'s limit!',
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.dangerRed),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // ── Numpad ─────────────────────────────────────────────
            Expanded(child: _buildNumpad()),
            // ── Add Expense CTA ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _value > 0 ? _submit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _value > 0 ? _catColor : AppTheme.border,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Apply Now Category', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final budget = context.read<BudgetProvider>();
    final t = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: widget.category,
      amount: _value,
      note: widget.category,
      dateTime: DateTime.now(),
    );
    budget.addTransaction(t);

    Navigator.pushReplacementNamed(
      context,
      '/expense-success',
      arguments: {'category': widget.category, 'amount': _value},
    );
  }

  Widget _buildNumpad() {
    final keys = ['1','2','3','4','5','6','7','8','9','.','0','⌫'];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      childAspectRatio: 1.8,
      children: keys.map((k) {
        return GestureDetector(
          onTap: () => k == '⌫' ? _backspace() : _append(k),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: k == '⌫' ? AppTheme.surfaceVariant : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: k == '⌫'
                  ? const Icon(Icons.backspace_outlined, color: AppTheme.textSecondary, size: 22)
                  : Text(k, style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w400, color: AppTheme.textPrimary)),
            ),
          ),
        );
      }).toList(),
    );
  }
}
