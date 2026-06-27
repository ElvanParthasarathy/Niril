import 'package:elvan_niril/src/adippadai/oru_mozhi/oru_mozhi_vazhanguthigal.dart';
import 'package:elvan_niril/src/adippadai/tharavuru/uruvugal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';

import '../../../../../../adippadai/nilaimai/seyali_nilaimai.dart';
import '../../../../../niril_podhu/kaatchi/thiruthi/koorugal/elvan_thiruthi_keezhvirivu.dart';
import '../../../../../../koorugal/podhu_koorugal/elvan_thiruthi_attai_kooru.dart';
import '../../../../../niril_podhu/kaatchi/koorugal/vaangunar_thaedu_kooru.dart';

/// §1 Customer — client search + company dropdown + saved-details card.
class KooliVaangunarKooru extends ConsumerWidget {
  final int? selectedVaangunarId;
  final Map<String, String> selectedVaangunarPeyarMap;
  final VaangunarTharavuru? selectedVaangunar;
  final ValueChanged<VaangunarTharavuru> onVaangunarSelected;
  final VoidCallback onVaangunarCleared;

  const KooliVaangunarKooru({
    super.key,
    required this.selectedVaangunarId,
    required this.selectedVaangunarPeyarMap,
    required this.selectedVaangunar,
    required this.onVaangunarSelected,
    required this.onVaangunarCleared,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return LayoutBuilder(builder: (context, constraints) {
      final customerColumn = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 6),
            child: Text(K.vaangunarPeyarThaedu.tr(context, ref),
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontSize: 12,
                )),
          ),
          VaangunarThaeduKooru(
            selectedId: selectedVaangunarId,
            onSelected: onVaangunarSelected,
            onCleared: onVaangunarCleared,
          ),
          if (selectedVaangunar != null) ...[
            const SizedBox(height: 12),
            ElvanThiruthiAttai(
              borderRadius: 16,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(K.chaemiththaTharavugal.tr(context, ref).toUpperCase(),
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        letterSpacing: 1.2,
                      )),
                  const SizedBox(height: 8),
                  Builder(
                    builder: (context) {
                      final kooliLang = ref.watch(kooliAchuMozhiProvider);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedVaangunar!.peyar[kooliLang] ??
                                selectedVaangunar!.peyar['Tamil'] ??
                                selectedVaangunarPeyarMap[kooliLang] ??
                                selectedVaangunarPeyarMap['Tamil'] ??
                                '',
                            style: tt.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          ..._buildAddressLines(selectedVaangunar!, kooliLang, tt, cs),
                        ],
                      );
                    },
                  ),
                  // GSTIN
                  if (selectedVaangunar!.gstin.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      'GSTIN: ${selectedVaangunar!.gstin.trim()}',
                      style: tt.bodySmall?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      );

      return customerColumn;
    });
  }

  /// Builds combined address lines for a given language key.
  List<Widget> _buildAddressLines(
    VaangunarTharavuru v,
    String key,
    TextTheme tt,
    ColorScheme cs,
  ) {
    final parts = <String>[];
    // Fallback to Tamil if requested key is empty
    final oor = (v.oor[key]?.isNotEmpty == true ? v.oor[key] : v.oor['Tamil'] ?? '').trim();
    final maavattam = (v.maavattam[key]?.isNotEmpty == true ? v.maavattam[key] : v.maavattam['Tamil'] ?? '').trim();
    final combined = [
      if (oor.isNotEmpty) oor,
      if (maavattam.isNotEmpty) maavattam,
    ].join(', ');
    if (combined.isNotEmpty) parts.add(combined);

    final maanilam = (v.maanilam[key]?.isNotEmpty == true ? v.maanilam[key] : v.maanilam['Tamil'] ?? '').trim();
    if (maanilam.isNotEmpty) parts.add(maanilam);

    if (parts.isEmpty) return [];

    final style = tt.bodySmall?.copyWith(
      color: cs.onSurfaceVariant,
      height: 1.5,
    );

    return [
      const SizedBox(height: 6),
      ...parts.map((line) => Text(line, style: style)),
    ];
  }
}
