import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../../koorugal/podhu_koorugal/elvan_thiruthi_attai_kooru.dart';
import '../../../../../niril_podhu/kaatchi/koorugal/porul_thaedu_kooru.dart';
import '../../../../../niril_podhu/tharavuru/pattiyal_tharavuru.dart';

/// Builds a single coolie line-item row: header label + delete + ElvanUrupadiAttai.
class KooliUrupadiKooru extends StatelessWidget {
  final int index;
  final KooliUrupadi item;
  final int itemCount;
  final NumberFormat formatter;
  final ValueChanged<KooliUrupadi> onUpdated;
  final VoidCallback onDeleted;
  final VoidCallback? onRequestAddNewProduct;

  const KooliUrupadiKooru({
    super.key,
    required this.index,
    required this.item,
    required this.itemCount,
    required this.formatter,
    required this.onUpdated,
    required this.onDeleted,
    this.onRequestAddNewProduct,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          // Item #N header + trash
          Row(
            children: [
              Text('Item #${index + 1}',
                  style: tt.titleSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  )),
              const Spacer(),
              if (itemCount > 1)
                IconButton(
                  icon: Icon(Icons.delete_outline,
                      color: cs.error, size: 20),
                  onPressed: onDeleted,
                ),
            ],
          ),
          const SizedBox(height: 4),
          ElvanUrupadiAttai(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                // Product search — wider
                SizedBox(
                  width: 280,
                  child: PorulThaeduKooru(
                    seyaliVagai: 'coolie',
                    initialText: item.porulPeyar,
                    onSelected: (p) {
                      onUpdated(item.copyWith(
                        porulId: p.id.toString(),
                        porulPeyar: p.porulPeyar['Tamil'] ??
                            p.porulPeyar['English'] ??
                            '',
                        vilai: p.vilai,
                      ));
                    },
                    onRequestAddNew: onRequestAddNewProduct,
                  ),
                ),
                // Weight
                SizedBox(
                  width: 120,
                  child: _numField('KG', item.edai, (v) {
                    onUpdated(
                        item.copyWith(edai: double.tryParse(v) ?? 0));
                  }),
                ),
                // Rate
                SizedBox(
                  width: 120,
                  child: _numField('Rate/KG', item.vilai, (v) {
                    onUpdated(
                        item.copyWith(vilai: double.tryParse(v) ?? 0));
                  }),
                ),
                // Row total (read-only)
                SizedBox(
                  width: 120,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text('₹${formatter.format(item.varisaiThogai)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: cs.primary,
                        )),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Compact borderless number field for use inside item cards.
  Widget _numField(
      String label, double value, ValueChanged<String> onChanged) {
    return TextFormField(
      initialValue: value > 0 ? value.toString() : '',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: InputBorder.none,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        isDense: true,
      ),
      onChanged: onChanged,
    );
  }
}
