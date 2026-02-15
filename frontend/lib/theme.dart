import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HerLunaTheme {
  // Light Palette
  static const Color primaryPlum = Color(0xFF5D425D);
  static const Color accentPlum = Color(0xFF8E738E);
  static const Color backgroundBeige = Color(0xFFF9F6F2);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textMain = Color(0xFF2D2D2D);

  // Dark Palette
  static const Color darkBackground = Color(0xFF1A161A); // Deep plum-charcoal
  static const Color darkCard = Color(0xFF252025); // Slightly lighter surface
  static const Color darkTextMain = Color(0xFFE5DEE5); // Soft lavender-white
  static const Color darkTextMuted = Color(0xFF8E738E); // Reusing accent plum

  static ThemeData get lightTheme => _buildTheme(Brightness.light);
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: isDark ? darkBackground : backgroundBeige,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryPlum,
        brightness: brightness,
        surface: isDark ? darkCard : cardWhite,
        secondaryContainer: primaryPlum.withOpacity(isDark ? 0.3 : 0.15),
      ),
      textTheme: GoogleFonts.quicksandTextTheme().copyWith(
        displayLarge: TextStyle(
          color: isDark ? darkTextMain : textMain,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: isDark ? darkTextMain : textMain,
          fontSize: 16,
        ),
      ),

      // Navigation Bar Logic
      // Navigation Bar Logic
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? darkCard : Colors.white,
        indicatorColor: primaryPlum.withOpacity(isDark ? 0.3 : 0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            // REMOVED 'const' FROM THE LINE BELOW
            return IconThemeData(color: isDark ? Colors.white : primaryPlum);
          }
          // REMOVED 'const' FROM THE LINE BELOW
          return IconThemeData(
            color: isDark ? darkTextMuted : accentPlum.withOpacity(0.6),
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final bool selected = states.contains(WidgetState.selected);
          return GoogleFonts.quicksand(
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            color: selected
                ? (isDark ? Colors.white : primaryPlum)
                : (isDark ? darkTextMuted : accentPlum.withOpacity(0.6)),
          );
        }),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPlum,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
