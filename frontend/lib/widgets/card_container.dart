import 'package:flutter/material.dart';
import '../core/colors.dart';

/// Soft card container with optional selection and tap handler.
class CardContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool isSelected;
  final double borderRadius;

  const CardContainer({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.isSelected = false,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.lavender.withValues(alpha: 0.3)
              : Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: isSelected ? AppColors.primaryDark : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
