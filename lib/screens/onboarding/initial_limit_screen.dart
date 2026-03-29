import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/budget_provider.dart';

class InitialLimitScreen extends StatefulWidget {
  const InitialLimitScreen({super.key});

  @override
  State<InitialLimitScreen> createState() => _InitialLimitScreenState();
}

class _InitialLimitScreenState extends State<InitialLimitScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _progressAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
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
    final daily = budget.adjustedDailyLimit;
    final remaining = budget.monthlyRemaining;
    final daysLeft = budget.daysLeft;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        leading: const SizedBox.shrink(),
        title: Column(
          children: [
            Text('Step 3 of 3', style: AppTheme.labelSmall),
            const SizedBox(height: 2),
            LinearProgressIndicator(
              value: 1.0,
              backgroundColor: AppTheme.border,
              valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool compactWidth = constraints.maxWidth < 480;
            final bool compactHeight = constraints.maxHeight < 760;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: compactWidth ? 16 : 28),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 560,
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: compactHeight ? 10 : 16),
                      // State badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppTheme.safeGreen.withAlpha(25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                    color: AppTheme.safeGreen,
                                    shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Text('Safe State',
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.safeGreen)),
                          ],
                        ),
                      ),
                      SizedBox(height: compactHeight ? 16 : 28),
                      Text('Calculating your\nfirst daily burn...',
                          style: AppTheme.headlineLarge,
                          textAlign: TextAlign.center),
                      SizedBox(height: compactHeight ? 20 : 36),

                      // ── Circular Progress Hero ─────────────────────────────
                      AnimatedBuilder(
                        animation: _progressAnim,
                        builder: (_, __) {
                          return SizedBox(
                            width: 240,
                            height: 240,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Background ring
                                SizedBox.expand(
                                  child: CircularProgressIndicator(
                                    value: 1.0,
                                    strokeWidth: 16,
                                    backgroundColor: Colors.transparent,
                                    valueColor: AlwaysStoppedAnimation(
                                        AppTheme.safeGreen.withAlpha(30)),
                                  ),
                                ),
                                // Animated fill ring
                                SizedBox.expand(
                                  child: CircularProgressIndicator(
                                    value:
                                        _progressAnim.value * 0.12, // start low
                                    strokeWidth: 16,
                                    backgroundColor: Colors.transparent,
                                    valueColor: const AlwaysStoppedAnimation(
                                        AppTheme.safeGreen),
                                    strokeCap: StrokeCap.round,
                                  ),
                                ),
                                // Center content
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '\$${daily.toStringAsFixed(2)}',
                                      style: GoogleFonts.inter(
                                        fontSize: 44,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.textPrimary,
                                        letterSpacing: -2,
                                        height: 1.0,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text('per day', style: AppTheme.bodyMedium),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      SizedBox(height: compactHeight ? 20 : 36),
                      // ── Stats row ─────────────────────────────────────────
                      if (compactWidth)
                        Column(
                          children: [
                            _StatBox(
                              label: 'Monthly Total',
                              value:
                                  '\$${budget.monthlyTotal.toStringAsFixed(2)}',
                            ),
                            const SizedBox(height: 12),
                            _StatBox(
                              label: '$daysLeft Days Left',
                              value: '\$${remaining.toStringAsFixed(2)}',
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: _StatBox(
                                label: 'Monthly Total',
                                value:
                                    '\$${budget.monthlyTotal.toStringAsFixed(2)}',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatBox(
                                label: '$daysLeft Days Left',
                                value: '\$${remaining.toStringAsFixed(2)}',
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 12),
                      // ── Tip card ──────────────────────────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.background,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Row(
                          children: [
                            const Text('💡', style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Setting a Rollover Reserve: We will tell you anytime your finances and action plan need to be adjusted today under your goal.',
                                style: AppTheme.bodyMedium
                                    .copyWith(fontSize: 12, height: 1.5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 36),
              // ── Stats row ─────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _StatBox(
                      label: 'Monthly Total',
                      value: '\$${budget.monthlyTotal.toStringAsFixed(2)}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatBox(
                      label: '$daysLeft Days Left',
                      value: '\$${remaining.toStringAsFixed(2)}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // ── Tip card ──────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Setting a Rollover Reserve: We will tell you anytime your finances and action plan need to be adjusted today under your goal.',
                        style: AppTheme.bodyMedium.copyWith(fontSize: 12, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.safeGreen),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Enter Dashboard', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
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
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTheme.labelSmall),
          const SizedBox(height: 4),
          Text(value, style: AppTheme.titleMedium.copyWith(fontSize: 16)),
        ],
      ),
    );
  }
}
