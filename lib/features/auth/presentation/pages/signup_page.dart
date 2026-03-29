import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../theme/app_theme.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_bloc_factory.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  AuthBloc? _authBloc;
  StreamSubscription<AuthState>? _authSubscription;

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _initError;

  @override
  void initState() {
    super.initState();
    try {
      _authBloc = createAuthBloc();
      _authSubscription = _authBloc!.stream.listen(_onAuthStateChanged);
    } catch (error) {
      _initError = _toSetupError(error);
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _authBloc?.close();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _onAuthStateChanged(AuthState state) {
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = state is AuthLoading;
    });

    if (state is AuthAuthenticated) {
      Navigator.pushNamedAndRemoveUntil(
          context, '/input-budget', (route) => false);
      return;
    }

    if (state is AuthFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  }

  void _handleSignup() {
    if (_authBloc == null) {
      _showSetupError();
      return;
    }

    final String name = _nameCtrl.text.trim();
    final String email = _emailCtrl.text.trim();
    final String password = _passCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email and password are required.')),
      );
      return;
    }

    _authBloc!.add(
      SignupRequested(
        email: email,
        password: password,
        displayName: name.isEmpty ? null : name,
      ),
    );
  }

  void _handleGoogleSignup() {
    if (_authBloc == null) {
      _showSetupError();
      return;
    }
    _authBloc!.add(const GoogleSigninRequested());
  }

  void _showSetupError() {
    final String message = _initError ??
        'Authentication is not available right now. Check Firebase setup and try again.';
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String _toSetupError(Object error) {
    final String message = error.toString();
    if (message.contains('[core/no-app]')) {
      return 'Firebase is not configured for this app yet. Run FlutterFire setup and restart.';
    }
    return message.replaceFirst('Exception: ', '');
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData prefixIcon,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.labelSmall),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword && _obscurePassword,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                AppTheme.bodyMedium.copyWith(color: AppTheme.textTertiary),
            prefixIcon: Icon(prefixIcon, color: AppTheme.textSecondary),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppTheme.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.primary, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppTheme.textSecondary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text('Create Account', style: AppTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Join Daily Burn and master your budget.',
                style: AppTheme.bodyMedium,
              ),
              if (_initError != null) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4E5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF6C26B)),
                  ),
                  child: Text(
                    _initError!,
                    style: AppTheme.bodyMedium.copyWith(
                      color: const Color(0xFF7A5200),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 40),
              _buildTextField(
                label: 'Full Name',
                hint: 'Alex Johnson',
                prefixIcon: Icons.person_outline,
                controller: _nameCtrl,
              ),
              _buildTextField(
                label: 'Email Address',
                hint: 'alex@example.com',
                prefixIcon: Icons.email_outlined,
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
              ),
              _buildTextField(
                label: 'Password',
                hint: '••••••••',
                prefixIcon: Icons.lock_outline,
                controller: _passCtrl,
                isPassword: true,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignup,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          'Sign Up',
                          style: GoogleFonts.inter(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _handleGoogleSignup,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.border),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    backgroundColor: Colors.white,
                  ),
                  child: Text(
                    'Sign up with Google',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account?', style: AppTheme.bodyMedium),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, '/login'),
                    child: Text(
                      'Log In',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
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
    );
  }
}
