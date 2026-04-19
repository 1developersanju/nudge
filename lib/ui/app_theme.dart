import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Dark Obsidian Sanctuary Tokens
  static const Color _darkPrimary = Color(0xFFD2CEFF);
  static const Color _darkPrimaryContainer = Color(0xFFB4B0FB);
  static const Color _darkOnPrimary = Color(0xFF2B2769);

  static const Color _darkSurface = Color(0xFF131315);
  static const Color _darkSurfaceContainerLowest = Color(0xFF0E0E10);
  static const Color _darkSurfaceContainerLow = Color(0xFF1B1B1D);
  static const Color _darkSurfaceContainer = Color(0xFF201F21);
  static const Color _darkSurfaceContainerHigh = Color(0xFF2A2A2C);
  static const Color _darkSurfaceContainerHighest = Color(0xFF353437);

  static const Color _darkOnSurface = Color(0xFFE5E1E4);
  static const Color _darkOnSurfaceVariant = Color(0xFFC8C5D1);
  static const Color _darkOutlineVariant = Color(0xFF474650);

  // Light Paper White Tokens
  static const Color _lightPrimary = Color(0xFF38318B); // Deeper purple primary
  static const Color _lightPrimaryContainer = Color(
    0xFF221C61,
  ); // Very dark purple for texts
  static const Color _lightOnPrimary = Colors.white;

  static const Color _lightSurface = Color(0xFFFCFAFF);
  static const Color _lightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color _lightSurfaceContainerLow = Color(0xFFF7F5FC);
  static const Color _lightSurfaceContainer = Color(0xFFF1EFF6);
  static const Color _lightSurfaceContainerHigh = Color(0xFFEBE9F0);
  static const Color _lightSurfaceContainerHighest = Color(0xFFE5E3EA);

  static const Color _lightOnSurface = Color(0xFF131315);
  static const Color _lightOnSurfaceVariant = Color(0xFF474650);
  static const Color _lightOutlineVariant = Color(0xFFC8C5D1);

  // Context-aware getters
  static Color primary(BuildContext context) =>
      Theme.of(context).colorScheme.primary;
  static Color primaryContainer(BuildContext context) =>
      Theme.of(context).colorScheme.primaryContainer;
  static Color onPrimary(BuildContext context) =>
      Theme.of(context).colorScheme.onPrimary;

  static Color surface(BuildContext context) =>
      Theme.of(context).colorScheme.surface;
  static Color surfaceContainerLowest(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainerLowest;
  static Color surfaceContainerLow(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainerLow;
  static Color surfaceContainer(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainer;
  static Color surfaceContainerHigh(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainerHigh;
  static Color surfaceContainerHighest(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainerHighest;

  static Color outlineVariant(BuildContext context) =>
      Theme.of(context).colorScheme.outlineVariant;

  // Fallbacks for easy access
  static Color card(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainerHigh;
  static Color muted(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;
  static Color ink(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  static ThemeData _build(Brightness brightness, ColorScheme cs) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: cs,
      splashFactory: InkRipple.splashFactory,
      scaffoldBackgroundColor: cs.surface,
      textTheme: GoogleFonts.manropeTextTheme(
        ThemeData(brightness: brightness).textTheme,
      ).apply(bodyColor: cs.onSurface, displayColor: cs.onSurface),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: cs.onSurface,
      ),
    );
    return base;
  }

  static ThemeData dark() {
    final cs =
        const ColorScheme.dark(
          primary: _darkPrimary,
          primaryContainer: _darkPrimaryContainer,
          onPrimary: _darkOnPrimary,
          surface: _darkSurface,
          onSurface: _darkOnSurface,
          onSurfaceVariant: _darkOnSurfaceVariant,
          outlineVariant: _darkOutlineVariant,
        ).copyWith(
          surfaceContainerLowest: _darkSurfaceContainerLowest,
          surfaceContainerLow: _darkSurfaceContainerLow,
          surfaceContainer: _darkSurfaceContainer,
          surfaceContainerHigh: _darkSurfaceContainerHigh,
          surfaceContainerHighest: _darkSurfaceContainerHighest,
        );
    return _build(Brightness.dark, cs);
  }

  static ThemeData light() {
    final cs =
        const ColorScheme.light(
          primary: _lightPrimary,
          primaryContainer: _lightPrimaryContainer,
          onPrimary: _lightOnPrimary,
          surface: _lightSurface,
          onSurface: _lightOnSurface,
          onSurfaceVariant: _lightOnSurfaceVariant,
          outlineVariant: _lightOutlineVariant,
        ).copyWith(
          surfaceContainerLowest: _lightSurfaceContainerLowest,
          surfaceContainerLow: _lightSurfaceContainerLow,
          surfaceContainer: _lightSurfaceContainer,
          surfaceContainerHigh: _lightSurfaceContainerHigh,
          surfaceContainerHighest: _lightSurfaceContainerHighest,
        );
    return _build(Brightness.light, cs);
  }
}
