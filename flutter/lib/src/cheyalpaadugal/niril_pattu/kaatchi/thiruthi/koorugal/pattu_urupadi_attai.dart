import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../../koorugal/podhu_koorugal/elvan_thiruthi_attai_kooru.dart';
import '../../../../niril_podhu/kaatchi/koorugal/porul_thaedu_kooru.dart';
import '../../../../niril_podhu/tharavuru/pattiyal_tharavuru.dart';

// ─────────────────────────────────────────────────────────────────────────────
// பட்டு உருபடி அட்டை — Single Line Item Card for Silk Invoice
// ─────────────────────────────────────────────────────────────────────────────

/// Indian currency formatter: ₹1,23,456.00
final _inrFormat = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 2,
);

/// A single line item card for the Silk Invoice Editor.
///
/// Displays product search, qty/rate/discount/total fields,
/// and info line (English name · GST%).
class PattuUrupadiAttai extends ConsumerWidget {
  const PattuUrupadiAttai({
    super.key,
    required this.item,
    required this.index,
    required this.itemCount,
    required this.seyaliVagai,
    required this.onItemUpdated,
    required this.onItemDeleted,
    required this.onItemCleared,
    required this.onDirty,
    required this.onRequestAddNewProduct,
  });

  final PattuUrupadi item;
  final int index;
  final int itemCount;
  final String seyaliVagai;
  final ValueChanged<PattuUrupadi> onItemUpdated;
  final VoidCallback onItemDeleted;
  final VoidCallback onItemCleared;
  final VoidCallback onDirty;
  final VoidCallback onRequestAddNewProduct;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final taxableAmount = item.adippadaiThogai - item.thallupadiThogai;
    final rowTax = taxableAmount * (item.variVizhukkaadu / 100);
    final rowTotal = taxableAmount + rowTax;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: "பொருள் #N" + trash icon ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 6),
                child: Text(
                  '${K.porul.tr(context, ref)} #${index + 1}',
                  style: tt.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              if (itemCount > 1)
                IconButton(
                  icon: Icon(Icons.delete_outline,
                      size: 20, color: cs.error),
                  onPressed: onItemDeleted,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),

          // ── Item card ──
          ElvanUrupadiAttai(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 600;
              const gap = SizedBox(width: 12);
              const vGap = SizedBox(height: 12);

              // Product search row (always full width)
              final productSearch = PorulThaeduKooru(
                seyaliVagai: seyaliVagai,
                initialText: item.porulPeyar,
                onSelected: (p) {
                  final updated = item.copyWith(
                    porulId: p.id.toString(),
                    porulPeyar:
                        p.porulPeyar['Tamil'] ?? p.porulPeyar['English'] ?? '',
                    porulPeyarEn: p.porulPeyar['English'] ?? '',
                    hsnKuriyeedu: p.hsnCode,
                    vilai: p.vilai,
                    variVizhukkaadu: p.variVeetham,
                    alagu: p.alagu,
                  );
                  onItemUpdated(updated);
                },
                onRequestAddNew: onRequestAddNewProduct,
                onCleared: onItemCleared,
              );

              // Build field widgets
              final isWeightItem = item.alagu == 'Kg';
              final qtyField = _buildItemField(
                isWeightItem ? 'Weight (kg)' : 'Qty',
                item.alavu,
                (v) => onItemUpdated(
                    item.copyWith(alavu: double.tryParse(v) ?? 0)),
                isWeight: isWeightItem,
              );

              final rateField = _buildItemField('Rate', item.vilai, (v) {
                onItemUpdated(
                    item.copyWith(vilai: double.tryParse(v) ?? 0));
              });

              final discField = Row(
                children: [
                  Expanded(
                    child: _buildItemField('Disc', item.thallupadi, (v) {
                      onItemUpdated(item.copyWith(
                          thallupadi: double.tryParse(v) ?? 0));
                    }),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      final newType = item.thallupadiVagai == 'percentage'
                          ? 'amount'
                          : 'percentage';
                      onItemUpdated(
                          item.copyWith(thallupadiVagai: newType));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.thallupadiVagai == 'percentage' ? '%' : '₹',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              );

              final totalDisplay = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total',
                    style: tt.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _inrFormat.format(rowTotal),
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                    ),
                  ),
                ],
              );

              // Bilingual info line (English name · GST%)
              final infoLine = (item.porulPeyarEn.isNotEmpty ||
                      item.variVizhukkaadu > 0)
                  ? Padding(
                      padding: const EdgeInsets.only(left: 4, top: 4),
                      child: Text(
                        [
                          if (item.porulPeyarEn.isNotEmpty) item.porulPeyarEn,
                          if (item.variVizhukkaadu > 0)
                            'GST ${item.variVizhukkaadu.toStringAsFixed(item.variVizhukkaadu.truncateToDouble() == item.variVizhukkaadu ? 0 : 1)}%',
                        ].join(' · '),
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : const SizedBox.shrink();

              if (isWide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    productSearch,
                    infoLine,
                    vGap,
                    Row(children: [
                      Expanded(child: qtyField),
                      gap,
                      Expanded(child: rateField),
                    ]),
                    vGap,
                    Row(children: [
                      Expanded(child: discField),
                      gap,
                      Expanded(child: totalDisplay),
                    ]),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  productSearch,
                  infoLine,
                  vGap,
                  Row(children: [
                    Expanded(child: qtyField),
                    gap,
                    Expanded(child: rateField),
                  ]),
                  vGap,
                  Row(children: [
                    Expanded(child: discField),
                    gap,
                    Expanded(child: totalDisplay),
                  ]),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Borderless numeric field — updates model on blur only.
  Widget _buildItemField(
      String label, double value, ValueChanged<String> onChanged,
      {bool isWeight = false}) {
    // Weight: always 3 decimals matching weighing machine (24.100 = 24kg 100g).
    // Non-weight: clean integers (6 not 6.0).
    String displayText = '';
    if (value != 0) {
      if (isWeight) {
        displayText = value.toStringAsFixed(3);
      } else {
        displayText = value == value.truncateToDouble()
            ? value.toInt().toString()
            : value.toString();
      }
    }
    return ItemFieldWidget(
      label: label,
      initialText: displayText,
      isWeight: isWeight,
      onValueCommitted: onChanged,
      onDirty: onDirty,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// எண்ணிக்கைப் புலம் — Stateful numeric field (blur-based commit)
// ─────────────────────────────────────────────────────────────────────────────

/// Stateful numeric field that owns its controller + focus node.
/// Updates the parent model only on blur (not every keystroke) to avoid lag.
class ItemFieldWidget extends StatefulWidget {
  const ItemFieldWidget({
    super.key,
    required this.label,
    required this.initialText,
    required this.onValueCommitted,
    this.isWeight = false,
    this.onDirty,
  });

  final String label;
  final String initialText;
  final ValueChanged<String> onValueCommitted;
  final bool isWeight;
  /// Called on first keystroke to mark form as dirty (before blur).
  final VoidCallback? onDirty;

  @override
  State<ItemFieldWidget> createState() => _ItemFieldWidgetState();
}

class _ItemFieldWidgetState extends State<ItemFieldWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(ItemFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update text if value changed externally AND field is not focused
    if (!_focusNode.hasFocus && oldWidget.initialText != widget.initialText) {
      _controller.text = widget.initialText;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      // Blur: commit value to parent
      final text = _controller.text.trim();
      widget.onValueCommitted(text);

      // Weight: format to 3 decimals on blur (weighing machine standard)
      if (widget.isWeight && text.isNotEmpty) {
        final v = double.tryParse(text) ?? 0;
        if (v > 0) {
          _controller.text = v.toStringAsFixed(3);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (_) {
        if (!_isDirty) {
          _isDirty = true;
          widget.onDirty?.call();
        }
      },
      decoration: InputDecoration(
        labelText: widget.label,
        suffixText: widget.isWeight ? 'kg' : null,
        border: InputBorder.none,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        isDense: true,
      ),
    );
  }
}
