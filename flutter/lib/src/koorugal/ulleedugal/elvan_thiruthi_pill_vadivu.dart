import 'package:flutter/material.dart';

class ElvanThiruthiPillVadivu {
  /// Returns the standard dark grey pill decoration used consistently 
  /// across text fields and autocomplete boxes in the editor.
  static InputDecoration getDecoration(BuildContext context, {double borderRadius = 100}) {
    return InputDecoration(
      isDense: true,
      constraints: const BoxConstraints(minHeight: 45),
      filled: true,
      fillColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.focused) ||
            states.contains(WidgetState.hovered)) {
          return Theme.of(context)
              .colorScheme
              .onSurface
              .withValues(alpha: 0.12);
        }
        return Theme.of(context)
            .colorScheme
            .onSurface
            .withValues(alpha: 0.08);
      }),
      contentPadding: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide.none,
      ),
    );
  }
}
