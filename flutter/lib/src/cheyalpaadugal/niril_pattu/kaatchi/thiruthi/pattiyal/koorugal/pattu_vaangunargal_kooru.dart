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
import 'maanila_thervu_maeladukku.dart';

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
              padding: const EdgeInsets.only(top: 12),
              child: SizedBox(
                width: double.infinity,
                child: ElvanThiruthiAttai(
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
                      selectedVaangunar!.peyar[ref.watch(silkMudhanmaiMozhiProvider)] ?? (data.selectedVaangunarPeyarMap[ref.watch(silkMudhanmaiMozhiProvider)]?.isNotEmpty == true ? data.selectedVaangunarPeyarMap[ref.watch(silkMudhanmaiMozhiProvider)] : data.selectedVaangunarPeyarMap[ref.watch(silkIrandaamMozhiProvider)]) ?? '',
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
      if (maanilam.isNotEmpty) lines.add(maanilam);
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
                  fontStyle: FontStyle.italic,
                ),
              )),
        ],
        if (v.gstin.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            'GSTIN: ${v.gstin.trim()}',
            style: tt.bodySmall?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

}

/// Place of Supply widget: two pills (editable English + locked Tamil).
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 500;

      final editablePill = GestureDetector(
        onTap: () => _showStatePickerSheet(context, cs),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Text(
                  placeOfSupply.isEmpty ? K.maanilamThaerodhu.tr(context, ref) : placeOfSupply,
                  style: tt.bodyMedium?.copyWith(
                    color: placeOfSupply.isEmpty
                        ? cs.onSurfaceVariant
                        : cs.onSurface,
                    fontWeight: placeOfSupply.isNotEmpty
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),
              if (placeOfSupply.isNotEmpty)
                GestureDetector(
                  onTap: onCleared,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(Icons.close, size: 16, color: cs.onSurfaceVariant),
                  ),
                )
              else
                Icon(Icons.arrow_drop_down, size: 20, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      );

      final tamilPill = placeOfSupplyTa.isNotEmpty
          ? Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_outline, size: 14, color: cs.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      placeOfSupplyTa,
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            K.vazhangalIdam.tr(context, ref),
            style: tt.labelMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          if (isNarrow)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                editablePill,
                if (placeOfSupplyTa.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  tamilPill,
                ],
              ],
            )
          else
            Row(
              children: [
                Expanded(child: editablePill),
                if (placeOfSupplyTa.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Expanded(child: tamilPill),
                ],
              ],
            ),
        ],
      );
    });
  }

  void _showStatePickerSheet(BuildContext context, ColorScheme cs) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => MaanilaThervuMeladukku(
        isDark: isDark,
        onSelected: (en, ta) {
          onSelected(en, ta);
          Navigator.pop(ctx);
        },
      ),
    );
  }
}
