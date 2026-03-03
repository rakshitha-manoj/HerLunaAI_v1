import 'package:flutter/material.dart';

/// HerLuna Design System
/// Premium, soft feminine, calm, intelligent aesthetic.
/// Deep muted purple palette with lavender accents.
class HerLunaTheme {
  // ── Color Palette ────────────────────────────────────────────────────
  static const Color primary = Color(0xFF6B4C9A);         // Deep muted purple
  static const Color primaryDark = Color(0xFF523A7A);
  static const Color accent = Color(0xFFB8A5D4);           // Soft lavender
  static const Color accentLight = Color(0xFFE8E0F0);      // Very light lavender
  static const Color background = Color(0xFFF8F5FC);       // Off-white lavender tint
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF2D2838);      // Dark charcoal
  static const Color textSecondary = Color(0xFF8E8999);    // Muted grey
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFB85C5C);            // Soft muted red
  static const Color success = Color(0xFF5C9A7A);          // Calm green
  static const Color surfaceLight = Color(0xFFF2ECF9);     // Cards hover/selected
  static const Color divider = Color(0xFFE8E0F0);

  // ── Gradient ─────────────────────────────────────────────────────────
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C5DAF), Color(0xFF9B7BC9)],
  );

  static const LinearGradient subtleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF2ECF9), Color(0xFFE8E0F0)],
  );

  // ── Typography ───────────────────────────────────────────────────────
  static const String fontFamily = 'Roboto';

  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.4,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textOnPrimary,
    letterSpacing: 0.3,
  );

  static const TextStyle labelText = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: textSecondary,
    letterSpacing: 0.2,
  );

  // ── Spacing ──────────────────────────────────────────────────────────
  static const double horizontalPadding = 24.0;
  static const double verticalSpacing = 24.0;
  static const double cardRadius = 18.0;
  static const double buttonRadius = 14.0;
  static const double inputRadius = 12.0;

  // ── Shadows ──────────────────────────────────────────────────────────
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: const Color(0xFF6B4C9A).withOpacity(0.06),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF6B4C9A).withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, 2),
    ),
  ];

  // ── ThemeData ────────────────────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    brightness: Brightness.light,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: accent,
      surface: cardColor,
      error: error,
      onPrimary: textOnPrimary,
      onSurface: textPrimary,
      onSecondary: textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: heading3,
      iconTheme: IconThemeData(color: textPrimary),
    ),
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF5F1FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputRadius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputRadius),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      hintStyle: bodyMedium,
      labelStyle: labelText,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: textOnPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
        textStyle: buttonText,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: cardColor,
      selectedItemColor: primary,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      elevation: 0,
      selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
    ),
    dividerColor: divider,
    dividerTheme: const DividerThemeData(color: divider, thickness: 0.5),
  );
}

// ── Reusable Widgets ──────────────────────────────────────────────────────

/// Full-width primary button
class HerLunaButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const HerLunaButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(text),
      ),
    );
  }
}

/// Soft card container
class HerLunaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool isSelected;

  const HerLunaCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? HerLunaTheme.surfaceLight : HerLunaTheme.cardColor,
          borderRadius: BorderRadius.circular(HerLunaTheme.cardRadius),
          border: Border.all(
            color: isSelected ? HerLunaTheme.primary : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: HerLunaTheme.cardShadow,
        ),
        child: child,
      ),
    );
  }
}

/// Selection chip for age range / options
class HerLunaChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const HerLunaChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? HerLunaTheme.accentLight : HerLunaTheme.cardColor,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? HerLunaTheme.primary : HerLunaTheme.divider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? HerLunaTheme.primary : HerLunaTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}
