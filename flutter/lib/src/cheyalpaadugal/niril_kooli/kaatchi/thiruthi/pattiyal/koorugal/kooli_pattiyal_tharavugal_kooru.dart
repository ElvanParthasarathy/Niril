import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../../../koorugal/podhu_koorugal/elvan_thiruthi_attai_kooru.dart';

import '../../../../../niril_podhu/kaatchi/koorugal/pattiyal_naal_kooru.dart';

// ─────────────────────────────────────────────────────────────────────────────
// கூலிப் பட்டியல் தரவுகள் கூறு — Invoice Details Section (Number + Date)
// ─────────────────────────────────────────────────────────────────────────────

/// §2 Invoice Details — bill number (editable with override) + date picker
/// in responsive layout (side-by-side on desktop, stacked on mobile).
class KooliPattiyalTharavugalKooru extends ConsumerWidget {
  const KooliPattiyalTharavugalKooru({
    super.key,
    required this.isEditing,
    required this.invoiceNumberOverride,
    required this.previewBillNumber,
    required this.isInvNumberEditing,
    required this.invNumberController,
    required this.profilePrefix,
    required this.pattiyalNaal,
    required this.onToggleEditInvNumber,
    required this.onInvNumberChanged,
    required this.onDateChanged,
    required this.onDirty,
  });

  final bool isEditing;
  final String invoiceNumberOverride;
  final String previewBillNumber;
  final bool isInvNumberEditing;
  final TextEditingController invNumberController;
  final String profilePrefix;
  final DateTime pattiyalNaal;
  final VoidCallback onToggleEditInvNumber;
  final ValueChanged<String> onInvNumberChanged;
  final ValueChanged<DateTime> onDateChanged;
  final VoidCallback onDirty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth >= 700;

      // ── Bill Number Field ──
      final billNumberField = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row with edit toggle
          Row(
            children: [
              Text(
                K.pattiyalKuriyeedu.tr(context, ref),
                style: tt.labelMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onToggleEditInvNumber,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    isInvNumberEditing ? Icons.check : Icons.edit_outlined,
                    size: 16,
                    color: cs.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Editable mode: locked prefix pill + editable number field
          if (isInvNumberEditing)
            Row(
              children: [
                // Locked prefix pill
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(12)),
                    border: Border.all(
                      color: cs.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '$profilePrefix-',
                    style: tt.bodyLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Editable number part
                Expanded(
                  child: TextField(
                    controller: invNumberController,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: '01',
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(12)),
                        borderSide: BorderSide(
                          color: cs.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      isDense: true,
                    ),
                    onChanged: (v) {
                      onInvNumberChanged(v);
                      onDirty();
                    },
                  ),
                ),
              ],
            )
          // Display mode: show override > preview > auto fallback
          else
            ElvanThiruthiAttai(
              child: Text(
                invoiceNumberOverride.isNotEmpty
                    ? invoiceNumberOverride
                    : previewBillNumber.isNotEmpty
                        ? previewBillNumber
                        : K.thaaniyangki.tr(context, ref),
                style: tt.bodyLarge?.copyWith(
                  color: invoiceNumberOverride.isNotEmpty
                      ? cs.onSurface
                      : cs.onSurfaceVariant,
                  fontWeight: invoiceNumberOverride.isNotEmpty
                      ? FontWeight.w600
                      : FontWeight.w500,
                ),
              ),
            ),
        ],
      );

      // ── Date Field ──
      final dateField = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            K.naal.tr(context, ref),
            style: tt.labelMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          PattiyalNaalKooru(
            selectedDate: pattiyalNaal,
            onDateChanged: onDateChanged,
          ),
        ],
      );

      if (wide) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: billNumberField),
            const SizedBox(width: 24),
            Expanded(child: dateField),
          ],
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          billNumberField,
          const SizedBox(height: 16),
          dateField,
        ],
      );
    });
  }
}
