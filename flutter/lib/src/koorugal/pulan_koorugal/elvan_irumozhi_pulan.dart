import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../adippadai/nilaimai/seyali_nilaimai.dart';
import '../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';

/// A reusable bilingual text field widget.
/// Renders 1 or 2 TextFields based on the app's bilingual setting.
/// Reads/writes data as a `Map<String, String>` compatible with `MozhiMapConverter`.
class ElvanIrumozhiPulan extends ConsumerWidget {
  const ElvanIrumozhiPulan({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.primaryController,
    this.secondaryController,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.words,
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBilingual = ref.watch(bilingualProvider);
    final primaryLang = ref.watch(primaryLanguageProvider);
    final secondaryLang = ref.watch(secondaryLanguageProvider);

    final translatedPrimaryLang = primaryLang.toLowerCase().tr(context, ref);
    final translatedSecondaryLang = secondaryLang.toLowerCase().tr(context, ref);

    final primaryValue = value[primaryLang] ?? '';
    final secondaryValue = value[secondaryLang] ?? '';

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Primary language field
        _buildTextField(
          context: context,
          isDark: isDark,
          label: '$label ($translatedPrimaryLang)',
          initialValue: primaryValue,
          controller: primaryController,
          autofocus: autofocus,
          onChanged: (text) {
            final updated = Map<String, String>.from(value);
            updated[primaryLang] = text;
            onChanged(updated);
          },
        ),

        // Secondary language field (only if bilingual)
        if (isBilingual) ...[
          const SizedBox(height: 12),
          _buildTextField(
            context: context,
            isDark: isDark,
            label: '$label ($translatedSecondaryLang)',
            initialValue: secondaryValue,
            controller: secondaryController,
            onChanged: (text) {
              final updated = Map<String, String>.from(value);
              updated[secondaryLang] = text;
              onChanged(updated);
            },
          ),
        ],
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
    required ValueChanged<String> onChanged,
  }) {
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
