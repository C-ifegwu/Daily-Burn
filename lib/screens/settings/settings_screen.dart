import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../providers/budget_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _dailyReminders = true;
  bool _overspendAlerts = true;
  bool _weeklySummary = false;

  @override
  Widget build(BuildContext context) {
    final budget = context.watch<BudgetProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        title: const Text('Settings'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Profile card ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primaryLight, AppTheme.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text('A', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Alex', style: AppTheme.titleMedium.copyWith(fontSize: 18)),
                        Text('alex@university.edu', style: AppTheme.bodyMedium.copyWith(fontSize: 13)),
                      ],
                    ),
                  ),
                  const Icon(Icons.edit_rounded, color: AppTheme.textSecondary, size: 18),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Budget Summary ────────────────────────────────────
            _SectionTitle('Budget'),
            _InfoCard(children: [
              _InfoRow(label: 'Monthly Total', value: '\$${budget.monthlyTotal.toStringAsFixed(2)}'),
              _InfoRow(label: 'Start Date', value: DateFormat('MMM d, y').format(budget.startDate)),
              _InfoRow(label: 'Daily Limit', value: '\$${budget.adjustedDailyLimit.toStringAsFixed(2)}/day'),
              _InfoRow(label: 'Days Remaining', value: '${budget.daysLeft} days'),
            ]),
            const SizedBox(height: 20),

            // ── Tools & Features ──────────────────────────────────
            _SectionTitle('Tools & Features'),
            _InfoCard(children: [
              _ActionRow(
                icon: Icons.notifications_none_rounded,
                label: 'Notifications',
                subtitle: 'Alerts and spending nudges',
                color: AppTheme.primary,
                onTap: () => Navigator.pushNamed(context, '/notifications'),
              ),
              _ActionRow(
                icon: Icons.track_changes_rounded,
                label: 'My Goals',
                subtitle: 'Track your savings goals',
                color: AppTheme.primary,
                onTap: () => Navigator.pushNamed(context, '/goals'),
              ),
              _ActionRow(
                icon: Icons.lock_rounded,
                label: 'Savings Lock',
                subtitle: 'Protect money from spending',
                color: AppTheme.primary,
                onTap: () => Navigator.pushNamed(context, '/savings-lock'),
              ),
              _ActionRow(
                icon: Icons.bar_chart_rounded,
                label: 'Insights',
                subtitle: 'Charts & spending breakdown',
                color: AppTheme.primary,
                onTap: () => Navigator.pushNamed(context, '/insights'),
              ),
              _ActionRow(
                icon: Icons.trending_up_rounded,
                label: 'Budget Forecast',
                subtitle: 'Projected spend & on-track status',
                color: AppTheme.primary,
                onTap: () => Navigator.pushNamed(context, '/forecast'),
              ),
              _ActionRow(
                icon: Icons.calendar_month_rounded,
                label: 'Monthly Review',
                subtitle: 'How did you do this month?',
                color: AppTheme.primary,
                onTap: () => Navigator.pushNamed(context, '/monthly-review'),
              ),
            ]),
            const SizedBox(height: 20),

            // ── Preferences ───────────────────────────────────────
            _SectionTitle('Preferences'),
            _InfoCard(children: [
              _ToggleRow(label: 'Daily Reminders', value: _dailyReminders, onChanged: (v) => setState(() => _dailyReminders = v)),
              _ToggleRow(label: 'Overspend Alerts', value: _overspendAlerts, onChanged: (v) => setState(() => _overspendAlerts = v)),
              _ToggleRow(label: 'Weekly Summary', value: _weeklySummary, onChanged: (v) => setState(() => _weeklySummary = v)),
            ]),
            const SizedBox(height: 20),

            // ── Budget Setup ──────────────────────────────────────
            _SectionTitle('Budget Setup'),
            _InfoCard(children: [
              _ActionRow(
                icon: Icons.edit_rounded,
                label: 'Edit Monthly Budget',
                color: AppTheme.primary,
                onTap: () => Navigator.pushNamed(context, '/input-budget'),
              ),
              _ActionRow(
                icon: Icons.calendar_today_rounded,
                label: 'Change Start Date',
                color: AppTheme.primary,
                onTap: () => Navigator.pushNamed(context, '/select-date'),
              ),
              _ActionRow(
                icon: Icons.delete_outline_rounded,
                label: 'Reset All Data',
                color: AppTheme.dangerRed,
                onTap: () => _showResetDialog(context),
              ),
            ]),
            const SizedBox(height: 20),

            // ── App info ──────────────────────────────────────────
            _SectionTitle('App'),
            _InfoCard(children: [
              _InfoRow(label: 'Version', value: 'v1.0.0'),
              _InfoRow(label: 'Built for', value: 'University Students'),
            ]),
          ],
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Reset Everything?', style: AppTheme.headlineMedium),
        content: Text('This will clear all your budget data and transactions.', style: AppTheme.bodyMedium),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Reset', style: TextStyle(color: AppTheme.dangerRed, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: AppTheme.labelSmall.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: children.asMap().entries.map((e) => Column(
          children: [
            e.value,
            if (e.key < children.length - 1)
              const Divider(color: AppTheme.border, height: 0, indent: 16),
          ],
        )).toList(),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Text(label, style: AppTheme.bodyMedium),
          const Spacer(),
          Text(value, style: AppTheme.titleMedium.copyWith(fontSize: 14)),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleRow({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Text(label, style: AppTheme.bodyMedium),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primary,
            activeThumbColor: Colors.white,
            inactiveThumbColor: AppTheme.textTertiary,
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final String label;
  final String? subtitle;
  final Color color;
  final VoidCallback onTap;
  final IconData? icon;
  const _ActionRow({required this.label, required this.color, required this.onTap, this.subtitle, this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: color.withAlpha(18), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTheme.bodyMedium.copyWith(color: color, fontWeight: FontWeight.w500)),
                  if (subtitle != null)
                    Text(subtitle!, style: AppTheme.labelSmall.copyWith(fontSize: 11)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color.withAlpha(160), size: 18),
          ],
        ),
      ),
    );
  }
}
