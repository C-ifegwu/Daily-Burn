import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class AddExpenseScreen extends StatelessWidget {
  const AddExpenseScreen({super.key});

  static const List<
      ({
        String name,
        String emoji,
        String subtitle,
        Color color,
      })> _categories = <({
    String name,
    String emoji,
    String subtitle,
    Color color,
  })>[
    (
      name: 'Food & Snacks',
      emoji: '🍔',
      subtitle: 'Meals, snacks, coffee',
      color: AppTheme.catFood,
    ),
    (
      name: 'Transport',
      emoji: '🚌',
      subtitle: 'Bus, bike, ride fares',
      color: AppTheme.catTransport,
    ),
    (
      name: 'Data & Airtime',
      emoji: '📶',
      subtitle: 'Bundles and recharge',
      color: AppTheme.catFun,
    ),
    (
      name: 'Books & Supplies',
      emoji: '📚',
      subtitle: 'Prints, stationery, books',
      color: AppTheme.catMisc,
    ),
    (
      name: 'Hostel & Utilities',
      emoji: '🏠',
      subtitle: 'Rent, light, water',
      color: Color(0xFF5B8CFF),
    ),
    (
      name: 'Health & Pharmacy',
      emoji: '💊',
      subtitle: 'Clinic and medicine',
      color: Color(0xFF3CB179),
    ),
    (
      name: 'Social & Events',
      emoji: '🎉',
      subtitle: 'Clubs, hangouts, outings',
      color: Color(0xFFFF8A65),
    ),
    (
      name: 'Emergency',
      emoji: '🆘',
      subtitle: 'Unexpected expenses',
      color: Color(0xFFE46D6D),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Select Category'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('What was\nthis for?', style: AppTheme.headlineLarge),
                  const SizedBox(height: 8),
                  Text('Pick the closest category to continue',
                      style: AppTheme.bodyMedium),
                  const SizedBox(height: 20),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 260,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      mainAxisExtent: 132,
                    ),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final c = _categories[index];
                      return _CategoryCard(
                        name: c.name,
                        emoji: c.emoji,
                        subtitle: c.subtitle,
                        color: c.color,
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/amount-input',
                          arguments: {'category': c.name},
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final String name;
  final String emoji;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _CategoryCard({
    required this.name,
    required this.emoji,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween(begin: 1.0, end: 0.94)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: widget.color.withAlpha(20),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: widget.color.withAlpha(60), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(widget.emoji, style: const TextStyle(fontSize: 28)),
                  const Spacer(),
                  Icon(Icons.arrow_forward_rounded,
                      color: widget.color, size: 18),
                ],
              ),
              const Spacer(),
              Text(
                widget.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.bodyMedium.copyWith(fontSize: 12),
              ),
              const SizedBox(height: 8),
              Container(
                height: 4,
                width: 30,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
