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

  static const List<int> _quickAmounts = <int>[500, 1000, 2000, 5000];

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
      _amount =
          _amount.length > 1 ? _amount.substring(0, _amount.length - 1) : '0';
    });
  }

  double get _value => double.tryParse(_amount) ?? 0;

  void _setQuickAmount(int amount) {
    setState(() {
      _amount = amount.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool compactHeight = MediaQuery.sizeOf(context).height < 760;

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
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double keypadHeight = compactHeight
                ? 236
                : (constraints.maxHeight * 0.34).clamp(250.0, 320.0);

            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 12),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: compactHeight ? 16 : 28),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Set Monthly Budget',
                                style: AppTheme.headlineMedium),
                            const SizedBox(height: 6),
                            Text(
                              'How much is in the bank for the month? You\'ll use your daily limit to track your daily finances.',
                              style: AppTheme.bodyMedium.copyWith(height: 1.5),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: compactHeight ? 18 : 30),
                      Text('MONTHLY TOTAL',
                          style:
                              AppTheme.labelSmall.copyWith(letterSpacing: 1.2)),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 320,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
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
                        ),
                      ),
                      if (_value > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
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
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: _quickAmounts
                              .map(
                                (int amount) => OutlinedButton(
                                  onPressed: () => _setQuickAmount(amount),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                        color: AppTheme.border),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text('\$$amount'),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: keypadHeight,
                        child: _buildNumpad(keypadHeight),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _value > 0
                                ? () {
                                    context
                                        .read<BudgetProvider>()
                                        .setMonthlyTotal(_value);
                                    Navigator.pushNamed(
                                        context, '/select-date');
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _value > 0
                                  ? AppTheme.primary
                                  : AppTheme.border,
                              foregroundColor: _value > 0
                                  ? Colors.white
                                  : AppTheme.textTertiary,
                            ),
                            child: const Text('Next →'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNumpad(double keypadHeight) {
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '0', '⌫'];
    final double keyHeight = ((keypadHeight - 24) / 4).clamp(50.0, 74.0);

    return GridView.builder(
      itemCount: keys.length,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisExtent: keyHeight,
      ),
      itemBuilder: (_, index) {
        final k = keys[index];
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
                  ? const Icon(Icons.backspace_outlined,
                      color: AppTheme.textSecondary, size: 22)
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
      },
    );
  }
}
