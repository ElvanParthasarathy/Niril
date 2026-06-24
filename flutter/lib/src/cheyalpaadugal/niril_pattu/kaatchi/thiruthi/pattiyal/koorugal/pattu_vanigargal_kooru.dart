import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../../../adippadai/tharavuthalam/seyali_tharavuthalam.dart';
import '../../../../../../koorugal/podhu_koorugal/elvan_thiruthi_attai_kooru.dart';
import '../../../../../niril_podhu/kaatchi/koorugal/vanigar_thaedu_kooru.dart';
import '../../../../../amaippugal/tharavu/niruvana_tharavugal_provider.dart';
import '../../../../../amaippugal/tharavu/niruvana_tharavugal.dart';
import 'maanila_thervu_maeladukku.dart';

// ─────────────────────────────────────────────────────────────────────────────
// பட்டு வணிகர்கள் கூறு — Customer Section (search + address + profile + PoS)
// ─────────────────────────────────────────────────────────────────────────────

/// Customer data from parent for display purposes.
class PattuVanigargalData {
  const PattuVanigargalData({
    required this.selectedVanigarId,
    required this.selectedVanigarPeyar,
    required this.selectedNiruvanamId,
    required this.placeOfSupply,
    required this.placeOfSupplyTa,
  });

  final int? selectedVanigarId;
  final String selectedVanigarPeyar;
  final int? selectedNiruvanamId;
  final String placeOfSupply;
  final String placeOfSupplyTa;
}

/// Callbacks from customer section back to parent orchestrator.
class PattuVanigargalCallbacks {
  const PattuVanigargalCallbacks({
    required this.onCustomerSelected,
    required this.onCustomerCleared,
    required this.onRequestAddNewCustomer,
    required this.onProfileChanged,
    required this.onPlaceOfSupplyChanged,
    required this.onPlaceOfSupplyCleared,
  });

  final void Function(VanigarEntry entry) onCustomerSelected;
  final VoidCallback onCustomerCleared;
  final VoidCallback onRequestAddNewCustomer;
  final void Function(int? id, NiruvanaTharavugal? profile) onProfileChanged;
  final void Function(String en, String ta) onPlaceOfSupplyChanged;
  final VoidCallback onPlaceOfSupplyCleared;
}

/// Section 1 + Place of Supply: Customer search, address card, profile dropdown,
/// and Place of Supply pills. Pure UI — delegates all state changes via callbacks.
class PattuVanigargalKooru extends ConsumerWidget {
  const PattuVanigargalKooru({
    super.key,
    required this.data,
    required this.callbacks,
    required this.selectedVanigar,
  });

  final PattuVanigargalData data;
  final PattuVanigargalCallbacks callbacks;
  final VanigarEntry? selectedVanigar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth >= 700;
      final customerSearch = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            K.vanigarPeyarThaedu.tr(context, ref),
            style: tt.labelMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          VanigarThaeduKooru(
            seyaliVagai: 'silk',
            selectedId: data.selectedVanigarId,
            onSelected: callbacks.onCustomerSelected,
            onCleared: callbacks.onCustomerCleared,
            onRequestAddNew: callbacks.onRequestAddNewCustomer,
          ),
        ],
      );

      final savedDetailsCard = selectedVanigar != null
          ? Padding(
              padding: const EdgeInsets.only(top: 12),
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
                      selectedVanigar!.peyar['Tamil'] ?? data.selectedVanigarPeyar,
                      style: tt.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    _buildAddressBlock(selectedVanigar!, cs, tt),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink();

      final profileDropdown = _buildProfileDropdown(context, ref);

      final leftColumn = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          profileDropdown,
          customerSearch,
          savedDetailsCard,
        ],
      );

      if (wide) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 5, child: leftColumn),
            const SizedBox(width: 24),
            const Expanded(flex: 7, child: SizedBox.shrink()),
          ],
        );
      }
      return leftColumn;
    });
  }

  // ── Address Block ──
  Widget _buildAddressBlock(VanigarEntry v, ColorScheme cs, TextTheme tt) {
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

    final tamilLines = buildLines('Tamil');
    final englishLines = buildLines('English');
    final gstin = v.gstin.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (tamilLines.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...tamilLines.map((line) => Text(
                line,
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.5,
                ),
              )),
        ],
        if (englishLines.isNotEmpty &&
            englishLines.join() != tamilLines.join()) ...[
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
        if (gstin.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            'GSTIN: $gstin',
            style: tt.bodySmall?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  // ── Profile Dropdown ──
  Widget _buildProfileDropdown(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(NiruvanaTharavugalListProvider);
    if (profiles.length <= 1) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<int>(
              initialValue: data.selectedNiruvanamId,
              decoration: InputDecoration(
                labelText: K.niruvanaThannuru.tr(context, ref),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
              items: profiles.map((p) {
                final name = p.niruvanathinPeyar['Tamil'] ??
                    p.niruvanathinPeyar['English'] ??
                     K.niruvanam.tr(context, ref);
                return DropdownMenuItem(value: p.id, child: Text(name));
              }).toList(),
              onChanged: (v) {
                final match = profiles.where((p) => p.id == v).firstOrNull;
                callbacks.onProfileChanged(v, match);
              },
            ),
          ),
          if (data.selectedNiruvanamId != null)
            IconButton(
              icon: Icon(Icons.close, color: cs.error, size: 20),
              tooltip: 'Clear',
              onPressed: () => callbacks.onProfileChanged(null, null),
            ),
        ],
      ),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: cs.outline.withValues(alpha: 0.3),
            ),
          ),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
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
