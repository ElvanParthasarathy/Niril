import 'package:elvan_niril/src/adippadai/iru_mozhi/iru_mozhi_vazhanguthigal.dart';
import 'package:elvan_niril/src/adippadai/tharavuru/uruvugal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../../../koorugal/podhu_koorugal/elvan_thiruthi_attai_kooru.dart';
import '../../../../../niril_podhu/kaatchi/koorugal/elvan_vaangunar_keezhvirivu_kooru.dart';
import '../../../../../../adippadai/nilaimai/seyali_nilaimai.dart';
import 'package:elvan_niril/src/koorugal/ulleedugal/elvan_thiruthi_thalaippu.dart';
import 'package:elvan_niril/src/koorugal/ulleedugal/elvan_thiruthi_pothan.dart';
import '../../../../../../koorugal/pulan_koorugal/elvan_irumozhi_autocomplete.dart';
import '../../../../../../adippadai/idangal_kalanjiyam/indhiya_maanilangal.dart';

// ─────────────────────────────────────────────────────────────────────────────
// பட்டு வணிகர்கள் கூறு — Customer Section (search + address + profile + PoS)
// ─────────────────────────────────────────────────────────────────────────────

/// Customer data from parent for display purposes.
class PattuVaangunargalData {
  const PattuVaangunargalData({
    required this.selectedVaangunarId,
    required this.selectedVaangunarPeyarMap,
    required this.placeOfSupply,
    required this.placeOfSupplyTa,
  });

  final int? selectedVaangunarId;
  final Map<String, String> selectedVaangunarPeyarMap;
  final String placeOfSupply;
  final String placeOfSupplyTa;
}

/// Callbacks from customer section back to parent orchestrator.
class PattuVaangunargalCallbacks {
  const PattuVaangunargalCallbacks({
    required this.onCustomerSelected,
    required this.onCustomerCleared,
    required this.onRequestAddNewCustomer,
    required this.onPlaceOfSupplyChanged,
    required this.onPlaceOfSupplyCleared,
  });

  final void Function(VaangunarTharavuru entry) onCustomerSelected;
  final VoidCallback onCustomerCleared;
  final VoidCallback onRequestAddNewCustomer;
  final void Function(String en, String ta) onPlaceOfSupplyChanged;
  final VoidCallback onPlaceOfSupplyCleared;
}

/// Section 1 + Place of Supply: Customer search, address card, profile dropdown,
/// and Place of Supply pills. Pure UI — delegates all state changes via callbacks.
class PattuVaangunargalKooru extends ConsumerWidget {
  const PattuVaangunargalKooru({
    super.key,
    required this.data,
    required this.callbacks,
    required this.selectedVaangunar,
  });

  final PattuVaangunargalData data;
  final PattuVaangunargalCallbacks callbacks;
  final VaangunarTharavuru? selectedVaangunar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return LayoutBuilder(builder: (context, constraints) {
      final isDesktop = MediaQuery.sizeOf(context).width >= 800;
      
      final customerSearch = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElvanThiruthiThalaippu(label: K.vaangunarPeyarThaedu.tr(context, ref)),
          ElvanVaangunarKeezhvirivuKooru(
            selectedVaangunarId: data.selectedVaangunarId,
            hideLabel: true,
            showClearButton: true,
            onChanged: (vaangunar) {
              if (vaangunar == null) {
                callbacks.onCustomerCleared();
              } else {
                callbacks.onCustomerSelected(vaangunar);
              }
            },
            onRequestAddNew: callbacks.onRequestAddNewCustomer,
          ),
        ],
      );

      final savedDetailsCard = selectedVaangunar != null
          ? Padding(
              padding: const EdgeInsets.only(top: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElvanThiruthiAttai(
                  color: cs.onSurface.withValues(alpha: 0.08),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      K.chaemiththaTharavugal.tr(context, ref),
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      selectedVaangunar!.peyar[ref.watch(silkIrandaamMozhiProvider)] ?? (data.selectedVaangunarPeyarMap[ref.watch(silkIrandaamMozhiProvider)]?.isNotEmpty == true ? data.selectedVaangunarPeyarMap[ref.watch(silkIrandaamMozhiProvider)] : data.selectedVaangunarPeyarMap[ref.watch(silkMudhanmaiMozhiProvider)]) ?? '',
                      style: tt.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    _buildAddressBlock(selectedVaangunar!, cs, tt, ref),
                  ],
                ),
              ),
            ),
          )
          : const SizedBox.shrink();

      final leftColumn = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          customerSearch,
          savedDetailsCard,
        ],
      );
      if (isDesktop) {
        return Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: leftColumn,
          ),
        );
      }
      return leftColumn;
    });
  }

  // ── Address Block ──
  Widget _buildAddressBlock(VaangunarTharavuru v, ColorScheme cs, TextTheme tt, WidgetRef ref) {
    final silkMudhanmaiMozhi = ref.watch(silkMudhanmaiMozhiProvider);
    final silkIrandaamMozhi = ref.watch(silkIrandaamMozhiProvider);

    List<String> buildLines(String key) {
      final lines = <String>[];
      final mugavari = (v.mugavari[key] ?? '').trim();
      if (mugavari.isNotEmpty) lines.add(mugavari);
      final oor = (v.oor[key] ?? '').trim();
      final maavattam = (v.maavattam[key] ?? '').trim();
      final pin = v.anjalKuriyeedu.trim();
      final cityLine = [
        if (oor.isNotEmpty) oor,
        if (maavattam.isNotEmpty) maavattam,
        if (pin.isNotEmpty) pin,
      ].join(', ');
      if (cityLine.isNotEmpty) lines.add(cityLine);
      final maanilam = (v.maanilam[key] ?? '').trim();
      final naadu = (v.naadu[key] ?? '').trim();
      final stateLine = [
        if (maanilam.isNotEmpty) maanilam,
        if (naadu.isNotEmpty) naadu,
      ].join(', ');
      if (stateLine.isNotEmpty) lines.add(stateLine);
      return lines;
    }

    final tamilLines = buildLines(silkMudhanmaiMozhi);
    final englishLines = buildLines(silkIrandaamMozhi);
    final showEnglish = englishLines.isNotEmpty &&
        englishLines.join() != tamilLines.join();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        if (tamilLines.isNotEmpty) ...[
          ...tamilLines.map((line) => Text(
                line,
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.5,
                ),
              )),
        ],
        if (showEnglish) ...[
          const SizedBox(height: 6),
          ...englishLines.map((line) => Text(
                line,
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                  height: 1.5,
                ),
              )),
        ],
        if (v.gstin.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            'GSTIN: ${v.gstin.trim()}',
            style: tt.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

}

/// Place of Supply widget: typeable autocomplete using ElvanIrumozhiAutocomplete.
class PattuVilippiIdam extends ConsumerWidget {
  const PattuVilippiIdam({
    super.key,
    required this.placeOfSupply,
    required this.placeOfSupplyTa,
    required this.onSelected,
    required this.onCleared,
  });

  final String placeOfSupply;
  final String placeOfSupplyTa;
  final void Function(String en, String ta) onSelected;
  final VoidCallback onCleared;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapValue = <String, String>{};
    if (placeOfSupply.isNotEmpty) {
      mapValue['English'] = placeOfSupply;
    }
    if (placeOfSupplyTa.isNotEmpty) {
      mapValue['Tamil'] = placeOfSupplyTa;
    }

    return ElvanIrumozhiAutocomplete(
      label: K.vazhangalIdam.tr(context, ref),
      value: mapValue,
      options: indhiyaMaanilangal,
      onChanged: (map) {
        final en = map['en'] ?? map['English'] ?? '';
        final ta = map['ta'] ?? map['Tamil'] ?? '';
        
        if (en.isEmpty && ta.isEmpty) {
          onCleared();
        } else {
          onSelected(en, ta);
        }
      },
    );
  }
}
