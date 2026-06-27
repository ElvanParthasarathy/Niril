import 'package:elvan_niril/src/adippadai/tharavuru/uruvugal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import 'package:intl/intl.dart';
import '../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../kalanjiyam/porul_nilaimai.dart';
import '../../../../koorugal/maeladukkugal/elvan_kizh_maeladukku/elvan_kizh_maeladukku.dart';
import '../../../../adippadai/nilaimai/achu_mozhi_facade.dart';
import '../../../../adippadai/iru_mozhi/iru_mozhi_vazhanguthigal.dart';
import '../../../../adippadai/nilaimai/seyali_nilaimai.dart';

// ─────────────────────────────────────────────────────────────────────────────
// பொருள் தேடு கூறு — Product Picker Selection
// ─────────────────────────────────────────────────────────────────────────────

/// Indian currency formatter: ₹1,23,456.00
final _inrFormat = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 2,
);

/// Selection widget for picking a [PorulTharavuru].
class PorulThaeduKooru extends ConsumerStatefulWidget {
  /// Callback fired when the user picks a product from the list.
  final ValueChanged<PorulTharavuru> onSelected;

  /// Called when the user taps the "Add New Product" action.
  final VoidCallback? onRequestAddNew;

  /// Optional text to pre-fill the search field.
  final String? initialText;

  /// The app mode identifier ('silk' or 'coolie').
  final String seyaliVagai;

  /// Called when the user clears the selected product (X button).
  final VoidCallback? onCleared;

  const PorulThaeduKooru({
    super.key,
    required this.onSelected,
    this.onRequestAddNew,
    this.onCleared,
    this.initialText,
    required this.seyaliVagai,
  });

  @override
  ConsumerState<PorulThaeduKooru> createState() => _PorulThaeduKooruState();
}

class _PorulThaeduKooruState extends ConsumerState<PorulThaeduKooru> {
  late String _currentText;
  PorulTharavuru? _selectedItem;

  @override
  void initState() {
    super.initState();
    _currentText = widget.initialText ?? '';
  }

  @override
  void didUpdateWidget(covariant PorulThaeduKooru oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialText != oldWidget.initialText) {
      _currentText = widget.initialText ?? '';
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _getDisplayName(
      BuildContext context, WidgetRef ref, PorulTharavuru entry) {
    // We use NiruvanaTharavugal helper technically, but we can't because it takes NiruvanaTharavugal.
    // We'll write our own logic respecting the current primary language:
    final primaryLang = ref.watch(primaryLanguageProvider);
    final peyar = entry.porulPeyar;

    if (peyar[primaryLang] != null && peyar[primaryLang]!.isNotEmpty) {
      return peyar[primaryLang]!;
    }
    return peyar['Tamil'] ?? peyar['English'] ?? '';
  }

  String _getSecondaryName(
      BuildContext context, WidgetRef ref, PorulTharavuru entry) {
    final secondaryLang = ref.watch(secondaryLanguageProvider);
    final peyar = entry.porulPeyar;

    if (peyar[secondaryLang] != null && peyar[secondaryLang]!.isNotEmpty) {
      return peyar[secondaryLang]!;
    }
    return peyar['English'] ?? peyar['Tamil'] ?? '';
  }

  bool _matchesQuery(PorulTharavuru entry, String query) {
    final q = query.toLowerCase();
    final peyar = entry.porulPeyar;
    final tamilMatch = (peyar['Tamil'] ?? '').toLowerCase().contains(q);
    final englishMatch = (peyar['English'] ?? '').toLowerCase().contains(q);
    final hsnMatch = entry.hsnCode.toLowerCase().contains(q);
    return tamilMatch || englishMatch || hsnMatch;
  }

  bool get _isSilk => widget.seyaliVagai == 'silk';

  void _openSelectionSheet(List<PorulTharavuru> items) {
    final isBilingual = ref.read(bilingualProvider);

    showElvanSelectionBottomSheet<PorulTharavuru>(
      context: context,
      title: K.porutkal.tr(context, ref),
      items: items,
      currentValue: _selectedItem,
      showSearch: true,
      searchFilter: _matchesQuery,
      onRequestAddNew: widget.onRequestAddNew,
      onSelected: (val) {
        setState(() {
          _selectedItem = val;
          _currentText = _getDisplayName(context, ref, val);
        });
        widget.onSelected(val);
      },
      itemLabelBuilder: (ctx, ref, item) => _getDisplayName(ctx, ref, item),
      subtitleBuilder: (ctx, ref, item) {
        if (!_isSilk) return ''; // Coolie mode has no price/secondary name logic in UI list
        
        final secondary = isBilingual ? _getSecondaryName(ctx, ref, item) : '';
        final parts = <String>[];
        
        if (secondary.isNotEmpty && secondary != _getDisplayName(ctx, ref, item)) {
          parts.add(secondary);
        }
        if (item.hsnCode.isNotEmpty) {
          parts.add('HSN: ${item.hsnCode}');
        }
        if (item.vilai > 0) {
          parts.add(_inrFormat.format(item.vilai));
        }
        
        if (parts.isEmpty) return '';
        return parts.join('  •  ');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final porulgalAsync = ref.watch(porulgalProvider);

    return porulgalAsync.when(
      loading: () => _buildFakeField(
        context: context,
        text: '...',
        enabled: false,
      ),
      error: (err, _) => _buildFakeField(
        context: context,
        text: K.pizhai.tr(context, ref),
        enabled: false,
      ),
      data: (porulgal) {
        return _buildFakeField(
          context: context,
          text:
              _currentText.isEmpty ? K.porutkal.tr(context, ref) : _currentText,
          isHint: _currentText.isEmpty,
          enabled: true,
          onTap: () => _openSelectionSheet(porulgal),
          onClear: _currentText.isNotEmpty
              ? () {
                  setState(() {
                    _currentText = '';
                    _selectedItem = null;
                  });
                  widget.onCleared?.call();
                }
              : null,
        );
      },
    );
  }

  Widget _buildFakeField({
    required BuildContext context,
    required String text,
    bool isHint = false,
    required bool enabled,
    VoidCallback? onTap,
    VoidCallback? onClear,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outline),
          ),
          child: Row(
            children: [
              Icon(
                Icons.inventory_2_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: isHint
                      ? textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.7),
                        )
                      : textTheme.bodyLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onClear != null)
                GestureDetector(
                  onTap: onClear,
                  child: const Icon(Icons.clear_rounded, size: 20),
                )
              else
                Icon(
                  Icons.arrow_drop_down,
                  color: colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
