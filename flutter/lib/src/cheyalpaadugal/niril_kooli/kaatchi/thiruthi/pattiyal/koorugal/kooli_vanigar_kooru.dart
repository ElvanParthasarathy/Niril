import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';

import '../../../../../../adippadai/tharavuthalam/seyali_tharavuthalam.dart';
import '../../../../../../koorugal/podhu_koorugal/elvan_thiruthi_attai_kooru.dart';
import '../../../../../niril_podhu/kaatchi/koorugal/vanigar_thaedu_kooru.dart';
import '../../../../../amaippugal/tharavu/niruvana_tharavugal.dart';

/// §1 Customer — client search + company dropdown + saved-details card.
class KooliVanigarKooru extends ConsumerWidget {
  final int? selectedVanigarId;
  final Map<String, String> selectedVanigarPeyarMap;
  final VanigarEntry? selectedVanigar;
  final ValueChanged<VanigarEntry> onVanigarSelected;
  final VoidCallback onVanigarCleared;

  const KooliVanigarKooru({
    super.key,
    required this.selectedVanigarId,
    required this.selectedVanigarPeyarMap,
    required this.selectedVanigar,
    required this.onVanigarSelected,
    required this.onVanigarCleared,
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
            child: Text(K.vanigarPeyarThaedu.tr(context, ref),
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontSize: 12,
                )),
          ),
          VanigarThaeduKooru(
            seyaliVagai: 'coolie',
            selectedId: selectedVanigarId,
            onSelected: onVanigarSelected,
            onCleared: onVanigarCleared,
          ),
          if (selectedVanigar != null) ...[
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
                  // English name (bold)
                  Text(
                    selectedVanigar!.peyar['English'] ??
                        selectedVanigar!.peyar['Tamil'] ??
                        (selectedVanigarPeyarMap['English']?.isNotEmpty == true ? selectedVanigarPeyarMap['English'] : selectedVanigarPeyarMap['Tamil']) ?? '',
                    style: tt.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // Tamil address
                  ..._buildAddressLines(selectedVanigar!, 'Tamil', tt, cs),
                  // English address (subtitle)
                  ..._buildAddressLines(selectedVanigar!, 'English', tt, cs,
                      isSubtitle: true),
                  // GSTIN
                  if (selectedVanigar!.gstin.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      'GSTIN: ${selectedVanigar!.gstin.trim()}',
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
  /// Tamil: normal color. English (isSubtitle): lighter, italic.
  List<Widget> _buildAddressLines(
    VanigarEntry v,
    String key,
    TextTheme tt,
    ColorScheme cs, {
    bool isSubtitle = false,
  }) {
    final parts = <String>[];
    final oor = (v.oor[key] ?? '').trim();
    final maavattam = (v.maavattam[key] ?? '').trim();
    final combined = [
      if (oor.isNotEmpty) oor,
      if (maavattam.isNotEmpty) maavattam,
    ].join(', ');
    if (combined.isNotEmpty) parts.add(combined);

    final maanilam = (v.maanilam[key] ?? '').trim();
    if (maanilam.isNotEmpty) parts.add(maanilam);

    if (parts.isEmpty) return [];

    // Skip English if identical to Tamil
    if (isSubtitle) {
      final tamilParts = <String>[];
      final tOor = (v.oor['Tamil'] ?? '').trim();
      final tMaav = (v.maavattam['Tamil'] ?? '').trim();
      final tCombined = [if (tOor.isNotEmpty) tOor, if (tMaav.isNotEmpty) tMaav].join(', ');
      if (tCombined.isNotEmpty) tamilParts.add(tCombined);
      final tMaan = (v.maanilam['Tamil'] ?? '').trim();
      if (tMaan.isNotEmpty) tamilParts.add(tMaan);
      if (parts.join() == tamilParts.join()) return [];
    }

    final style = isSubtitle
        ? tt.bodySmall?.copyWith(
            color: cs.onSurfaceVariant.withValues(alpha: 0.7),
            height: 1.5,
            fontStyle: FontStyle.italic,
          )
        : tt.bodySmall?.copyWith(
            color: cs.onSurfaceVariant,
            height: 1.5,
          );

    return [
      const SizedBox(height: 6),
      ...parts.map((line) => Text(line, style: style)),
    ];
  }
}
