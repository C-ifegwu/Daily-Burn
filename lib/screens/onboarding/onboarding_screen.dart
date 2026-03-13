// Legacy onboarding screen replaced by new welcome_screen → input_budget_screen → select_date_screen flow.
// This file is kept as a placeholder to prevent import errors from any cached build artifacts.
// It is NOT used in navigation anymore.
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: const Center(child: Text('Redirecting...')),
    );
  }
}
