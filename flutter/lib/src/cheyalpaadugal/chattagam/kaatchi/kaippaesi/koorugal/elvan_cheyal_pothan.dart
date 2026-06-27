import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A reusable top-bar text action button (e.g. "சேமி", "அழி", "அனுப்பு").
///
/// Designed to be passed as a [navAction] into [ElvanShell] / [ElvanSubpageShell].
/// Fixed at 50px height to perfectly align with [ElvanBackButton]'s 50×50 circle
/// during both the expanded and collapsed (pinned) states.
///
/// Usage:
/// ```dart
/// ElvanSubpageShell(
///   navActions: [
///     ElvanCheyalPothan(
///       label: K.chaemiPtn.tr(context, ref),
///       onPressed: _handleSave,
///     ),
///   ],
/// )
/// ```
class ElvanCheyalPothan extends StatelessWidget {
  const ElvanCheyalPothan({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.fontWeight = FontWeight.bold,
  });

  /// The text displayed on the button.
  final String label;

  /// Callback when the button is tapped.
  final VoidCallback? onPressed;

  /// Optional text color override. Defaults to CupertinoButton's blue.
  final Color? color;

  /// Font weight for the label. Defaults to bold.
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50, // Must match ElvanBackButton's 50×50 exactly!
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        // ignore: deprecated_member_use
        minSize: 0, // Override CupertinoButton's default 44px minimum
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: fontWeight,
            color: color ?? Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
