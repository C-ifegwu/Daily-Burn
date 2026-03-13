import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class AddExpenseScreen extends StatelessWidget {
  const AddExpenseScreen({super.key});

  static const _categories = [
    ('Food', '🍔', AppTheme.catFood),
    ('Transport', '🚌', AppTheme.catTransport),
    ('Fun', '🎮', AppTheme.catFun),
    ('Misc', '🛍️', AppTheme.catMisc),
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text('What was\nthis for?', style: AppTheme.headlineLarge),
              const SizedBox(height: 8),
              Text('Choose a category to continue', style: AppTheme.bodyMedium),
              const SizedBox(height: 40),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.15,
                physics: const NeverScrollableScrollPhysics(),
                children: _categories.map(
                  (c) => _CategoryCard(
                    name: c.$1,
                    emoji: c.$2,
                    color: c.$3,
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/amount-input',
                      arguments: {'category': c.$1},
                    ),
                  ),
                ).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final String name;
  final String emoji;
  final Color color;
  final VoidCallback onTap;
  const _CategoryCard({required this.name, required this.emoji, required this.color, required this.onTap});

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween(begin: 1.0, end: 0.94).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          decoration: BoxDecoration(
            color: widget.color.withAlpha(20),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: widget.color.withAlpha(60), width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.emoji, style: const TextStyle(fontSize: 44)),
              const SizedBox(height: 12),
              Text(
                widget.name,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 3,
                width: 24,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
