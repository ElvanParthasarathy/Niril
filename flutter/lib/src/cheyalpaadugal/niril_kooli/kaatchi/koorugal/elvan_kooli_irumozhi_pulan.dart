import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../adippadai/mozhiyaakkam/k.dart';

/// A reusable bilingual text field widget.
/// Renders 1 or 2 TextFields based on the app's bilingual setting.
/// Reads/writes data as a `Map<String, String>` compatible with `MozhiMapConverter`.
class ElvanKooliIrumozhiPulan extends ConsumerWidget {
  const ElvanKooliIrumozhiPulan({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.primaryController,
    this.secondaryController,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.words,
    this.maxLines = 1,
    this.forceStacked = false,
  });

  /// Label displayed above the fields (e.g. 'Product Name').
  final String label;

  /// Current value as a language map: {"Tamil": "...", "English": "..."}.
  final Map<String, String> value;

  /// Called whenever either field changes.
  final ValueChanged<Map<String, String>> onChanged;

  /// Optional controllers for external control.
  final TextEditingController? primaryController;
  final TextEditingController? secondaryController;

  /// Whether the primary field should autofocus.
  final bool autofocus;

  /// Text capitalization for both fields.
  final TextCapitalization textCapitalization;

  /// Maximum number of lines for the text fields.
  final int maxLines;

  /// If true, the layout will always be stacked vertically even on Desktop.
  final bool forceStacked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Coolie mode is fixed to Tamil (primary) and English (secondary).
    // It intentionally ignores the global hot-swap state.
    const primaryLang = 'ta';
    const secondaryLang = 'en';

    final translatedPrimaryLang = K.tamil.tr(context, ref);
    final translatedSecondaryLang = K.english.tr(context, ref);

    final primaryValue = value[primaryLang] ?? '';
    final secondaryValue = value[secondaryLang] ?? '';

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryWidget = _buildTextField(
      context: context,
      isDark: isDark,
      label: '$label ($translatedPrimaryLang)',
      initialValue: primaryValue,
      controller: primaryController,
      autofocus: autofocus,
      maxLines: maxLines,
      onChanged: (text) {
        final updated = Map<String, String>.from(value);
        updated[primaryLang] = text;
        onChanged(updated);
      },
    );

    final secondaryWidget = _buildTextField(
      context: context,
      isDark: isDark,
      label: '$label ($translatedSecondaryLang)',
      initialValue: secondaryValue,
      controller: secondaryController,
      maxLines: maxLines,
      onChanged: (text) {
        final updated = Map<String, String>.from(value);
        updated[secondaryLang] = text;
        onChanged(updated);
      },
    );

    final isDesktop = MediaQuery.sizeOf(context).width >= 800;

    if (isDesktop && !forceStacked) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: primaryWidget),
          const SizedBox(width: 16),
          Expanded(child: secondaryWidget),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        primaryWidget,
        const SizedBox(height: 12),
        secondaryWidget,
      ],
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required bool isDark,
    required String label,
    required String initialValue,
    TextEditingController? controller,
    bool autofocus = false,
    int maxLines = 1,
    required ValueChanged<String> onChanged,
  }) {
    final radius = maxLines > 1 ? 24.0 : 100.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.3,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          autofocus: autofocus,
          textCapitalization: textCapitalization,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: WidgetStateColor.resolveWith((states) {
              if (states.contains(WidgetState.focused)) {
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
            contentPadding: EdgeInsets.only(
              left: 20,
              right: maxLines > 1 ? 8 : 20,
              top: 14,
              bottom: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
