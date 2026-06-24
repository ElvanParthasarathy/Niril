import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import 'package:intl/intl.dart';

import '../../../../../../koorugal/podhu_koorugal/elvan_thiruthi_attai_kooru.dart';
import '../../../../../niril_podhu/kaatchi/koorugal/porul_thaedu_kooru.dart';
import '../../../../../niril_podhu/tharavuru/pattiyal_tharavuru.dart';
import '../../../../../niril_pattu/kaatchi/thiruthi/pattiyal/koorugal/pattu_urupadi_attai.dart';

/// Builds a single coolie line-item row: header label + delete + ElvanUrupadiAttai.
class KooliUrupadiKooru extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Weight display: 3 decimals (weighing machine standard) e.g. 24.100
    // Rate display: clean integer (6 not 6.0)
    String weightText = '';
    if (item.edai != 0) {
      weightText = item.edai.toStringAsFixed(3);
    }

    String rateText = '';
    if (item.vilai != 0) {
      rateText = item.vilai == item.vilai.truncateToDouble()
          ? item.vilai.toInt().toString()
          : item.vilai.toString();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          // Item #N header + trash
          Row(
            children: [
              Text('${K.porul.tr(context, ref)} #${index + 1}',
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
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
                          final tamilName = p.porulPeyar['Tamil'] ?? '';
                          final englishName = p.porulPeyar['English'] ?? '';
                          onUpdated(item.copyWith(
                            porulId: p.id.toString(),
                            porulPeyar: tamilName.isNotEmpty
                                ? tamilName
                                : englishName,
                            porulPeyarEn: tamilName.isNotEmpty
                                ? englishName
                                : '',
                            vilai: p.vilai,
                          ));
                        },
                        onRequestAddNew: onRequestAddNewProduct,
                        onCleared: () {
                          onUpdated(const KooliUrupadi());
                        },
                      ),
                    ),
                    // Weight (kg) — instant math, 3-decimal on blur
                    SizedBox(
                      width: 120,
                      child: ItemFieldWidget(
                        label: K.kiKi.tr(context, ref),
                        initialText: weightText,
                        isWeight: true,
                        onValueCommitted: (v) {
                          onUpdated(
                            item.copyWith(edai: double.tryParse(v) ?? 0),
                          );
                        },
                        onChanged: (v) {
                          onUpdated(
                            item.copyWith(edai: double.tryParse(v) ?? 0),
                          );
                        },
                      ),
                    ),
                    // Rate (per kg) — instant math, clean integer on blur
                    SizedBox(
                      width: 120,
                      child: ItemFieldWidget(
                        label: K.vilaiKiKi.tr(context, ref),
                        initialText: rateText,
                        onValueCommitted: (v) {
                          onUpdated(
                            item.copyWith(vilai: double.tryParse(v) ?? 0),
                          );
                        },
                        onChanged: (v) {
                          onUpdated(
                            item.copyWith(vilai: double.tryParse(v) ?? 0),
                          );
                        },
                      ),
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
                        child: Text(
                            '₹${formatter.format(item.varisaiThogai)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: cs.primary,
                            )),
                      ),
                    ),
                  ],
                ),
                // English subtitle
                if (item.porulPeyarEn.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      item.porulPeyarEn,
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
