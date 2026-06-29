import 'package:flutter/material.dart';

/// A native Material button designed specifically for Elvan Editors (Thiruthi).
/// It visually matches the standard text fields (`ElvanThiruthiUlleedu`) 
/// ensuring pixel-perfect consistency (45px height, 20px padding, pill shape).
class ElvanThiruthiPothan extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;
  final double height;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;

  const ElvanThiruthiPothan({
    super.key,
    required this.onTap,
    required this.child,
    this.height = 45.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? (Theme.of(context).colorScheme.brightness == Brightness.light ? Colors.white : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08)),
      borderRadius: BorderRadius.circular(100),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: height,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
