import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import 'package:intl/intl.dart';
import '../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../adippadai/tharavuthalam/seyali_tharavuthalam.dart';
import '../../kalanjiyam/porul_nilaimai.dart';

// ─────────────────────────────────────────────────────────────────────────────
// பொருள் தேடு கூறு — Product Picker Autocomplete
// ─────────────────────────────────────────────────────────────────────────────
// Reusable autocomplete widget that searches PorulTable entries by bilingual
// product name. Displays HSN code (for Silk mode) and rate alongside each
// option. Used by both Silk and Coolie invoice editors.
// ─────────────────────────────────────────────────────────────────────────────

/// Indian currency formatter: ₹1,23,456.00
final _inrFormat = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 2,
);

/// Autocomplete search widget for selecting a [PorulEntry].
///
/// Watches [porulgalStreamProvider] and filters the list by matching the
/// query against both Tamil and English name fields from the `porulPeyar` map.
class PorulThaeduKooru extends ConsumerStatefulWidget {
  /// Callback fired when the user picks a product from the list.
  final ValueChanged<PorulEntry> onSelected;

  /// Optional text to pre-fill the search field.
  final String? initialText;

  /// The app mode identifier ('silk' or 'coolie').
  final String seyaliVagai;

  const PorulThaeduKooru({
    super.key,
    required this.onSelected,
    this.initialText,
    required this.seyaliVagai,
  });

  @override
  ConsumerState<PorulThaeduKooru> createState() => _PorulThaeduKooruState();
}

class _PorulThaeduKooruState extends ConsumerState<PorulThaeduKooru> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Extracts the display name from a [PorulEntry], preferring Tamil.
  String _getDisplayName(PorulEntry entry) {
    final peyar = entry.porulPeyar; // Map<String, String>
    return peyar['Tamil'] ?? peyar['English'] ?? '';
  }

  /// Extracts the secondary (alternate-language) name, or empty string.
  String _getSecondaryName(PorulEntry entry) {
    final peyar = entry.porulPeyar;
    if (peyar.containsKey('Tamil') && peyar['Tamil']!.isNotEmpty) {
      return peyar['English'] ?? '';
    }
    return peyar['Tamil'] ?? '';
  }

  /// Returns `true` if the entry matches the search [query] (case-insensitive).
  bool _matchesQuery(PorulEntry entry, String query) {
    final q = query.toLowerCase();
    final peyar = entry.porulPeyar;
    final tamilMatch =
        (peyar['Tamil'] ?? '').toLowerCase().contains(q);
    final englishMatch =
        (peyar['English'] ?? '').toLowerCase().contains(q);
    // Also search HSN code.
    final hsnMatch = entry.hsnCode.toLowerCase().contains(q);
    return tamilMatch || englishMatch || hsnMatch;
  }

  /// Whether this is silk mode (shows HSN code).
  bool get _isSilk => widget.seyaliVagai == 'silk';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final porulgalAsync = ref.watch(porulgalStreamProvider);

    return porulgalAsync.when(
      loading: () => _buildTextField(
        context,
        enabled: false,
        hintText: '...',
      ),
      error: (err, _) => _buildTextField(
        context,
        enabled: false,
        hintText: 'பிழை',
      ),
      data: (porulgal) {
        return Autocomplete<PorulEntry>(
          displayStringForOption: _getDisplayName,
          initialValue: widget.initialText != null
              ? TextEditingValue(text: widget.initialText!)
              : null,
          optionsBuilder: (textEditingValue) {
            final query = textEditingValue.text.trim();
            if (query.isEmpty) return const Iterable.empty();
            return porulgal.where((p) => _matchesQuery(p, query));
          },
          onSelected: (entry) {
            _textController.text = _getDisplayName(entry);
            widget.onSelected(entry);
          },
          fieldViewBuilder: (
            context,
            fieldController,
            focusNode,
            onFieldSubmitted,
          ) {
            return TextField(
              controller: fieldController,
              focusNode: focusNode,
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(
                labelText: K.porutkal.tr(context, ref),
                hintText: K.porutkal.tr(context, ref),
                prefixIcon: Icon(
                  Icons.inventory_2_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
                suffixIcon: fieldController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 20),
                        onPressed: () {
                          fieldController.clear();
                          _textController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerLowest,
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                surfaceTintColor: colorScheme.surfaceTint,
                color: colorScheme.surfaceContainerLow,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 280,
                    maxWidth: 420,
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: colorScheme.outlineVariant),
                    itemBuilder: (context, index) {
                      final entry = options.elementAt(index);
                      final primary = _getDisplayName(entry);
                      final secondary = _getSecondaryName(entry);

                      return ListTile(
                        dense: true,
                        title: Text(
                          primary,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (secondary.isNotEmpty)
                              Text(
                                secondary,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            if (_isSilk && entry.hsnCode.isNotEmpty)
                              Text(
                                'HSN: ${entry.hsnCode}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.outline,
                                  fontFamily: 'monospace',
                                ),
                              ),
                          ],
                        ),
                        trailing: Text(
                          _inrFormat.format(entry.vilai),
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                        onTap: () => onSelected(entry),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Builds a disabled text field for loading / error states.
  Widget _buildTextField(
    BuildContext context, {
    required bool enabled,
    required String hintText,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextField(
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(
          Icons.inventory_2_rounded,
          color: colorScheme.onSurfaceVariant,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerLowest,
      ),
    );
  }
}
