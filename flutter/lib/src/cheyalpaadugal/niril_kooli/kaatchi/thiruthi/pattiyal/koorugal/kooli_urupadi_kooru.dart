import 'package:elvan_niril/src/adippadai/oru_mozhi/oru_mozhi_vazhanguthigal.dart';
import 'package:elvan_niril/src/adippadai/oru_mozhi/oru_mozhi_porul_udhavi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import 'package:intl/intl.dart';

import '../../../../../../koorugal/podhu_koorugal/elvan_thiruthi_attai_kooru.dart';
import '../../../../../../koorugal/ulleedugal/elvan_thiruthi_ulleedu.dart';
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

    final kooliLang = ref.watch(kooliAchuMozhiProvider);
    final primaryName = OruMozhiPorulUdhavi.mudhanmaiPeyar(item.mozhiMap, kooliLang);
    final secondaryName = OruMozhiPorulUdhavi.thunaiPeyar(item.mozhiMap, kooliLang);
    final displayPrimary = primaryName.isNotEmpty ? primaryName : item.porulPeyar;
    final displaySecondary = secondaryName.isNotEmpty ? secondaryName : item.porulPeyarEn;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item #N header + trash
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 24, bottom: 4),
                child: Text('${K.porul.tr(context, ref)} #${index + 1}',
                    style: tt.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
                    )),
              ),
              Opacity(
                opacity: itemCount > 1 ? 1.0 : 0.0,
                child: IgnorePointer(
                  ignoring: itemCount <= 1,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12, bottom: 4),
                    child: IconButton(
                      icon: const Icon(CupertinoIcons.delete, size: 16),
                      color: cs.onSurfaceVariant,
                      style: IconButton.styleFrom(
                        padding: const EdgeInsets.all(6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white.withValues(alpha: 0.08) 
                            : Colors.white,
                      ),
                      onPressed: onDeleted,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          ElvanUrupadiAttai(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 600;
              const gap = SizedBox(width: 12);
              const vGap = SizedBox(height: 12);

              // Product search row (always full width)
              final productSearch = PorulThaeduKooru(
                seyaliVagai: 'coolie',
                initialText: displayPrimary,
                onSelected: (p) {
                  final primaryName = OruMozhiPorulUdhavi.mudhanmaiPeyar(p.porulPeyar, kooliLang);
                  final secondaryName = OruMozhiPorulUdhavi.thunaiPeyar(p.porulPeyar, kooliLang);
                  onUpdated(item.copyWith(
                    porulId: p.id.toString(),
                    porulPeyar: primaryName.isNotEmpty
                        ? primaryName
                        : secondaryName,
                    porulPeyarEn: primaryName.isNotEmpty
                        ? secondaryName
                        : '',
                    mozhiMap: p.porulPeyar,
                  ));
                },
                onRequestAddNew: onRequestAddNewProduct,
                onCleared: () {
                  onUpdated(const KooliUrupadi());
                },
              );

              // Build field widgets
              final weightField = _buildItemField(
                context,
                K.edai.tr(context, ref),
                item.edai,
                (v) => onUpdated(
                    item.copyWith(edai: double.tryParse(v) ?? 0)),
                isWeight: true,
              );

              final rateField = _buildItemField(
                context, 
                K.vilai.tr(context, ref), 
                item.vilai, 
                (v) => onUpdated(
                    item.copyWith(vilai: double.tryParse(v) ?? 0)),
              );

              final totalDisplay = ElvanThiruthiUlleedu(
                key: ValueKey(item.varisaiThogai),
                label: K.motham.tr(context, ref),
                initialValue: formatter.format(item.varisaiThogai),
                readOnly: true,
              );

              // Info line (Secondary name)
              final infoLine = displaySecondary.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(left: 16, top: 12),
                      child: Text(
                        displaySecondary,
                        style: TextStyle(
                          color: cs.onSurface.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.3,
                          fontSize: 10,
                        ),
                      ),
                    )
                  : const SizedBox.shrink();

              if (isWide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: productSearch),
                        gap,
                        Expanded(flex: 1, child: weightField),
                        gap,
                        Expanded(flex: 1, child: rateField),
                        gap,
                        Expanded(flex: 1, child: totalDisplay),
                      ],
                    ),
                    infoLine,
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  productSearch,
                  infoLine,
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: weightField),
                    gap,
                    Expanded(child: rateField),
                  ]),
                  vGap,
                  totalDisplay,
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Borderless numeric field — instant math + blur formatting.
  Widget _buildItemField(
      BuildContext context, String label, double value, ValueChanged<String> onChanged,
      {bool isWeight = false}) {
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
      onChanged: onChanged,
      backgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
    );
  }
}
