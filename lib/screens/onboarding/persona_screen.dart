// Legacy persona screen — replaced by the new onboarding flow.
// Kept to avoid dangling imports.
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class PersonaScreen extends StatelessWidget {
  const PersonaScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: AppTheme.background, body: const Center(child: Text('Redirecting...')));
  }
}
