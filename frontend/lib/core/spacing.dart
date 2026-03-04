import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  // Vertical Spacing (Heights)
  static const SizedBox verticalTiny = SizedBox(height: 8.0);
  static const SizedBox verticalSmall = SizedBox(height: 16.0); // Between Title & Tagline
  static const SizedBox verticalMedium = SizedBox(height: 32.0); // Between Logo & Title
  static const SizedBox verticalLarge = SizedBox(height: 48.0);  // Before Loader
  static const SizedBox verticalExtraLarge = SizedBox(height: 64.0);

  // Horizontal Spacing (Widths)
  static const SizedBox horizontalSmall = SizedBox(width: 8.0);
  static const SizedBox horizontalMedium = SizedBox(width: 16.0);

  // Common Padding/Margins
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 40.0);
  static const EdgeInsets elementPadding = EdgeInsets.all(12.0);
}