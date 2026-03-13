import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../providers/budget_provider.dart';
import '../../widgets/transaction_detail_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _circleCtrl;
  late Animation<double> _circleAnim;

  @override
  void initState() {
    super.initState();
    _circleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
    _circleAnim = CurvedAnimation(parent: _circleCtrl, curve: Curves.easeOutCubic);
    _circleCtrl.forward();
  }

  @override
  void dispose() { _circleCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetProvider>(
      builder: (context, budget, _) {
        final pct = budget.todaySpentPct;
        final stateColor = AppTheme.budgetColor(pct);
        final isWarning = pct > 0.8;
        final now = DateTime.now();

        return Scaffold(
          backgroundColor: AppTheme.background,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                // ── Header ─────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Good morning, Alex 👋',
                              style: AppTheme.bodyMedium.copyWith(fontSize: 13),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat('EEEE, MMM d').format(now),
                              style: AppTheme.titleMedium,
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Notification bell
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/notifications'),
                          child: Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: const Icon(Icons.notifications_none_rounded, color: AppTheme.textSecondary, size: 20),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Avatar
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withAlpha(25),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              'A',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Warning banner ─────────────────────────────────
                if (isWarning)
                  SliverToBoxAdapter(child: _buildWarningBanner(budget)),

                // ── Hero Circle ────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                    child: Column(
                      children: [
                        // State badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: stateColor.withAlpha(25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(width: 8, height: 8, decoration: BoxDecoration(color: stateColor, shape: BoxShape.circle)),
                              const SizedBox(width: 8),
                              Text(
                                AppTheme.budgetStateLabel(pct),
                                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: stateColor),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        // The Magic Circle
                        AnimatedBuilder(
                          animation: _circleAnim,
                          builder: (_, __) => _buildCircle(budget, stateColor),
                        ),
                        const SizedBox(height: 20),
                        // Today's date tag
                        Text(
                          DateFormat('EEEE MMM d').format(now),
                          style: AppTheme.bodyMedium.copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Quick action buttons ───────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.add_rounded,
                            label: 'Add Expense',
                            color: AppTheme.primary,
                            onTap: () => Navigator.pushNamed(context, '/add-expense'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.trending_up_rounded,
                            label: 'Forecast',
                            color: AppTheme.textSecondary,
                            onTap: () => Navigator.pushNamed(context, '/forecast'),
                            isOutline: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Minimalist Stats ───────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _MiniStat(
                            label: 'Monthly Total Remaining',
                            value: '\$${budget.monthlyRemaining.toStringAsFixed(2)}',
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MiniStat(
                            label: 'Days Left in Month',
                            value: '${budget.daysLeft}',
                            unit: ' days',
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Today's Activity ──────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                    child: Row(
                      children: [
                        Text("Today's Activity", style: AppTheme.titleMedium),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {},
                          child: Text('Open All', style: AppTheme.bodyMedium.copyWith(color: AppTheme.primary, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ),

                if (budget.todayTransactions.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: _EmptyActivity(),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) {
                          final t = budget.todayTransactions[i];
                          return GestureDetector(
                            onTap: () => showTransactionDetail(context, t),
                            child: _ActivityRow(
                              category: t.category,
                              note: t.note,
                              amount: t.amount,
                              time: DateFormat('h:mm a').format(t.dateTime),
                            ),
                          );
                        },
                        childCount: budget.todayTransactions.length,
                      ),
                    ),
                  ),

                // ── Smart Spending Tips ────────────────────────────
                SliverToBoxAdapter(child: _buildTips()),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWarningBanner(BudgetProvider budget) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.dangerRed,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: Colors.white.withAlpha(40), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Today\'s Budget', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
                Text(
                  '\$${budget.todayRemaining.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.white.withAlpha(40), borderRadius: BorderRadius.circular(20)),
            child: Text('Balance Low', style: GoogleFonts.inter(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildCircle(BudgetProvider budget, Color stateColor) {
    final pct = budget.todaySpentPct;
    return SizedBox(
      width: 240,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 20,
              color: stateColor.withAlpha(20),
            ),
          ),
          // Progress arc
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: (_circleAnim.value * pct).clamp(0.0, 1.0),
              strokeWidth: 20,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(stateColor),
              strokeCap: StrokeCap.round,
            ),
          ),
          // White inner circle with shadow
          Container(
            width: 188,
            height: 188,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: stateColor.withAlpha(40),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Today\'s Burn',
                  style: AppTheme.labelSmall.copyWith(fontSize: 11, letterSpacing: 0.5),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${budget.todayRemaining.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    color: stateColor,
                    letterSpacing: -2,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'left today',
                  style: AppTheme.bodyMedium.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: stateColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(pct * 100).toStringAsFixed(0)}% used',
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: stateColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTips() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text('Smart Spending Tips', style: AppTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 14),
          ...[
            ('Cook at home tonight and save ~\$8', AppTheme.safeGreen),
            ('Walk instead of a cab — save \$3', AppTheme.primary),
            ('Your food spend is up 12% this week', AppTheme.warningYellow),
          ].map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(width: 6, height: 6, decoration: BoxDecoration(color: t.$2, shape: BoxShape.circle)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(t.$1, style: AppTheme.bodyMedium.copyWith(fontSize: 13))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isOutline;
  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap, this.isOutline = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 52,
        decoration: BoxDecoration(
          color: isOutline ? AppTheme.surface : color,
          borderRadius: BorderRadius.circular(14),
          border: isOutline ? Border.all(color: AppTheme.border) : null,
          boxShadow: isOutline ? null : [BoxShadow(color: color.withAlpha(60), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isOutline ? color : Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: isOutline ? AppTheme.textPrimary : Colors.white)),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final Color color;
  const _MiniStat({required this.label, required this.value, this.unit, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTheme.labelSmall.copyWith(fontSize: 11)),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: color, letterSpacing: -0.8)),
              if (unit != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 1),
                  child: Text(unit!, style: AppTheme.bodyMedium.copyWith(fontSize: 12)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final String category;
  final String note;
  final double amount;
  final String time;
  const _ActivityRow({required this.category, required this.note, required this.amount, required this.time});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.categoryColors[category] ?? AppTheme.primary;
    final icon = AppTheme.categoryIcons[category] ?? Icons.receipt_long_rounded;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color.withAlpha(30), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(note, style: AppTheme.titleMedium.copyWith(fontSize: 14)),
                Text(category, style: AppTheme.bodyMedium.copyWith(fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('-\$${amount.toStringAsFixed(2)}', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.dangerRed)),
              Text(time, style: AppTheme.labelSmall.copyWith(fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyActivity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
      child: Column(
        children: [
          const Text('🎉', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 10),
          Text('No expenses today!', style: AppTheme.titleMedium),
          const SizedBox(height: 4),
          Text('Tap + Add Expense to log your first spend.', style: AppTheme.bodyMedium.copyWith(fontSize: 13), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
