import 'package:flutter/material.dart';
import 'package:elvan_niril/src/koorugal/podhu_koorugal/elvan_thiruthi_attai_kooru.dart';

class ElvanThiruthiPillVadivu {
  /// Returns the standard dark grey pill decoration used consistently 
  /// across text fields and autocomplete boxes in the editor.
  static InputDecoration getDecoration(BuildContext context, {double borderRadius = 100, bool isMultiline = false}) {
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: WidgetStateColor.resolveWith((states) {
        final isInsideCard = ElvanAttaiSoolal.check(context);
        final isLight = Theme.of(context).colorScheme.brightness == Brightness.light;
        if (states.contains(WidgetState.focused) ||
            states.contains(WidgetState.hovered)) {
          return (isLight && !isInsideCard) ? Colors.white : Theme.of(context)
              .colorScheme
              .onSurface
              .withValues(alpha: 0.12);
        }
        return (isLight && !isInsideCard) ? Colors.white : Theme.of(context)
            .colorScheme
            .onSurface
            .withValues(alpha: 0.08);
      }),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: isMultiline ? 16 : 14.5,
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
