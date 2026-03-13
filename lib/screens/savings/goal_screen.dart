import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

// ── Goal model ────────────────────────────────────────────────────────────────
class SavingsGoal {
  final String id;
  final String name;
  final String emoji;
  final double target;
  double saved;

  SavingsGoal({
    required this.id,
    required this.name,
    required this.emoji,
    required this.target,
    this.saved = 0,
  });

  double get progress => (saved / target).clamp(0.0, 1.0);
  bool get isComplete => saved >= target;
  double get remaining => (target - saved).clamp(0, double.infinity);
}

// ──────────────────────────────────────────────────────────────────────────────
class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key});

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  final List<SavingsGoal> _goals = [
    SavingsGoal(id: '1', name: 'Emergency Fund', emoji: '🛡️', target: 500, saved: 120),
    SavingsGoal(id: '2', name: 'New Laptop', emoji: '💻', target: 800, saved: 340),
    SavingsGoal(id: '3', name: 'Holiday Trip', emoji: '✈️', target: 1200, saved: 60),
  ];

  // ── Add goal ────────────────────────────────────────────────────────────────
  void _showAddGoalSheet() {
    final nameCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    String selectedEmoji = '🎯';
    final emojis = ['🎯','🛡️','💻','✈️','🎓','🏠','🚗','🎮','📱','🍕'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text('New Goal', style: AppTheme.headlineMedium),
              const SizedBox(height: 20),
              // Emoji picker
              Text('Pick an icon', style: AppTheme.bodyMedium.copyWith(fontSize: 12)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: emojis.map((e) => GestureDetector(
                  onTap: () => setModalState(() => selectedEmoji = e),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: selectedEmoji == e ? AppTheme.primary.withAlpha(25) : AppTheme.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: selectedEmoji == e ? AppTheme.primary : AppTheme.border, width: selectedEmoji == e ? 1.5 : 1),
                    ),
                    child: Center(child: Text(e, style: const TextStyle(fontSize: 22))),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Goal Name',
                  hintText: 'e.g. New Laptop',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
                  filled: true,
                  fillColor: AppTheme.background,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: targetCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Target Amount',
                  hintText: 'e.g. 500',
                  prefixText: '\$  ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
                  filled: true,
                  fillColor: AppTheme.background,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final target = double.tryParse(targetCtrl.text) ?? 0;
                    if (name.isEmpty || target <= 0) return;
                    Navigator.pop(ctx);
                    setState(() {
                      _goals.add(SavingsGoal(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: name,
                        emoji: selectedEmoji,
                        target: target,
                      ));
                    });
                  },
                  child: const Text('Create Goal', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Add funds ───────────────────────────────────────────────────────────────
  void _showAddFundsSheet(SavingsGoal goal) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(goal.emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Add Funds', style: AppTheme.headlineMedium.copyWith(fontSize: 20)),
                    Text(goal.name, style: AppTheme.bodyMedium),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: ctrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: -1),
              decoration: InputDecoration(
                hintText: '0.00',
                prefixText: '\$  ',
                prefixStyle: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w400, color: AppTheme.textSecondary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
                filled: true,
                fillColor: AppTheme.background,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(ctrl.text) ?? 0;
                  if (amount <= 0) return;
                  Navigator.pop(ctx);
                  setState(() {
                    goal.saved = (goal.saved + amount).clamp(0, goal.target);
                  });
                  if (goal.isComplete) _showCelebration(goal);
                },
                child: const Text('Add Funds', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Celebration dialog ──────────────────────────────────────────────────────
  void _showCelebration(SavingsGoal goal) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text('Goal Reached!', style: AppTheme.headlineMedium, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('You\'ve hit your ${goal.name} goal of \$${goal.target.toStringAsFixed(2)}. Amazing work! 🔥', style: AppTheme.bodyMedium.copyWith(height: 1.5), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.safeGreen),
                onPressed: () => Navigator.pop(context),
                child: const Text('Awesome! 🙌', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalTarget = _goals.fold(0.0, (s, g) => s + g.target);
    final totalSaved = _goals.fold(0.0, (s, g) => s + g.saved);
    final overallPct = totalTarget > 0 ? totalSaved / totalTarget : 0.0;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        title: const Text('My Goals'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: _showAddGoalSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    const Icon(Icons.add_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text('New', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // ── Overall progress card ─────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primary, AppTheme.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: AppTheme.primary.withAlpha(60), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Saved', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 6),
                          Text('\$${totalSaved.toStringAsFixed(2)}', style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1.5)),
                          Text('of \$${totalTarget.toStringAsFixed(2)} total goals', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
                          const SizedBox(height: 14),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: overallPct,
                              backgroundColor: Colors.white.withAlpha(40),
                              valueColor: const AlwaysStoppedAnimation(Colors.white),
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text('${(overallPct * 100).toStringAsFixed(0)}% complete across ${_goals.length} goals', style: GoogleFonts.inter(fontSize: 11, color: Colors.white70)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Ring
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: overallPct,
                            strokeWidth: 8,
                            backgroundColor: Colors.white.withAlpha(40),
                            valueColor: const AlwaysStoppedAnimation(Colors.white),
                            strokeCap: StrokeCap.round,
                          ),
                          Text('${(overallPct * 100).toStringAsFixed(0)}%', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (_goals.isEmpty)
            SliverFillRemaining(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🎯', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: 16),
                  Text('No goals yet', style: AppTheme.headlineMedium),
                  const SizedBox(height: 6),
                  Text('Tap "+ New" to add your first savings goal.', style: AppTheme.bodyMedium),
                ],
              ),
            )
          else ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                child: Row(
                  children: [
                    Text('Your Goals', style: AppTheme.titleMedium),
                    const Spacer(),
                    Text('${_goals.where((g) => g.isComplete).length}/${_goals.length} complete', style: AppTheme.bodyMedium.copyWith(fontSize: 12, color: AppTheme.safeGreen)),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _GoalCard(goal: _goals[i], onAddFunds: () => _showAddFundsSheet(_goals[i]), onDelete: () => setState(() => _goals.removeAt(i))),
                  childCount: _goals.length,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
class _GoalCard extends StatelessWidget {
  final SavingsGoal goal;
  final VoidCallback onAddFunds;
  final VoidCallback onDelete;
  const _GoalCard({required this.goal, required this.onAddFunds, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final color = goal.isComplete ? AppTheme.safeGreen : AppTheme.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: goal.isComplete ? AppTheme.safeGreen.withAlpha(60) : AppTheme.border, width: goal.isComplete ? 1.5 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Ring
              SizedBox(
                width: 52,
                height: 52,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: goal.progress,
                      strokeWidth: 5,
                      backgroundColor: color.withAlpha(25),
                      valueColor: AlwaysStoppedAnimation(color),
                      strokeCap: StrokeCap.round,
                    ),
                    Text(goal.emoji, style: const TextStyle(fontSize: 20)),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(goal.name, style: AppTheme.titleMedium),
                        if (goal.isComplete) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: AppTheme.safeGreen.withAlpha(25), borderRadius: BorderRadius.circular(20)),
                            child: Text('Done ✓', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.safeGreen)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('\$${goal.saved.toStringAsFixed(2)} / \$${goal.target.toStringAsFixed(2)}', style: AppTheme.bodyMedium.copyWith(fontSize: 12)),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (v) { if (v == 'delete') onDelete(); },
                itemBuilder: (_) => [const PopupMenuItem(value: 'delete', child: Text('Delete'))],
                child: const Icon(Icons.more_vert_rounded, color: AppTheme.textSecondary, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: goal.progress,
              backgroundColor: color.withAlpha(18),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                goal.isComplete ? 'Goal reached! 🎉' : '\$${goal.remaining.toStringAsFixed(2)} to go',
                style: AppTheme.labelSmall.copyWith(color: color, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text('${(goal.progress * 100).toStringAsFixed(0)}%', style: AppTheme.labelSmall.copyWith(fontWeight: FontWeight.w700, color: color)),
            ],
          ),
          if (!goal.isComplete) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: OutlinedButton(
                onPressed: onAddFunds,
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: AppTheme.primary),
                ),
                child: Text('+ Add Funds', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primary)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
