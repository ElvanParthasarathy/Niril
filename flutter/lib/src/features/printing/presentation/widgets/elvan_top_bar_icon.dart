import 'package:flutter/material.dart';

/// A highly optimized custom icon button for the Elvan Top Bar.
/// It uses InkResponse directly to draw a perfect circular ripple
/// without any of the forced padding or stadium shape restrictions of Material 3's IconButton.
class ElvanTopBarIcon extends StatefulWidget {
  const ElvanTopBarIcon({
    super.key,
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  State<ElvanTopBarIcon> createState() => _ElvanTopBarIconState();
}

class _ElvanTopBarIconState extends State<ElvanTopBarIcon> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 26,
        height: 26, // Exact tap target size to prevent overlap
        child: OverflowBox(
          maxWidth: 54,
          maxHeight: 54,
          child: Container(
            width: 54,
            height: 54, // Perfect massive circle size
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isPressed 
                  ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12)
                  : Colors.transparent,
            ),
            child: Icon(widget.icon, size: 26),
          ),
        ),
      ),
    );
  }
}
