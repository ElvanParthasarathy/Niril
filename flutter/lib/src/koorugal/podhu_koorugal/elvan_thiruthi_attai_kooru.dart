import 'package:flutter/material.dart';

/// திருத்தி அட்டை கூறு — Editor card matching React's ElvanCard component.
///
/// Features:
/// - `borderRadius: 24` (default, customizable)
/// - No shadow, no border
/// - Light: white bg, Dark: `rgba(255,255,255,0.03)`
/// - Optional tap with scale animation
class ElvanThiruthiAttai extends StatelessWidget {
  const ElvanThiruthiAttai({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.padding,
    this.onTap,
    this.margin,
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final container = Material(
      type: MaterialType.card,
      color: isDark
          ? Colors.white.withValues(alpha: 0.03)
          : Colors.white,
      borderRadius: BorderRadius.circular(borderRadius),
      animationDuration: const Duration(milliseconds: 200),
      child: Container(
        margin: margin,
        padding: padding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: child,
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: container,
      );
    }

    return container;
  }
}

/// Item card (used inside line items) — smaller radius, different bg.
///
/// Matches React's item row: `borderRadius: 16px`,
/// `bgcolor: dark ? 'action.hover' : 'background.paper'`
class ElvanUrupadiAttai extends StatelessWidget {
  const ElvanUrupadiAttai({
    super.key,
    required this.child,
    this.padding,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: isDark
            ? cs.surfaceContainerHighest
            : cs.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );
  }
}
