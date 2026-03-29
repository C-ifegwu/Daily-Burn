import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../providers/budget_provider.dart';

class SelectDateScreen extends StatefulWidget {
  const SelectDateScreen({super.key});

  @override
  State<SelectDateScreen> createState() => _SelectDateScreenState();
}

class _SelectDateScreenState extends State<SelectDateScreen> {
  DateTime _selectedDate = DateTime.now();
  final DateTime _focusedMonth = DateTime.now();
  bool _isNavigating = false;

  List<DateTime> get _calendarDays {
    final first = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final startWeekday = first.weekday % 7; // 0=Sun
    final start = first.subtract(Duration(days: startWeekday));
    return List.generate(42, (i) => start.add(Duration(days: i)));
  }

  DateTime get _endDate => DateTime(
        _selectedDate.year,
        _selectedDate.month + 1,
        _selectedDate.day,
      );

  void _continueToNextStep(BudgetProvider budget) {
    if (_isNavigating) {
      return;
    }

    _isNavigating = true;
    context.read<BudgetProvider>().setupBudget(
          monthlyTotal: budget.monthlyTotal,
          startDate: _selectedDate,
        );
    Navigator.pushNamed(context, '/initial-limit').then((_) {
      if (mounted) {
        _isNavigating = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final budget = context.watch<BudgetProvider>();
    final dayCount = _endDate.difference(_selectedDate).inDays;

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
            Text('Step 2 of 3', style: AppTheme.labelSmall),
            const SizedBox(height: 2),
            LinearProgressIndicator(
              value: 0.66,
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
            final bool compactWidth = constraints.maxWidth < 420;
            final double horizontalPadding = compactWidth ? 16 : 20;

              // Calendar card
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Month header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Row(
                        children: [
                          Text(
                            DateFormat('MMMM yyyy').format(_focusedMonth),
                            style: AppTheme.titleMedium,
                          ),
                          const Spacer(),
                          const Icon(Icons.calendar_month_rounded, color: AppTheme.primary, size: 20),
                        ],
                      ),
                    ),
                    // Day headers
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: ['Su','Mo','Tu','We','Th','Fr','Sa'].map((d) => Expanded(
                          child: Center(
                            child: Text(d, style: AppTheme.labelSmall.copyWith(fontWeight: FontWeight.w700)),
                          ),
                        )).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Calendar card
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(10),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Month header
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                              child: Row(
                                children: [
                                  Text(
                                    DateFormat('MMMM yyyy')
                                        .format(_focusedMonth),
                                    style: AppTheme.titleMedium,
                                  ),
                                  const Spacer(),
                                  Icon(Icons.calendar_month_rounded,
                                      color: AppTheme.primary, size: 20),
                                ],
                              ),
                            ),
                            // Day headers
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                children: [
                                  'Su',
                                  'Mo',
                                  'Tu',
                                  'We',
                                  'Th',
                                  'Fr',
                                  'Sa'
                                ]
                                    .map((d) => Expanded(
                                          child: Center(
                                            child: Text(d,
                                                style: AppTheme.labelSmall
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.w700)),
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Grid
                            GridView.count(
                              crossAxisCount: 7,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              childAspectRatio: 1,
                              children: _calendarDays.map((day) {
                                final isCurrentMonth =
                                    day.month == _focusedMonth.month;
                                final isSelected =
                                    day.year == _selectedDate.year &&
                                        day.month == _selectedDate.month &&
                                        day.day == _selectedDate.day;
                                final isToday =
                                    day.year == DateTime.now().year &&
                                        day.month == DateTime.now().month &&
                                        day.day == DateTime.now().day;

              const SizedBox(height: 16),
              // Summary row
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.today_rounded, color: AppTheme.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${DateFormat('MMM d').format(_selectedDate)} → ${DateFormat('MMM d').format(_endDate)}',
                        style: AppTheme.titleMedium.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isNavigating
                              ? null
                              : () => _continueToNextStep(budget),
                          child: const Text('Continue to Step 3'),
                        ),
                      ),
                      const SizedBox(height: 28),
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
