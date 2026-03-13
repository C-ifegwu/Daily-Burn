import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/budget_provider.dart';

// ── Simple in-memory notification model ──────────────────────────────────────
class AppNotification {
  final String id;
  final String title;
  final String body;
  final String emoji;
  final DateTime time;
  final Color color;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.emoji,
    required this.time,
    required this.color,
    this.isRead = false,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<AppNotification> _notifications;

  @override
  void initState() {
    super.initState();
    final budget = context.read<BudgetProvider>();
    _notifications = _generateNotifications(budget);
  }

  List<AppNotification> _generateNotifications(BudgetProvider budget) {
    final now = DateTime.now();
    return [
      if (budget.todaySpentPct > 0.8)
        AppNotification(
          id: 'overspend_today',
          title: 'Daily Limit Alert',
          body: 'You\'ve used ${(budget.todaySpentPct * 100).toStringAsFixed(0)}% of today\'s \$${budget.adjustedDailyLimit.toStringAsFixed(2)} limit.',
          emoji: '🚨',
          time: now.subtract(const Duration(minutes: 5)),
          color: AppTheme.dangerRed,
        ),
      AppNotification(
        id: 'daily_summary',
        title: 'Daily Summary',
        body: 'You spent \$${budget.todaySpent.toStringAsFixed(2)} today. \$${budget.todayRemaining.toStringAsFixed(2)} remains for the day.',
        emoji: '📊',
        time: now.subtract(const Duration(hours: 1)),
        color: AppTheme.primary,
      ),
      if (budget.currentStreak >= 3)
        AppNotification(
          id: 'streak',
          title: '${budget.currentStreak}-Day Streak! 🔥',
          body: 'You\'ve stayed under your daily limit for ${budget.currentStreak} days in a row. Keep it up!',
          emoji: '🏆',
          time: now.subtract(const Duration(hours: 6)),
          color: AppTheme.warningYellow,
        ),
      AppNotification(
        id: 'monthly_progress',
        title: 'Monthly Progress',
        body: '\$${budget.totalSpentThisMonth.toStringAsFixed(2)} spent of \$${budget.monthlyTotal.toStringAsFixed(2)}. ${budget.daysLeft} days left.',
        emoji: '📅',
        time: now.subtract(const Duration(hours: 8)),
        color: AppTheme.safeGreen,
      ),
      AppNotification(
        id: 'adjusted_limit',
        title: 'Daily Limit Updated',
        body: 'Your adjusted daily limit is now \$${budget.adjustedDailyLimit.toStringAsFixed(2)} based on remaining budget.',
        emoji: '⚡',
        time: now.subtract(const Duration(days: 1)),
        color: AppTheme.primary,
        isRead: true,
      ),
      AppNotification(
        id: 'weekly_tip',
        title: 'Spending Tip',
        body: 'Your top category this week is ${budget.topCategory}. Try a no-spend day to stretch your budget further.',
        emoji: '💡',
        time: now.subtract(const Duration(days: 1, hours: 3)),
        color: AppTheme.warningYellow,
        isRead: true,
      ),
      AppNotification(
        id: 'welcome',
        title: 'Welcome to Daily Burn 👋',
        body: 'Your budget is set up! Track every expense to stay on top of your daily burn.',
        emoji: '🔥',
        time: now.subtract(const Duration(days: 3)),
        color: AppTheme.primary,
        isRead: true,
      ),
    ];
  }

  void _markAllRead() {
    setState(() {
      for (final n in _notifications) {
        n.isRead = true;
      }
    });
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final unread = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        title: Column(
          children: [
            const Text('Notifications'),
            if (unread > 0)
              Text('$unread unread', style: AppTheme.labelSmall.copyWith(fontSize: 11, color: AppTheme.primary)),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: _markAllRead,
              child: Text('Mark all read', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primary)),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmpty()
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              itemCount: _notifications.length,
              itemBuilder: (ctx, i) => _NotifCard(
                notif: _notifications[i],
                timeAgo: _timeAgo(_notifications[i].time),
                onTap: () => setState(() => _notifications[i].isRead = true),
              ),
            ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔔', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text('All caught up!', style: AppTheme.headlineMedium),
          const SizedBox(height: 6),
          Text('No notifications right now.', style: AppTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final AppNotification notif;
  final String timeAgo;
  final VoidCallback onTap;
  const _NotifCard({required this.notif, required this.timeAgo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notif.isRead ? AppTheme.surface : notif.color.withAlpha(10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notif.isRead ? AppTheme.border : notif.color.withAlpha(60),
            width: notif.isRead ? 1 : 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: notif.color.withAlpha(20), borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(notif.emoji, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(notif.title, style: AppTheme.titleMedium.copyWith(fontSize: 14))),
                      Text(timeAgo, style: AppTheme.labelSmall.copyWith(fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(notif.body, style: AppTheme.bodyMedium.copyWith(fontSize: 12, height: 1.45)),
                ],
              ),
            ),
            if (!notif.isRead)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Container(width: 8, height: 8, decoration: BoxDecoration(color: notif.color, shape: BoxShape.circle)),
              ),
          ],
        ),
      ),
    );
  }
}
