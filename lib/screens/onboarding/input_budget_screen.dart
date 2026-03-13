import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/budget_provider.dart';

class InputBudgetScreen extends StatefulWidget {
  const InputBudgetScreen({super.key});

  @override
  State<InputBudgetScreen> createState() => _InputBudgetScreenState();
}

class _InputBudgetScreenState extends State<InputBudgetScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text('Step 1 of 3', style: AppTheme.labelSmall),
            const SizedBox(height: 2),
            LinearProgressIndicator(
              value: 0.33,
              backgroundColor: AppTheme.border,
              valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Set Monthly Budget', style: AppTheme.headlineMedium),
                  const SizedBox(height: 6),
                  Text(
                    'How much is in the bank for the month? You\'ll use your daily limit to track your daily finances.',
                    style: AppTheme.bodyMedium.copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            // Amount label
            Text('MONTHLY TOTAL', style: AppTheme.labelSmall.copyWith(letterSpacing: 1.2)),
            const SizedBox(height: 10),
            // Amount display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    '\$',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                Text(
                  _amount,
                  style: GoogleFonts.inter(
                    fontSize: 64,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    letterSpacing: -3,
                    height: 1.0,
                  ),
                ),
              ],
            ),

            // Hint
            if (_value > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.safeGreen.withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Daily limit ≈ \$${(_value / 30).toStringAsFixed(2)}/day',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppTheme.safeGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Numpad
            Expanded(child: _buildNumpad()),

            // CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _value > 0
                      ? () {
                          context.read<BudgetProvider>().setMonthlyTotal(_value);
                          Navigator.pushNamed(context, '/select-date');
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _value > 0 ? AppTheme.primary : AppTheme.border,
                    foregroundColor: _value > 0 ? Colors.white : AppTheme.textTertiary,
                  ),
                  child: const Text('Next →'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumpad() {
    final keys = ['1','2','3','4','5','6','7','8','9','.','0','⌫'];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      childAspectRatio: 2.0,
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
                  : Text(
                      k,
                      style: GoogleFonts.inter(
                        fontSize: 26,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.textPrimary,
                      ),
                    ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
