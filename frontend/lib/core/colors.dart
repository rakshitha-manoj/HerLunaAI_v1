import 'package:flutter/material.dart';

class AppColors {
  // Purely static class to prevent instantiation
  AppColors._();

  /// Background: Light warm off-white / Neutral cream
  /// (First column in the palette)
  static const Color background = Color(0xFFEBE3DE);

  /// Primary Dark: Deep muted purple/eggplant
  /// (Second column in the palette - ideal for primary text or dark accents)
  static const Color primaryDark = Color(0xFF534354);

  /// Primary Muted: Medium dusty purple
  /// (Third column in the palette - ideal for the "HerLuna AI" title)
  static const Color primaryMuted = Color(0xFF7B6B7C);

  /// Soft Lavender: Light pastel purple
  /// (Fourth column in the palette - ideal for subtle UI elements or secondary backgrounds)
  static const Color lavender = Color(0xFFD6CDE1);

  /// Mint/Seafoam: Soft sage green
  /// (Fifth column in the palette - ideal for accent highlights or "pattern" icons)
  static const Color accentMint = Color(0xFFC7E2D9);

  // Text Specific Mappings
  static const Color textMain = primaryDark;
  static const Color textSecondary = primaryMuted;
  static const Color taglineGrey = Color(0xFF8C8C8C); // Standard soft grey for subtext
}