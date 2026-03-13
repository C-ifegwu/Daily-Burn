import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/budget_provider.dart';

class SavingsLockScreen extends StatefulWidget {
  const SavingsLockScreen({super.key});

  @override
  State<SavingsLockScreen> createState() => _SavingsLockScreenState();
}

class _SavingsLockScreenState extends State<SavingsLockScreen>
    with SingleTickerProviderStateMixin {
  bool _locked = false;
  double _savingsTarget = 200.0;
  final TextEditingController _targetCtrl = TextEditingController(text: '200');
  late AnimationController _lockAnim;
  late Animation<double> _lockScale;

  @override
  void initState() {
    super.initState();
    _lockAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _lockScale = Tween(begin: 1.0, end: 1.15)
        .animate(CurvedAnimation(parent: _lockAnim, curve: Curves.easeOutBack));
  }

  @override
  void dispose() {
    _lockAnim.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  void _toggleLock() {
    if (!_locked) {
      _showLockConfirm();
    } else {
      _showUnlockConfirm();
    }
  }

  void _showLockConfirm() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(color: AppTheme.primary.withAlpha(20), shape: BoxShape.circle),
              child: const Icon(Icons.lock_rounded, color: AppTheme.primary, size: 36),
            ),
            const SizedBox(height: 20),
            Text('Lock \$${_savingsTarget.toStringAsFixed(2)}?', style: AppTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'This amount will be protected and subtracted from your spendable budget. You can unlock anytime.',
              style: AppTheme.bodyMedium.copyWith(height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => _locked = true);
                  _lockAnim.forward().then((_) => _lockAnim.reverse());
                },
                child: const Text('Lock It In 🔒', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: AppTheme.bodyMedium.copyWith(fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUnlockConfirm() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(color: AppTheme.warningYellow.withAlpha(25), shape: BoxShape.circle),
              child: const Icon(Icons.lock_open_rounded, color: AppTheme.warningYellow, size: 36),
            ),
            const SizedBox(height: 20),
            Text('Unlock Savings?', style: AppTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Your \$${_savingsTarget.toStringAsFixed(2)} savings will be released back into your spendable budget.',
              style: AppTheme.bodyMedium.copyWith(height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => _locked = false);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warningYellow),
                child: const Text('Unlock 🔓', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Keep Locked', style: AppTheme.bodyMedium.copyWith(fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final budget = context.watch<BudgetProvider>();
    final spendable = budget.monthlyRemaining - (_locked ? _savingsTarget : 0);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        title: const Text('Savings Lock'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Lock status hero ──────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: _locked ? AppTheme.primary.withAlpha(15) : AppTheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _locked ? AppTheme.primary.withAlpha(60) : AppTheme.border,
                  width: _locked ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  ScaleTransition(
                    scale: _lockScale,
                    child: GestureDetector(
                      onTap: _toggleLock,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: _locked ? AppTheme.primary : AppTheme.surfaceVariant,
                          shape: BoxShape.circle,
                          boxShadow: _locked
                              ? [BoxShadow(color: AppTheme.primary.withAlpha(60), blurRadius: 20, spreadRadius: 2)]
                              : null,
                        ),
                        child: Icon(
                          _locked ? Icons.lock_rounded : Icons.lock_open_rounded,
                          color: _locked ? Colors.white : AppTheme.textSecondary,
                          size: 44,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _locked ? 'Savings Locked 🔒' : 'Savings Unlocked',
                    style: AppTheme.headlineMedium.copyWith(color: _locked ? AppTheme.primary : AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _locked
                        ? '\$${_savingsTarget.toStringAsFixed(2)} is protected from spending'
                        : 'Tap the lock to protect your savings',
                    style: AppTheme.bodyMedium.copyWith(fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  if (_locked) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.safeGreen.withAlpha(25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_rounded, color: AppTheme.safeGreen, size: 16),
                          const SizedBox(width: 8),
                          Text('Active — earning discipline', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.safeGreen)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Set target amount ─────────────────────────────────
            if (!_locked) ...[
              Text('Savings Target', style: AppTheme.titleMedium),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('How much do you want to lock away?', style: AppTheme.bodyMedium.copyWith(fontSize: 13)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _targetCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: -0.5),
                      decoration: InputDecoration(
                        prefixText: '\$  ',
                        prefixStyle: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w400, color: AppTheme.textSecondary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.border)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
                        filled: true,
                        fillColor: AppTheme.background,
                      ),
                      onChanged: (v) => setState(() => _savingsTarget = double.tryParse(v) ?? 0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ── Budget summary ────────────────────────────────────
            Text('Budget Impact', style: AppTheme.titleMedium),
            const SizedBox(height: 12),
            _ImpactRow(label: 'Monthly Remaining', value: budget.monthlyRemaining, color: AppTheme.textPrimary),
            const SizedBox(height: 8),
            _ImpactRow(label: 'Savings Locked', value: _locked ? _savingsTarget : 0, color: AppTheme.primary),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Divider(color: AppTheme.border),
            ),
            _ImpactRow(label: 'Spendable Budget', value: spendable.clamp(0, double.infinity), color: AppTheme.safeGreen, isBold: true),
            const SizedBox(height: 32),

            // ── CTA ───────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _toggleLock,
                style: ElevatedButton.styleFrom(backgroundColor: _locked ? AppTheme.warningYellow : AppTheme.primary),
                child: Text(
                  _locked ? '🔓  Unlock Savings' : '🔒  Lock Savings',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white),
                ),
              ),
            ),

            // ── Tips ──────────────────────────────────────────────
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [const Text('💡', style: TextStyle(fontSize: 18)), const SizedBox(width: 8), Text('Why use Savings Lock?', style: AppTheme.titleMedium)]),
                  const SizedBox(height: 12),
                  ...[
                    'Prevents impulse spending from your savings',
                    'Keeps your emergency fund intact',
                    'Builds financial discipline over time',
                  ].map((t) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(t, style: AppTheme.bodyMedium.copyWith(fontSize: 13, height: 1.4))),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImpactRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final bool isBold;
  const _ImpactRow({required this.label, required this.value, required this.color, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: isBold ? AppTheme.titleMedium : AppTheme.bodyMedium),
        const Spacer(),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: GoogleFonts.inter(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: color,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}
