import 'package:elvan_niril/src/adippadai/vazhikaattal/niril_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../adippadai/mozhiyaakkam/k.dart';
import 'package:elvan_niril/src/koorugal/ulleedugal/elvan_thiruthi_ulleedu.dart';

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
    return ElvanThiruthiUlleedu(
      label: label,
      initialValue: initialValue,
      controller: controller,
      autofocus: autofocus,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
      onChanged: onChanged,
    );
  }
}
