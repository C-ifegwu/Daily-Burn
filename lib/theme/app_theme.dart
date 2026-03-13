import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Brand Colors ──────────────────────────────────────────────
  static const Color primary = Color(0xFFFF6B35);      // Orange
  static const Color primaryLight = Color(0xFFFF8F65);
  static const Color primaryDark = Color(0xFFE04E1A);

  // ── Budget State Colors ───────────────────────────────────────
  static const Color safeGreen = Color(0xFF34C759);    // Under 50%
  static const Color warningYellow = Color(0xFFFFB84D); // 50–80%
  static const Color dangerRed = Color(0xFFFF3B30);    // Over 80%

  // ── Neutrals ─────────────────────────────────────────────────
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F2F5);
  static const Color border = Color(0xFFE8EAED);

  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFFB0B7C3);

  // ── Category Colors ───────────────────────────────────────────
  static const Color catFood = Color(0xFFFF6B6B);
  static const Color catTransport = Color(0xFF4ECDC4);
  static const Color catFun = Color(0xFFFFE66D);
  static const Color catMisc = Color(0xFFA78BFA);

  // ── Theme ─────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: safeGreen,
        surface: surface,
        error: dangerRed,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        centerTitle: true,
        foregroundColor: textPrimary,
        titleTextStyle: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(color: textTertiary, fontSize: 15),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  // ── Budget State Helper ───────────────────────────────────────
  static Color budgetColor(double pct) {
    if (pct <= 0.5) return safeGreen;
    if (pct <= 0.8) return warningYellow;
    return dangerRed;
  }

  static String budgetStateLabel(double pct) {
    if (pct <= 0.5) return 'Safe State';
    if (pct <= 0.8) return 'Caution';
    return 'Warning';
  }

  // ── Text Styles ───────────────────────────────────────────────
  static TextStyle get heroAmount => GoogleFonts.inter(
        fontSize: 52,
        fontWeight: FontWeight.w800,
        color: textPrimary,
        letterSpacing: -2.5,
        height: 1.0,
      );

  static TextStyle get headlineLarge => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: textPrimary,
        letterSpacing: -1,
        height: 1.15,
      );

  static TextStyle get headlineMedium => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.5,
      );

  static TextStyle get titleMedium => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.2,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        letterSpacing: -0.1,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textSecondary,
        letterSpacing: 0.1,
      );

  // ── Category Maps ─────────────────────────────────────────────
  static Map<String, Color> get categoryColors => {
        'Food': catFood,
        'Transport': catTransport,
        'Fun': catFun,
        'Misc': catMisc,
      };

  static Map<String, IconData> get categoryIcons => {
        'Food': Icons.restaurant_rounded,
        'Transport': Icons.directions_bus_rounded,
        'Fun': Icons.sports_esports_rounded,
        'Misc': Icons.shopping_bag_rounded,
      };

  static Map<String, String> get categoryEmojis => {
        'Food': '🍔',
        'Transport': '🚌',
        'Fun': '🎮',
        'Misc': '🛍️',
      };
}
