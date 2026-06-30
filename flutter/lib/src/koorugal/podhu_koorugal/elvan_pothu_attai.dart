import 'package:flutter/material.dart';

/// A completely reusable Elvan Card component.
/// It wraps the content in a Material + InkWell to provide the native
/// Android ripple effect upon tap. It also smoothly animates background
/// color changes when `isSelected` changes.
class ElvanPothuAttai extends StatelessWidget {
  const ElvanPothuAttai({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 24.0,
  });

  /// The inner content of the card
  final Widget child;

  /// Triggered on tap
  final VoidCallback? onTap;

  /// Triggered on long press
  final VoidCallback? onLongPress;

  /// Whether the card is selected (changes the background color)
  final bool isSelected;

  /// Inner padding for the content
  final EdgeInsetsGeometry padding;

  /// Corner border radius
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultBg = isDark ? const Color(0xFF111111) : Colors.white;
    final selectedBg = isDark
        ? const Color(0xFF1A1A1A)
        : Colors.black.withValues(alpha: 0.04);
    
    final bgColor = isSelected ? selectedBg : defaultBg;

    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(begin: bgColor, end: bgColor),
      duration: const Duration(milliseconds: 200),
      builder: (context, color, _) {
        return Material(
          color: color,
          borderRadius: BorderRadius.circular(borderRadius),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Padding(
              padding: padding,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
