import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../adippadai/tharavuthalam/seyali_tharavuthalam.dart';
import '../../kalanjiyam/vanigar_nilaimai.dart';

// ─────────────────────────────────────────────────────────────────────────────
// வணிகர் தேடு கூறு — Customer Picker Autocomplete
// ─────────────────────────────────────────────────────────────────────────────
// Reusable autocomplete widget that searches VanigarTable entries by bilingual
// name (Tamil & English). Used by both Silk and Coolie invoice editors.
// ─────────────────────────────────────────────────────────────────────────────

/// Autocomplete search widget for selecting a [VanigarEntry].
///
/// Watches [vanigargalStreamProvider] and filters the list by matching the
/// query against both Tamil and English name fields from the `peyar` map.
class VanigarThaeduKooru extends ConsumerStatefulWidget {
  /// Callback fired when the user picks a customer from the list.
  final ValueChanged<VanigarEntry> onSelected;

  /// If set, pre-fills the display text with this customer's name.
  final int? selectedId;

  /// The app mode identifier ('silk' or 'coolie').
  final String seyaliVagai;

  const VanigarThaeduKooru({
    super.key,
    required this.onSelected,
    this.selectedId,
    required this.seyaliVagai,
  });

  @override
  ConsumerState<VanigarThaeduKooru> createState() =>
      _VanigarThaeduKooruState();
}

class _VanigarThaeduKooruState extends ConsumerState<VanigarThaeduKooru> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Extracts the display name from a [VanigarEntry], preferring Tamil.
  String _getDisplayName(VanigarEntry entry) {
    final peyar = entry.peyar; // Map<String, String>
    return peyar['Tamil'] ?? peyar['English'] ?? '';
  }

  /// Extracts the secondary (alternate-language) name, or empty string.
  String _getSecondaryName(VanigarEntry entry) {
    final peyar = entry.peyar;
    // If Tamil is the primary, show English as secondary (and vice versa).
    if (peyar.containsKey('Tamil') && peyar['Tamil']!.isNotEmpty) {
      return peyar['English'] ?? '';
    }
    return peyar['Tamil'] ?? '';
  }

  /// Extracts the city display text from the bilingual `oor` map.
  String _getOorDisplay(VanigarEntry entry) {
    final oor = entry.oor;
    return oor['Tamil'] ?? oor['English'] ?? '';
  }

  /// Returns `true` if the entry matches the search [query] (case-insensitive).
  bool _matchesQuery(VanigarEntry entry, String query) {
    final q = query.toLowerCase();
    final peyar = entry.peyar;
    final tamilMatch =
        (peyar['Tamil'] ?? '').toLowerCase().contains(q);
    final englishMatch =
        (peyar['English'] ?? '').toLowerCase().contains(q);
    return tamilMatch || englishMatch;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final vanigargalAsync = ref.watch(vanigargalStreamProvider);

    return vanigargalAsync.when(
      loading: () => _buildTextField(
        context,
        enabled: false,
        hintText: '...',
      ),
      error: (err, _) => _buildTextField(
        context,
        enabled: false,
        hintText: 'பிழை', // Error
      ),
      data: (vanigargal) {
        // Pre-fill text if selectedId is provided.
        if (widget.selectedId != null && _textController.text.isEmpty) {
          final selected = vanigargal.cast<VanigarEntry?>().firstWhere(
                (v) => v!.id == widget.selectedId,
                orElse: () => null,
              );
          if (selected != null) {
            _textController.text = _getDisplayName(selected);
          }
        }

        return Autocomplete<VanigarEntry>(
          displayStringForOption: _getDisplayName,
          optionsBuilder: (textEditingValue) {
            final query = textEditingValue.text.trim();
            if (query.isEmpty) return const Iterable.empty();
            return vanigargal.where((v) => _matchesQuery(v, query));
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
            // Sync the external controller with the field controller.
            if (widget.selectedId != null && fieldController.text.isEmpty) {
              fieldController.text = _textController.text;
            }

            return TextField(
              controller: fieldController,
              focusNode: focusNode,
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(
                labelText: K.vanigargal.tr(context, ref),
                hintText: K.vanigargal.tr(context, ref),
                prefixIcon: Icon(
                  Icons.person_search_rounded,
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
                  borderSide: BorderSide(
                    color: colorScheme.outline,
                  ),
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
                    maxWidth: 400,
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
                      final oor = _getOorDisplay(entry);

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
                            if (oor.isNotEmpty)
                              Text(
                                oor,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.outline,
                                ),
                              ),
                          ],
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
          Icons.person_search_rounded,
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
