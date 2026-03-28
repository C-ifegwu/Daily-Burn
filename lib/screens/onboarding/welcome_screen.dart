import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  static const _features = [
    (
      '🔥',
      'Zero-effort tracking',
      'Log expenses in seconds — no spreadsheets.'
    ),
    (
      '⚡',
      'Auto-if-you-overspend',
      'We recalculate your daily limit automatically.'
    ),
    ('🔒', 'Set the limit', 'Your daily burn adapts so you never run dry.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: ListView(
                children: [
                  const SizedBox(height: 48),
                  // Icon
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppTheme.primaryLight, AppTheme.primaryDark],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                        child: Text('🔥', style: TextStyle(fontSize: 36))),
                  ),
                  const SizedBox(height: 28),
                  // Heading
                  Text('Budgeting,\nsimplified.',
                      style: AppTheme.headlineLarge),
                  const SizedBox(height: 12),
                  Text(
                    'Daily Burn calculates a dynamic daily limit, so you always know exactly what you can spend today.',
                    style: AppTheme.bodyMedium.copyWith(height: 1.6),
                  ),
                  const SizedBox(height: 36),
                  // Features
                  ..._features.map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppTheme.background,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                                child: Text(f.$1,
                                    style: const TextStyle(fontSize: 22))),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(f.$2, style: AppTheme.titleMedium),
                                const SizedBox(height: 2),
                                Text(f.$3,
                                    style: AppTheme.bodyMedium
                                        .copyWith(fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: OutlinedButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/login'),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppTheme.border),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              backgroundColor: Colors.white,
                            ),
                            child: Text(
                              "Log In",
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/signup'),
                            child: Text(
                              "Sign Up",
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
