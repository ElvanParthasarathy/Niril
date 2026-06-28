import 'package:flutter/material.dart';

/// Single source of truth for all Elvan Editor (Thiruthi) field styling.
///
/// Every standalone pill-shaped form field — text inputs, dropdowns,
/// date pickers, autocomplete fields — MUST reference these constants
/// to guarantee pixel-perfect uniformity across the entire app.
///
/// Inline/table fields (inside cards, list items, table cells) are
/// intentionally exempt and may use their own compact styling.
class ElvanThiruthiMarabu {
  ElvanThiruthiMarabu._();

  // ── Sizing ──
  static const singleLineConstraints = BoxConstraints.tightFor(height: 48);
  static const multiLineConstraints = BoxConstraints(minHeight: 48);
  static const contentPadding =
      EdgeInsets.symmetric(horizontal: 20, vertical: 16);

  // ── Shape ──
  static const double borderRadius = 100.0;

  // ── Typography ──
  static const double fontSize = 14.0;
  static const double labelFontSize = 12.0;

  // ── Icons ──
  static const double iconSize = 18.0;

  // ── Fill Colors ──
  static const double fillAlpha = 0.08;
  static const double focusAlpha = 0.12;

  // ── Pre-built Borders ──
  static OutlineInputBorder get border => OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide.none,
      );

  /// Dynamic fill color that darkens on focus/hover.
  static WidgetStateColor buildFillColor(BuildContext context) {
    final base = Theme.of(context).colorScheme.onSurface;
    return WidgetStateColor.resolveWith((states) {
      if (states.contains(WidgetState.focused) ||
          states.contains(WidgetState.hovered)) {
        return base.withValues(alpha: focusAlpha);
      }
      return base.withValues(alpha: fillAlpha);
    });
  }

  /// Standard label widget used above editor fields.
  static Widget buildLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: labelFontSize,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.3,
          color: Theme.of(context)
              .colorScheme
              .onSurface
              .withValues(alpha: 0.5),
        ),
      ),
    );
  }

  /// Standard InputDecoration for pill-shaped editor fields.
  /// Callers can override specific properties via copyWith if needed.
  static InputDecoration buildDecoration(BuildContext context, {
    String? hintText,
    String? errorText,
    String? prefixText,
    String? suffixText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool isMultiLine = false,
  }) {
    return InputDecoration(
      constraints: isMultiLine ? multiLineConstraints : singleLineConstraints,
      isDense: true,
      filled: true,
      fillColor: buildFillColor(context),
      contentPadding: contentPadding,
      hintText: hintText,
      errorText: errorText,
      prefixText: prefixText,
      suffixText: suffixText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: border,
      enabledBorder: border,
      focusedBorder: border,
      errorBorder: border,
      focusedErrorBorder: border,
      disabledBorder: border,
    );
  }
}
